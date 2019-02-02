package N8UR::TimeNutsTools;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT   = qw( make_frac_freq make_frac_freq_stringi
				make_pretty_freq_string scale_freq
				logline logline_text );

our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw();
our $VERSION = 1.00;


=head1 NAME

N8UR::TimeNutsTools - useful routines for manipulating time and frequency data

=head1 VERSION

Version 1.00

=cut

=head1 SYNOPSIS

	use N8UR::TimeNutsTools;
	
	# return fractional difference (e.g., -6.23e-12) of $actual
	# vs. $reference frequencies.  $scale is "MHz", "kHz",
	# or "Hz" (not case sensitive, but must be quoted) and
	# defines the unit of the integer portion the inputs.
	# (Both $reference and $actual must use the same scale.)

	$float = make_frac_freq($reference,$actual,$scale);
	
	# same as above, but convert to nicely formatted string

	$string = make_frac_freq_string($reference,$actual,"MHz");
	
	# output formatted string of float $freq
	# $places is number of digits to the right of the
	# decimal point.  $scale is "MHz", "kHz", or "Hz" 
	# (not case sensitive, but must be quoted) and
	# defines the unit of the integer portion the input.

	$string = make_pretty_freq_string($freq, $places, "MHz");

	# mainly used internally for pretty printing.  returns 
	# value to use in sprintf for the number of characters to 
	# the left of the decimal point, including leading spaces.

	$int = scale_freq($input);

	# prints formatted log data.  $tagtype is "mjd" or "iso",
	# for the timestamp format.  $tagprecision is the number of
	# decimal places for MJD.  $precision is number of decimal
	# for formatted data.  $value1 through $value4 are data values
	# in numeric form.i
	# [ TODO: allow arbitrary number of data fields. ]

	logline($tagtype, $tagprecision, $precision, \
		$value1, $value2, $value3, $value4)

	# as above, but prints one or two text fields with timestamps
	# [ TODO: allow arbitrary number of data fields. ]

	logline_text($tagtype, $tagprecision, $value1, $value2);

=head1 EXPORT

	make_frac_freq()
	make_frac_freq_string()
	make_pretty_freq_string()
	scale_freq()
	logline()
	logline_text()

=cut
sub make_frac_freq {
	my $reference = shift;
	my $actual = shift;
	my $scale = shift;
	my $left_places = scale_freq($scale);
	if ($left_places == 2) { $actual = $actual * 1e6; }
	if ($left_places == 5) { $actual = $actual * 1e3; }
	if ($left_places == 2) { ; } # we're in Hz already

	return (($actual-$reference)/$reference);
	}

sub make_frac_freq_string {
	my $reference = shift;
	my $actual = shift;
	my $places = shift;
	my $scale = shift;
	
	my $frac = make_frac_freq($reference,$actual,$scale);

	# allow room for sign,int,dot
	my $format_left = $places + 3;
	my $frac_string = sprintf("% +${format_left}.${places}e", $frac);
	return $frac_string;
}

sub make_pretty_freq_string {
	my $freq = shift;	
	my $places = shift;
	my $scale = shift;
	my $left_places = scale_freq($scale);

	$freq = trim($freq);

	my ($leftpart,$rightpart) = (split /\./,$freq);
	my @triad = unpack "A3" x int(($places/3)+1), $rightpart;

	my $j;
	my $work = $triad[0];
	for ($j = 1;$j < @triad;$j++) {
		if ($j == @triad) {
			$triad[$j] = sprintf("%-3s",$triad[$j]);
			}
		$work = $work . " " . $triad[$j];
		}

	$work = sprintf("%${left_places}s",$leftpart) . "\." . $work;
	return $work;
}
sub scale_freq {
	my $scale = shift;
	$scale = trim($scale);
	$scale = lower_case($scale);

	my $left_places;
	if (!$scale) { $left_places = 0; }
	if ($scale eq "mhz")	{ $left_places = 2; } 	
	if ($scale eq "khz")	{ $left_places = 5; }
	if ($scale eq "hz")	{ $left_places = 8; }
	return $left_places;
}

sub logline {
	my $tagtype = shift;		# mjd or iso
	my $tagprecision = shift;	# decimal places for mjd printf
	my $precision = shift;		# decimal places for vars
	my $value1 = shift;
	my $value2 = shift;
	my $value3 = shift;
	my $value4 = shift;

	my $tmpstring;

	my $dt = DateTime->now;

	my $timetag = "";
	if ($tagtype eq "mjd") {
		$timetag = sprintf("%6.${tagprecision}f",
			round($tagprecision,$dt->mjd));
	}
	if ($tagtype eq "iso") {
		$timetag = $dt->ymd('-') . 'T' . $dt->hms(':');
	}
	$tmpstring = sprintf(" %1.*e",$precision,$value1);
	if ($value2) {
		$tmpstring = $tmpstring . sprintf(" %1.*e",$precision,$value2);
	 }
	if ($value3) {
		$tmpstring = $tmpstring . sprintf(" %1.*e",$precision,$value3);
	 }
	if ($value4) {
		$tmpstring = $tmpstring . sprintf(" %1.*e",$precision,$value4);
	 }

	return $timetag . $tmpstring . "\n";
}

sub logline_text {
	my $tagtype = shift;		# mjd or iso
	my $tagprecision = shift;	# decimal places for mjd
	my $value1 = shift;
	my $value2 = shift;

	my $result;

	my $dt = DateTime->now;

	my $timetag = "";
	if ($tagtype eq "mjd") {
		$timetag = sprintf("%5.${tagprecision}f",
			round($tagprecision,$dt->mjd));
	}
	if ($tagtype eq "iso") {
		$timetag = $dt->ymd('-') . 'T' . $dt->hms(':');
	}

	if ($value2) {
		$result = $timetag . " " . $value1 . " " . $value2 . "\n";
	} else {
		$result = $timetag . " " . $value1 . "\n";
	}
	return $result;
}
1; # End of N8UR::TimeNutsTools
__END__
