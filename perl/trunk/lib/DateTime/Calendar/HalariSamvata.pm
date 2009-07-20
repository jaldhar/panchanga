package DateTime::Calendar::HalariSamvata;

# $Id$

use strict;
use warnings;
use Carp;
use base 'DateTime::Indic::Chandramana';

our $VERSION = 0.1;

## no critic 'ProhibitConstantPragma'

sub _era {
    my ($self) = @_;

    return 3044;
}

sub _masa_offset {
    my ($self) = @_;

    return 4;
}

1;

__END__

=head1 NAME

DateTime::Calendar::HalariSamvata - Halari/Kutchhi calendar.

=head1 VERSION

This documentation describes version 0.1 of this module.

=head1 SYNOPSIS

use DateTime::Calendar::HalariSamvata;

=head1 ABSTRACT

A module that implements the ChandramAna (luni-solar) calendar used in some 
Western parts of the Indian state of Gujarat.

=head1 DESCRIPTION

The hAlArI saMvata started in the 3044th year of the current kali yuga.  The 
year begins on AShADha shukla 1 and months are amAsanta.

=head1 USAGE

See L<DateTime::Indic::Chandramana> for available methods.

=head1 BUGS

Please report any bugs or feature requests through the web interface at
<http://code.google.com/p/panchanga/issues/list>. I
will be notified, and then you’ll automatically be notified of progress
on your bug as I make changes. B<Please do not use rt.cpan.org!.>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Calendar::HalariSamvata

Support requests for this module and questions about panchanga ganita should
be sent to the panchanga-devel@lists.braincells.com email list. See
L<http://lists.braincells.com/> for more details.

Questions related to the DateTime API should be sent to the
datetime@perl.org email list. See L<http://lists.perl.org/> for more details.

You can also look for information at:

=over 4

=item * This projects web site

L<http://code.google.com/p/panchanga/>

=item * This projects (read-only) subversion source code repository

L<http://panchanga.googlecode.com/svn/perl/>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DateTime-Indic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DateTime-Indic>

=item * Search CPAN

L<http://search.cpan.org/dist/DateTime-Indic>

=back

=head1 SEE ALSO

L<DateTime>

=head1 AUTHOR

Jaldhar H. Vyas, C<< <jaldhar at braincells.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009, Consolidated Braincells Inc.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this distribution.

