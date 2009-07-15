package DateTime::Indic::Chandramana;

# $Id$

use warnings;
use strict;
use Carp qw/ carp croak /;
use DateTime::Event::Lunar qw/ :phases /;
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

Version 0.01

=cut

our $VERSION = '0.01';

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

my @masa_nama = qw{ chaitra vaishAka jyeShTa AShADha shrAvaNa bhAdrapada
  ashvina kArtika mArgashIrasa pauSha mAgha phAlguna
};

my @masa_abbrev = qw{ chai vai jye AshA shrA bhA a kA  mAr pau mA phA };

my @paksha_nama = qw{shukla kR^iShNa};

my @paksha_abbrev = qw{shu kR^i};

my $adhika_nama = 'adhika';

=head1 METHODS

=head2 new (%args)

TODO

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
                default   => 0,
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
                solar_longitude( dt_from_moment($approx) ) - (
                    $self->{masa} +
                      ( $self->_purnimanta && $self->{paksha} == 0 ? 1 : 0 ) -
                      ( $self->_masa_offset > 1 ? 0 : 1 )
                  ) * 30 + 180,
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

=head2 clone

TODO

=cut

sub clone {
    my ($self) = @_;
    return bless { %{$self} }, ref $self;
}

=head2 from_object

TODO

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

my %formats = (
    'x' =>
      sub { join( q{ }, $_[0]->varsha, $_[0]->masa_name, $_[0]->udita_tithi, ) }
    ,
);

=head2 strftime(@formats)

TODO

=cut

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

=head2 utc_rd_values

TODO

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

=head2 _era

TODO

=cut

sub _era {
    my ($self) = @_;

    return 0;
}

=head2 _masa_offset

TODO

=cut

sub _masa_offset {
    my ($self) = @_;

    return 1;
}

=head2 _purnimanta

TODO

=cut

sub _purnimanta {
    my ($self) = @_;

    return 0;
}

=head2 varsha

TODO

=cut

sub varsha {
    my ($self) = @_;

    return $self->{varsha};
}

=head2 masa_name

TODO

=cut

sub masa_name {
    my ($self) = @_;

    return ( $self->{adhikamasa} ? "$adhika_nama " : q{} )
      . $masa_nama[ $self->{masa} - 1 ];
}

=head2 udita_tithi

TODO

=cut

sub udita_tithi {
    my ($self) = @_;

    return
        $paksha_nama[ $self->{paksha} ] . q{ }
      . ( $self->{adhikatithi} ? "$adhika_nama " : q{} )
      . $self->{tithi};
}

=head1 AUTHOR

Jaldhar H. Vyas, C<< <jaldhar at braincells.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-datetime-indic at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DateTime-Indic>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Indic::Chandramana

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=DateTime-Indic>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DateTime-Indic>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/DateTime-Indic>

=item * Search CPAN

L<http://search.cpan.org/dist/DateTime-Indic>

=back


=head1 SEE ALSO

L<DateTime>

=head1 COPYRIGHT & LICENSE

Copyright 2008 Consolidated Braincells Inc, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;    # End of DateTime::Indic::Chandramana
