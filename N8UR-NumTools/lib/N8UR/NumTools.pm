package N8UR::NumTools;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT   = qw( round dec2bin dec2bin_no_leading_zeroes bin2dec bin2hex );
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw();
our $VERSION = 1.00;

use Time::HiRes qw(usleep);
use DateTime;

=head1 NAME

N8UR::NumTools - The great new N8UR::NumTools!

=head1 VERSION

Version 1.00

=cut

=head1 SYNOPSIS
	use N8UR::NumTools;

	# round $input to $num_places
    $num = round($num_places,$input)

	# true if $input is numeric
    $boolean = is_number($input);

	# convert $input from decimal into bitmask; output as string
    $string = dec2bin($input);

	# same thing, but trim leading zeroes
    $string = dec2bin_no_leading_zeroes($input);

    # convert bitmap $input to decimal number
    $num = bin2dec($input)

	# convert bitmap $input to hexadecimal number
    $num = bin2hex($input)

=head1 EXPORT
    round()
    is_number()
    dec2bin()
    dec2bin_no_leading_zeroes();
    bin2dec()
    bin2hex()

=head1 AUTHOR

John Ackermann, C<< <jra at febo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-n8ur-numtools at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=N8UR-NumTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc N8UR::NumTools


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=N8UR-NumTools>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/N8UR-NumTools>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/N8UR-NumTools>

=item * Search CPAN

L<http://search.cpan.org/dist/N8UR-NumTools/>

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


sub round {
	my($places) = shift;
        my($number) = shift;
	my($rounded);
	if ($number < 0) {
		$rounded = int(($number*10**$places) -.5
			* ($number <=> 0) )/10**$places;
	}
	else {
		$rounded = int(($number*10**$places) +.5
			* ($number <=> 0) )/10**$places;
	}

	return $rounded
        };

sub is_number {
	# returns true if input is a decimal number
    	$_ = shift;
	if ( /^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$/ ) {
		return 1;
		}
	else {
		return 0;
		}
}

sub dec2bin {
	my $str = unpack("B32", pack("N", shift));
	return $str;
}

sub dec2bin_no_leading_zeroes {
	my $str = unpack("B32", pack("N", shift));
	$str =~ s/^0+(?=\d)//;
	return $str;
}

sub bin2dec {
	return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

sub bin2hex {
	return hex(unpack("N", pack("B32", substr("0" x 32 . shift, -32))));
}

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

n8ur - Perl extension for blah blah blah

=head1 SYNOPSIS

	use n8ur;
	$num = round($num_places,$input)
	$boolean = is_number($input)
	$string = dec2bin($input)
	$string = dec2bin_no_leading_zeroes($input)
	$num = bin2dec($input)
	$num = bin2hex($input)

=head1 DESCRIPTION

Some useful functions I use in my programs.

=head2 EXPORT

None by default.

=head1 SEE ALSO

=head1 AUTHOR

John Ackermann   N8UR, jra@febo.com

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 by John Ackermann N8UR (jra@febo.com)

This program may be copied, modified, distributed and used for 
any legal purpose provided that (a) the copyright notice above as well
as these terms are retained on all copies; (b) any modifications that 
correct bugs or errors, or increase the program's functionality, are 
sent via email to the author at the address above; and (c) such 
modifications are made subject to these license terms.

=cut

# returns $input rounded to $places places
sub round {
	my($places) = shift;
        my($number) = shift;
	my($rounded);
	if ($number < 0) {
		$rounded = int(($number*10**$places) -.5
			* ($number <=> 0) )/10**$places;
	}
	else {
		$rounded = int(($number*10**$places) +.5
			* ($number <=> 0) )/10**$places;
	}

	return $rounded
        };


# returns true if input is a decimal number
sub is_number {
    	$_ = shift;
	if ( /^[+-]?(?:\d+(?:\.\d*)?|\.\d+)$/ ) {
		return 1;
		}
	else {
		return 0;
		}
}

# returns bitmap of $input
sub dec2bin {
	my $str = unpack("B32", pack("N", shift));
	return $str;
}

# returns bitmap of $input with leading zeroes trimmed
sub dec2bin_no_leading_zeroes {
	my $str = unpack("B32", pack("N", shift));
	$str =~ s/^0+(?=\d)//;
	return $str;
}

# returns bitmap input as decimal number
sub bin2dec {
	return unpack("N", pack("B32", substr("0" x 32 . shift, -32)));
}

# returns bitmap input as hexadecimal number
sub bin2hex {
	return hex(unpack("N", pack("B32", substr("0" x 32 . shift, -32))));
}

1; # End of N8UR::NumTools
