package DateTime::Indic::Chandramana;

# $Id$

use warnings;
use strict;
use Carp qw/ carp croak /;
use DateTime::Event::Lunar;
use DateTime::Indic::Utils qw/ epoch sidereal_year sidereal_month calendar_year
  lunar_day lunar_on_or_before solar_longitude zodiac /;
use DateTime::Event::Sunrise;
use DateTime::Util::Calc qw/ amod dt_from_moment mod search_next /;
use Memoize;
use Params::Validate qw/ validate BOOLEAN SCALAR OBJECT UNDEF /;
use POSIX qw/ floor /;

=head1 NAME

DateTime::Indic::Chandramana - Base class for Indian luni-solar calendars

=head1 VERSION

Version 0.2

=cut

our $VERSION = '0.2';

=head1 SYNOPSIS

This class is meant to be subclassed not used directly.

=head1 ABSTRACT

A module that implements an Indian ChandramAna (luni-solar,) nirAyana
(sidereal,) khagolasiddha (heliocentric,) and spaShTa (based on the true times
of astronomical events) calendar.  The calendar described in this module isn't
actually used as-is though; rather it is a basis for actual Indian luni-solar
calendars which are implemented in other modules in the
L<DateTime::Indic> collection.

=cut

my @varsha_nama = qw{ prabhava vibhava shukla pramoda prajApati a~ngirA
  shrImukha bhAva yuvA dhAtA ishvara bahudhAnya pramAthI vikrama vR^isha
  chitrabhAnu subhAnu tAraNa pArthiva vyaya sarvajit sarvadhArI virodhI
  vikrti khara nandana vijaya jaya manmatha durmukha hemalambi vilambi
  vikArI shArvarI plava shubhakrta shobhana krodhI vishvavAsu parAbhava
  plava~nga kIlaka saumya sAdharaNa virodhakrta paridhAvi pramAdi Ananda
  rAkshasa anala pi~Ngala kAlayukta siddhArthi raudra durmati dundubhi
  rudhirodgArI raktAkShI krodhana kshaya
};

my @vara_nama = qw{
  ravivAra somavAra ma~ngalavAra budhavAra guruvAra shukravAra shanivAra
};

my @vara_abbrev = qw { ra so ma bu gu shu sha };

my @masa_nama = qw{
  chaitra vaishAkha jyeShTa AShADha shrAvaNa bhAdrapada ashvina kArtika
  mArgashIrasa pauSha mAgha phAlguna
};

my @masa_abbrev = qw{
  chai vai jye AshA shrA bhA a kA  mAr pau mA phA
};

my @paksha_nama = qw{shukla kR^iShNa};

my @paksha_abbrev = qw{shu kR^i};

my $adhika_nama = 'adhika';

my $adhika_abbrev = 'a';

my @tithi_nama = qw{
  pratipadA dvitIyA tR^itIya chaturthI paMchamI ShaShTI saptamI aShTamI
  navamI dashamI ekAdashI dvAdashI trayodashI chaturdashI
};

my @tithi_abbrev = qw{
  pra dvi tR^i cha paM Sha sa a na da e dvA tra chada
};

my $amavasya_nama = 'amAvAsyA';

my $amavasya_abbrev = 'a';

my $purnima_nama = 'pUrNimA';

my $purnima_abbrev = 'pU';

=head1 METHODS

=head2 DATETIME METHODS

These methods are either required by the L<DateTime> API or copied from it.

=head3 new (%args)

Constructs a new instance of this class.  The following arguments can be given:

=over 4

=item * varsha

The numeric year according to the calender's era.  Defaults to 0.

=item * masa

The mAsa (lunar month) as a number from 1 to 12.  Defaults to 1.

=item * adhikamasa

1 if this is an adhika (leap) mAsa, 0 otherwise.  Defaults to 0.

=item * paksha

1 if this is the kR^iShNapakSha (waning half)  of a mAsa, 0 if it is the
shuklapakSha (waxing half.)  Defaults to 0.

=item * tithi

The numeric tithi (lunar day) expressed as a number from 1 to 14 or by 
convention, 15 for the pUrNimA (full moon) and 30 for the amAvAsya (new moon.) 
Defaults to 1.

=item * adhikatithi

1 if this is an adhika (leap) tithi, 0 otherwise.  Defaults to 0.

=item * latitude

The latitude of the point for which the panchanga is to be calculated 
expressed as decimal degrees.  Negative values are used for latitudes south of 
the equator so the allowable range for this argument is from -180 to 180.  
Defaults to 23.15, the latitude of avantika.

