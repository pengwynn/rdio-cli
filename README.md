# Rdio CLI

A simple command line interface for [Rdio][].

## Installation

```
gem install rdio-cli
```

## Usage

```shell

$ rdio help

NAME
    rdio - Simple CLI for Rdio

SYNOPSIS
    rdio [global options] command [command options] [arguments...]

VERSION
    0.0.1

GLOBAL OPTIONS
    --access_secret=arg   - (default: none)
    --access_token=arg    - (default: none)
    --consumer_key=arg    - (default: none)
    --consumer_secret=arg - (default: none)
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
    toggle          - Toggle playback
    user            - Show the current Rdio user
    version, v      - Get CLI and application version info
    volume, vol     - Set volume for player
```

## TODO
* `[ ]` Snag current track to collection
* `[ ]` Create a playlist
* `[ ]` Follow a user
* `[ ]` Tail a user?

## Copyright
Copyright (c) 2012 Wynn Netherland. See [LICENSE][] for details.

[rdio]: http://rdio.com
[LICENSE]: https://github.com/pengwynn/rdio-cli/blob/master/LICENSE.md
