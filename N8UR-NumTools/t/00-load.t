#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'N8UR::NumTools' ) || print "Bail out!\n";
}

diag( "Testing N8UR::NumTools $N8UR::NumTools::VERSION, Perl $], $^X" );
