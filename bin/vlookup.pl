#!/usr/bin/perl -w

use strict;
use warnings;
use Data::Dumper;

die "usage: $0 SearchNeedleFile NeedleIDCol SearchHaystackFile HaystackIDCol HaystackAppendCol OutputFile"
	unless $#ARGV==5;

open(NEEDLE, $ARGV[0]);
open(HAYSTACK, $ARGV[2]);
open(OUT, ">$ARGV[5]");

my $needleIDcol = $ARGV[1];
my $haystackIDcol = $ARGV[3];
my $haystackOUTcol = $ARGV[4];

my @needleOrderArr;

my %needleHash;
my %haystackHash;

my %usedNeedle;

my $line;
my @lineArr;

my $testID;

while(<NEEDLE>)
{
	chomp($_);
	$line = $_;
	@lineArr = split("\t", $line);
	$testID = $lineArr[$needleIDcol];

	while(exists $usedNeedle{$testID})
	{
		$testID = $testID . "tttest";	
	}

	if(!exists $usedNeedle{$testID})
	{
		$usedNeedle{$testID} = 1;
		push(@needleOrderArr, $testID);	
		$needleHash{$testID} = $line;
	}
}
my $sizeHash = keys %needleHash;
print "Needle hash populated " . $sizeHash . "\n";

while(<HAYSTACK>)
{
	chomp($_);
	$line = $_;
	@lineArr = split("\t", $line);
	

	$haystackHash{$lineArr[$haystackIDcol]} = $line;
}
$sizeHash = keys %haystackHash;
print "Haystack hash populated " . $sizeHash . "\n";

my $keyclean;

foreach my $key (@needleOrderArr)
{

	chomp($needleHash{$key});

	if($key =~ m/tttest/)
	{
		$keyclean = substr($key, 0, index($key, "tttest"));
	}
	else
	{
		$keyclean = $key;
	}
	
	print OUT $needleHash{$key};

	if(exists $haystackHash{$keyclean})
	{
		@lineArr = split("\t", $haystackHash{$keyclean});
		chomp($lineArr[$haystackOUTcol]);
		print OUT "\t" . $lineArr[$haystackOUTcol];
	}
	else
	{
		print OUT "\tXXX";
	}
	print OUT "\n";
}

exit(0);
