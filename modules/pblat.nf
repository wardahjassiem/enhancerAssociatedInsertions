#!/usr/bin/env nextflow

process pblat {

  publishDir "${params.outdir}/pblat"
  
  input: 
    path chrpath
    path fasta

  output:	
    path "*.blat.psl", emit: psl 

  """
  for x in $chrpath
    do
      export chr=`basename \$x .fa`
  	  pblat -threads=23 -minScore=0 -stepSize=1 \$x $fasta \$chr.${fasta.baseName}.psl
	  tail -n +6 \$chr.${fasta.baseName}.psl > \$chr.${fasta.baseName}.blat.psl
  done

  """
}


