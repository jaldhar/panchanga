#!perl
#
# $Id$
#
use strict;
use warnings;

use Test::More tests => 365;
use DateTime;
use DateTime::Calendar::VikramaSamvata::Gujarati;

# Source Janmabhoomi Panchanga (Nov 2006 - Mar 2008)
my $dates = {
    '01' => [
        '2063 pauSha shukla 13',
        '2063 pauSha shukla 14',
        '2063 pauSha shukla 15',
        '2063 pauSha kR^iShNa 1',
        '2063 pauSha kR^iShNa 2',
        '2063 pauSha kR^iShNa 3',
        '2063 pauSha kR^iShNa 4',
        '2063 pauSha kR^iShNa 5',
        '2063 pauSha kR^iShNa 6',
        '2063 pauSha kR^iShNa 7',
        '2063 pauSha kR^iShNa 8',
        '2063 pauSha kR^iShNa adhika 8',
        '2063 pauSha kR^iShNa 9',
        '2063 pauSha kR^iShNa 10',
        '2063 pauSha kR^iShNa 11',
        '2063 pauSha kR^iShNa 12',
        '2063 pauSha kR^iShNa 13',
        '2063 pauSha kR^iShNa 14',
        '2063 pauSha kR^iShNa 30',
        '2063 mAgha shukla 1',
        '2063 mAgha shukla 3',
        '2063 mAgha shukla 4',
        '2063 mAgha shukla 5',
        '2063 mAgha shukla 6',
        '2063 mAgha shukla 7',
        '2063 mAgha shukla 8',
        '2063 mAgha shukla 9',
        '2063 mAgha shukla 10',
        '2063 mAgha shukla 11',
        '2063 mAgha shukla 12',
        '2063 mAgha shukla 13',
    ],
    '02' => [
        '2063 mAgha shukla 14',
        '2063 mAgha shukla 15',
        '2063 mAgha kR^iShNa 1',
        '2063 mAgha kR^iShNa 2',
        '2063 mAgha kR^iShNa 3',
        '2063 mAgha kR^iShNa 4',
        '2063 mAgha kR^iShNa 5',
        '2063 mAgha kR^iShNa 6',
        '2063 mAgha kR^iShNa 7',
        '2063 mAgha kR^iShNa 8',
        '2063 mAgha kR^iShNa 9',
        '2063 mAgha kR^iShNa 10',
        '2063 mAgha kR^iShNa 11',
        '2063 mAgha kR^iShNa 12',
        '2063 mAgha kR^iShNa 13',
        '2063 mAgha kR^iShNa 14',
        '2063 mAgha kR^iShNa 30',
        '2063 phAlguna shukla 1',
        '2063 phAlguna shukla 2',
        '2063 phAlguna shukla 3',
        '2063 phAlguna shukla 4',
        '2063 phAlguna shukla 6',
        '2063 phAlguna shukla 7',
        '2063 phAlguna shukla 8',
        '2063 phAlguna shukla 9',
        '2063 phAlguna shukla 10',
        '2063 phAlguna shukla 11',
        '2063 phAlguna shukla 12',
    ],
    '03' => [
        '2063 phAlguna shukla 13',
        '2063 phAlguna shukla 14',
        '2063 phAlguna shukla 15',
        '2063 phAlguna kR^iShNa 1',
        '2063 phAlguna kR^iShNa adhika 1',
        '2063 phAlguna kR^iShNa 2',
        '2063 phAlguna kR^iShNa 3',
        '2063 phAlguna kR^iShNa 4',
        '2063 phAlguna kR^iShNa 5',
        '2063 phAlguna kR^iShNa 6',
        '2063 phAlguna kR^iShNa 7',
        '2063 phAlguna kR^iShNa 8',
        '2063 phAlguna kR^iShNa 9',
        '2063 phAlguna kR^iShNa 10',
        '2063 phAlguna kR^iShNa 11',
        '2063 phAlguna kR^iShNa 12',
        '2063 phAlguna kR^iShNa 13',
        '2063 phAlguna kR^iShNa 14',
        '2063 phAlguna kR^iShNa 30',            
        '2063 chaitra shukla 2',
        '2063 chaitra shukla 3',
        '2063 chaitra shukla 4',
        '2063 chaitra shukla 5',
        '2063 chaitra shukla 6',
        '2063 chaitra shukla 7',
        '2063 chaitra shukla 8',
        '2063 chaitra shukla 9',
        '2063 chaitra shukla 10',
        '2063 chaitra shukla 11',
        '2063 chaitra shukla 12',
        '2063 chaitra shukla 13',
    ],
    '04' => [
        '2063 chaitra shukla 14',
        '2063 chaitra shukla 15',
        '2063 chaitra kR^iShNa 1',
        '2063 chaitra kR^iShNa 2',
        '2063 chaitra kR^iShNa 3',
        '2063 chaitra kR^iShNa 4',
        '2063 chaitra kR^iShNa adhika 4',
        '2063 chaitra kR^iShNa 5',
        '2063 chaitra kR^iShNa 6',
        '2063 chaitra kR^iShNa 7',
        '2063 chaitra kR^iShNa 8',
        '2063 chaitra kR^iShNa 9',
        '2063 chaitra kR^iShNa 10',
        '2063 chaitra kR^iShNa 11',
        '2063 chaitra kR^iShNa 13',
        '2063 chaitra kR^iShNa 14',
        '2063 chaitra kR^iShNa 30',
        '2063 vaishAka shukla 1',
        '2063 vaishAka shukla 2',
        '2063 vaishAka shukla 3',
        '2063 vaishAka shukla 5',
        '2063 vaishAka shukla 6',
        '2063 vaishAka shukla 7',
        '2063 vaishAka shukla 8',
        '2063 vaishAka shukla 9',
        '2063 vaishAka shukla 10',
        '2063 vaishAka shukla 11',
        '2063 vaishAka shukla 12',
        '2063 vaishAka shukla adhika 12',
        '2063 vaishAka shukla 13',
    ],
    '05' => [
        '2063 vaishAka shukla 14',
        '2063 vaishAka shukla 15',
        '2063 vaishAka kR^iShNa 1',
        '2063 vaishAka kR^iShNa 2',
        '2063 vaishAka kR^iShNa 3',
        '2063 vaishAka kR^iShNa 4',
        '2063 vaishAka kR^iShNa 5',
        '2063 vaishAka kR^iShNa 6',
        '2063 vaishAka kR^iShNa 7',
        '2063 vaishAka kR^iShNa 8',
        '2063 vaishAka kR^iShNa 9',
        '2063 vaishAka kR^iShNa 10',
        '2063 vaishAka kR^iShNa 11',
        '2063 vaishAka kR^iShNa 12',
        '2063 vaishAka kR^iShNa 13',
        '2063 vaishAka kR^iShNa 30',
        '2063 adhika jyeShTa shukla 1',
        '2063 adhika jyeShTa shukla 2',
        '2063 adhika jyeShTa shukla 3',
        '2063 adhika jyeShTa shukla 4',
        '2063 adhika jyeShTa shukla 5',
        '2063 adhika jyeShTa shukla 6',
        '2063 adhika jyeShTa shukla 7',
        '2063 adhika jyeShTa shukla 8',
        '2063 adhika jyeShTa shukla 9',
        '2063 adhika jyeShTa shukla 10',
        '2063 adhika jyeShTa shukla 11',
        '2063 adhika jyeShTa shukla 12',
        '2063 adhika jyeShTa shukla 13',
        '2063 adhika jyeShTa shukla 14',
        '2063 adhika jyeShTa shukla 15',
    ],
    '06' => [
        '2063 adhika jyeShTa shukla adhika 15',
        '2063 adhika jyeShTa kR^iShNa 1',
        '2063 adhika jyeShTa kR^iShNa 2',
        '2063 adhika jyeShTa kR^iShNa 3',
        '2063 adhika jyeShTa kR^iShNa 4',
        '2063 adhika jyeShTa kR^iShNa 5',
        '2063 adhika jyeShTa kR^iShNa 6',
        '2063 adhika jyeShTa kR^iShNa 8',
        '2063 adhika jyeShTa kR^iShNa 9',
        '2063 adhika jyeShTa kR^iShNa 10',
        '2063 adhika jyeShTa kR^iShNa 11',
        '2063 adhika jyeShTa kR^iShNa 12',
        '2063 adhika jyeShTa kR^iShNa 13',
        '2063 adhika jyeShTa kR^iShNa 14',
        '2063 adhika jyeShTa kR^iShNa 30',
        '2063 jyeShTa shukla 1',
        '2063 jyeShTa shukla 3',
        '2063 jyeShTa shukla 4',
        '2063 jyeShTa shukla 5',
        '2063 jyeShTa shukla 6',
        '2063 jyeShTa shukla 7',
        '2063 jyeShTa shukla 8',
        '2063 jyeShTa shukla adhika 8',
        '2063 jyeShTa shukla 9',
        '2063 jyeShTa shukla 10',
        '2063 jyeShTa shukla 11',
        '2063 jyeShTa shukla 12',
        '2063 jyeShTa shukla 13',
        '2063 jyeShTa shukla 14',
        '2063 jyeShTa shukla 15',
    ],
    '07' => [
        '2063 jyeShTa kR^iShNa 1',
        '2063 jyeShTa kR^iShNa 2',
        '2063 jyeShTa kR^iShNa 3',
        '2063 jyeShTa kR^iShNa 4',
        '2063 jyeShTa kR^iShNa 5',
        '2063 jyeShTa kR^iShNa 6',
        '2063 jyeShTa kR^iShNa 7',
        '2063 jyeShTa kR^iShNa 8',
        '2063 jyeShTa kR^iShNa 9',
        '2063 jyeShTa kR^iShNa 11',
        '2063 jyeShTa kR^iShNa 12',
        '2063 jyeShTa kR^iShNa 13',
        '2063 jyeShTa kR^iShNa 14',
        '2063 jyeShTa kR^iShNa 30',
        '2063 AShADha shukla 1',
        '2063 AShADha shukla 2',
        '2063 AShADha shukla 3',
        '2063 AShADha shukla 4',
        '2063 AShADha shukla 5',
        '2063 AShADha shukla 6',
        '2063 AShADha shukla 7',
        '2063 AShADha shukla 8',
        '2063 AShADha shukla 9',
        '2063 AShADha shukla 10',
        '2063 AShADha shukla 11',
        '2063 AShADha shukla adhika 11',
        '2063 AShADha shukla 12',
        '2063 AShADha shukla 13',
        '2063 AShADha shukla 14',
        '2063 AShADha shukla 15',
        '2063 AShADha kR^iShNa 2',
    ],
    '08' => [
        '2063 AShADha kR^iShNa 3',
        '2063 AShADha kR^iShNa 4',
        '2063 AShADha kR^iShNa 5',
        '2063 AShADha kR^iShNa 6',
        '2063 AShADha kR^iShNa 7',
        '2063 AShADha kR^iShNa 8',
        '2063 AShADha kR^iShNa 9',
        '2063 AShADha kR^iShNa 10',
        '2063 AShADha kR^iShNa 11',
        '2063 AShADha kR^iShNa 12',
        '2063 AShADha kR^iShNa 14',
        '2063 AShADha kR^iShNa 30',
        '2063 shrAvaNa shukla 1',
        '2063 shrAvaNa shukla 2',
        '2063 shrAvaNa shukla 3',
        '2063 shrAvaNa shukla adhika 3',
        '2063 shrAvaNa shukla 4',
        '2063 shrAvaNa shukla 5',
        '2063 shrAvaNa shukla 6',
        '2063 shrAvaNa shukla 7',
        '2063 shrAvaNa shukla 8',
        '2063 shrAvaNa shukla 9',
        '2063 shrAvaNa shukla 10',
        '2063 shrAvaNa shukla 11',
        '2063 shrAvaNa shukla 12',
        '2063 shrAvaNa shukla 13',
        '2063 shrAvaNa shukla 14',
        '2063 shrAvaNa shukla 15',
        '2063 shrAvaNa kR^iShNa 1',
        '2063 shrAvaNa kR^iShNa 2',
        '2063 shrAvaNa kR^iShNa 3',
    ],
    '09' => [
        '2063 shrAvaNa kR^iShNa 5',
        '2063 shrAvaNa kR^iShNa 6',
        '2063 shrAvaNa kR^iShNa 7',
        '2063 shrAvaNa kR^iShNa 8',
        '2063 shrAvaNa kR^iShNa 9',
        '2063 shrAvaNa kR^iShNa 10',
        '2063 shrAvaNa kR^iShNa 11',
        '2063 shrAvaNa kR^iShNa 12',
        '2063 shrAvaNa kR^iShNa 13',
        '2063 shrAvaNa kR^iShNa 14',
        '2063 shrAvaNa kR^iShNa 30',
        '2063 bhAdrapada shukla 1',
        '2063 bhAdrapada shukla 2',
        '2063 bhAdrapada shukla 3',
        '2063 bhAdrapada shukla 4',
        '2063 bhAdrapada shukla 5',
        '2063 bhAdrapada shukla 6',
        '2063 bhAdrapada shukla adhika 6',
        '2063 bhAdrapada shukla 7',
        '2063 bhAdrapada shukla 8',
        '2063 bhAdrapada shukla 9',
        '2063 bhAdrapada shukla 10',
        '2063 bhAdrapada shukla 11',
        '2063 bhAdrapada shukla 12',
        '2063 bhAdrapada shukla 13',
        '2063 bhAdrapada shukla 15',
        '2063 bhAdrapada kR^iShNa 1',
        '2063 bhAdrapada kR^iShNa 2',
        '2063 bhAdrapada kR^iShNa 3',
        '2063 bhAdrapada kR^iShNa 4',
    ],
    '10' => [
        '2063 bhAdrapada kR^iShNa 5',
        '2063 bhAdrapada kR^iShNa 7',
        '2063 bhAdrapada kR^iShNa 8',
        '2063 bhAdrapada kR^iShNa 9',
        '2063 bhAdrapada kR^iShNa 10',
        '2063 bhAdrapada kR^iShNa 11',
        '2063 bhAdrapada kR^iShNa 12',
        '2063 bhAdrapada kR^iShNa 13',
        '2063 bhAdrapada kR^iShNa 14',
        '2063 bhAdrapada kR^iShNa adhika 14',
        '2063 bhAdrapada kR^iShNa 30',
        '2063 ashvina shukla 1',
        '2063 ashvina shukla 2',
        '2063 ashvina shukla 3',
        '2063 ashvina shukla 4',
        '2063 ashvina shukla 5',
        '2063 ashvina shukla 6',
        '2063 ashvina shukla 7',
        '2063 ashvina shukla 8',
        '2063 ashvina shukla 9',
        '2063 ashvina shukla 10',
        '2063 ashvina shukla 11',
        '2063 ashvina shukla 12',
        '2063 ashvina shukla 13',
        '2063 ashvina shukla 14',
        '2063 ashvina shukla 15',
        '2063 ashvina kR^iShNa 2',
        '2063 ashvina kR^iShNa 3',
        '2063 ashvina kR^iShNa 4',
        '2063 ashvina kR^iShNa 5',
        '2063 ashvina kR^iShNa 6',
    ],
    '11' => [
        '2063 ashvina kR^iShNa 7',
        '2063 ashvina kR^iShNa 8',
        '2063 ashvina kR^iShNa 9',
        '2063 ashvina kR^iShNa 10',
        '2063 ashvina kR^iShNa 11',
        '2063 ashvina kR^iShNa 12',
        '2063 ashvina kR^iShNa 13',
        '2063 ashvina kR^iShNa 14',
        '2063 ashvina kR^iShNa 30',
        '2064 kArtika shukla 1',
        '2064 kArtika shukla adhika 1',
        '2064 kArtika shukla 2',
        '2064 kArtika shukla 3',
        '2064 kArtika shukla 4',
        '2064 kArtika shukla 5',
        '2064 kArtika shukla 6',
        '2064 kArtika shukla 7',
        '2064 kArtika shukla 8',
        '2064 kArtika shukla 9',
        '2064 kArtika shukla 10',
        '2064 kArtika shukla 11',
        '2064 kArtika shukla 12',
        '2064 kArtika shukla 14',
        '2064 kArtika shukla 15',
        '2064 kArtika kR^iShNa 1',
        '2064 kArtika kR^iShNa 2',
        '2064 kArtika kR^iShNa 3',
        '2064 kArtika kR^iShNa 4',
        '2064 kArtika kR^iShNa 6',
        '2064 kArtika kR^iShNa 7',
    ],
    '12' => [
        '2064 kArtika kR^iShNa 8',
        '2064 kArtika kR^iShNa 9',
        '2064 kArtika kR^iShNa adhika 9',
        '2064 kArtika kR^iShNa 10',
        '2064 kArtika kR^iShNa 11',
        '2064 kArtika kR^iShNa 12',
        '2064 kArtika kR^iShNa 13',
        '2064 kArtika kR^iShNa 14',
        '2064 kArtika kR^iShNa 30',
        '2064 mArgashIrasa shukla 1',
        '2064 mArgashIrasa shukla 2',
        '2064 mArgashIrasa shukla 3',
        '2064 mArgashIrasa shukla 4',
        '2064 mArgashIrasa shukla 5',
        '2064 mArgashIrasa shukla 6',
        '2064 mArgashIrasa shukla 7',
        '2064 mArgashIrasa shukla 8',
        '2064 mArgashIrasa shukla 9',
        '2064 mArgashIrasa shukla 10',
        '2064 mArgashIrasa shukla 11',
        '2064 mArgashIrasa shukla 12',
        '2064 mArgashIrasa shukla 13',
        '2064 mArgashIrasa shukla 14',
        '2064 mArgashIrasa kR^iShNa 1',
        '2064 mArgashIrasa kR^iShNa 2',
        '2064 mArgashIrasa kR^iShNa 3',
        '2064 mArgashIrasa kR^iShNa 4',
        '2064 mArgashIrasa kR^iShNa 5',
        '2064 mArgashIrasa kR^iShNa 6',
        '2064 mArgashIrasa kR^iShNa 7',
        '2064 mArgashIrasa kR^iShNa 8',
    ],
};

foreach my $month (sort keys %{$dates}) {
    my $day = 0;    
    foreach my $expected (@{$dates->{$month}}) {
        ++$day;
        my $dt = DateTime->new(day => $day, month => $month, year => 2007, 
            time_zone => 'Asia/Calcutta');
        # sunrise at Mumbai
        my $date =
        DateTime::Calendar::VikramaSamvata::Gujarati->from_object(
            object    => $dt,
            latitude  => '18.96',
            longitude => '72.82',
        );
        is($date->strftime("%x"), $expected, "$month $day, 2007");
    }
}

