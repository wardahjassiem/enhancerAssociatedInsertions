#!/usr/bin/env nextflow

process closest_features {

  publishDir "${params.outdir}/genes"

  input:
    path regions
    val genes 
    
  output:
    path "*.bed"

  script:
  """
  closest-features --closest --dist --delim '\t' $regions $genes > ${regions.baseName}_features.bed
  """
}

process sort_bed {

  publishDir "${params.outdir}/sort_bed"

  input:
    path bed

  output:
    path "*.bed", emit: bedops_sorted

  script:
  println "======: " + bed;
  baseName = bed[0].toString().split('\\_')[0]
  """
  sort-bed $bed | uniq > ${baseName}_sorted.bed
  """
}
