## no critic (RequirePodSections)
# $Id$
package DateTime::Calendar::HalariSamvata;

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

The hAlArI SaMvata started in the 3044th year of the present Kali
Yuga.  The year begins on AShADha shukla 1 and months are amAsanta.

=head1 USAGE

See L<DateTime::Calendar::Indic::Chandramana> for available methods.

=head1 AUTHOR

Jaldhar H. Vyas, E<lt>jaldhar@braincells.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008, Consolidated Braincells Inc.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

L<http://datetime.perl.org/> -- The DateTime project web site.

