package DateTime::Indic::Locale::sn_utf8;

# $Id$

use warnings;
use strict;

our $VERSION = '0.2';

my @varsha_nama = qw{
  प्रभव विभव शुक्ल प्रमोद प्रजापति अंगिरा
  श्रीमुख भाव युवा धाता ईश्वर बहुधान्य
  प्रमाथी विक्रम वृष चित्रभानु सुभानु तारण
  पार्थिव व्यय सर्वजित सर्वधारी विरोधी विकृति
  खर नन्दन विजय जय मन्मथ दुर्मुख
  हेमलम्बि विलम्बि विकारी शार्वरी प्लव शुभकृत
  शोभन क्रोधी विश्ववासु पराभव प्लवंग कीलक
  सौम्य साधारण विरोधकृत परिधावि प्रमादी आनन्द
  राक्षस अनल पिङ्गल कालयुक्त सिद्धार्थि रौद्र
  दुर्मति दुन्दुभि रुधिरोद्गारी रक्ताक्षी क्रोधन क्षय
};

my @vara_nama = qw{
  रविवार सोमवार मङ्गलवार बुधवार गुरुवार शुक्रवार शनिवार
};

my @vara_abbrev = qw{ र सो म बु गु शु श };

my @masa_nama = qw{
  चैत्र वैशाक ज्येष्ट आषाढ श्रावण भाद्रपद
  अश्विन कार्तिक मार्गशीरस पौश माघ फाल्गुन
};

my @masa_abbrev = qw{
  चै वै ज्ये आ श्रा भा
  अ का मार्ग पौ मा फा
};

my @paksha_nama = qw{ शुक्ल कृष्ण };

my @paksha_abbrev = qw{ शु कृ };

my $adhika = 'अधिक';

my $adhika_abbrev = 'अ';

my @tithi_nama = qw{
  प्रतिपदा द्वितीया तृतीया चतुर्थी पंञ्चमी षष्टी सप्तमी अष्टमी
  नवमी दशमी एकादशी द्वादशी त्रयोदशी चतुर्दशी
};

my @tithi_abbrev = qw{
  प्र द्वि तृ च पं ष स अ न द ए द्वा त्र चद
};

my $amavasya_nama = 'अमावास्या';

my $amavasya_abbrev = 'अ';

my $purnima_nama = 'पूर्णिमा';

my $purnima_abbrev = 'पू';

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
