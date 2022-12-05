#!/usr/bin/env nextflow

process sort_index {

  publishDir "${params.outdir}/sorted", pattern: "*.bam"
  publishDir "${params.outdir}/indexed", pattern: "*.bam.bai"

  input: 
    path bam 

  output:
    path "*.bam", emit: sorted_bam
    path "*.bai"

  script:
  """
  sambamba sort $bam -o ${bam.baseName}_sorted.bam
  """
}


process sort_index_macs {
  
  publishDir "${params.outdir}/sorted_macs"

  input:
    tuple val(pair_id), file(ctl), file(trt)

  output:
    tuple val(pair_id), path ('*_c.sorted.bam'), path ('*_t.sorted.bam'), emit: sorted_bam

  script:
  println "======: " + ctl + ", " + trt;
  """
  # trt 
  sambamba sort ${trt.baseName}.bam -o ${trt.baseName}.sorted.bam
  # ctl
  sambamba sort ${ctl.baseName}.bam -o ${ctl.baseName}.sorted.bam
  """
}


process unique_reads {

  publishDir "${params.outdir}/unique"

  input:
    tuple val(pair_id), file(ctl), file(trt) 

  output:
    tuple val(pair_id), path ('*_c.sorted_unique.bam'), path ('*_t.sorted_unique.bam'), emit: unique_bam

  script:
  println "\\\\\\\\\\\\\\: " + ctl + ", " + trt;
  """
  # ctl 
  sambamba view -h -t 2 -f bam -F "[XS] == null and not unmapped  and not duplicate" ${ctl.baseName}.bam > ${ctl.baseName}_unique.bam
  # trt
  sambamba view -h -t 2 -f bam -F "[XS] == null and not unmapped  and not duplicate" ${trt.baseName}.bam > ${trt.baseName}_unique.bam

  """
}
