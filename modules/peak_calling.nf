#!/usr/bin/env nextflow 
  
 include { align_fq } from './bowtie2'
 include { sam2bam } from './samtobam' 
 include { sort_index_macs; unique_reads } from './sambamba'
 include { macs } from './macs'
 include { bigwig } from './bigwig' 
  
 workflow peak_calling {
  take: 
    trt_ctl_fq
    bowtie2Ind
    
 
  main:
    align_fq ( trt_ctl_fq, bowtie2Ind )
    sam2bam (align_fq.out.aligned_sam) 
    sort_index_macs ( sam2bam.out.aligned_bam )
    unique_reads (sort_index_macs.out.sorted_bam )
    macs ( unique_reads.out.unique_bam )
    

  emit: 
    macs.out.peaks_bed  
        | map { file ->
          def key = file.name.toString().tokenize('_').get(0)
          return tuple(key, file)
        } \
        | groupTuple() \

 
  
}


