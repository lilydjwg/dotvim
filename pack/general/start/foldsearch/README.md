# Foldsearch

This plugin provides commands that fold away lines that don't match a specific
search pattern. This pattern can be the word under the cursor, the last search
pattern, a regular expression or spelling errors. There are also commands to
change the context of the shown lines.

The plugin can be found on [Bitbucket], [GitHub] and [VIM online].

## Commands

### The `:Fw` command

Show lines which contain the word under the cursor.

The optional *context* option consists of one or two numbers:

  - A 'unsigned' number defines the context before and after the pattern.
  - If a number has a '-' prefix, it defines only the context before the pattern.
  - If it has a '+' prefix, it defines only the context after a pattern.

Default *context* is current context.

### The `:Fs` command

Show lines which contain previous search pattern.

For a description of the optional *context* please see |:Fw|

Default *context* is current context.

### The `:Fp` command

Show the lines that contain the given regular expression.

Please see |regular-expression| for patterns that are accepted.

### The `:FS` command

Show the lines that contain spelling errors.

### The `:Fl` command

Fold again with the last used pattern

### The `:Fc` command

Show or modify current *context* lines around matching pattern.

For a description of the optional *context* option please see |:Fw|

### The `:Fi` command

Increment *context* by one line.

### The `:Fd` command

Decrement *context* by one line.

### The `:Fe` command

Set modified fold options to their previous value and end foldsearch.

## Mappings

  - `Leader>fw` : `:Fw` with current context
  - `Leader>fs` : `:Fs` with current context
  - `Leader>fS` : `:FS`
  - `Leader>fl` : `:Fl`
  - `Leader>fi` : `:Fi`
  - `Leader>fd` : `:Fd`
  - `Leader>fe` : `:Fe`

Mappings can be disabled by setting |g:foldsearch_disable_mappings| to 1

## Settings

Use: `let g:option_name=option_value` to set them in your global vimrc.

### The `g:foldsearch_highlight` setting

Highlight the pattern used for folding.

  - Value `0`: Don't highlight pattern
  - Value `1`: Highlight pattern
  - Default: `0`

### The `g:foldsearch_disable_mappings` setting

Disable the mappings. Use this to define your own mappings or to use the
plugin via commands only.

  - Value `0`: Don't disable mappings (use mappings)
  - Value `1`: Disable Mappings
  - Default: `0`

## Contribute

To contact the author (Markus Braun), please send an email to <markus.braun@krawel.de>

If you think this plugin could be improved, fork on [Bitbucket] or [GitHub] and
send a pull request or just tell me your ideas.

## Credits

  - Karl Mowatt-Wilson for bug reports
  - John Appleseed for patches

## Changelog

v1.1.0 : 2014-12-15

  - use vim autoload feature to load functions on demand
  - better save/restore of modified options

v1.0.1 : 2013-03-20

  - added |g:foldsearch_disable_mappings| config variable

v1.0.0 : 2012-10-10

  - handle multiline regular expressions correctly

v2213 : 2008-07-26

  - fixed a bug in context handling

v2209 : 2008-07-17

  - initial version


[Bitbucket]: https://bitbucket.org/embear/foldsearch
[GitHub]: https://github.com/embear/vim-foldsearch
[VIM online]: http://www.vim.org/scripts/script.php?script_id=2302
