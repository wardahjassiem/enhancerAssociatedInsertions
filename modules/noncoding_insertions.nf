#!/usr/bin/env nextflow 

nextflow.enable.dsl = 2
  
 include { align_ungapped } from './bowtie'
 include { align_gapped } from './bowtie2'
 include { samtobam; samtobam as samtobam_1; samtobam as samtobam_2 } from './samtobam'
 include { sort_index; sort_index as sort_index_1; sort_index as sort_index_2} from './sambamba' 
 include { retrieve_headers; header_to_insertion; header_to_insertion as header_to_insertion_1; compile_insertions } from './support'
 include { codingDNA } from './codingDNA'
 include { identify_ncinsertions } from './bedtools_intersect'
 include { bamtosam } from './bamtosam' 
 include { extract_insertions; insertions_fastq; insertions_fasta; filter_sam_by_column } from './awk_filters'
 include { pblat } from './pblat'
 include { filter_insertions; convert_fastqto2col; vlookup; vlookup_2; filter_sam_by_string } from './perl' 
 

 workflow ID_insertions {
   take:
     trt_fq
     bowtie1Ind
     bowtie2Ind
     genes
     exons
     chrpath
   
   main:
     align_ungapped ( trt_fq, bowtie1Ind )
     align_gapped ( align_ungapped.out.bwt_fq, bowtie2Ind )
     samtobam ( align_gapped.out.bwt2_sam )
     sort_index ( samtobam.out.reads_bam ) 
     extract_insertions ( align_gapped.out.bwt2_sam )
     retrieve_headers ( align_gapped.out.bwt2_sam )
     header_to_insertion ( retrieve_headers.out.headers, extract_insertions.out.ins_sam)  
     samtobam_1 ( header_to_insertion.out.headed_sam )
     sort_index_1 ( samtobam_1.out.reads_bam )
     codingDNA ( genes )
     identify_ncinsertions ( sort_index_1.out.sorted_bam, exons )
     bamtosam ( identify_ncinsertions.out.ncins_bam )
     insertions_fastq ( bamtosam.out.reads_sam )
     insertions_fasta ( bamtosam.out.reads_sam  )
     pblat ( chrpath.collect(), insertions_fasta.out.ins_fa )  
     compile_insertions ( pblat.out.psl )
     filter_insertions ( compile_insertions.out.combined_psl )
     convert_fastqto2col ( insertions_fastq.out.ins_fq )
     vlookup ( filter_insertions.out.filt_pblat.join(convert_fastqto2col.out.fq_2col) )
     vlookup_2 ( vlookup.out.sam_1.join(convert_fastqto2col.out.fq_2col) )
     filter_sam_by_column ( vlookup_2.out.sam_2 )
     filter_sam_by_string ( filter_sam_by_column.out.v2_sam )
     header_to_insertion_1 ( retrieve_headers.out.headers, filter_sam_by_string.out.string_sam )
     samtobam_2 ( header_to_insertion_1.out.headed_sam )
     sort_index_2 ( samtobam_2.out.reads_bam )    

   emit:
     sort_index_2.out.sorted_bam  
        | map { file ->
          def key = file.name.toString().tokenize('_').get(0)
          return tuple(key, file)
        } \
        | groupTuple() \

}

