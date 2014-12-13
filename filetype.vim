set nocompatible " openSUSE needs this because its /etc/vimrc calls syntax on too early
" More ignored extensions (modified from the standard one)
if exists("*fnameescape")
  au BufNewFile,BufRead ?\+.pacsave,?\+.pacnew
	\ exe "doau filetypedetect BufRead " . fnameescape(expand("<afile>:r"))
elseif &verbose > 0
  echomsg "Warning: some filetypes will not be recognized because this version of Vim does not have fnameescape()"
endif

augroup filetypedetect
  au BufNewFile,BufRead *.rj				setf rj
  au BufNewFile,BufRead *.jsm				setf javascript
  au BufNewFile,BufRead *.json				setf json
  au BufNewFile,BufRead *.lrc				setf lrc
  au BufNewFile,BufRead *.s,*.S				setf gas
  au BufNewFile,BufRead *.asm,*.ASM			setf masm
  au BufNewFile,BufRead *.asy				setf asy
  au BufNewFile,BufRead */python/pyexe/*		setf python
  au BufRead		*access[._]log*,*/nginx/*[._]log*	setf httplog
  au BufRead		*/.getmail/*rc			setf getmailrc
  au BufRead		.msmtprc			setf msmtp
  au BufNewFile,BufRead .htaccess.*			setf apache
  au BufRead		pacman.log			setf pacmanlog
  au BufRead		/var/log/*.log*			setf messages
  au BufNewFile,BufRead *.rfc				setf rfc
  au BufNewFile,BufRead *.aspx,*.ascx			setf html
  au BufNewFile,BufRead *.md				setf markdown
  au BufRead		grub.cfg			setf sh
  au BufRead		$HOME/temp/mb			setf mb
  au BufNewFile,BufRead	*.wiki				setf vimwiki
  au BufNewFile,BufRead $HOME/.vim/dict/*.txt,$VIM/vimfiles/dict/*.txt	setf dict
  au BufNewFile,BufRead fcitx_skin.conf,*/fcitx*.{conf,desc}*,*/fcitx/profile	setf dosini
  au BufNewFile,BufRead mimeapps.list			setf desktop
  au BufRead		*tmux.conf			setf tmux
  au BufRead		rc.conf				setf sh
  au BufRead		*.grf,*.url			setf dosini
  au BufRead		accels				setf lisp
  au BufNewFile,BufRead	PKGBUILD			setf sh
  au BufNewFile,BufRead	*.install,install,.INSTALL	setf sh
  au BufNewFile,BufRead	ejabberd.cfg*			setf erlang
  au BufNewFile,BufRead	*/xorg.conf.d/*			setf xf86conf
  au BufNewFile,BufRead	*fluxbox/keys			setf fluxkeys
  au BufNewFile,BufRead	*fluxbox/menu			setf fluxbox
  au BufNewFile,BufRead hg-editor-*.txt			setf hgcommit
  au BufNewFile,BufRead *openvpn*/*.conf,*.ovpn		setf openvpn
  au BufNewFile,BufRead	*.pxi				setf pyrex
  au BufRead		$HOME/.cabal/config		setf cabal
  au BufNewFile,BufRead *.stp				setf stap
  au BufNewFile,BufRead *.io				setf io
  au BufNewFile,BufRead supervisor*.conf                setf dosini
  au BufRead		*procmaillog			setf mail
  au BufNewFile,BufRead *.i				setf swig

  " Websites
  au BufRead		forum.ubuntu.org.cn_*,bbs.archlinuxcn.org_post.php*.txt		setf bbcode
  au BufRead		*fck_source.html*		setf html
  au BufRead		*docs.google.com_Doc*		setf html
  au BufNewFile,BufRead	*postmore/wiki/*.wiki		setf googlecodewiki
  au BufRead		lilydjwg.is-programmer.com_edit*		setf html
  au BufNewFile,BufRead	*.mw,*wpTextbox*.txt,*wiki__text*.txt		setf wiki
  au BufRead		/tmp/segmentfault.com_*-input*	setf markdown
augroup END
