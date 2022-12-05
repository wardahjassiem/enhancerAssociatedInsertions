#!/usr/bin/env nextflow

process fetch_sra {

    publishDir "${params.outdir}/fastq_reads"

    input:
    path ID

    output:
    path "*.fastq", emit: reads     
    
"""
fetchsra.py --sra fetchsra_trt.txt

"""
}

process fetch_sra_macs {
  
  publishDir  "${params.outdir}/SRAdir_5K", mode: "copy"  

  input:
    val sra

  output:
    file "*.fastq"

  script:
  """
  fetchsra.py --sra $sra
  """
}



