# fluent.vim
Fluent Syntax Highlighting for vim/neovim

![Screenshot](https://github.com/projectfluent/fluent.vim/blob/master/images/screenshot.png?raw=true)

## Installation


### Using [Vundle][]

1. Add `Plugin 'projectfluent/fluent.vim'` to `~/.vimrc`
2. `:PluginInstall` or `$ vim +PluginInstall +qall`

*Note:* Vundle will not automatically detect Rust files properly if `filetype
on` is executed before Vundle. Please check the [quickstart][vqs] for more
details.

### Using [Pathogen][]

```shell
git clone --depth=1 https://github.com/projectfluent/fluent.vim.git ~/.vim/bundle/fluent.vim
```

### Using [NeoBundle][]

1. Add `NeoBundle 'projectfluent/fluent.vim'` to `~/.vimrc`
2. Re-open vim or execute `:source ~/.vimrc`

### Using [vim-plug][]

1. Add `Plug 'projectfluent/fluent.vim'` to `~/.vimrc`
2. `:PlugInstall` or `$ vim +PlugInstall +qall`


## Status

The syntax highlighting is very basic and fragile at the moment.
Feel free to take over and improve - we'll gladly accept patches.

## Learn more

Find out more about Project Fluent at [projectfluent.org][], including links to
implementations, and information about how to get involved.

[Fluent Syntax Guide]: http://projectfluent.org/fluent/guide
[projectfluent.org]: http://projectfluent.org
[Vundle]: https://github.com/gmarik/vundle
[vqs]: https://github.com/gmarik/vundle#quick-start
[Pathogen]: https://github.com/tpope/vim-pathogen
[NeoBundle]: https://github.com/Shougo/neobundle.vim
[vim-plug]: https://github.com/junegunn/vim-plug
