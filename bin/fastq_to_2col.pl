#!/usr/bin/perl -w

use strict;

open(IN, "<$ARGV[0]");

my $counter = 0;
my $line;
my $id;
my ($seq, $qual);

while(<IN>) {
  chomp($_);
  $line = $_;
  if($counter % 4 == 0) {
    $id = $line;
    $id =~ s/\@//;
  }
  if($counter % 4 == 1) {
    $seq = $line;
  }
  if($counter % 4 == 3) {
    $qual = $line;
    print $id . "\t" . $seq . "\t" . $qual . "\n";
  }

  $counter++;
}



exit(0);