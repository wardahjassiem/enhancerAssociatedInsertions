#!/usr/bin/env nextflow

process align_ungapped {
  
  publishDir "${params.outdir}/bwt_fq_sam",
    saveAs: {filename -> filename.indexOf(".sam") > 0 ? "sam/$filename" : "fastq/$filename"}
  
  input:
    path fastq 
    val bowtie1Ind 
      
  output:
    path "*.sam" 
    path "*.fastq", emit: bwt_fq 

  """
  bowtie --best --strata -m 1 -n 2 -p 24 --un ${fastq.baseName}-un.fastq -S -x $bowtie1Ind --max /dev/null $fastq > ${fastq.baseName}_ungapped.sam
  """
}

