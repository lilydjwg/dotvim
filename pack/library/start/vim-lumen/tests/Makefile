all: tests
tests: tests_vim tests_neovim
tests_vim:
	PATH=./:${PATH} vim -f --not-a-term -u vimrc -S run_test.vim test_general.vim || ( cat *.failed.log && false )
tests_neovim:
	PATH=./:${PATH} nvim -u vimrc -S run_test.vim test_general.vim || ( cat *.failed.log && false )
