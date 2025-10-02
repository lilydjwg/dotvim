# diffchar.vim
*Highlight the exact differences, based on characters and words*
```
 ____   _  ____  ____  _____  _   _  _____  ____   
|    | | ||    ||    ||     || | | ||  _  ||  _ |  
|  _  || ||  __||  __||     || | | || | | || | ||  
| | | || || |__ | |__ |   __|| |_| || |_| || |_||_ 
| |_| || ||  __||  __||  |   |     ||     ||  __  |
|     || || |   | |   |  |__ |  _  ||  _  || |  | |
|____| |_||_|   |_|   |_____||_| |_||_| |_||_|  |_|
```

This plugin has been developed in order to make diff mode more useful. Vim
highlights all the text in between the first and last different characters on
a changed line. But this plugin will find the exact differences between them,
character by character - so called *DiffChar*.

For example, in diff mode:
![example1](example1.png)

This plugin will exactly show the changed/added/deleted units:
![example2](example2.png)

#### Sync with diff mode
This plugin will synchronously show/reset the highlights of the exact
differences as soon as the diff mode begins/ends. And the exact differences
will be kept updated while editing. Note that this plugin does nothing if an
`inline` item is set in the `doffopt` option and its value is other than
`simple`. On plugin loading, the item is removed only if set by default so
that this plugin can work.

#### Diff unit
This plugin shows the diffs based on a `g:DiffUnit`. Its default is 'Word1'
and it handles a `\w\+` word and a `\W` character as a diff unit. There are other
types of word provided and you can also set 'Char' to compare character by
character. In addition, you can specify one or more diff unit delimiters, such
as comma (','), colon (':'), tab ("\t"), and HTML tag symbols ('<' and '>'),
and also specify a custom pattern in the `g:DiffUnit`.

#### Diff matching colors
In diff mode, the corresponding `hl-DiffChange` lines are compared between two
windows. As a default, all the changed units are highlighted with
`hl-DiffText`. You can set `g:DiffColors` to use more than one matching color
to make it easy to find the corresponding units between two windows. The
number of colors depends on the color scheme. In addition, an added unit is
always highlighted with `hl-DiffAdd` and the position of the corresponding
deleted unit is shown with bold/underline or a virtual blank column,
depending on a `g:DiffDelPosVisible`.

#### Diff pair visible
While showing the exact differences, when the cursor is moved on a diff unit,
you can see its corresponding unit highlighted with `hl-Cursor`,
`hl-TermCursor`, or similar one in another window, based on a
`g:DiffPairVisible`. If you change its default, the corresponding unit is
echoed in the command line or displayed in a popup/floating window just below
the cursor position or at the mouse position. Those options take effect on
`:diffupdate` command as well.

#### Jump to next/prev diff unit
You can use `]b` or `]e` to jump cursor to start or end position of the next
diff unit, and `[b` or `[e` to the start or end position of the previous unit.

#### Get/put a diff unit
Like line-based `:diffget`/`:diffput` and `do`/`dp` vim commands, you can use
`<Leader>g` and `<Leader>p` commands in normal mode to get and put each diff
unit, where the cursor is on, between 2 buffers and undo its difference. Those
keymaps are configurable in your vimrc and so on.

#### Check diff lines locally
When the diff mode begins, this plugin locally checks the `hl-DiffChange`
lines in the limited range of the current visible and its upper/lower lines of
a window. And each time a cursor is moved on to another range upon scrolling
or searching, those diff lines will be checked in that range. Which means,
independently of the file size, the number of lines to be checked and then the
time consumed are always constant.

#### Tab page individual
This plugin works on each tab page individually. You can use a tab page
variable (t:), instead of a global one (g:), to specify different options on
each tab page. Note that this plugin can not handle more than two diff mode
windows in a tab page. If it would happen, to prevent any trouble, all the
highlighted units are to be reset in the tab page.

#### Follow 'diffopt' option
This plugin supports `icase`, `iwhite`, `iwhiteall`, and `iwhiteeol` in the
`diffopt` option. In addition, when `indent-heuristic` is specified,
positioning of the added/deleted diff units is adjusted to reduce the number
of diff hunks and make them easier to read.

