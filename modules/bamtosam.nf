#!/usr/bin/env nextflow

process bamtosam {

  publishDir "${params.outdir}/bamtosam"

  input: 
     path insertions_bam 
	
  output:
    path "*.sam", emit: reads_sam

  script:
  println "++++++++++++: " + insertions_bam; 
  """
  samtools view ${insertions_bam} > ${insertions_bam.baseName}.sam
  """
}


