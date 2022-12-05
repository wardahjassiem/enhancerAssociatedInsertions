#!/usr/bin/env nextflow

process codingDNA {

  publishDir "${params.outdir}/exons"

  input:
    path DNA

  output:
    path "*.bed"
    
  """
  extract_exons.pl ${DNA} | tail -n +2 > exon_ucsc.bed
  """
}

