#!perl
#
# $Id$
#
use strict;
use warnings;

use Test::More tests => 121;
use DateTime;
use DateTime::Calendar::VikramaSamvata::Northern;

# Source Janmabhoomi Panchanga (2007-2009)
my $dates = {
    '01' => [
        '2064 pauSha kR^iShNa 9',
        '2064 pauSha kR^iShNa 10',
        '2064 pauSha kR^iShNa adhika 10',
        '2064 pauSha kR^iShNa 11',
        '2064 pauSha kR^iShNa 12',
        '2064 pauSha kR^iShNa 13',
        '2064 pauSha kR^iShNa 14',
        '2064 pauSha kR^iShNa 30',
        '2064 pauSha shukla 1',
        '2064 pauSha shukla 2',
        '2064 pauSha shukla 3',
        '2064 pauSha shukla 4',
        '2064 pauSha shukla 5',
        '2064 pauSha shukla 6',
        '2064 pauSha shukla 7',
        '2064 pauSha shukla 8',
        '2064 pauSha shukla 9',
        '2064 pauSha shukla 10',
        '2064 pauSha shukla 12',
        '2064 pauSha shukla 13',
        '2064 pauSha shukla 14',
        '2064 pauSha shukla 15',
        '2064 mAgha kR^iShNa 1',
        '2064 mAgha kR^iShNa 2',
        '2064 mAgha kR^iShNa 3',
        '2064 mAgha kR^iShNa 4',
        '2064 mAgha kR^iShNa 5',
        '2064 mAgha kR^iShNa 6',
        '2064 mAgha kR^iShNa 7',
        '2064 mAgha kR^iShNa 8',
        '2064 mAgha kR^iShNa 9',
    ],
    '02' => [
        '2064 mAgha kR^iShNa 10',
        '2064 mAgha kR^iShNa 11',
        '2064 mAgha kR^iShNa 12',
        '2064 mAgha kR^iShNa adhika 12',
        '2064 mAgha kR^iShNa 13',
        '2064 mAgha kR^iShNa 14',
        '2064 mAgha kR^iShNa 30',
        '2064 mAgha shukla 1',
        '2064 mAgha shukla 2',
        '2064 mAgha shukla 4',
        '2064 mAgha shukla 5',
        '2064 mAgha shukla 6',
        '2064 mAgha shukla 7',
        '2064 mAgha shukla 8',
        '2064 mAgha shukla 9',
        '2064 mAgha shukla 10',
        '2064 mAgha shukla 11',
        '2064 mAgha shukla 12',
        '2064 mAgha shukla 13',
        '2064 mAgha shukla 14',
        '2064 mAgha shukla 15',
        '2064 phAlguna kR^iShNa 1',
        '2064 phAlguna kR^iShNa 2',
        '2064 phAlguna kR^iShNa 3',
        '2064 phAlguna kR^iShNa 4',
        '2064 phAlguna kR^iShNa 5',
        '2064 phAlguna kR^iShNa 6',
        '2064 phAlguna kR^iShNa 7',
        '2064 phAlguna kR^iShNa 8',
    ],
    '03' => [
        '2064 phAlguna kR^iShNa 9',
        '2064 phAlguna kR^iShNa 10',
        '2064 phAlguna kR^iShNa 11',
        '2064 phAlguna kR^iShNa 12',
        '2064 phAlguna kR^iShNa 13',
        '2064 phAlguna kR^iShNa 14',
        '2064 phAlguna kR^iShNa 30',
        '2064 phAlguna shukla 1',
        '2064 phAlguna shukla 2',
        '2064 phAlguna shukla 3',
        '2064 phAlguna shukla 4',
        '2064 phAlguna shukla 5',
        '2064 phAlguna shukla 6',
        '2064 phAlguna shukla 8',
        '2064 phAlguna shukla 9',
        '2064 phAlguna shukla 10',
        '2064 phAlguna shukla 11',
        '2064 phAlguna shukla 12',
        '2064 phAlguna shukla 13',
        '2064 phAlguna shukla 14',
        '2064 phAlguna shukla 15',
        '2065 chaitra kR^iShNa 1',
        '2065 chaitra kR^iShNa 2',
        '2065 chaitra kR^iShNa 3',
        '2065 chaitra kR^iShNa 4',
        '2065 chaitra kR^iShNa adhika 4',
        '2065 chaitra kR^iShNa 5',
        '2065 chaitra kR^iShNa 6',
        '2065 chaitra kR^iShNa 7',
        '2065 chaitra kR^iShNa 8',
        '2065 chaitra kR^iShNa 9',
    ],
    '04' => [
        '2065 chaitra kR^iShNa 10',
        '2065 chaitra kR^iShNa 11',
        '2065 chaitra kR^iShNa 12',
        '2065 chaitra kR^iShNa 13',
        '2065 chaitra kR^iShNa 14',
        '2065 chaitra kR^iShNa 30',
        '2065 chaitra shukla 2',
        '2065 chaitra shukla 3',
        '2065 chaitra shukla 4',
        '2065 chaitra shukla 5',
        '2065 chaitra shukla 6',
        '2065 chaitra shukla 7',
        '2065 chaitra shukla 8',
        '2065 chaitra shukla 9',
        '2065 chaitra shukla 10',
        '2065 chaitra shukla 11',
        '2065 chaitra shukla 12',
        '2065 chaitra shukla 13',
        '2065 chaitra shukla 14',
        '2065 chaitra shukla 15',
        '2065 vaishAkha kR^iShNa 1',
        '2065 vaishAkha kR^iShNa 2',
        '2065 vaishAkha kR^iShNa 3',
        '2065 vaishAkha kR^iShNa 4',
        '2065 vaishAkha kR^iShNa 5',
        '2065 vaishAkha kR^iShNa 6',
        '2065 vaishAkha kR^iShNa 7',
        '2065 vaishAkha kR^iShNa adhika 7',
        '2065 vaishAkha kR^iShNa 8',
        '2065 vaishAkha kR^iShNa 9',
    ],
};

foreach my $month (sort keys %{$dates}) {
    my $day = 0;    
    foreach my $expected (@{$dates->{$month}}) {
        ++$day;
        my $dt = DateTime->new(day => $day, month => $month, year => 2008, 
            time_zone => 'Asia/Kolkata');
        # sunrise at Mumbai
        my $date =
        DateTime::Calendar::VikramaSamvata::Northern->from_object(
            object    => $dt,
            latitude  => '18.96',
            longitude => '72.82',
        );
        is($date->strftime("%x"), $expected, "$month $day, 2008");
    }
}

