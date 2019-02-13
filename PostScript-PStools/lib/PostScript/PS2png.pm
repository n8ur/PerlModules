package PostScript::PS2png;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT      = qw( ps2png );
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw(); 
our $VERSION = 1.00;
=head1 NAME

PostScript::PS2png - Convert PS to PNG using Ghostscript

=head1 VERSION

Version 1.00

=cut


=head1 SYNOPSIS

This is ps2png.pl by Norbert Haider, University of Vienna,
copyright 2005, converted to a module with a few tweaks.

ps2png reads a Postscript file and generates a 2D graphical images 
in PNG format by piping the PS file through Ghostscript.  Ghostscript 
must be installed and the "gs" command must be in your search path.

Usage:
	use PostScript::PS2pngi qw( ps2png );
	ps2png($rotation, $pixels_wide, $aspect, $infile, [$verbose])	

$rotation is "r" or "R" for rotate, and anything else to leave alone

$pixels_wide is the width of the out PNG file.  The height
will be scaled to maintain the original aspect ratio.

$aspect allows adjustment of the out aspect ratio.  The height
of the out image is multiplied by this amount.  1 maintains the
original ratio.

$infile file is the name of the PostScript file.  The out file will
have the same name with the extension changed from ".ps" to ".png".

$verbose, if true, causes the function to print out status messages.  If
false (or omitted) ps2png works silently.

=head1 EXPORT

ps2png($rotation, $pixels_wide, $aspect, $infile, [$verbose])	

=head1 AUTHOR

Original program by Norbert Heider.  Conversion to module format by
John Ackermann, C<< <jra at febo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-postscript-ps2png at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PostScript-PS2png>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PostScript::PS2png


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PostScript-PS2png>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PostScript-PS2png>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PostScript-PS2png>

=item * Search CPAN

L<http://search.cpan.org/dist/PostScript-PS2png/>

=back


=head1 ACKNOWLEDGEMENTS

Heavily based on "ps2png.pl" by Norbert Heider.

=head1 LICENSE AND COPYRIGHT

Original code copyright 2005 by Norbert Heider and published without
license terms.  Modifications are copyright 2019 John Ackermanni and
subject to the license terms below.

This program is free software; you can redistribute it and/or modify it
under the terms of the the Artistic License (2.0). You may obtain a
copy of the full license at:

L<http://www.perlfoundation.org/artistic_license_2_0>

Any use, modification, and distribution of the Standard or Modified
Versions is governed by this Artistic License. By using, modifying or
distributing the Package, you accept this license. Do not use, modify,
or distribute the Package, if you do not accept this license.

If your Modified Version has been derived from a Modified Version made
by someone other than you, you are nevertheless required to ensure that
your Modified Version complies with the requirements of this license.

This license does not grant you the right to use any trademark, service
mark, tradename, or logo of the Copyright Holder.

This license includes the non-exclusive, worldwide, free-of-charge
patent license to make, have made, use, offer to sell, sell, import and
otherwise transfer the Package with respect to any patent claims
licensable by the Copyright Holder that are necessarily infringed by the
Package. If you institute patent litigation (including a cross-claim or
counterclaim) against any party alleging that the Package constitutes
direct or contributory patent infringement, then this Artistic License
to you shall terminate on the date that such litigation is filed.

Disclaimer of Warranty: THE PACKAGE IS PROVIDED BY THE COPYRIGHT HOLDER
AND CONTRIBUTORS "AS IS' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES.
THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE, OR NON-INFRINGEMENT ARE DISCLAIMED TO THE EXTENT PERMITTED BY
YOUR LOCAL LAW. UNLESS REQUIRED BY LAW, NO COPYRIGHT HOLDER OR
CONTRIBUTOR WILL BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING IN ANY WAY OUT OF THE USE OF THE PACKAGE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


=cut

