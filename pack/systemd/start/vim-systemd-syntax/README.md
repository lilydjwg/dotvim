# vim-systemd-syntax

syntax highlighting and filetype detection for systemd unit files!

## Features

* Highlights known unit file directives and recognizeable values!
* Marks errors due to invalid or misspelled options/values!
* Over 80 hours of playtime!

## Installation

You can install `wgwoods/vim-systemd-syntax` pretty easily with your favorite
Vim plugin manager. (If you don't have one already,
[vim-plug](https://github.com/junegunn/vim-plug) is nice and simple.)

This should probably work too:

    mkdir -p ~/.vim/plugin
    cd ~/.vim/plugin
    git clone https://github.com/wgwoods/vim-systemd-syntax

Or you can just drop the three `.vim` files in `~/.vim/syntax`,
`~/.vim/ftdetect`, and `/.vim/ftplugin` manually. I'm sure you'll figure it
out, you red-hot vim hacker you.

## TODO

* Add missing directives?
  (I haven't updated this since 2011. Pull requests welcome!)
* Generate syntax from `/usr/lib/systemd/systemd --dump-config`
  so it's always up-to-date
    * Heck why doesn't [systemd] do that as part of its build?
* Contribute script to [systemd] that generates `syntax/systemd.vim` for us
* Retire to a life of leisure

[systemd]: https://github.com/systemd/systemd/

## License

Distributed under the same terms as `vim` itself.
