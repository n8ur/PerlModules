#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'N8UR::TimeNutsTools' ) || print "Bail out!\n";
}

diag( "Testing N8UR::TimeNutsTools $N8UR::TimeNutsTools::VERSION, Perl $], $^X" );
