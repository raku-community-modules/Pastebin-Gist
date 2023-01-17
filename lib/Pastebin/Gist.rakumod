use WWW :extras;
use JSON::Fast;

unit class Pastebin::Gist:ver<1.007>:auth<zef:raku-community-modules>;

class X is Exception { has $.message }

constant API-URL   = 'https://api.github.com/';
constant PASTE-URL = 'https://gist.github.com/';
constant %UA       = :User-Agent('Rakudo Pastebin::Gist');

subset ValidGistToken of Str where /:i
                                       | ghp_ <[a..f 0..9]> ** 36
                                       | <[a..f 0..9]> ** 40
                                   /;
has ValidGistToken:D $.token = %*ENV<PASTEBIN_GIST_TOKEN>;

method paste(
    $paste,
    Str  :$desc     = '',
    Str  :$filename = 'nopaste.txt',
    Bool :$public   = False,
--> Str:D) {
    my %content = public      => $public,
                  description => $desc,
                  files       => $paste ~~ Hash
                                    ?? $paste
                                    !! { $filename => { content => $paste } };

    my $res = jpost API-URL ~ 'gists', %content.&to-json,
        |%UA, :Authorization("token $!token"), :Content-Type<application/json>
    orelse die X.new: :message(.exception.message);

    PASTE-URL ~ $res<id>
}

method fetch($what --> List:D) {
    with jget API-URL ~ "gists/$what.split('/').tail()", |%UA -> $res {
        my %files;
        %files{$_} = $res.<files>{$_}<content> for $res<files>:v.keys;
        %files, $res<description>
    }
    else -> $_ {
        when *.exception.message.contains: 'Error 404' {
            die X.new: :message('404 paste not found');
        }
        die X.new: :message(.exception.message);
    }
}

method delete($what --> Bool:D) {
    with delete API-URL ~ "gists/$what.split('/').tail()", |%UA,
        :Authorization("token $!token"), :Content-Type<application/json>
    {
        True
    }
    else -> $_ {
        when *.exception.message.contains: 'Error 404' {
            die X.new: :message('404 paste not found');
        }
        die X.new: :message(.exception.message);
    }
}

=begin pod

=head1 NAME

Pastebin::Gist - Raku interface to https://gist.github.com/

=head1 SYNOPSIS

=begin code :lang<raku>

use Pastebin::Gist;
my $p = Pastebin::Gist.new(
    token => 'ghp_4ca292960fafc63fb6798f148e3b47ea9fff',
);

my $paste-url = $p.paste("<foo>bar</foo>");

my $paste-url = $p.paste(
    {
        'file1.raku' => { content => "Paste content 1" },
        'meow.css' => { content => "Paste content 2" },
    },
    :desc("Foo Bar"),
    :!public,
);

$p.delete: $paste-url; # delete a gist

=end code

=head1 DESCRIPTION

This module allows the user to create and paste to GitHub Gists as well as retrieve them.

=head1 METHODS

=head2 C<new>

=begin code :lang<raku>

# Assuming PASTEBIN_GIST_TOKEN env var has the token:
my $p = Pastebin::Gist.new;

# Set token via an argument:
my $p = Pastebin::Gist.new(
    token => 'ghp_4ca292960fafc63fb6798f148e3b47ea9fff',
)

Creates new C<Pastebin::Gist> object. Accepts the following settings:

=end code

=head3 C<token>

=begin code :lang<raku>

token => 'ghp_4ca292960fafc63fb6798f148e3b47ea9fff'

=end code

To use this module you need to
L<create a GitHub token|https://github.com/settings/tokens>. Only the C<gist>
permission is needed.

You can avoid providing the C<token> argument by setting the
C<PASTEBIN_GIST_TOKEN> environmental variable to the value of your token.

=head2 Local User Testing

In order to test the module with your token, use the installed executable 'test-pastebin-gist'
to insure all works before using this module in other programs.

=head2 C<paste>

=begin code :lang<raku>

my $paste-url = $p.paste('Paste content');
my $paste-url = $p.paste('Paste content', filename => 'foo.raku');
my $paste-url = $p.paste(
    {
        'file1.raku' => { content => "Paste content 1" },
        'meow.css'   => { content => "Paste content 2" },
    },
    :desc('Optional summary'),
    :public,
);

=end code

B<Returns> URL to the created paste (e.g.
L<https://gist.github.com/5590bc07b8d5bd8fd98d>). On failure, throws
`Pastebin::Gist::X` exception whose `$.message` method has reason for error.
First positional argument can either be a string of content to paste or
a hashref where keys are filenames and values are hashrefs with
values key C<content> set to content of files to paste. Using a hashref
allows you to make a gist with multiple files. All other arguments
are optional and are as follows:

=head3 C<desc>

=begin code :lang<raku>

desc => 'Optional summary',

=end code

B<Optional>. Provides the description (summary) of the gist. By default
not specified.

=head3 C<public>

=begin code :lang<raku>

public => True,

=end code

B<Optional>. Takes C<True> or C<False> values. If set to C<True>, your
gist will be visible in search results and I<recent gists> page.
B<Defaults to:> C<False>.

=head3 C<filename>

=begin code :lang<raku>

filename => "Foo.raku"

=end code

B<Optional>. Applies only when the first positional argument to
L</paste> is a string. Specifies the filename to use for your gist
(affects syntax highlighting). B<Defaults to:> C<nopaste.txt>.

Note: L<GitHub's API docs|https://developer.github.com/v3/gists/#create-a-gist>
have this blurb in them:

    Don't name your files "gistfile" with a numerical suffix.
    This is the format of the automatic naming scheme that
    Gist uses internally.

It tells you not to use files C<gistfile3> or C<gistfile33.txt>. Behaviour
when using this types of values for C<filename> is not defined.

=head2 C<fetch>

=begin code :lang<raku>

my ( $files, $desc )
  = $p.fetch('https://gist.github.com/5590bc07b8d5bd8fd98d');

my ( $files, $desc ) = $p.fetch('5590bc07b8d5bd8fd98d');
say "Title: $desc";
for $files.keys {
    say "File: $_\nContent:\n$files{$_}";
}

=end code

B<Returns> a two-item list: files in the gist and gist's title.
B<Takes> one mandatory argument: a full URL or just the
ID number of the gist  you want to retrieve. The C<$files> is a hashref,
where keys are file names and values are the file's contents.
On failure, throws
`Pastebin::Gist::X` exception whose `$.message` method has reason for error.

=head2 C<delete>

=begin code :lang<raku>

$p.delete: 'https://gist.github.com/5590bc07b8d5bd8fd98d';
$p.delete: '5590bc07b8d5bd8fd98d';

=end code

B<Returns> `True`. Deletes an existing gist referenced by either the ID or the
full URL to it. On failure, throws `Pastebin::Gist::X` exception whose
`$.message` method has reason for error.

=head1 AUTHOR

Zoffix Znet

=head1 COPYRIGHT AND LICENSE

Copyright 2015 - 2018 Zoffix Znet

Copyright 2019 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
