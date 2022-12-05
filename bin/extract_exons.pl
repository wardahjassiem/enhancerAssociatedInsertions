#!/usr/bin/perl -w

use strict;

open(IN, "<$ARGV[0]");

my @lineArr;
my @exonStartsArr;
my @exonEndsArr;
my $end;
my $chrom;
my $exonCount;
my $name;

while(<IN>)
{
	chomp($_);
	@lineArr = split("\t", $_);
	$chrom = $lineArr[2];	
	$name = $lineArr[1];
	
	if($chrom !~ /random/)
	{
		@exonStartsArr = split(",", $lineArr[9]);
		@exonEndsArr = split(",", $lineArr[10]);
	
		$exonCount = @exonStartsArr;
	
		for(my $i=0; $i<$exonCount; $i++)
		{
			print $chrom . "\t" . $exonStartsArr[$i] . "\t" . $exonEndsArr[$i] . "\t" . $name . "_" . $i . "\n";
		}
	}
}

exit(0);
