unit class Pastebin::Gist:version<1.001001>;

use LWP::Simple;
use URI::Encode;
use HTML::Entity;

subset ValidGistToken      of Str where /:i <[a..f 0..9]> ** 40/;
subset ValidGistIndentSize of Int where any(2, 4, 8);
subset ValidGistIndentType of Str where any(<tabs spaces>);
subset ValidGistWrapMethod of Str where any(<no soft>);

has Str                 $!gist-url     = 'https://gist.github.com/';
has ValidGistToken      $.token        = $ENV{PASTEBIN_GIST_TOKEN};
has ValidGistIndentSize $.indent       = 4;
has ValidGistIndentType $.indent-type  = 'spaces';
has ValidGistWrapMethod $.wrap         = 'no';

method paste ($paste, :$desc, :$filename) returns Str {
    my $paste_id = (LWP::Simple.new.post( $.gist-url ~ 'paste', {},
        'channel='
        ~ '&nick='
        ~ '&summary=' ~ uri_encode_component( ($summary // '').Str )
        ~ '&paste='   ~ uri_encode_component( $paste.Str )
        ~ '&Paste+it=Paste+it'
    ) ~~ m:P5{meta http-equiv="refresh" content="5;url=http://fpaste.scsys.co.uk/(\d+)">})[0];

    $paste_id
        or fail 'Did not find paste ID in response from the pastebin';

    return $.pastebin_url ~ $paste_id;
}

method fetch ($what) returns List {

}
