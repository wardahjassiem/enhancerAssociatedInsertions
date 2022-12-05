#!/usr/bin/env nextflow

process retrieve_headers {

  publishDir "${params.outdir}/headers"

  input:
    path bwt_reads

  output:
    path "*.sam", emit: headers

  """
  head -n 27 $bwt_reads > ${bwt_reads.baseName}_header.sam
  """
}

process header_to_insertion {
 
  publishDir "${params.outdir}/insertions_with_headers"
  
  input:
    path headers
    path insertions

  output:
    path "*.sam", emit: headed_sam

 """
 cat $headers $insertions > ${insertions.baseName}_headed.sam
 """
}


process compile_insertions {

  publishDir "${params.outdir}/combined_psl" 
 
  input:
    path tailers
 
  output:
    path "*.psl", emit: combined_psl 
    
  script:
  basename = tailers[0].toString().split('\\.')[1]
  """
  cat $tailers > ${basename}.psl
  """
}


