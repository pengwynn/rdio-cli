# Rdio CLI

A simple command line interface for [Rdio][]. Requires the desktop app to be
installed since playback controls talk to the app via AppleScript.

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

### Lyrics

Plain text, terminal-friendly lyrics are served up via [makeitpersonal.co][]:

```
~ rdio current
Now playing: That Old Time Feeling / Rodney Crowell / This One's for Him: A Tribute to Guy Clark

~ rdio lyrics
Sorry, We don't have lyrics for this song yet.

~ rdio lyrics --artist="Guy Clark"

And that old time feeling goes sneakin' down the hall
Like an old gray cat in winter, keepin' close to the wall
And that old time feeling comes stumblin' up the street
Like an old salesman kickin' the papers from his feet

And that old time feeling draws circles around the block
Like old women with no children, holdin' hands with the clock
And that old time feeling falls on its face in the park
Like an old wino prayin' he can make it till it's dark

And that old time feeling comes and goes in the rain
Like an old man with his checkers, dyin' to find a game
And that old time feeling plays for beer in bars
Like an old blues-time picker who don't recall who you are

And that old time feeling limps through the night on a crutch
Like an old soldier wonderin' if he's paid too much
And that old time feeling rocks and spits and cries
Like an old lover rememberin' the girl with the clear blue eyes

And that old time feeling goes sneakin' down the hall
Like an old gray cat in winter, keepin' close to the wall

```

### Shows

Upcoming events are served via [last.fm/api][]

```
~ rdio current
Now playing: That Old Time Feeling / Rodney Crowell / This One's for Him: A Tribute to Guy Clark

~ rdio shows
Here are 10 upcoming events for Rodney Crowell
Toronto             Canada          Fri, 22 Mar 2013 20:00:00 
North Bethesda, MD  United States   Fri, 29 Mar 2013 19:30:00 
London              United Kingdom  Thu, 09 May 2013 20:00:00 
Birmingham          United Kingdom  Fri, 10 May 2013 16:16:01 
Belfast             Ireland         Sun, 12 May 2013 19:30:00 
Dublin              Ireland         Mon, 13 May 2013 20:00:00 
Brussels            Belgium         Mon, 20 May 2013 13:20:01 
Paris               France          Wed, 22 May 2013 20:00:00 
København C         Denmark         Sun, 26 May 2013 20:00:00 
Berlin              Germany         Thu, 30 May 2013 00:38:01

~ rdio shows --artist="Johnny Cash"
No upcoming events for Johnny Cash
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
    lyrics          - Show lyrics for a track
    mute            - Mute the Rdio player
    next            - Skip to next track
    pause           - Pause the player
    play            - Plays the current track
    previous, prev  - Play previous track
    quit, q         - Quit Rdio
    shows           - Show upcoming events for an artist
    snag            - Add the current track or album to your collection
    toggle          - Toggle playback
    user            - Show the current Rdio user
    version, v      - Get CLI and application version info
    volume, vol     - Set volume for player
```

## TODO
* `[✓]` <del>Snag current track to collection</del>
* `[✓]` <del>Snag current album to collection</del>
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
[makeitpersonal.co]: http://makeitpersonal.co
[last.fm/api]: http://www.last.fm/api
