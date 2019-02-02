#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'PostScript::Join' ) || print "Bail out!\n";
}

diag( "Testing PostScript::Join $PostScript::Join::VERSION, Perl $], $^X" );
