#!/usr/bin/env nextflow

process macs {

  publishDir "${params.outdir}/peak_macs"

  input:
    tuple val(pair_id), file(ctl), file(trt)    

  output:
    path "*_treat_pileup.bdg", emit: pileup_bdg
    path "*_summits.bed", emit: peaks_bed

  script:
  println "++++++: " + ctl + ", " + trt;
  baseName = trt[0].toString().split('\\_')[0]
  """
  macs2 callpeak -t ${trt} -c ${ctl} -g hs --bdg -n ${baseName} -f BAM -p 1e-9  
  """
}

