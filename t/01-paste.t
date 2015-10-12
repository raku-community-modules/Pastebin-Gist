
use v6;
use Test;
use lib 'lib';
use Pastebin::Gist;

my $p = Pastebin::Gist.new(
    token => '3f2b4ca292960fafc63fb6798f148e3b47ea9bad',
);
my $paste_url = $p.paste(
    "Perl 6 Module Test<p>\n& <pre>foo",
    desc => 'My Summary <>&',
);
ok $paste_url ~~ /^ 'https://gist.github.com/' <[\w]>+ $/,
    "Paste URL [$paste_url] is sane";

my ( $files, $desc ) = $p.fetch( $paste_url );
is $desc, 'My Summary <>&', 'Retrieved description is good';
for keys $files {
    is $_, 'nopaste.txt', 'Paste filename is sane';
    is $files.{$_}, "Perl 6 Module Test<p>\n& <pre>foo",
        'Paste content is sane';

}

done-testing;

=finish

GitHub testing account:
Login: perl6-tester
Pass: tester-perl6
Token: 3f2b4ca292960fafc63fb6798f148e3b47ea9bad
