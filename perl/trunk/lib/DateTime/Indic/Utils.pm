package DateTime::Indic::Utils;

# $Id$

use base 'Exporter';
use warnings;
use strict;
use Carp qw/ carp croak /;
use DateTime::Util::Calc qw/ mod revolution sin_deg /;
use POSIX qw/ ceil floor /;
use Math::Trig qw( pi pi2 atan deg2rad tan );

our @EXPORT_OK = qw/
  epoch
  anomalistic_year
  anomalistic_month
  J1900
  sidereal_year
  sidereal_month
  synodic_month
  creation
  ahargana
  ayanamsha
  lunar_longitude
  lunar_on_or_before
  solar_longitude
  saura_rashi
  saura_varsha
  tithi_at_dt
  /;

=head1 NAME

DateTime::Indic::Utils - Utility functions for Indian calendar calculation

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

  my $dt = DateTime->now;
  
  my $ahargana = ahargana($dt);

  my $ayanamsha = ayanamsha($dt);

  my $moon = lunar_longitude($dt);
  
  
  my $d1 = DateTime::Calendar::VikramaSamvata::Gujarati->new(
    varsha => 2064,
    masa   => 7,
    paksha => 1,
    tithi  => 30,
  );
  my $d2 = DateTime::Calendar::VikramaSamvata::Gujarati->new(
    varsha => 2065,
    masa   => 1,
    paksha => 0,
    tithi  => 15,
  );
  my $bool = lunar_on_or_before($d1, $d2);
  
  my $sun = solar_longitude($dt);

  my $rashi = saura_rashi($dt);
  
  my $year = saura_varsha($dt);
  
  my $lunar_day = tithi_at_dt($dt);


=head1 ABSTRACT

A collection of utility functions and constants helpful in creating Indian 
calendars.

=head1 DESCRIPTION

Note:  In this document, Sanskrit words are transliterated using the ITRANS
scheme.

These functions and constants were not included directly in 
L<DateTime::Indic::Chandramana> as they are more useful stand-alone. None of 
them are exported by default.

Most of the functions operate on L<DateTime> objects which I would like to 
change wherever possible.

=head1 CONSTANTS

=head2 epoch

Fixed date of the beginning of the Kali Yuga.

=cut

## no critic 'ProhibitConstantPragma'

use constant epoch => -1_132_959;

=head2 anomalistic_year

Time from aphelion to aphelion.

=cut

use constant anomalistic_year => 1_577_917_828_000 / ( 4_320_000_000 - 387 );

=head2 anomalistic_month

Time from apogee to apogee, with bija correction.

=cut

use constant anomalistic_month => 1_577_917_828 / 57_753_336 - 488_199;

=head2 J1900

The Julian date at noon on Jan 1, 1900.

=cut

use constant J1900 => 2_415_020.0;

=head2 sidereal_year

Mean length of Hindu sidereal year.

=cut

use constant sidereal_year => 365 + ( 279_457 / 1_080_000 );

=head2 sidereal_month

Mean length of Hindu sidereal month.

=cut

use constant sidereal_month => 27 + ( 4_644_439 / 14_438_334 );

=head2 synodic_month

Mean time from new moon to new moon.

=cut

use constant synodic_month => 29 + ( 7_087_771 / 13_358_334 );

=head2 creation

Fixed date of the beginning of the present yuga cycle.

=cut

use constant creation => epoch - 1_955_880_000 * sidereal_year;

=head1 FUNCTIONS

=head2 ahargana($dt)

Return the number of days that have elapsed from the beginning of the current
Kali Yuga to C<$dt>.

=cut

sub ahargana {
    my ($dt) = @_;

    return ( $dt->utc_rd_values )[0] - epoch;
}

=head2 ayanamsha($dt)

Given a datetime object, returns the chitrapakSha ayanAMsha.

=cut

