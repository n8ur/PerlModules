package N8UR::Gpib;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT = qw( checkSRQ serviceSRQ serviceSRQmulti ibwrite );
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw();
our $VERSION = 1.00;



use Time::HiRes qw(usleep);
use LinuxGpib;
use DateTime;

=head1 NAME

N8UR::Gpib - Routines for gpib under Linux

=head1 VERSION

Version 1.00

=cut

=head1 SYNOPSIS

Depends on LinuxGpib -- https://linux-gpib.sourceforge.io/

Routines to handle gpib communications:

# check SRQ on $board
$boolean = checkSRQ($board)

# if SRQ asserted, read one line and return
$string = serviceSRQ($board)

# if SRQ asserted, read $num_reading lines into array and return
@string = serviceSRQmulti($board,$num_readings)

# write $command to $dev
ibwrite($device,$command)

=head1 EXPORT

checkSRQ()
serviceSRQ()
serviceSRQmulti()
ibwrite()

=head1 AUTHOR

John Ackermann, C<< <jra at febo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-n8ur-gpib at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=N8UR-Gpib>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc N8UR::Gpib


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=N8UR-Gpib>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/N8UR-Gpib>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/N8UR-Gpib>

=item * Search CPAN

L<http://search.cpan.org/dist/N8UR-Gpib/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2019 John Ackermann.

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
sub checkSRQ {
	my $board = shift;
	my $lines;	
	LinuxGpib::iblines($board,$lines);
	# 0x2000 is bit 14, busSRQ
	if ($lines & 0x2000) {
		return 1;
	} else {
		return 0;
	}
}
	
sub serviceSRQ {
	my $dev = shift;
	my $status;
	my $device_status = 0x00;
	my $reading;
	my $tries;

	$status = 0x8000;
	$tries = 0;
	while ($status == 0x8000 && $tries < 3) {
		if ($tries > 0) { usleep(1000) };
		$status = LinuxGpib::ibrsp($dev,$device_status);
		$tries++
		}
	if ($tries == 3) {die "Oops: ibrsp $dev failed 3 times!\n";}
	usleep(500);
	# 0x40 is bit 6, "service me, please"
	if ($device_status & 0x40) {
		# get reading
		$status = 0x8000;
		$tries = 0;
		while ($status == 0x8000 && $tries < 3) {
			if ($tries > 0) { usleep(500) };
			$status = LinuxGpib::ibrd($dev,$reading,2048);
			}
		if ($tries == 3) {die "Oops: ibrd $dev failed 3 times!\n";}
		return $reading;
	} else {
		return 0;
	}
}

sub serviceSRQmulti {
        my $dev = shift;
        my $num_readings = shift;
        my $status;
        my $tries;
        my $device_status = 0x00;
        my $i;
        my $tmp;
        my @reading;

        $status = 0x8000;
        $tries = 0;
        while ($status == 0x8000 && $tries < 3) {
                if ($tries > 0) { usleep(500) };
                $status = LinuxGpib::ibrsp($dev,$device_status);
                $tries++;
                }
        if ($tries == 3) {die "Oops: ibrsp $dev failed 3 times!\n";}
        usleep(500);

        # 0x40 is bit 6, "service me, please"
        $status = 0x8000;
        $tries = 0;
        if ($device_status & 0x40) {
                # get reading for each line
                for ($i=1;$i <= $num_readings;$i++) {
                        $status = 0x8000;
                        $tries = 0;
                        while ($status == 0x8000 && $tries < 3) {
                                if ($tries > 0) { usleep(500) };
                                $status = LinuxGpib::ibrd($dev,$tmp,2048);
                                }
                        if ($tries == 3) {
                                die "Oops: ibrd $dev failed 3 times!\n";
                        }
                        $reading[$i] = $tmp;
                }
                return @reading;
        } else {
                return 0;
        }
}

sub ibwrite {
	my $dev = shift;
	my $command = shift;
	my $ibsta = 0x8000;
	my $tries = 0;
	while ($ibsta == 0x8000 && $tries < 3) {
                if ($tries > 0) { usleep(500) };
        	$ibsta = LinuxGpib::ibwrt($dev,$command,length($command));
        	$tries++;
        	}
    if ($tries == 3) {die "Oops: Couldn't do ibwrt $command!\n"};
    return 0;
}

1; # End of N8UR::Gpib
