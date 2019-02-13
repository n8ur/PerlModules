package PostScript::PStools::PSjoin;

use 5.006;
use strict;
use warnings;
use Exporter qw( import );

our @EXPORT      = qw( psjoin );
our @EXPORT_OK   = qw();
our %EXPORT_TAGS = qw();
our $VERSION = 1.00;

=head1 NAME

PostScript::PStools::PSjoin - Concatenate PostScript files.
Module wrapper around "psjoin.pl" by Tom Sato 
<VEF00200@nifty.ne.jp>, http://homepage3.nifty.com/tsato/

=head1 VERSION

Version 1.0

=cut

=head1 SYNOPSIS

This is a wrapper around psjoin.pl
(http://t-sato.in.coocan.jp/tools/psjoin.html)

PostScript::PStools::PSjoin concatenates several PostScript files and 
generates a single PostScript document. The concatenated 
PostScript document will be written to the standard output.

The input PostScript files must comply with the DSC (Document Structuring 
Convention). psjoin can fail to work depending on the input PostScript file 
or combination of the input PostScript files.

    use PostScript::PStools::PSjoin;
    psjoin("-p","psfile1.ps","psfile2.ps","psfile3.ps");

psjoin() takes the following options as the first parameter
passed to the function:

-a  Align first page of each documents to odd page, by inserting 
    an extra blank page after odd-paged documents - may be useful
    when concatenating two-sided documents.

-s  Try to close unclosed save operators in the input files. This 
    option may be useful when input PostScript files have save 
    operators which don't have corresponding restore operators, and 
    the joined PostScript file causes ``limitcheck'' PostScript error 
    due to too deeply nested save operators.

-p  Force insert corresponding PostScript prolog/trailer codes into 
    all pages. Normally, to reduce the size of the output file, psjoin 
    tries not to insert largest prolog/trailer codes repeatedly.

-h  Display short description about the program and exit. 


NOTE NOTE NOTE: All I (John) did was make the minimum set of changes
that would allow the sub-ized psjoin.pl program run without errors.  I
don't know anything about PostScript formats, or the psjoin internals.
Use at your own risk!

=head1 EXPORT
psjoin; 
=cut

=head1 AUTHOR
Tom Sato, C<< <VEF00200 at nifty.ne.jp>>
http://homepage3.nifty.com/tsato/
Module wrapper by John Ackermann, C<< <jra at febo.com> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-postscript-pstools-psjoin at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=PostScript-PStools-PSjoin>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc PostScript::PStools::PSjoin


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=PostScript-PStools-PSjoin>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/PostScript-PStools-PSjoin>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/PostScript-PStools-PSjoin>

=item * Search CPAN

L<http://search.cpan.org/dist/PostScript-PStools-PSjoin/>

=back


=head1 ACKNOWLEDGEMENTS
Main code written by Tom Sati

=head1 LICENSE AND COPYRIGHT

Copyright 2002,2003 by Tom Sato
Portions copyright 2019 by John Ackermann

The psjoin.pl program was released without license terms.
John Ackermann's additions are licensed as follows:

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

sub psjoin {
# psjoin - concatenate PostScript files
#
# version 0.2, 2002-07-18
# version 0.3, 2003-11-30
#
# by Tom Sato <VEF00200@nifty.ne.jp>, http://homepage3.nifty.com/tsato/
# module-ized 2019-02-01 by John Ackermann jra@febo.com

my @args = @_;
my $force_even = 0;
my $force_save = 0;
my $dont_strip = 0;
my $save = "save %psjoin\n";
my $restore = "restore %psjoin\n";
my $prolog_inx;
my @trailer;
my $i;
my $j;
my @prolog;
my $in_comment;
my $in_prolog;
my $in_trailer;
my @comments;
my @pages;
my $page_num;
my $size;
my $saved;
my $largest;
my $total_pages;


while ($args[0] =~ /^-[a-z]/i) {
    if ($args[0] eq "-a") {
	$force_even = 1;
	shift @args;
    } elsif ($args[0] eq "-s") {
	$force_save = 1;
	$save = "/#psjoin-save# save def %psjoin\n";
	$restore = "#psjoin-save# restore %psjoin\n";
	shift @args;
    } elsif ($args[0] eq "-p") {
	$dont_strip = 1;
	shift @args;
    } elsif ($args[0] eq "-h") {
	print STDERR "psjoin - concatenate PostScript files (version 0.3)\n";
	print STDERR "by Tom Sato <VEF00200\@nifty.ne.jp>,";
	print STDERR " http://member.nifty.ne.jp/tsato/\n\n";
	print STDERR "Usage: psjoin [ options... ] filenames...\n\n";
	print STDERR "Option:\n";
	print STDERR "  -a: align first page of each documents to odd page\n";
	print STDERR "  -s: try to close unclosed save operators\n";
	print STDERR "  -p: not strip prolog/trailer of the input files\n";
	print STDERR "  -h: display this\n";
	exit 0;
    } else {
	print STDERR "$0: unknown option: $args[0]\n";
	print STDERR "(\"$0 -h\" for short description)\n";
	exit 2;
    }
}

shift @args if $args[0] eq "--";

if ($dont_strip) {
    $prolog_inx = 9999;
    $prolog[$prolog_inx] = "% [ psjoin: don't strip ]\n";
    $trailer[$prolog_inx] = "% [ psjoin: don't strip ]\n";
} else {
    for ($i = 0; $i <= $#args; $i++) {
	open(IN, $args[$i]) || die "$0: can't open \"$args[$i]\" ($!)";

	$in_comment = 1;
	$in_prolog = 1;
	$in_trailer = 0;
	$comments[$i] = "";
	$prolog[$i] = "";
	$trailer[$i] = "";
	$pages[$i] = 0;
	while (<IN>) {
	    next if /^%%BeginDocument/ .. /^%%EndDocument/;

	    if ($in_comment) {
		next if /^%!PS-Adobe-/; 
		next if /^%%Title/;
		next if /^%%Pages/;
		next if /^%%Creator/;
		$in_comment = 0 if /^%%EndComments/;
		$comments[$i] .= $_;
		next;
	    } elsif ($in_prolog) {
		if (/^%%Page:/) {
		    $in_prolog = 0;
		} else {
		    $prolog[$i] .= $_;
		    next;
		}
	    }

	    $in_trailer = 1 if /^%%Trailer/;
	    if ($in_trailer) {
		$trailer[$i] .= $_;
		next;
	    }

	    $pages[$i]++ if /^%%Page:/;
	}
	close(IN);

	if ($prolog[$i]) {
	    for ($j = 0; $j < $i; $j++) {
		if ($prolog[$j] eq $prolog[$i]) {
		    $pages[$j] += $pages[$i];
		    last;
		}
	    }
	}
    }

    $largest = 0;
    $prolog_inx = 0;
    for ($i = 0; $i <= $#args; $i++) {
	open(IN, $args[$i]) || die "$0: can't open \"$args[$i]\" ($!)";
	$size = length($prolog[$i]) * $pages[$i];
	if ($largest < $size) {
	    $largest = $size;
	    $prolog_inx = $i;
	}
    }
}

print "%!PS-Adobe-3.0\n";
print "%%Title: @args\n";
print "%%Creator: psjoin 0.2\n";
print "%%Pages: (atend)\n";
if ($comments[$prolog_inx]) {print $comments[$prolog_inx]};

print "\n";
print $prolog[$prolog_inx];
for ($i = 0; $i <= $#args; $i++) {
    if ($prolog[$i]) {
	$prolog[$i] =~ s/^%%/% %%/; 
        $prolog[$i] =~ s/\n%%/\n% %%/g;
        $trailer[$i] =~ s/^%%/% %%/;
        $trailer[$i] =~ s/\n%%/\n% %%/g;
	}
}

$total_pages = 0;
for ($i = 0; $i <= $#args; $i++) {
	#print STDOUT "processing $args[$i]\n";
    print "\n";
    print "% [ psjoin: file = $args[$i] ]\n";
    if (($prolog[$i]) && ($prolog[$i] ne $prolog[$prolog_inx])) {
        print "% [ psjoin: Prolog/Trailer will be inserted to every page ]\n";
    } else {
        print "% [ psjoin: common Prolog/Trailer will be used ]\n";
    }

    $in_comment = 1 if !$dont_strip;
    $in_prolog = 1 if !$dont_strip;
    $in_trailer = 0;
    $saved = 0;
    $page_num = 0;

    open(IN, $args[$i]) || die "$0: can't open \"$args[$i]\" ($!)";
    while (<IN>) {
        if (/^%%BeginDocument/ .. /^%%EndDocument/) {
            # s/^(%[%!])/% \1/;
            print $_;
        } else {
            if ($in_comment) {
                $in_comment = 0 if /^%%EndComments/;
            } elsif ($in_prolog) {
                if (/^%%Page:/) {
                    $in_prolog = 0;
                } else {
                    next;
                }
            }
            $in_trailer = 1 if !$dont_strip && /^%%Trailer/;
            next if $in_trailer;

            if (/^%%Page:/) {
                if ($saved) {
                    print $trailer[$i];
		    print $restore;
                    $saved = 0;
                }

                $page_num++;
                $total_pages++;
                print "\n";
                print "%%Page: ($i-$page_num) $total_pages\n";
                if (($prolog[$i]) && ($prolog[$i] ne $prolog[$prolog_inx])) {
		    print $save;
                    print $prolog[$i];
                    $saved = 1;
                } elsif ($force_save) {
		    print $save;
		}
            } else {
                #s/^(%[%!])/% \1/;
                s/^(%[%!])/% $1/;
                print $_;
            }
        }
    }
    close(IN);

    if ($force_even && $page_num % 2 != 0) {
	$page_num++;
	$total_pages++;
	print "\n";
	print "%%Page: ($i-E) $total_pages\n";
	print "% [ psjoin: empty page inserted to force even pages ]\n";
	print "showpage\n";
    }

    if ($saved) {
        print $trailer[$i];
        print $restore;
    } elsif ($force_save) {
        print $restore;
    }
}

print "\n";
print "%%Trailer\n";
print $trailer[$prolog_inx];
print "%%Pages: $total_pages\n";
print "%%EOF\n";
}
1; # End of PostScript::PStools::PSjoin
