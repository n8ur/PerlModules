package N8UR::StringTools;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT = qw(trim collapse squash lower_case upper_case round parse_value);
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw();
our $VERSION = 1.00;

use DateTime;
use Time::HiRes qw(usleep);
=head1 NAME

N8UR::StringTools - some string manipulation tools I find useful

=head1 VERSION

Version 1.00

=cut

=head1 SYNOPSIS

	use N8UR::StringTools;

    # remove whitespace, nulls, crlf, and newlines
    $string = trim($input)

    # collapse multiple spaces to just one
    $string = collapse($input)

    # remove all spaces from string
    $string = squash($input)

	# return $input as lower case
    $string = lower_case($input)

	# return $input as upper case
    $string = upper_case($input)

    ($prefix,$value,$suffix) = parse_value($string)

=head1 EXPORT

    trim()
    collapse()
    squash()
    lower_case()
    upper_case()
    parse_value($string)

=head1 AUTHOR

John Ackermann, C<< <jra at febo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-n8ur-stringtools at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=N8UR-StringTools>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc N8UR::StringTools


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=N8UR-StringTools>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/N8UR-StringTools>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/N8UR-StringTools>

=item * Search CPAN

L<http://search.cpan.org/dist/N8UR-StringTools/>

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

# remove whitespace, nulls, crlf, and newlines
sub trim {
	$_ = shift;
	s/\n/ /sg;		# convert newlines to spaces
	s/\r/ /sg;		# convert carriage returns to spaces
	s/\000/ /sg;	# convert nulls to spaces
	s/^\s+//sg;		# trim leading spaces
	s/\s+$//sg;		# trim trailing spaces
	return $_;
}

# collapse multiple spaces to just one
sub collapse {
	$_ = shift;
	s/\s+/ /sg;		# collapse multiple spaces to just one
	return $_;
}

# remove all spaces from string
sub squash {
	$_ = shift;
	s/\s//sg;		# remove all spaces
	return $_;
}

# return string as lower case
sub lower_case {
	$_ = shift;
	$_ =~ tr [A-Z] [a-z];
	return $_;
}

# return string as upper case
sub upper_case {
	$_ = shift;
	$_ =~ tr [a-z] [A-Z];
	return $_;
}

sub parse_value {
	# splits input into alpha prefix, numeric value, and alpha suffix
	# first split is when a digit, or "+", "-", or "." is encountered
	# second split is at first alpha after the number
	my($val) = shift;
	my $prefix = "";
	my $value = "";
	my $suffix = "";
	my $j = 0;
	my $end = 0;

	# get rid of any embedded spaces
	$val = squash($val);

	until ( (substr($val,$j,1) =~ /[\d+-\.]/) || ($j == length($val)) ) {
		$prefix .= substr($val,$j,1);
		$j++;
		$end = $j;
		}

	if ($end > 1) {
		$val = substr($val,$end);
		}

	$j = 0;
	$end = 0;
	until ( (substr($val,$j,1) =~ /[a-z]/i) || ($j == length($val)) ) {
		$j++;
		$end = $j;
		}

	$value = substr($val,0,$end);
	$suffix = substr($val,$end);

	return $prefix,$value,$suffix;
}

__END__
1; # End of N8UR::StringTools
