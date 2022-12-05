#!/usr/bin/env nextflow

process identify_ncinsertions {

  publishDir "${params.outdir}/noncodingReads"

  input: 
    path bam
    val exons 

  output:
    path "*.bam", emit: ncins_bam

  script:
  baseName = bam[0].toString().split('\\_')[0]
  """
  bedtools intersect -v -a ${bam} -b ${exons} > ${baseName}_noncoding.bam
  """
}



process identify_enhancers {

  publishDir "${params.outdir}/enhancers_bam"

  input:
    tuple val(key), path(bm), path(bd) 
      
  output:
    path "*.bam", emit: enhancers_bam

  script:
  println "======: " + bm + ", " + bd; 
  """
  bedtools intersect -a ${bm} -b ${bd} > ${bd.baseName}_intersect.bam
  """
}