=item * longitude

The longitude of the point for which the panchanga is to be calculated 
expressed as decimal degrees.  Negative values are used for longitudes west of 
Greenwich so the allowable range for this argument is from -180 to 180.  
Defaults to 75.76, the longitude of avantika.

=back

=cut

## no critic 'ProhibitConstantPragma'

sub new {
    my ( $class, @arguments ) = @_;

    my %args = validate(
        @arguments,
        {
            varsha => {
                type    => SCALAR,
                default => 0,
            },
            masa => {
                type      => SCALAR,
                default   => 1,
                callbacks => {
                    'between 1 and 12' => sub { ( $_[0] > 0 && $_[0] < 13 ) },
                },
            },
            adhikamasa => {
                type    => BOOLEAN,
                default => 0,
                callbacks =>
                  { '0 or 1' => sub { ( $_[0] == 0 || $_[0] == 1 ) }, },
            },
            paksha => {
                type    => BOOLEAN,
                default => 0,
                callbacks =>
                  { '0 or 1' => sub { ( $_[0] == 0 || $_[0] == 1 ) }, },
            },
            tithi => {
                type      => SCALAR,
                default   => 1,
                callbacks => {
                    'between 1 and 14, or 15 or 30' => sub {
                        ( $_[0] > 0 && $_[0] < 15 )
                          || $_[0] == 15
                          || $_[0] == 30;
                    },
                },
            },
            adhikatithi => {
                type    => BOOLEAN,
                default => 0,
                callbacks =>
                  { '0 or 1' => sub { ( $_[0] == 0 || $_[0] == 1 ) }, },
            },
            latitude => {
                type      => SCALAR,
                default   => '23.15',
                callbacks => {
                    'between -180 and 180' =>
                      sub { ( $_[0] >= -180 && $_[0] < 180 ) },
                },
            },
            longitude => {
                type      => SCALAR,
                default   => '75.76',
                callbacks => {
                    'between -180 and 180' =>
                      sub { ( $_[0] >= -180 && $_[0] < 180 ) },
                },
            },

            #        locale     =>   {
            #                            type => SCALAR | OBJECT | UNDEF,
            #                            default => undef,
            #                        },
        }
    );

    my $self = bless \%args, $class;

    $self->{lunar_day} =
      ( $self->{paksha} == 1 && $self->{tithi} < 30 )
      ? $self->{tithi} + 15
      : $self->{tithi};

    #    if(defined($self->{locale})) {
    #        $self->{locale}  = DateTime::Locale->load($args{locale})
    #            unless (ref $self->{locale});
    #    }

    return $self;
}

sub _fixed_from_lunar {
    my ($self) = @_;

    memoize('_lunar_from_fixed');

    my $approx =
      epoch +
      sidereal_year *
      ( $self->{varsha} +
          $self->_era +
          ( $self->{masa} - ( $self->_masa_offset > 1 ? 0 : 1 ) ) / 12.0 );

    if ( $self->{masa} < $self->_masa_offset ) {
        $approx += sidereal_year;
    }

    my $s = floor(
        $approx - ( 1.0 / 360.0 ) * sidereal_year * (
            mod(
                solar_longitude( dt_from_moment($approx) ) -
                  ( $self->{masa} - ( $self->_masa_offset > 1 ? 0 : 1 ) ) * 30 +
                  180,
                360
              ) - 180
        )
    );

    my $k = lunar_day( dt_from_moment( $s + ( 1.0 / 4.0 ) ) );

    my $x;
    my $mid = $self->_lunar_from_fixed( dt_from_moment( $s - 15 ),
        $self->{latitude}, $self->{longitude} );
    if (
        $mid->{masa} < $self->{masa}
        || ( $mid->{adhikamasa}
            && !$self->{adhikamasa} )
      )
    {
        $x = mod( $k + 15, 30 ) - 15;
    }
    else {
        $x = mod( $k - 15, 30 ) + 15;
    }

    my $est = $s + $self->{lunar_day} - $x;

    my $tau = $est - mod(
        lunar_day( dt_from_moment( $est + ( 1.0 / 4.0 ) ) ) -
          $self->{lunar_day} +
          15,
        30
    ) + 15;

    my $date = dt_from_moment($tau);

    search_next(
        base  => $date,
        check => sub {
            return lunar_on_or_before(
                $self,
                $self->_lunar_from_fixed(
                    $_[0], $self->{latitude}, $self->{longitude},
                ),
            );
        },
        next => sub { $_[0]->add( days => 1 ); },
    );

    return ( $date->utc_rd_values )[0];
}