sub ps2png {

	my $rotate = shift;
	my $pixels_wide = shift;
	my $aspect = shift;
	my $infile = shift;
	my $verbose = shift;

	if (index("Rr",$rotate,) > -1) {
		$rotate = 1;
	} else {
		$rotate = 0;
	}

	my $outfile = $infile;
	if (index($outfile,'.') > -1) {
		$outfile = substr($outfile,0,rindex($outfile,'.'));
	}
	$outfile = $outfile . '.png';
	
	open (PSFILE, "<$infile") || die ("cannot open in file $infile!");

	my $line;
	my $ps = "";
	while ($line = <PSFILE>) {
		$line =~ s/\r//g;      # remove carriage return characters (DOS/Win)
		$ps = $ps . $line;
	}

	# extract bounding box and from that, coordinates
	my	$bb =  filterthroughcmd($ps,
		"gs -q -sDEVICE=bbox -dNOPAUSE -dBATCH  -r300 -g500000x500000 - ");
	my @bbrec =   split(/\n/, $bb);
	my $bblores = $bbrec[0];
	$bblores =~ s/%%BoundingBox://g;
	chomp($bblores);
	$bblores = ltrim($bblores);
	my @bbcorner = split(/\ /, $bblores);
	my $bbleft = $bbcorner[0];
	my $bbbottom = $bbcorner[1];
	my $bbright = $bbcorner[2];
	my $bbtop = $bbcorner[3];
	
	# size in points (1/72 inch) of in file
	my $x_in_pt = $bbleft + $bbright;
	my $y_in_pt = $bbtop + $bbbottom;

	# aspect ratio of the in
	my $in_aspect = sprintf "%.3f", $x_in_pt / $y_in_pt;
	
	# convert to pixels at 300 dpi
	my $x_in_px = sprintf "%.0f", ($x_in_pt / 72) * 300;
	my $y_in_px = sprintf "%.0f", ($y_in_pt / 72) * 300;

	# convert to inches, just because
	my $x_in_in = sprintf "%.1f", ($x_in_pt / 72);
	my $y_in_in = sprintf "%.1f", ($y_in_pt / 72);

	my $x_sf;
	if ($rotate) {
		$x_sf = sprintf "%.3f", $pixels_wide / $y_in_px;
	} else {
		$x_sf = sprintf "%.3f", $pixels_wide / $x_in_px;
	}

	# set x to the size set on command line	
	my $x_out_px = $pixels_wide;
	my $x_out_pt = sprintf "%.2f",$x_out_px / (300 / 72);

	# set y scaling factor; adjust aspect ratio if needed
	my $y_sf = sprintf "%.3f", $x_sf / $aspect;

	# scale y accordingly
	my $y_out_pt;
	my $y_out_px;
	if ($rotate) {
		$y_out_pt = sprintf "%.2f",$y_in_pt * $y_sf * $in_aspect;
		$y_out_px = sprintf "%.0f", $y_out_pt * (300 / 72);
		($x_sf,$y_sf) = ($y_sf,$x_sf);
	} else {
		$y_out_pt = sprintf "%.2f",$y_in_pt * $y_sf;
		$y_out_px = sprintf "%.0f", $y_out_pt * (300 / 72);
	}


	my $rotation;		# orientation == 0 landscape, 3 rotate
	my $device_width_points;
	my $device_height_points;
	if ($rotate) {
		$rotation = 3;
		$device_width_points = $y_out_pt;
		$device_height_points = $x_out_pt;
	} else {
		$rotation = 0;
		$device_width_points = $x_out_pt;
		$device_height_points = $y_out_pt;
	}
	

	my $rotation_string = 
		#" -dAutoRotatePages=/None -c '<</Orientation " .
		" -c '<</Orientation " .
		 	$rotation . ">> setpagedevice'";

	if ($verbose) {
		print "infile= $infile outfile= $outfile\n";
		if ($rotate) {
			print "Convert to rotate\n"
		} else {
			print "Keep orientation\n";
		}
		print "x_in_pt= $x_in_pt y_in_pt = $y_in_pt\n";
		print "x_in_px= $x_in_px y_in_px = $y_in_px\n";
		print "in aspect ratio= $in_aspect\n";
		print "scaling factors x= $x_sf, y= $y_sf\n";
		print "\n";
		print "x_out_pt= $x_out_pt y_out_pt= $y_out_pt\n";
		print "x_out_px= $x_out_px y_out_px= $y_out_px\n";
		print "device_width_points= $device_width_points";
		print " device_height_points= $device_height_points\n";
		print "rotation_string= $rotation_string\n";
	}

	## insert the PS "scale" command
	$ps = $x_sf . " " . $y_sf . " scale\n" . $ps;

	my $gsopt1 = " -r300 -dGraphicsAlphaBits=4 -dTextAlphaBits=4";
	$gsopt1 = $gsopt1 . " -dDEVICEWIDTHPOINTS=$device_width_points";
	$gsopt1 = $gsopt1 . " -dDEVICEHEIGHTPOINTS=$device_height_points";
	$gsopt1 = $gsopt1 . " -sOutputFile=" . $outfile;
	$gsopt1 = $gsopt1 . $rotation_string;
	my $gscmd = "gs -q -sDEVICE=pnggray -dNOPAUSE -dBATCH " . $gsopt1 . " - ";
	system("echo \"$ps\" \| $gscmd");
}
# =	===========================================================

sub filterthroughcmd {
	my $infile  = shift;
	my $cmd     = shift;
	my $line;
	my $res      = "";

	# stderr must be redirected to stdout
	# because the Ghostscript "bbox" device writes to stderr
	open(FHSUB, "echo \"$infile\"|$cmd 2>&1 |");
	while($line = <FHSUB>) {
		$res = $res . $line;
	}

	return $res;
}

sub ltrim() {
	my $subline1 = shift;
	$subline1 =~ s/^\ +//g;
	return $subline1;
}

sub round() {
	my $in = shift;
	return sprintf "%.0f", $in;
}

1; # End of PostScript::PS2png
