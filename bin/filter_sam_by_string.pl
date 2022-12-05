#!/usr/bin/perl -w

use strict;
use Scalar::Util qw(looks_like_number);


open(IN, "<$ARGV[0]");
open(OUTSAM, ">$ARGV[1]");
open(OUTINSERTSBED, ">$ARGV[2]");

my @lineArr;
my $line;
my $cigarstring;
my $seq;
my ($match1, $match1Len);
my ($insert, $insertLen);
my ($match2, $match2Len);
my $remainingCigar;

while(<IN>) {
  chomp($_);
  $line = $_;
  @lineArr = split("\t", $line);

  $cigarstring = $lineArr[5];
  $seq = $lineArr[9];

  my $c = () = $cigarstring =~ /I/g; 

  if($c ==1) { 


    $match1Len = substr($cigarstring, 0, index($cigarstring, "M"));
    $match1 = substr($seq, 0, $match1Len);
    $remainingCigar = substr($cigarstring, index($cigarstring, "M")+1 );
  
    $insertLen = substr($remainingCigar, 0, index($remainingCigar, "I"));



    if(looks_like_number($insertLen)) 
    {

      $insert = substr($seq, $match1Len, $insertLen);
      $remainingCigar = substr($remainingCigar, index($remainingCigar, "I")+1);

      $match2Len = substr($remainingCigar, 0, -1);
      $match2 = substr($seq, $match1Len + $insertLen);


      ###### DETERMINE HOW MANY UNIQUE LETTERS ARE USED IN INSERT
      my @tmp=split('',$insert);
      my $count;
      my %count;
      foreach(@tmp){
	if(exists($count{$_})) {
	  $count{$_}=$count{$_}+1;
	}
	else {
	  $count{$_} = 1;
	}
      }
      my $numUniqInsLetters = keys %count;

      my $firstafter = substr($match2, 0, length($insert));
      my $lastbefore = substr($match1, length($match1) - length($insert), length($insert));

      print OUTSAM $line . "\n";

      my $insertStart = $lineArr[3] + $match1Len;

      print OUTINSERTSBED $lineArr[2] . "\t" . $insertStart . "\t" . $insertStart . "\t" . $insert . "\n";


    }
  }
}




exit(0);