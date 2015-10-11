
use v6;
use Test;
use lib 'lib';
use Pastebin::Gist;

my $p = Pastebin::Gist.new;
my $paste_url = $p.paste("Perl 6 Module Test<p>\n& <pre>foo", 'My Summary <>&');
ok $paste_url ~~ /^^ 'http://fpaste.scsys.co.uk/'  \d+ $$/,
    "Paste URL [$paste_url] is sane";

my ( $content, $summary ) = $p.fetch( $paste_url );
is $content, "Perl 6 Module Test<p>\n& <pre>foo", 'Retrieved content is good';
is $summary, 'My Summary <>&', 'Retrieved summary is good';

( $content, $summary ) = $p.fetch( ($paste_url ~~ /(\d+)/)[0] );
is $content, "Perl 6 Module Test<p>\n& <pre>foo",
    'Retrieved content is good when using paste ID only';
is $summary, 'My Summary <>&',
    'Retrieved summary is good when using paste ID only';

done-testing;

=finish

GitHub testing account:
Login: perl6-tester
Pass: tester-perl6
Token: 4c6567f85f0980f30987b69b69767647c2165a26
