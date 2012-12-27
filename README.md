# Rdio CLI

A simple command line interface for [Rdio][].

## Installation

```
gem install rdio-cli
```

## Usage

Rdio CLI is powered by [GLI][] and has a Git-like (sub)command interface:

```bash
$ rdio current
Now playing: All The Roadrunning / Mark Knopfler And Emmylou Harris / Real Live Roadrunning
```

```bash
$ rdio current "♫ %{track} ♫"
♫ All The Roadrunning ♫
```

### Full usage help

```
$ rdio help
NAME
    rdio - Simple CLI for Rdio

SYNOPSIS
    rdio [global options] command [command options] [arguments...]

VERSION
    0.0.1

GLOBAL OPTIONS
    --access_secret=arg   - (default: )
    --access_token=arg    - (default: )
    --consumer_key=arg    - (default: )
    --consumer_secret=arg - (default: )
    --help                - Show this message
    --version             -

COMMANDS
    authorize, auth - Authorize Rdio account
    browse          - Open the current track in Rdio player
    current         - Display the current track info
    help            - Shows a list of commands or help for one command
    initconfig      - Initialize the config file using current global options
    link            - Get a shareable link for the current track
    mute            - Mute the Rdio player
    next            - Skip to next track
    pause           - Pause the player
    play            - Plays the current track
    previous, prev  - Play previous track
    quit, q         - Quit Rdio
    snag            - Add the current track or album to your collection
    toggle          - Toggle playback
    user            - Show the current Rdio user
    version, v      - Get CLI and application version info
    volume, vol     - Set volume for player
```

## TODO
* `[✓]` <del>Snag current track to collection</del>
* `[ ]` Snag current album to collection
* `[ ]` Create a playlist
* `[ ]` Follow a user
* `[ ]` Tail a user?

## Credits

* Uses Rdio's [rdio-simple][] library for API access.
* Inspired by [Drew Stokes][]'s [Node version][node-rdio].

## Copyright
Copyright (c) 2012 Wynn Netherland. See [LICENSE][] for details.

[rdio]: http://rdio.com
[LICENSE]: https://github.com/pengwynn/rdio-cli/blob/master/LICENSE.md
[rdio-simple]: https://github.com/rdio/rdio-simple
[Drew Stokes]: https://github.com/dstokes
[node-rdio]: https://github.com/dstokes/rdio-cli
[GLI]: https://github.com/davetron5000/gli
