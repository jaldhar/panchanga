package DateTime::Indic::Locale::sn_utf8;

# $Id$

use warnings;
use strict;

our $VERSION = '0.1';

my @varsha_nama = (
    'प्रभव',                      'विभव',
    'शुक्ल',                      'प्रमोद',
    'प्रजापति',             'अंगिरा',
    'श्रीमुख',                'भाव',
    'युवा',                         'धाता',
    'ईश्वर',                      'बहुधान्य',
    'प्रमाथी',                'विक्रम',
    'वृष',                            'चित्रभानु',
    'सुभानु',                   'तारण',
    'पार्थिव',                'व्यय',
    'सर्वजित',                'सर्वधारी',
    'विरोधी',                   'विकृति',
    'खर',                               'नन्दन',
    'विजय',                         'जय',
    'मन्मथ',                      'दुर्मुख',
    'हेमलम्बि',             'विलम्बि',
    'विकारी',                   'शार्वरी',
    'प्लव',                         'शुभकृत',
    'शोभन',                         'क्रोधी',
    'विश्ववासु',          'पराभव',
    'प्लवंग',                   'कीलक',
    'सौम्य',                      'साधारण',
    'विरोधकृत',             'परिधावि',
    'प्रमादी',                'आनन्द',
    'राक्षस',                   'अनल',
    'पिङ्गल',                   'कालयुक्त',
    'सिद्धार्थि',       'रौद्र',
    'दुर्मति',                'दुन्दुभि',
    'रुधिरोद्गारी', 'रक्ताक्षी',
    'क्रोधन',                   'क्षय',
);

my @vara_nama = (
    'रविवार',       'सोमवार',
    'मङ्गलवार', 'बुधवार',
    'गुरुवार',    'शुक्रवार',
    'शनिवार',
);

my @vara_abbrev =
  ( 'र', 'सो', 'म', 'बु', 'गु', 'शु', 'श', );

my @masa_nama = (
    'चैत्र',             'वैशाक',
    'ज्येष्ट',       'आषाढ',
    'श्रावण',          'भाद्रपद',
    'अश्विन',          'कार्तिक',
    'मार्गशीरस', 'पौश',
    'माघ',                   'फाल्गुन',
);

my @masa_abbrev = (
    'चै',          'वै', 'ज्ये', 'आ',
    'श्रा',    'भा', 'अ',          'का',
    'मार्ग', 'पौ', 'मा',       'फा',
);

my @paksha_nama = ( 'शुक्ल', 'कृष्ण' );

my @paksha_abbrev = ( 'शु', 'कृ' );

my $adhika = 'अधिक';

my $adhika_abbrev = 'अ';

my @nakshatra_nama = (
    'अश्विनी',
    'भरणी',
    'कृत्तिका',
    'रोहिणी',
    'मृगशीर्ष',
    'आर्द्रा',
    'पुनर्वसु',
    'पुष्य',
    'आश्लेषा',
    'मघा',
    'पूर्वफाल्गुनी',
    'उत्तराफाल्गुनी',
    'हस्त',
    'चित्रा',
    'स्वाती',
    'विशाखा',
    'अनुराधा',
    'ज्येष्टा',
    'मूल',
    'पूर्वाषाढा',
    'उत्तराषाढा',
    'श्रवण',
    'धनिष्ट',
    'शततारा',
    'पूर्वाभाद्रपदा',
    'उत्तरभाद्रपदा',
    'रेवती',
);

my @yoga_nama = (
    'विष्कुंभ', 'प्रीति',
    'आयुष्मान', 'सौभाग्य',
    'शोभन',             'अतिगण्ड',
    'सुकर्मा',    'धृति',
    'शूल',                'गण्ड',
    'वृद्धि',       'ध्रुव',
    'व्याघात',    'हर्षण',
    'वज्र',             'सिद्धि',
    'व्यतिपात', 'वरीयान',
    'परिघ',             'शिव',
    'सिद्ध',          'साध्य',
    'शुभ',                'शुक्ल',
    'ब्रह्मा',    'ऐन्द्र',
    'वैधृति',
);

1;

__END__

=head1	NAME

DateTime::Indic::Locale::sn_utf8 - Sanskrit UTF8 locale for Indic calendars

=head1 SUPPORT

Support requests for this module and questions about panchanga ganita should
be sent to the panchanga-devel@lists.braincells.com email list. See 
L<http://lists.braincells.com/> for more details.

Questions related to the DateTime API should be sent to the 
datetime@perl.org email list. See L<http://lists.perl.org/> for more details.

Please submit bugs to the CPAN RT system at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=datetime-Calendar-indic>
or via email at bug-datetime-calendar-indic@rt.cpan.org.

=head1 AUTHOR

Jaldhar H. Vyas, E<lt>jaldhar@braincells.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2007, Consolidated Braincells Inc.

This library is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

The full text of the license can be found in the LICENSE file included
with this module.

=head1 SEE ALSO

L<http://datetime.perl.org/> -- The DateTime project web site.

=cut
