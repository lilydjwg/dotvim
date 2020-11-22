# i3config.vim - vim i3 config syntax highlighting

This file contains the syntax highlighting that I use for i3 config in Vim.
Compared to the vim standard *conf* syntax highlighting, i3config
adds highlighting of all keywords,
types and options as defined in the i3 configuration manual.

I built this based on the current specification
provided (as of Sat 12 Mar 2016) in:

<http://i3wm.org/docs/userguide.html#configuring>

![](i3config.vim.gif)

*using vim color scheme [dracula](https://github.com/dracula/vim)*

*using Powerline font [ProFont for Powerline](https://github.com/powerline/fonts/blob/master/ProFont/README.rst)*

## Features

i3config does what a syntax highlighting would do and additionally
provides some sort of syntax checking. If you end up with *Bold Red*
lines in your i3 config file this would mean that your syntax is wrong
or there is an issue in the plugin.
If that is the case please report the issue and/or
make a pull request to cover the case.

### File type detection

There is no specific extension for i3 config file.
For auto detection, the recommended method is to rename your file to something like:

+ .i3.config
+ i3.config
+ something.i3config
+ something.i3.config

> This way you can keep your file clean somewhere in a
dotfile repository and have it symlinked to ~/.i3/config

If you don't want to, then you can always do:

```vim
:set ft=i3config
```

or

```vim
:set filetype=i3config
```

or you can add this line your .vimrc file

```vim
aug i3config_ft_detection
  au!
  au BufNewFile,BufRead ~/.config/i3/config set filetype=i3config
aug end
```
Additonally, you an add `# vim: filetype=i3config` anywhere in your config file, as suggested by the original plugin (see below).

## Installation instructions

Follow one of the steps below and reload vim afterwards.

### Vundle

Install using [Vundle](https://github.com/gmarik/Vundle.vim) by adding

```vim
Plugin 'mboughaba/i3config.vim'
```

to `.vimrc` and run `:PluginInstall`.

### vim-plug

Install using [vim-plug](https://github.com/junegunn/vim-plug). Similar than the installation for Vundle, just change `Plugin` to `Plug`:

Add

```vim
Plug 'mboughaba/i3config.vim'
```

to `.vimrc` and run `:PlugInstall`.

> I use Vundle myself, the two steps below may not be fully correct,
you need to change them to fit your needs.

### Git submodule + Pathogen

If you have [pathogen](https://github.com/tpope/vim-pathogen) installed,
and you prefer to use git submodules, run

```sh
cd ~/.vim
git submodule add https://github.com/mboughaba/i3config.vim.git bundle/syntax/
```

### Manual installation

If you don't have either Vundle or Pathogen installed, copy both i3config.vim file
to .vim/after/syntax and .vim/after/ftdetect respectively.

```sh
git clone https://github.com/mboughaba/i3config.git /tmp/i3config.vim
mkdir -p ~/.vim/after/syntax/
mv /tmp/i3config.vim/after/syntax/i3config.vim ~/.vim/after/syntax/i3config.vim
rm -rf /tmp/i3config.vim
```

## Inspired by

+ PotatoesMaster/i3-vim-syntax
  <https://github.com/PotatoesMaster/i3-vim-syntax>
+ vim-scripts/edifact.vim
  <https://github.com/vim-scripts/edifact.vim> (For Error highlighting).

### What about PotatoesMaster/i3-vim-syntax

*PotatoesMaster/i3-vim-syntax* was the one I used in the past.
But as the maintainer himself pointed out,
there are some issues and a rewrite is needed.

## Contribution

Feel free to make a pull request, I will integrate it when time permits.
Make sure to add a line to cover your test in the *test.i3config*.

## Background information

### Author

Mohamed Boughaba

Development is done at: <https://github.com/mboughaba/i3config.vim>

## License

MIT
