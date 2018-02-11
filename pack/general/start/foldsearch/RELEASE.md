# Create a release

  1. Update Changelog in `README.md`
  2. Convert `README.md` to help file: `html2vimdoc -f foldsearch README.md >doc/foldsearch.txt`
  3. Commit current version: `hg commit -m 'prepare release vX.Y.Z'`
  4. Tag version: `hg tag vX.Y.Z -m 'tag release vX.Y.Z'`
  5. Push release to [Bitbucket] and [GitHub]:
    - `hg push ssh://hg@bitbucket.org/embear/foldsearch`
    - `hg push git+ssh://git@github.com:embear/vim-foldsearch.git`
  6. Create a Vimball archive: `hg locate | vim -C -c '%MkVimball! foldsearch .' -c 'q!' -`
  7. Update [VIM online]

[Bitbucket]: https://bitbucket.org/embear/foldsearch
[GitHub]: https://github.com/embear/vim-foldsearch
[VIM online]: http://www.vim.org/scripts/script.php?script_id=2302