#### Comparison algorithm
To find the exact differences, this plugin uses "An O(NP) Sequence Comparison
Algorithm" developed by S.Wu, et al., which always finds an optimum sequence.
But it takes time to check a long and dissimilar line. To improve the
performance, the algorithm is also implemented in Vim9 script. In addition,
if available, this plugin uses a builtin diff function (`diff()` in vim
patch-9.1.0071 and Lua `vim.diff()` in nvim 0.6.0) and makes it much faster.

#### See also
There are other diff related plugins available:
* [spotdiff.vim](https://github.com/rickhowe/spotdiff.vim): A range and area selectable `:diffthis` to compare partially
* [wrapfiller](https://github.com/rickhowe/wrapfiller): Align each wrapped line virtually between windows
* [difffilter](https://github.com/rickhowe/difffilter): Selectively compare lines as you want in diff mode
* [diffunitsyntax](https://github.com/rickhowe/diffunitsyntax): Highlight word or character based diff units in diff format

### Options

* `g:DiffUnit`, `t:DiffUnit`: A type of difference unit

  | Value | Description |
  | --- | --- |
  | 'Char' | any single character |
  | 'Word1' | `\w\+` word and any `\W` single character (default) |
  | 'Word2' | non-space and space words |
  | 'Word3' | `\<` or `\>` character class boundaries (set by `iskeyword`) |
  | 'word' | see `word` |
  | 'WORD' | see `WORD` |
  | '[{del}]' | one or more diff unit delimiters (e.g. "[,:\t<>]") |
  | '/{pat}/' | a pattern to split into diff units (e.g. '/.\{4}\zs/') |

* `g:DiffColors`, `t:DiffColors`: Matching colors for changed units

  | Value | Description |
  | --- | --- |
  | 0 | `hl-DiffText` (default) |
  | 1 | `hl-DiffText` + a few (3, 4, ...) highlight groups |
  | 2 | `hl-DiffText` + several (7, 8, ...) highlight groups |
  | 3 | `hl-DiffText` + many (11, 12, ...) highlight groups |
  | 100 | all available highlight groups in random order |
  | [{hlg}] | a list of your favorite highlight groups |

* `g:DiffPairVisible`, `t:DiffPairVisible`: Visibility of corresponding diff units

  | Value | Description |
  | --- | --- |
  | 0 | disable |
  | 1 | highlight with `hl-Cursor` (default) |
  | 2 | highlight with `hl-Cursor` + echo in the command line |
  | 3 | highlight with `hl-Cursor` + popup/floating window at cursor position |
  | 4 | highlight with `hl-Cursor` + popup/floating window at mouse position |

* `g:DiffDelPosVisible`, `t:DiffDelPosVisible`: Visibility of the position of deleted units

  | Value | Description |
  | --- | --- |
  | 0 | disable |
  | 1 | highlight previous/next chars of a deleted unit in bold/underline (default if inline "virtual-text" is not available) |
  | 2 | virtually show a blank column (set by `space` item in `listchars`) wih `hl-DiffDelete` (default if inline "virtual-text" is available) |

### Keymaps

| Mapping | Default Key | Description |
| --- | --- | --- |
| `<Plug>JumpDiffCharPrevStart` | `[b` | Jump cursor to the start position of the previous diff unit |
| `<Plug>JumpDiffCharNextStart` | `]b` | Jump cursor to the start position of the next diff unit |
| `<Plug>JumpDiffCharPrevEnd` | `[e` | Jump cursor to the end position of the previous diff unit |
| `<Plug>JumpDiffCharNextEnd` | `]e` | Jump cursor to the end position of the next diff unit |
| `<Plug>GetDiffCharPair` | `<Leader>g` | Get a corresponding diff unit from another buffer to undo difference |
| `<Plug>PutDiffCharPair` | `<Leader>p` | Put a corresponding diff unit to another buffer to undo difference |