sub _lunar_from_fixed {
    my ( $self, $dt, $latitude, $longitude ) = @_;

    my $result = {};

    my $sun = DateTime::Event::Sunrise->new(
        latitude  => $latitude,
        longitude => $longitude,
        altitude  => 0,
    );
    my $suryodaya = $sun->sunrise_datetime($dt);

    $result->{lunar_day} = lunar_day($suryodaya);

    # adhikatithi
    my $last_suryodaya =
      $sun->sunrise_datetime( $dt->clone->subtract( days => 1 ) );
    $result->{adhikatithi} =
      ( $result->{lunar_day} == lunar_day($last_suryodaya) ) ? 1 : 0;

    # paksha and normalize tithi number
    $result->{paksha} = 0;
    $result->{tithi}  = $result->{lunar_day};
    if ( $result->{tithi} > 15 ) {
        $result->{paksha} = 1;
        if ( $result->{tithi} != 30 ) {
            $result->{tithi} -= 15;
        }
    }

    # masa and adhikamasa
    my $pnm = DateTime::Event::Lunar->new_moon_before(
        datetime     => $suryodaya,
        on_or_before => 1
    );
    my $nnm = DateTime::Event::Lunar->new_moon_after(
        datetime    => $suryodaya,
        on_or_after => 1
    );
    my $solarmonth     = zodiac($pnm);
    my $nextsolarmonth = zodiac($nnm);

    $result->{masa} = amod( $solarmonth + 1, 12 );
    $result->{adhikamasa} = ( $solarmonth == $nextsolarmonth ) ? 1 : 0;
    if (   $self->_purnimanta
        && $result->{adhikamasa} == 0
        && $result->{paksha} == 1 )
    {
        $result->{masa} = amod( $result->{masa} + 1, 12 );
    }

    # varsha
    if ( $result->{masa} <= ( $self->_purnimanta ? 2 : 1 ) ) {
        $result->{varsha} =
          calendar_year( $suryodaya->clone->add( days => 180 ) );
    }
    else {
        $result->{varsha} = calendar_year($suryodaya);
    }
    $result->{varsha} -= $self->_era;
    if ( $result->{masa} < $self->_masa_offset ) {
        $result->{varsha}--;
    }

    return $result;
}

=head3 clone

Returns a copy of the object.

=cut

sub clone {
    my ($self) = @_;
    return bless { %{$self} }, ref $self;
}

=head3 from_object

Builds a C<DateTime::Calendar::Chandramana> object from another I<DateTime> 
object.  This function takes an C<object> parameter and optionally C<locale>. 
For example:


=cut

sub from_object {
    my ( $class, @arguments ) = @_;

    my %args = validate(
        @arguments,
        {
            object => {
                type => OBJECT,
                can  => 'utc_rd_values',
            },
            latitude => {
                type      => SCALAR,
                default   => '23.15',    # lat. of Avantika
                callbacks => {
                    'between -180 and 180' =>
                      sub { ( $_[0] >= -180 && $_[0] < 180 ) },
                },
            },
            longitude => {
                type      => SCALAR,
                default   => '75.76',    # long. of Avantika
                callbacks => {
                    'between -180 and 180' =>
                      sub { ( $_[0] >= -180 && $_[0] < 180 ) },
                },
            },

            #        locale    => {
            #                        type => SCALAR | OBJECT | UNDEF,
            #                        default => undef,
            #                     },
        }
    );

    my $results =
      $class->_lunar_from_fixed( $args{object}, $args{latitude},
        $args{longitude}, );

    my $newobj = $class->new(
        varsha      => $results->{varsha},
        masa        => $results->{masa},
        adhikamasa  => $results->{adhikamasa},
        paksha      => $results->{paksha},
        tithi       => $results->{tithi},
        adhikatithi => $results->{adhikatithi},
        latitude    => $args{latitude},
        longitude   => $args{longitude},

        #locale      => $args{locale},
    );
    return $newobj;
}

=head3 strftime(@formats)

This function takes one or more parameters consisting of strings
containing special specifiers.  For each such string it will return a
string formatted according to the specifiers, er, specified.  The following
specifiers are allowed in the format string:

=over 4

=item * %a Equivalent to L<adhikamasa_abbrev>.

=item * %A Equivalent to L<adhikamasa_name>.

=item * %l Equivalent to L<adhikatithi_abbrev>.

=item * %L Equivalent to L<adhikatithi_name>.

=item * %m Equivalent to L<masa_abbrev>.

