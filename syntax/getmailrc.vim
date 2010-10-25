" Vim syntax file
" Language:	getmailrc - configuration file for getmail version 4
" Maintainer:	Nikolai Nespor <nikolai.nespor@utanet.at>
" URL:		http://www.unet.univie.ac.at/~a9600989/vim/getmailrc.vim
" Last Change:	2005 02 22

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" string, ints and comments
syn match gmComment     /#.*$/
syn match gmInt         /\<\d\+\>/
syn region gmDbQuoteStr start=+"+ skip=+\\"+ end=+"+
syn region gmQuoteStr   start=+'+ skip=+\\'+ end=+'+

" booleans are case insensitive
syn case ignore
  syn keyword gmTrue 1 true yes on
  syn keyword gmFalse 0 false no off
syn case match

syn match gmParam       /^\s*\w\+\s*=/ contains=gmKeywd
syn match gmSection     /^\s*\[\(retriever\|destination\|options\)\]\s*$/
syn match gmFilterSec   /^\s*\[filter-\w\+\]\s*$/

syn keyword gmType type contained

" retriever section
"

" retriever type
syn match gmRetType /^\s*type\s*=\s*[a-zA-Z3]\+\s*$/ contains=gmRetTypes,gmType
syn keyword gmRetTypes BrokenUIDLPOP3Retriver contained 
syn keyword gmRetTypes SimplePOP3Retriever SimpleIMAPRetriever contained 
syn keyword gmRetTypes SimplePOP3SSLRetriever SimpleIMAPSSLRetriever contained 
syn keyword gmRetTypes MultidropPOP3Retriever MultidropPOP3SSLRetriever contained 
syn keyword gmRetTypes MultidropSPDSRetriever MultidropIMAPRetriever contained 
syn keyword gmRetTypes MultidropIMAPSSLRetriever contained 

" common retriever options
syn keyword gmKeywd password port server username contained 
" POP3
syn keyword gmKeywd use_apop contained 
" IMAP
syn keyword gmKeywd mailboxes move_on_delete contained 
" SSL
syn keyword gmKeywd certfile keyfile contained 
" multidrop
syn keyword gmKeywd envelope_recipient contained 
" timeout
syn keyword gmKeywd timeout contained 

" destination section
"

" destination type
syn match gmDestType /^\s*type\s*=\s*\(Maildir\|Mboxrd\|MDA_external\|MultiDestination\|MultiGuesser\|MultiSorter\|MDA_qmaillocal\)\s*$/ contains=gmDestTypes,gmType
syn keyword gmDestTypes Maildir Mboxrd MDA_external MultiDestination contained 
syn keyword gmDestTypes MultiGuesser MultiSorter MDA_qmaillocal contained 

" Maildir, Mboxrd and MDA_external common options
syn keyword gmKeywd path contained 
" MDA_external
syn keyword gmKeywd allow_root_commands arguments group contained 
syn keyword gmKeywd unixfrom user contained 
" MultiSorter
syn keyword gmKeywd default locals contained 
" MDA_qmaillocal plus allow_root_command, group and user from
" MDA_external
syn keyword gmKeywd conf-break defaultdelivery homedir contained 
syn keyword gmKeywd localdomain localpart_translate qmaillocal contained 
syn keyword gmKeywd strip_delivered_to contained 

" option section
"
syn keyword gmKeywd delete delete_after delivered_to contained 
syn keyword gmKeywd max_messages_per_session max_message_size contained 
syn keyword gmKeywd message_log message_log_syslog read_all received contained 
syn keyword gmKeywd verbose contained 

" filter section
"

" filter type
syn match gmFilterType /^\s*type\s*=\s*\(Filter_classifier\|Filter_external\|Filter_TMDA\)\s*$/ contains=gmFilterTypes,gmType
syn keyword gmFilterTypes Filter_classifier Filter_external Filter_TMDA contained

" filter options
syn keyword gmKeywd allow_root_commands arguments exitcodes_drop contained 
syn keyword gmKeywd exitcodes_keep group path unixfrom user contained 

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_getmail_syn_inits")
  if version < 508
    let did_getmail_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif
  HiLink gmComment      Comment
  HiLink gmInt          Identifier
  HiLink gmDbQuoteStr   String
  HiLink gmQuoteStr     String
  
  HiLink gmTrue         Identifier
  HiLink gmFalse        Constant
  
  HiLink gmParam        Normal
  HiLink gmSection      Statement
  HiLink gmFilterSec    Statement

  HiLink gmKeywd        Type
  HiLink gmType         Type

  HiLink gmRetTypes     PreProc
  HiLink gmDestTypes    PreProc
  HiLink gmFilterTypes  PreProc
  delcommand HiLink
endif

let b:current_syntax = "getmail"

" vim: ts=8
