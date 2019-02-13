#!/usr/bin/perl -w

# test program for PS2png
# invoke as: ./pstest.pl r 800 1 test.ps v
# where r = rotate, 800 = output width, 1 = aspect ratio,i
# test.ps = infile, v = verbose

use strict;
use FindBin;
use lib $FindBin::Bin;

use PS2png qw( ps2png );

my ($rotation,$pixels_wide,$aspect,$infile,$verbose) = @ARGV;
PostScript::PS2png::ps2png($rotation,$pixels_wide,$aspect,$infile,$verbose);
exit;
