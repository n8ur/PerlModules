#!/usr/bin/perl -w

# test program for PS2png
# invoke as: ./pstest.pl r 800 1 test.ps v
# where r = rotate, 800 = output width, 1 = aspect ratio,i
# test.ps = infile, v = verbose

use strict;
use lib ".";

use PostScript::PStools::PS2png qw( ps2png );

my ($rotation,$pixels_wide,$aspect,$infile,$verbose) = @ARGV;
ps2png($rotation,$pixels_wide,$aspect,$infile,$verbose);
exit;
