#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'N8UR::Gpib' ) || print "Bail out!\n";
}

diag( "Testing N8UR::Gpib $N8UR::Gpib::VERSION, Perl $], $^X" );
