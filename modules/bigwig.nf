#!/usr/bin/env nextflow

process bigwig {
    
  publishDir "${params.outdir}/bigwig"

  input:
    path treat_pileup
    path chrom_sizes

  output:
    file "*.bw"

  """
  bedGraphToBigWig ${treat_pileup} hg19.chrom.sizes peaks_MACS.bw
  """
}


