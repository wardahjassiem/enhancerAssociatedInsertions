#!/usr/bin/env nextflow 

nextflow.enable.dsl = 2

log.info """\
 C h I P S E Q - N F   P I P E L I N E
 ===================================
 sraids: ${params.sraids}
 bowtieInd: ${params.bowtieInd}
 bowtie2Ind: ${params.bowtie2Ind}
 hg19_chrom_sizes: ${params.hg19_chrom_sizes}
 genes: ${params.genes} 
 trt_ctl_fq  = ${params.trt_ctl_fq}
 trt_fq = ${params.trt_fq}
 hg19_genes = ${params.hg19_genes}

 """

 include { ID_insertions } from './modules/noncoding_insertions'  
 include { peak_calling } from './modules/peak_calling'
 include { enhancers } from './modules/enhancers'
   
 workflow {
  
  chrpath = Channel
              .fromPath("$baseDir/rfasta/chr*.fa")
  
  trt_fq = Channel
                 .fromPath( params.trt_fq )
                 .ifEmpty { error "Cannot find fastq files matching: ${params.trt_fq}" }

  trt_ctl_fq = Channel
                 .fromFilePairs( params.trt_ctl_fq )
                 .ifEmpty { error "Cannot find fastq files matching: ${params.trt_ctl_fq}" }

  exons = Channel
            .value(params.exons)
  
  
  ID_insertions( trt_fq, params.bowtieInd, params.bowtie2Ind, params.genes, exons, chrpath )
  peak_calling( trt_ctl_fq, params.bowtie2Ind )
  enhancers ( ID_insertions.out, peak_calling.out, params.hg19_genes ) 
}

