#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 3;

BEGIN {
    use_ok( 'PostScript::PStools::PSjoin' ) || print "Bail out!\n";
    use_ok( 'PostScript::PStools::PS2png' ) || print "Bail out!\n";
    use_ok( 'PostScript::PStools::PS2pdf' ) || print "Bail out!\n";
}

diag( "Testing PostScript::PStools::PSjoin $PostScript::PStools::PSjoin::VERSION, Perl $], $^X" );
