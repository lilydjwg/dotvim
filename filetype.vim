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
  au BufRead		*access[._]log*			setf httplog
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
  au BufRead		*/itsalltext/lilydjwg.is-programmer.com*	setf html
  au BufRead		lilydjwg.is-programmer.com_edit*		setf html
  au BufRead		forum.ubuntu.org.cn_*	 	setf bbcode
  au BufRead		*/itsalltext/*forum*		setf bbcode
  au BufRead		*/itsalltext/easwy.com.*	setf bbcode
  au BufRead		*/itsalltext/*mail*		setf mail
  au BufRead		*/itsalltext/groups.google*	setf mail
  au BufRead		*fck_source.html*		setf html
  au BufRead		*docs.google.com_Doc*		setf html
  au BufNewFile,BufRead	*.mw,*wpTextbox*.txt,*wiki__text*.txt		setf wiki
  au BufNewFile,BufRead	*postmore/wiki/*.wiki		setf googlecodewiki
  au BufNewFile,BufRead	*.wiki				setf vimwiki
  au BufNewFile,BufRead $HOME/.vim/dict/*.txt,$VIM/vimfiles/dict/*.txt	setf dict
  au BufNewFile,BufRead /lib/udev/rules.d/*		setf udevrules
  au BufNewFile,BufRead fcitx_skin.conf,*fcitx*/config,*/fcitx/*.conf,*/fcitx/profile	setf desktop
  au BufNewFile,BufRead mimeapps.list			setf desktop
  au BufRead		*tmux.conf			setf tmux
  au BufRead		rc.conf				setf sh
  au BufRead		*.grf				setf dosini
  au BufNewFile,BufRead	PKGBUILD			setf sh
  au BufNewFile,BufRead	*.install,install		setf sh
  au BufNewFile,BufRead	ejabberd.cfg*			setf erlang
  au BufNewFile,BufRead	*/xorg.conf.d/*			setf xf86conf
  au BufNewFile,BufRead	*fluxbox/keys			setf fluxkeys
  au BufNewFile,BufRead	*fluxbox/menu			setf fluxbox
  au BufNewFile,BufRead hg-editor-*.txt			setf hgcommit
  au BufNewFile,BufRead *openvpn*/*.conf,*.ovpn		setf openvpn
  au BufNewFile,BufRead	*.pxi   			setf pyrex
  au BufRead		$HOME/.cabal/config		setf cabal
augroup END
