package PostScript::PS2pdf;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT      = qw( ps2pdf );
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw(); 
our $VERSION = 1.00;
=head1 NAME

PostScript::PStools::PS2pdf - Convert PS to PDF using Ghostscript

=head1 VERSION

Version 1.00

=cut


=head1 SYNOPSIS

ps2pdf is a dead simple stupid function to convert a PostScript 
file to PDF using ghostscript.

There's already a nice-looking module on CPAN called PostScript::Convert
(http://metacpan.org/pod/PostScript::Convert) that could do this job
with more flexibility.  I created this simply to avoid another module
installation.

Usage:
	use PostScript::PS2tools::PStopdf qw( ps2pdf );
	ps2png($infile)	

=head1 EXPORT

ps2pdf($infile)	

=head1 AUTHOR

John Ackermann C<< <jra at febo.com> >>

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

sub ps2pdf {

	my $infile = shift;

	my $outfile = $infile;
	if (index($outfile,'.') > -1) {
		$outfile = substr($outfile,0,rindex($outfile,'.'));
	}
	$outfile = $outfile . '.pdf';

	my $gscmd = "gs -q -sDEVICE= -dNOPAUSE -dBATCH " . $gsopt1 . " - ";
    system("echo \"$ps\" \| $gscmd");
	
}
1; # End of PostScript::PS2png
