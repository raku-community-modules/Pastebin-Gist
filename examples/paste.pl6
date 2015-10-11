#!/usr/bin/env perl6

use lib 'lib';
use Pastebin::Gist;


my $p = Pastebin::Gist.new(
    token => '4c6567f85f0980f30987b69b69767647c2165a26'
);

say "Pasting test content...";
my $paste_url = $p.paste('<pre>test paste1</pre>');
say "Paste is located at $paste_url";

# say "Retrieiving paste content...";
# my ( $content, $summary ) = get_paste($paste_url);
# say "Summary: $summary";
# say "Content: $content";