sub ayanamsha {
    my ($dt) = @_;

    # Although most DateTime objects have a jd() method we can only rely on
    # utc_rd_values() existing.
    my $jdate = ( $dt->utc_rd_values )[0] + 1_721_424.5;

    my $d2r = 0.0174532925;
    my $t = ( ( $jdate - J1900 ) - 0.5 ) / 36_525;

    # Mean lunar node
    my $ln = ( ( 933_060 - 6_962_911 * $t + 7.5 * $t * $t ) / 3_600.0 ) % 360.0;

    # Mean Sun
    my $off = ( 259_205_536.0 * $t + 2_013_816.0 ) / 3_600.0;

    $off =
      17.23 * sin( $d2r * $ln ) +
      1.27 * sin( $d2r * $off ) -
      ( 5_025.64 + 1.11 * $t ) * $t;

    # 84038.27 = Fagan-Bradley 80861.27 = Chitrapaksha (Lahiri)
    $off = ( $off - 80_861.27 ) / 3_600.0;

    return $off;
}

=head2 lunar_longitude($dt)

Given a L<DateTime> object C<$dt>, returns the sayana longitude of the moon at 
C<$dt> in decimal degrees.

=cut

sub lunar_longitude {
    my ($dt) = @_;
    ## no critic 'ProhibitParensWithBuiltins'

    my ( $days, $seconds, $nano ) = $dt->utc_rd_values;
    my $jdate  = $days + 1_721_425.5;
    my $offset = ( 86_400 - $seconds ) / 3_600.0;

    my $t  = ( $jdate - 2_415_020 - $offset / 24.0 ) / 36_525.0;
    my $dn = $t * 36_525.0;
    my ( $A, $B, $C, $D, $E, $F, $l, $M, $mm );
    my $t2 = $t * $t;
    my $t3 = $t2 * $t;
    my ( $ang, $ang1 );
    my $anom = revolution(
        358.475_833 + 35_999.04_975 * $t - 1.50e-4 * $t2 - 3.3e-6 * $t3 );
    $A = 0.003964 * ( sin deg2rad( 346.56 + $t * 132.87 - $t2 * 0.0091731 ) );
    $B = ( sin deg2rad( 51.2 + 20.2 * $t ) );
    my $omeg = revolution(
        259.183_275 - 1_934.1_420 * $t + 0.002_078 * $t2 + 0.0_000_022 * $t3 );
    $C = ( sin deg2rad($omeg) );

    $l =
      revolution( 270.434_164 +
          481_267.8_831 * $t -
          0.001_133 * $t2 +
          0.0_000_019 * $t3 +
          0.000_233 * $B + $A +
          0.001_964 * $C );
    $mm =
      deg2rad( 296.104_608 +
          477_198.8_491 * $t +
          0.009_192 * $t2 +
          1.44e-5 * $t3 +
          0.000_817 * $B + $A +
          0.002_541 * $C );
    $D =
      deg2rad( 350.737_486 +
          445_267.1_142 * $t -
          0.001_436 * $t2 +
          1.9e-6 * $t3 + $A +
          0.002_011 * $B +
          0.001_964 * $C );
    $F =
      deg2rad( 11.250_889 +
          483_202.0_251 * $t -
          0.003_211 * $t2 -
          0.0_000_003 * $t3 +
          $A -
          0.024_691 * $C -
          0.004_328 * ( sin deg2rad( $omeg + 275.05 - 2.3 * $t ) ) );
    $M = deg2rad( $anom - 0.001778 * $B );
    $E = 1.0 - 0.002_495 * $t - 0.00_000_752 * $t2;
    $ang =
      $l +
      6.288_750 * ( sin $mm ) +
      1.274_018 * sin( $D + $D - $mm ) +
      0.658_309 * sin( $D + $D ) +
      0.213_616 * sin( $mm + $mm ) -
      0.114_336 * sin( $F + $F ) +
      0.058_793 * sin( $D + $D - $mm - $mm );
    $ang =
      $ang +
      0.053_320 * sin( $D + $D + $mm ) -
      0.034_718 * ( sin $D ) +
      0.015_326 * sin( $D + $D - $F - $F ) -
      0.012_528 * sin( $F + $F + $mm ) -
      0.010_980 * sin( $F + $F - $mm );
    $ang =
      $ang +
      0.010_674 * sin( 4.0 * $D - $mm ) +
      0.010_034 * sin( 3.0 * $mm ) +
      0.008_548 * sin( 4.0 * $D - $mm - $mm ) +
      0.005_162 * sin( $mm - $D ) +
      0.003_996 * sin( $mm + $mm + $D + $D ) +
      0.003_862 * sin( 4.0 * $D );
    $ang =
      $ang +
      0.003_665 * sin( $D + $D - $mm - $mm - $mm ) +
      0.002_602 * sin( $mm - $F - $F - $D - $D ) -
      0.002_349 * sin( $mm + $D ) -
      0.001_773 * sin( $mm + $D + $D - $F - $F ) -
      0.001_595 * sin( $F + $F + $D + $D ) -
      0.001_110 * sin( $mm + $mm + $F + $F );
    $ang1 =
      -0.185_596 * ( sin $M ) +
      0.057_212 * sin( $D + $D - $M - $mm ) +
      0.045_874 * sin( $D + $D - $M ) +
      0.041_024 * sin( $mm - $M ) -
      0.030_465 * sin( $mm + $M ) -
      0.007_910 * sin( $M - $mm + $D + $D ) -
      0.006_783 * sin( $D + $D + $M ) +
      0.005_000 * sin( $M + $D );
    $ang1 =
      $ang1 +
      0.004_049 * sin( $D + $D + $mm - $M ) +
      0.002_695 * sin( $mm + $mm - $M ) +
      0.002_396 * sin( $D + $D - $M - $mm - $mm ) -
      0.002_125 * sin( $mm + $mm + $M ) +
      0.001_220 * sin( 4.0 * $D - $M - $mm );
    $ang1 =
      $ang1 +
      $E *
      ( 0.002_249 * sin( $D + $D - $M - $M ) -
          0.002_079 * sin( $M + $M ) +
          0.002_059 * sin( $D + $D - $M - $M - $mm ) );

    return revolution( $ang + $E * $ang1 );
}

