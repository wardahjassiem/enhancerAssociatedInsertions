#!/usr/bin/env nextflow

process extract_insertions {

  publishDir "${params.outdir}/insertions"

  input:
    path mapped

  output:
    path "*.sam", emit: ins_sam

  shell:
  $/
   awk -F\\t '{if($6 ~ "I") print $0}' !{mapped} > !{mapped.baseName}_ext.sam  
  /$
}


process insertions_fasta {
 
  publishDir "${params.outdir}/insertions_fasta"
 
  input:
    path sam
 

  output:
    path "*.fasta", emit: ins_fa

  shell:
  $/
   awk -F\\t '{
    if($18 ~ "MD") 
     print ">"$3"."$4"."$18"."$6 "\n" $10
    else 
     print ">"$3"."$4"."$19"."$6 "\n" $10
   }' !{sam} > !{sam.baseName}.fasta
   sed -i s/\:/\./g !{sam.baseName}.fasta   
  /$
}


process insertions_fastq {
 
  publishDir "${params.outdir}/insertions_fastq"

  input:
    path sam
 
  output:
    path "*.fastq", emit: ins_fq

  shell:
  $/
   awk -F\\t '{
    if($18 ~ "MD") 
     print "@"$3"."$4"."$18"."$6 "\n" $10 "\n+\n" $11
    else 
     print "@"$3"."$4"."$19"."$6 "\n" $10 "\n+\n" $11
   }' !{sam} > !{sam.baseName}.fastq
   sed -i s/\:/\./g !{sam.baseName}.fastq
   
  /$
}


process filter_sam_by_column {

  publishDir "${params.outdir}/filtered_sam_by_column"

  input:
    path v2_ins 
 
  output:
	path "*.sam", emit: v2_sam 

  shell:
  $/
    awk -F\\t '{
	    print $1 "\t" $2 "\t" $3 "\t" $4+1 "\t" $5 "\t" $6 "\t" $7 "\t" $8 "\t" $9 "\t" $12 "\t" $13
	}' !{v2_ins} > !{v2_ins.baseName}.sam
  /$
}


process adjust_zero_length_features {

  publishDir "${params.outdir}/adjusted_zero_length_features"

  input:
    path bed 

  output:
    path "*.bed", emit: half_open

  shell:
  $/  
  awk -F\\t 'BEGIN {OFS="\t"} ; { $3=$3+1; print $0 }' $bed > ${bed.baseName}_halfopen.bed
  /$
}


process enhancer_uniq {

  publishDir "${params.outdir}/enhancers_uniq"

  input:
    path bed 

  output:
    path "*.bed"

  shell:
  $/  
  awk -F\\t '{print $1 "_" $2 "_" $3 "_" $4}' $bed | uniq | sed s/\_/\\t/g > ${bed.baseName}.unique.bed
  /$
}


