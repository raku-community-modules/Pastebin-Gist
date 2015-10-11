unit class Pastebin::Gist:version<1.001001>;

use LWP::Simple;
use URI::Encode;

constant API-URL   = 'http://api.github.com/gists';
constant PASTE-URL = 'https://gist.github.com/';

subset ValidGistToken      of Str where /:i <[a..f 0..9]> ** 40/;
subset ValidGistIndentSize of Int where any(2, 4, 8);
subset ValidGistIndentType of Str where any(<tabs spaces>);
subset ValidGistWrapMethod of Str where any(<no soft>);

has ValidGistToken      $.token        = %*ENV<PASTEBIN_GIST_TOKEN>;
has ValidGistIndentSize $.indent       = 4;
has ValidGistIndentType $.indent-type  = 'spaces';
has ValidGistWrapMethod $.wrap         = 'no';

method paste (
    Str   $paste,
    Str  :$desc     = '',
    Str  :$filename = 'gistfile1.txt',
    Bool :$public   = False
) returns Str {
    my %content =
        public      => $public,
        description => $desc,
        files       => { $filename => { content => $paste } };

say %content.perl;

    say API-URL;
    say to-json %content;
    say  'Authorization=' ~ uri_encode_component( "token $!token"    )
   ~ 'Content='       ~ uri_encode_component( to-json %content   )
   ~ 'Content_Type='  ~ uri_encode_component( 'application/json' );

    my $res = LWP::Simple.new.post( API-URL, {},
              'Authorization=' ~ uri_encode_component( "token $!token"    )
            ~ 'Content='       ~ uri_encode_component( to-json %content   )
            ~ 'Content_Type='  ~ uri_encode_component( 'application/json' )
    );

    return PASTE-URL ~ from-json( $res ).<id>;
}

method fetch ($what) returns List {

}
