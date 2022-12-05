#!/usr/bin/env nextflow

process filter_insertions {

  publishDir "${params.outdir}/filt_pblat"

  input:
    path combined

  output: 
    tuple val(key), path ('*.sam'), emit: filt_pblat
     
  script:    
  key = combined.getSimpleName();
  """
  filter_blat_output_v2.pl ${combined} 9
  """
}

process convert_fastqto2col {

  publishDir "${params.outdir}/fq_2col"

  input:
    path fastq 

  output:
    tuple val(key), path ('*.2col'), emit: fq_2col
    
  script:
  key = fastq.getSimpleName();
  """
  fastq_to_2col.pl ${fastq} > ${fastq.baseName}.2col
  """
}


process vlookup {

  publishDir "${params.outdir}/vlookup"

  input: 
    tuple val(key), file(psl_sam), file(inserts)

  output:
    tuple val(key), path ('*.sam.1'), emit: sam_1
    

  """
  vlookup.pl ${psl_sam} 0 ${inserts} 0 1 ${psl_sam.baseName}.sam.1
  """
}

process vlookup_2 {

  publishDir "${params.outdir}/vlookup2"

  input:
    tuple val(key), file(sam_1), file(ins_2) 

  output:
    path "*.sam.2", emit: sam_2
    
  """
  vlookup.pl ${sam_1} 0 ${ins_2} 0 2 ${sam_1.baseName}.sam.2
  """
}

process filter_sam_by_string {

  publishDir "${params.outdir}/insertions_filt_string"

  input:
    path real_sam 

  output:
    path "*.filt.sam", emit: string_sam

  script:
  """
  filter_sam_by_string.pl ${real_sam} ${real_sam.baseName}.filt.sam ${real_sam.baseName}.inserts.bed
  """
}

process sam2bed {

  publishDir "${params.outdir}/sam2bed"

  input:
    path sam

  output:
    path "*.inserts.bed", emit: string_bed

  script:
  """
  filter_sam_by_string.pl ${sam} ${sam.baseName}.filt.sam ${sam.baseName}.inserts.bed
  """
}
