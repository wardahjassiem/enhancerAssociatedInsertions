#!/usr/bin/env nextflow

process align_gapped {

  publishDir "${params.outdir}/bwt2_sam"

  input:

    path fastq 
    val bowtie2Ind
     
  output:
    
    path "*.sam", emit: bwt2_sam 
         
  """
  bowtie2 -k 1 -p 24 -q -x $bowtie2Ind -U $fastq -S ${fastq.baseName}_mapped.sam
  """
}


process align_fq {
  
  publishDir "${params.outdir}/aligned_sam"
  
  input:
  
    tuple val(pair_id), file(fastqs)
    val bowtie2Ind

  output:
  
    tuple val(pair_id), path ('*_c.sam'), path ('*_t.sam'), emit: aligned_sam

  script:
  fq1_name = fastqs.find{it.toString().contains('_t.fastq')}.getBaseName();
  fq2_name = fastqs.find{it.toString().contains('_c.fastq')}.getBaseName();
  """
  bowtie2 -p 5 -q --local -x $bowtie2Ind -U ${fastqs.find{it.toString().contains('_t.fastq')}} -S ${fq1_name}.sam
  bowtie2 -p 5 -q --local -x $bowtie2Ind -U ${fastqs.find{it.toString().contains('_c.fastq')}} -S ${fq2_name}.sam
  """
}
