[![Actions Status](https://github.com/raku-community-modules/Pastebin-Gist/workflows/test/badge.svg)](https://github.com/raku-community-modules/Pastebin-Gist/actions)

NAME
====

Pastebin::Gist - Raku interface to https://gist.github.com/

SYNOPSIS
========

```raku
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

my $fetch-url = 'https://gist.github.com/raiph/849a4a9d8875542fb86df2b2eda89296';
my ($content-hash, $description) = $p.fetch: $fetch-url;
dd $content-hash; # Hash $content-hash = ${".md" => "Great description of Raku core - the content of file .md - goes here"}
dd $description; # Str $description = "Raku's \"core\""

$p.delete: $paste-url; # delete a gist
```

DESCRIPTION
===========

This module allows the user to create and paste to GitHub Gists as well as retrieve them.

METHODS
=======

`new`
-----

```raku
# Assuming PASTEBIN_GIST_TOKEN env var has the token:
my $p = Pastebin::Gist.new;

# Set token via an argument:
my $p = Pastebin::Gist.new(
    token => 'ghp_4ca292960fafc63fb6798f148e3b47ea9fff',
)

Creates new C<Pastebin::Gist> object. Accepts the following settings:
```

### `token`

```raku
token => 'ghp_4ca292960fafc63fb6798f148e3b47ea9fff'
```

To use this module you need to [create a GitHub token](https://github.com/settings/tokens). Only the `gist` permission is needed.

You can avoid providing the `token` argument by setting the `PASTEBIN_GIST_TOKEN` environmental variable to the value of your token.

Local User Testing
------------------

In order to test the module with your token, use the installed executable 'test-pastebin-gist' to insure all works before using this module in other programs.

`paste`
-------

```raku
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
```

**Returns** URL to the created paste (e.g. [https://gist.github.com/5590bc07b8d5bd8fd98d](https://gist.github.com/5590bc07b8d5bd8fd98d)). On failure, throws `Pastebin::Gist::X` exception whose `$.message` method has reason for error. First positional argument can either be a string of content to paste or a hashref where keys are filenames and values are hashrefs with values key `content` set to content of files to paste. Using a hashref allows you to make a gist with multiple files. All other arguments are optional and are as follows:

### `desc`

```raku
desc => 'Optional summary',
```

**Optional**. Provides the description (summary) of the gist. By default not specified.

### `public`

```raku
public => True,
```

**Optional**. Takes `True` or `False` values. If set to `True`, your gist will be visible in search results and *recent gists* page. **Defaults to:** `False`.

### `filename`

```raku
filename => "Foo.raku"
```

**Optional**. Applies only when the first positional argument to [/paste](/paste) is a string. Specifies the filename to use for your gist (affects syntax highlighting). **Defaults to:** `nopaste.txt`.

Note: [GitHub's API docs](https://developer.github.com/v3/gists/#create-a-gist) have this blurb in them:

    Don't name your files "gistfile" with a numerical suffix.
    This is the format of the automatic naming scheme that
    Gist uses internally.

It tells you not to use files `gistfile3` or `gistfile33.txt`. Behaviour when using this types of values for `filename` is not defined.

`fetch`
-------

```raku
my ( $files, $desc )
  = $p.fetch('https://gist.github.com/5590bc07b8d5bd8fd98d');

my ( $files, $desc ) = $p.fetch('5590bc07b8d5bd8fd98d');
say "Title: $desc";
for $files.keys {
    say "File: $_\nContent:\n$files{$_}";
}
```

**Returns** a two-item list: files in the gist and gist's title. **Takes** one mandatory argument: a full URL or just the ID number of the gist you want to retrieve. The `$files` is a hashref, where keys are file names and values are the file's contents. On failure, throws `Pastebin::Gist::X` exception whose `$.message` method has reason for error.

`delete`
--------

```raku
$p.delete: 'https://gist.github.com/5590bc07b8d5bd8fd98d';
$p.delete: '5590bc07b8d5bd8fd98d';
```

**Returns** `True`. Deletes an existing gist referenced by either the ID or the full URL to it. On failure, throws `Pastebin::Gist::X` exception whose `$.message` method has reason for error.

AUTHOR
======

Zoffix Znet

COPYRIGHT AND LICENSE
=====================

Copyright 2015 - 2018 Zoffix Znet

Copyright 2019 - 2022 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

