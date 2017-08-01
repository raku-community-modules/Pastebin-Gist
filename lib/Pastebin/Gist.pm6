use WWW;
use JSON::Fast;
unit class Pastebin::Gist;

constant API-URL   = 'https://api.github.com/';
constant PASTE-URL = 'https://gist.github.com/';

subset ValidGistToken of Str where /:i <[a..f 0..9]> ** 40/;
has ValidGistToken $.token = %*ENV<PASTEBIN_GIST_TOKEN>;

BEGIN WWW.^ver
    andthen $_ >= v1.004001 or die 'Need WWW.pm6 version 1.004001 or newer';

method paste (
    $paste,
    Str  :$desc     = '',
    Str  :$filename = 'nopaste.txt',
    Bool :$public   = False,
) returns Str {
    my %content = public      => $public,
                  description => $desc,
                  files       => $paste ~~ Hash
                                    ?? $paste
                                    !! { $filename => { content => $paste } };

    my $res = jpost API-URL ~ 'gists', %content.&to-json,
            :Authorization("token $!token"), :Content-Type<application/json>,
            :User-Agent('Rakudo Pastebin::Gist')
    orelse die "Error communicating with GitHub: {.exception.message}";

    return PASTE-URL ~ $res<id>;
}

method fetch ($what) returns List {
    my $res = jget API-URL ~ "gists/$what.split('/').tail()",
        :User-Agent('Rakudo Pastebin::Gist')
    orelse die "Error communicating with GitHub: {.exception.message}";

    my %files;
    %files{$_} = $res<files>{$_}<content> for $res<files>:v.keys;

    return %files, $res<description>;
}