=head2 lunar_on_or_before ($d1, $d2)

Given two lunar dates, C<$d1> and C<$d2>, returns true if C<$d1> is on or 
before C<$d2>.

=cut

sub lunar_on_or_before {
    my ( $d1, $d2 ) = @_;

    return $d1->{varsha} < $d2->{varsha}
      || $d1->{varsha} == $d2->{varsha}
      && (
           $d1->{masa} < $d2->{masa}
        || $d1->{masa} == $d2->{masa}
        && (
               $d1->{adhikamasa} && !$d2->{adhikamasa}
            || $d1->{adhikamasa} == $d2->{adhikamasa}
            && (   $d1->{lunar_day} < $d2->{lunar_day}
                || $d1->{lunar_day} == $d2->{lunar_day}
                && ( !$d1->{adhikatithi} || $d2->{adhikatithi} ) )
        )
      );
}

=head2 solar_longitude($dt)

Given a L<DateTime> object C<$dt>, returns the sayana longitude of the sun at 
C<$dt> in decimal degrees.

=cut

sub solar_longitude {
    my ($dt) = @_;

    my ( $days, $seconds, $nano ) = $dt->utc_rd_values;
    my $jdate  = $days + 1_721_425.5;
    my $offset = ( 86_400 - $seconds ) / 3_600.0;

    my $t    = ( $jdate - 2_415_020 - $offset / 24.0 ) / 36_525.0;
    my $dn   = $t * 36_525.0;
    my $t2   = $t * $t;
    my $t3   = $t2 * $t;
    my $mnln = deg2rad( 279.69_668 + $t * 36_000.76_892 + $t2 * 0.0_003_025 );
    my $ecc  = 0.01675104 - $t * 0.0_000_418 - $t2 * 0.000_000_126;
    my $orbr = 1.0_000_002;
    my $anom =
      deg2rad( 358.475_833 +
          35_999.04_975 * $t -
          1.50e-4 * $t * $t -
          3.3e-6 * $t * $t * $t );
    my $anmn  = $anom;
    my $daily = deg2rad(1.0);
    my $A     = deg2rad( 153.23 + 22_518.7_541 * $t );
    my $B     = deg2rad( 216.57 + 45_037.5_082 * $t );
    my $C     = deg2rad( 312.69 + 329_64.3_577 * $t );
    my $D     = deg2rad( 350.74 + 445_267.1_142 * $t - 0.00144 * $t2 );
    my $E     = deg2rad( 231.19 + 20.20 * $t );
    my $H     = deg2rad( 353.40 + 65_928.7_155 * $t );
    my $c1    = deg2rad(
        (
            1.34 *   ( cos $A ) +
              1.54 * ( cos $B ) +
              2.0 *  ( cos $C ) +
              1.79 * ( sin $D ) +
              1.78 * ( sin $E )
        ) * 1.00e-3
    );
    my $c2 = deg2rad(
        (
            0.543 *   ( sin $A ) +
              1.575 * ( sin $B ) +
              1.627 * ( sin $C ) +
              3.076 * ( cos $D ) +
              0.927 * ( sin $H )
        ) * 1.0e-5
    );
    my $incl = 0.0;
    my $ascn = 0.0;
    my $anec = 0.0;

    for ( my $eold = $anmn ; abs( $anec - $eold ) > 1.0e-8 ; $eold = $anec )
    {    ## no critic 'ProhibitCStyleForLoops'
        $anec =
          $eold +
          ( $anmn + $ecc * ( sin $eold ) - $eold ) /
          ( 1.0 - $ecc * ( cos $eold ) );
    }
    my $antr =
      atan( sqrt( ( 1.0 + $ecc ) / ( 1.0 - $ecc ) ) * tan( $anec / 2.0 ) ) *
      2.0;
    if ( $antr < 0.0 ) {
        $antr += pi2;
    }

    #  calculate the heliocentric longitude  trlong.
    my $u = $mnln + $antr - $anmn - $ascn;
    if ( $u > pi2 ) {
        $u -= pi2;
    }
    if ( $u < 0.0 ) {
        $u += pi2;
    }
    my $n  = int( $u * 2.0 / pi );
    my $uu = atan( cos($incl) * tan($u) );
    if ( $n != int( $uu * 2.0 / pi ) ) {
        $uu += pi;
    }
    if ( $n == 3 ) {
        $uu += pi;
    }
    my $trlong = $uu + $ascn + $c1;
    my $rad = $orbr * ( 1.0 - $ecc * ( cos $anec ) ) + $c2;

    return revolution( $trlong * 180.0 / pi );
}

=head2 saura_rashi ($dt)

returns the zodiacal sign of the sun at DateTime C<$dt> as an integer in the
range 1 .. 12.

=cut

sub saura_rashi {
    my ($dt) = @_;

    return floor( ( solar_longitude($dt) + ayanamsha($dt) ) / 30.0 ) + 1;
}

=head2 saura_varsha ($dt)

Returns the solar year at datetime C<$dt>.

=cut

sub saura_varsha {
    my ($dt) = @_;

    return floor( ahargana($dt) / sidereal_year );
}

=head2 tithi_at_dt ($dt)

Returns the phase of the moon (tithi) at DateTime C<$dt>, as an integer in the
range 1..30.

=cut

sub tithi_at_dt {
    my ($dt) = @_;

    my $t = mod( lunar_longitude($dt) - solar_longitude($dt), 360 );

    return ceil( $t / 12.0 );
}

=head1 BUGS

Please report any bugs or feature requests through the web interface at
<http://code.google.com/p/panchanga/issues/list>. I
will be notified, and then you’ll automatically be notified of progress
on your bug as I make changes. B<Please do not use rt.cpan.org!.>

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc DateTime::Indic::Utils

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

1;    # End of DateTime::Indic::Utils
