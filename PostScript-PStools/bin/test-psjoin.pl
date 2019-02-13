#!/usr/bin/perl -w

# simple test program for PSjoin
# do:  ./test.pl "file1" "file2" "outfile"

use strict;
use lib ".";
use PostScript::PStools::PSjoin qw( psjoin );

my $fh;
my $file1 = shift;
my $file2 = shift;
my $outfile = shift;

open($fh,">","test_output.ps") or die "Can't open file$!\n";
select($fh);
psjoin("-p",$file1,$file2);
select(STDIN);
close ($fh);
