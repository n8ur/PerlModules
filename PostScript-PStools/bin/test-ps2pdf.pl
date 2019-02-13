#!/usr/bin/perl -w

# test program for PS2pdf
# invoke as: ./test-ps2pdf.pl "input file name"

use strict;

use lib ".";
use PostScript::PStools::PS2pdf qw( ps2pdf );

my ($infile) = @ARGV;
ps2pdf($infile);
exit;
