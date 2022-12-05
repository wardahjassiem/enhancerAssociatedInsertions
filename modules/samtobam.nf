#!/usr/bin/env nextflow

process samtobam {
    
  publishDir "${params.outdir}/bam_fq"

  input: 
    path sam
	
  output:
    path "*.bam", emit: reads_bam
    
  """
  samtools view -h -bS $sam > ${sam.baseName}.bam
  """
}

process sam2bam {
  
  publishDir "${params.outdir}/aligned_bam"

  input:
    tuple val(pair_id), file(ctl), file(trt)

  output:
    tuple val( pair_id), path ('*_c.bam'), path ('*_t.bam'), emit: aligned_bam 

  script:
  println "======: " + ctl + ", " + trt;
  """
  # trt 
  samtools view -bS -h $trt > ${trt.baseName}.bam
 
  # ctl
  samtools view -bS -h $ctl > ${ctl.baseName}.bam
 
  """
}


