# vim-mcfunction
A powerful syntax highlighter for mcfunction (the format for Minecraft datapack functions) in vim.
Instead of simply highlighting a few keywords, it aims to tell you exactly how the game will interpret the commands in order to greatly reduce development time.

![vim-mcfuncion sample](https://github.com/rubixninja314/vim-mcfunction/wiki/vim-mcfunction2.png)

## Installation

To install using [vim-plug](https://github.com/junegunn/vim-plug), add
```
call plug#begin('~/.vim/plugged')

Plug 'rubixninja314/vim-mcfunction'

call plug#end()
```
to your .vimrc

This plugin has a handful of settings to tweak how it works, including the ability to change the version of Minecraft that it highlights for.
You can check out these setting in the [wiki](https://github.com/rubixninja314/vim-mcfunction/wiki/Configuration).

## Final Notes / Warnings

As of right now, sounds (used by `/playsound` and `/stopsound`) and recipes (used by `/recipe`) are not fully implemented.
Specifically, some sounds that were not available in older snapshots may still highlight as a false-positive, and only the recipes that happen to share a name with an item will highlight.
The multiplayer commands may or may not work. To my knowledge they highlight correctly, but I am not sure if they'll actually run.

If you notice any discrepancies, please feel free to submit an issue.

There may be some features that are not fully implemented, as of this point the main goal with this project is to begin keeping it up to date with current Minecraft versions.
