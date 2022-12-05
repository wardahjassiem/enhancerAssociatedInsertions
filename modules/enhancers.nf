#!/usr/bin/env nextflow 
nextflow.enable.dsl = 2

 include { identify_enhancers } from './bedtools_intersect'
 include { bamtosam } from './bamtosam' 
 include { sam2bed } from './perl' 
 include { adjust_zero_length_features } from './awk_filters'
 include { closest_features; sort_bed } from './bedops' 

 workflow enhancers {
   take:
    bam
    bed
    hg19_genes
     
    main:
          
     identify_enhancers ( bam.join(bed) )             
     bamtosam ( identify_enhancers.out.enhancers_bam  )     
     sam2bed ( bamtosam.out )
     adjust_zero_length_features ( sam2bed.out.string_bed )
     sort_bed (adjust_zero_length_features.out.half_open)
     closest_features ( sort_bed.out.bedops_sorted, hg19_genes )
}
