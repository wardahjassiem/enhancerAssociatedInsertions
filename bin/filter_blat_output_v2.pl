#!/usr/bin/perl -w

use strict;

open(IN, "<$ARGV[0]");

my $uniqueCol = $ARGV[1];

my $line;
my %usedHash;
my $joinedString;
my %countHash;

my $outputString;

my @lineArr;

my %hitsHash;

my %scoreHash;
my $fakeGstring = "";
my $fake0string = "";

while(<IN>)
{
	chomp($_);
	$line = $_;
	@lineArr = split("\t", $line);
	$joinedString = $lineArr[$uniqueCol];  # GETS THE chr.position.CIGAR string

	my $readSize = $lineArr[10];
	$fakeGstring = "G" x $readSize;
	$fake0string = "0" x $readSize;


	if($lineArr[11] == 0 && $lineArr[12] == $readSize) {  #### IF THE WHOLE READ IS ALIGNED
	  if($lineArr[7] < $readSize) {  #### SANITY CHECK FOR RIDICULOUSLY LONG INDELS
	    if(exists($countHash{$joinedString})) { ## IF THERE'S ALREADY A HIT
	      for(my $i=0; $i<$countHash{$joinedString}-1; $i++) {  ## CHECK TO SEE IF THE HIT IS IDENTICAL (COMES FROM PCR DUPS OF SAME READ)
		print $i . "\t" . $countHash{$joinedString} . "\n";
		if($line ne $hitsHash{$i}) {
		  $countHash{$joinedString} +=1;
		  print "has mult hits\n";
		  print $line . "\n";
		}
	      }
	    }
	    else {
	      $countHash{$joinedString} =1;
	      $scoreHash{$joinedString} = 0;
	      $hitsHash{0} = $line;
	      print "has first hit\n";
	    }
	  }
	}
	if(exists($scoreHash{$joinedString})) { ### TAKE THE SINGLE BEST HIT PER READ
	  if($lineArr[0] > $scoreHash{$joinedString}) {
	    $scoreHash{$joinedString} = $lineArr[0];
	    $usedHash{$joinedString} = join("\t", @lineArr);
	  }
	}
}

close(IN);

open(OUT, ">$ARGV[0].unique");
open(OUTBED, ">$ARGV[0].inserts.bed");
open(OUTSAM, ">$ARGV[0].sam");
open(OUTINSERTS, ">$ARGV[0].ins.txt");

foreach my $bed (keys %usedHash)
{
      $outputString = $usedHash{$bed};
      $outputString =~ s/\,/\t/g;
	
      if(exists($countHash{$bed})) {
	if($countHash{$bed} ==1 ) {
	  @lineArr = split("\t", $outputString);
	  my @IDarr = split(/\./, $lineArr[9]);
	  my $bowtieChrom = $IDarr[0];
	  my $blatChrom = $lineArr[13];
	  my $bowtieStart = $IDarr[1];
	  my $blatStart = $lineArr[15];
	  my $blatInsertStart = $lineArr[18] + $blatStart;
	  my $cigarString = $IDarr[-1];
	  print "---" . $blatStart . "---" . $blatChrom . "---" . $bowtieChrom . "---" . $bowtieStart . "\n";
# 	  die;

	    if($lineArr[1] == 0) {  # IF NO MISMATCHES
	      if($lineArr[4] == 1) {  # ONLY ONE INSERTION
		if($lineArr[5] < 20) { # INSERTION IS LT 20bp
		  if($bowtieChrom eq $blatChrom) {
		    if(abs($bowtieStart - $blatStart) < 100) {
		      print OUT $outputString . "\n";
		      print OUTBED $blatChrom . "\t" . $blatInsertStart . "\t" . $blatInsertStart . "\n";
		      print OUTSAM $lineArr[9] . "\t0\t" . $bowtieChrom . "\t" . $blatStart . "\t255\t" . $cigarString . "\t*\t0\t0\t" . $fakeGstring . "\t" . $fake0string . "\n";
		      print OUTINSERTS $bowtieChrom . "\t" . $blatInsertStart . "\t" . $blatInsertStart . "\t" . $lineArr[9] . "\t" . $cigarString . "\t" . $lineArr[5] . "\n";
		    }
		  }
		}
	      }
# 	    }
	  }
	}
	else { print "Too many hits\n"; }
      }
}


exit(0);