#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'PostScript::PS2png' ) || print "Bail out!\n";
}

diag( "Testing PostScript::PS2png $PostScript::PS2png::VERSION, Perl $], $^X" );