=item * %M Equivalent to L<masa_name>.

=item * %p Equivalent to L<paksha_abbrev>.

=item * %P Equivalent to L<paksha_name>.

=item * %t Equivalent to L<tithi_abbrev>.

=item * %T Equivalent to L<tithi_name>.

=cut

#=item * %v Equivalent to L<vara_abbrev>.
#
#=item * %V Equivalent to L<vara_name>.
#

=item * %w Equivalent to L<tithi>.

=item * %x Equivalent to '%y %A %M %P %L %w'

=item * %y Equivalent to L<varsha>.

=cut

#=item * %Y Equivalent to L<varsha_name>.
#

=item * %% A literal `%' character.

=back 

Any method name may be specified using the format C<%{method}> name
where "method" is a valid C<DateTime::Calendar::Chandramana> object method.

=cut

my %formats = (

    'a' => sub { $_[0]->adhikamasa_abbrev },

    'A' => sub { $_[0]->adhikamasa_name },

    'l' => sub { $_[0]->adhikatithi_abbrev },

    'L' => sub { $_[0]->adhikatithi_name },

    'm' => sub { $_[0]->masa_abbrev },

    'M' => sub { $_[0]->masa_name },

    'p' => sub { $_[0]->paksha_abbrev },

    'P' => sub { $_[0]->paksha_name },

    't' => sub { $_[0]->tithi_abbrev },

    'T' => sub { $_[0]->tithi_name },

    #    'v' => sub { $_[0]->vara_abbrev },
    #
    #    'V' => sub { $_[0]->vara_name },
    #
    'w' => sub { $_[0]->tithi },

    'x' => sub {
        join q{},
          (
            $_[0]->varsha . q{ },
            $_[0]->adhikamasa ? ( $_[0]->adhikamasa_name . q{ } ) : q{},
            $_[0]->masa_name . q{ },
            $_[0]->paksha_name . q{ },
            $_[0]->adhikatithi ? ( $_[0]->adhikatithi_name . q{ } ) : q{},
            $_[0]->tithi,
          );
    },

    'y' => sub { $_[0]->varsha },

    #    'Y' => sub { $_[0]->varsha_name },

    '%' => sub { q{%} },    ## no critic 'ProhibitNoisyQuotes'
);

sub strftime {
    my $self = shift;

    # make a copy or caller's scalars get munged
    my @formats = @_;

    my @r;
    foreach my $f (@formats) {
        $f =~ s/
                (
                 ?:
                 %{(\w+)} # method name like %{day_name}
                 |
                 %([%a-zA-Z]) # single character specifier like %d
                )
               /
                (
                 $1
                 ? ( $self->can($1) ? $self->$1() : "\%{$1}" )
                 : $2
                 ? ( $formats{$2} ? $formats{$2}->($self) : "\%$2" )
                 : $3
                )
               /smgex;

        if ( !wantarray ) {
            return $f;
        }

        push @r, $f;
    }

    return @r;
}

=head3 utc_rd_values

Returns a three-element array containing the current UTC RD days, seconds, and 
nanoseconds.  See L<DateTime> for more details.

=cut

sub utc_rd_values {
    my ($self) = @_;

    if ( !exists $self->{rd_days} ) {
        $self->{rd_days}     = $self->_fixed_from_lunar;
        $self->{rd_secs}     = 0;
        $self->{rd_nanosecs} = 0;
    }

    return ( $self->{rd_days}, $self->{rd_secs}, $self->{rd_nanosecs} || 0 );
}

sub _era {
    my ($self) = @_;

    return 0;
}

sub _masa_offset {
    my ($self) = @_;

    return 1;
}

sub _purnimanta {
    my ($self) = @_;

    return 0;
}

#sub _varsha_name_style {
#    my($self) = @_;
#
#    return 0;
#}

=head2 UNITS OF TIME

These methods return various parts of a chandramAna date.

=head3 varsha

Returns the varSha.

=cut

sub varsha {
    my ($self) = @_;

    return $self->{varsha};
}

#=head3 varsha_name
#
#TODO
#
#=cut
#
#sub varsha_name {
#    my ($self) = @_;
#
#    my $ky = $self->{varsha} + $self->era;
#    if ($self->{masa} >= $self->masa_offset) {
#        $ky++;
#    }
#    my $barhaspatya_varsha = ($self->_varsha_name_style
#        ? ($ky + ($ky / 86) + 25) # northern
#        : ($ky + 12)              # southern
#    ) % 60;
#    return $varsha_nama[$barhaspatya_varsha];
#}

=head3 adhikamasa

Returns 1 if this is an adhikamAsa or 0 if it is not.

=cut

sub adhikamasa {
    my ($self) = @_;

    return $self->{adhikamasa};
}

=head3 adhikamasa_abbrev

Returns the abbreviated adhikamAsa name.  (By default 'a '.)

=cut

sub adhikamasa_abbrev {
    my ($self) = @_;

    return ( $self->{adhikamasa} ? $adhika_abbrev : undef );
}

=head3 adhikamasa_name

Returns the full adhikamAsa name. (By default 'adhika '.)

=cut

sub adhikamasa_name {
    my ($self) = @_;

    return ( $self->{adhikamasa} ? $adhika_nama : undef );
}

=head3 masa

Returns the mAsa as a number from 1 to 12

=cut

sub masa {
    my ($self) = @_;

    return $self->{masa};
}

=head3 masa_abbrev

Returns the abbreviated mAsa name.

=cut

sub masa_abbrev {
    my ($self) = @_;

    return $masa_abbrev[ $self->{masa} - 1 ];
}

=head3 masa_name

Returns the full mAsa name.

=cut

sub masa_name {
    my ($self) = @_;

    return $masa_nama[ $self->{masa} - 1 ];
}

=head3 paksha

Returns 1 if this is the kR^iShNapakSha or 0 if it is the shuklapakSha.

=cut

sub paksha {
    my ($self) = @_;

    return $self->{paksha};
}

=head3 paksha_abbrev

Returns the abbreviated pakSha name.  By default either 'shu' for shukla or 
'kR^i' for kR^iShNa.

=cut

sub paksha_abbrev {
    my ($self) = @_;

    return $paksha_abbrev[ $self->{paksha} ];
}

=head3 paksha_name

Returns the full paksha name. By default either shukla or kR^iShNa.

=cut

sub paksha_name {
    my ($self) = @_;

    return $paksha_nama[ $self->{paksha} ];
}

=head3 adhikatithi

Returns 1 if this is an adhikatithi or 0 if it is not.

=cut

sub adhikatithi {
    my ($self) = @_;

    return $self->{adhikatithi};
}

=head3 adhikatithi_abbrev

Returns the abbreviated adhikatithi name.  (By default 'a '.)

=cut

sub adhikatithi_abbrev {
    my ($self) = @_;

    return ( $self->{adhikatithi} ? $adhika_abbrev : undef );
}

=head3 adhikatithi_name

Returns the full adhikatithi name. (By default 'adhika '.)

=cut

sub adhikatithi_name {
    my ($self) = @_;

    return ( $self->{adhikatithi} ? $adhika_nama : undef );
}

=head3 tithi

Returns the tithi as a decimal number.

=cut

sub tithi {
    my ($self) = @_;

    return $self->{tithi};
}

=head3 tithi_abbrev

Returns the abbreviated tithi name.

=cut

sub tithi_abbrev {
    my ($self) = @_;

    if ( $self->{tithi} == 15 ) {
        return $purnima_abbrev;
    }

    if ( $self->{tithi} == 30 ) {
        return $amavasya_abbrev;
    }

    return $tithi_abbrev[ $self->{tithi} - 1 ];
}

=head3 tithi_name

Returns the full tithi name.

=cut

sub tithi_name {
    my ($self) = @_;

    if ( $self->{tithi} == 15 ) {
        return $purnima_nama;
    }

    if ( $self->{tithi} == 30 ) {
        return $amavasya_nama;
    }

    return $tithi_nama[ $self->{tithi} - 1 ];
}

#=head3 vara
#
#returns the day of the week as a decimal number.
#
#=cut
#
#sub vara {
#    my ($self) = @_;
#
#    return $self->{vara};
#}
#
#=head3 vara_abbrev
#
#returns the abbreviated name of the current day of the week.
#
#=cut
#
#sub vara_abbrev {
#    my ($self) = @_;
#
#    return $vara_abbrev[ $self->{vara} ];
#}
#
#=head3 vara_name
#
#returns the name of the current day of the week.
#
#=cut
#
#sub vara_name {
#    my ($self) = @_;
#
#    return $vara_nama[ $self->{vara} ];
#}

=head1 BUGS

Please report any bugs or feature requests through the web interface at
<http://code.google.com/p/panchanga/issues/list>. I
will be notified, and then you’ll automatically be notified of progress
on your bug as I make changes. B<Please do not use rt.cpan.org!.>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Indic::Chandramana

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

=cut

1;    # End of DateTime::Indic::Chandramana

