" ingo/plugin/rendered.vim: Functions to interactively work with rendered items.
"
" DEPENDENCIES:
"   - ingo/avoidprompt.vim autoload script
"   - ingo/query.vim autoload script
"   - ingo/subs/BraceCreation.vim autoload script
"   - ingo/plugin/rendered/*.vim autoload scripts
"
" Copyright: (C) 2018-2021 Ingo Karkat
"   The VIM LICENSE applies to this script; see ':help copyright'.
"
" Maintainer:	Ingo Karkat <ingo@karkat.de>
let s:save_cpo = &cpo
set cpo&vim

function! ingo#plugin#rendered#List( what, renderer, additionalOptions, items )
"******************************************************************************
"* PURPOSE:
"   Allow interactive reordering, filtering, and eventual rendering of List
"   a:items (and potentially more a:additionalOptions).
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Text describing what each element in a:items represents (e.g.
"           "matches").
"   a:renderer  Object that implements the rendering of the a:items.
"		Can supply additional rendering options presented to the user,
"		via a List returned from a:renderer.options(). If such an option
"		is chosen, a:renderer.handleOption(command) is invoked. Finally,
"		a:renderer.render(items) is used to render the List.
"		This library ships with some default renderers that can be
"		copy()ed and passed; see below.
"   a:additionalOptions List of additional options presented to the user. Can
"                       include "&" accelerators; these will be dropped in the
"                       command passed to a:renderer.handleOption().
"   a:items     List of items to be renderer.
"* RETURN VALUES:
"   List of [command, renderedItems]. The command contains "Quit" if the user
"   chose to cancel. If an additional option was chosen, command contains the
"   option (without "&" accelerators), and renderedItems the (so far unrendered,
"   but potentially filtered) List of a:items. If an ordering was chosen,
"   command is empty and renderedItems contains the result.
"******************************************************************************
    let l:items = a:items
    let l:processOptions = a:additionalOptions + ['&Confirm each', '&Subset', '&Quit']
    let l:additionalChoices = map(copy(a:additionalOptions), 'ingo#query#StripAccellerator(v:val)')

    let l:save_guioptions = &guioptions
    set guioptions+=c
    try
	while 1
	    redraw
	    let l:orderingOptions = []
	    let l:orderingToItems = {}
	    let l:orderingToString = {}
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, '&Original',   a:renderer, l:items, l:items)
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, 'Re&versed',   a:renderer, l:items, reverse(copy(l:items)))
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, '&Ascending',  a:renderer, l:items, sort(copy(l:items)))
	    call s:AddOrdering(l:orderingOptions, l:orderingToItems, l:orderingToString, '&Descending', a:renderer, l:items, reverse(sort(copy(l:items))))

	    let l:orderingMessage = printf('Choose ordering for %d %s: ', len(l:items), a:what)

	    let l:rendererOptions = a:renderer.options()
	    let l:renderChoices = map(copy(l:rendererOptions), 'ingo#query#StripAccellerator(v:val)')
	    let l:ordering = ingo#query#ConfirmAsText(l:orderingMessage, l:orderingOptions + l:rendererOptions + l:processOptions, 1)
	    if empty(l:ordering) || l:ordering ==# 'Quit'
		return ['Quit', '']
	    elseif l:ordering ==# 'Confirm each' || l:ordering == 'Subset'
		if v:version < 702 | runtime autoload/ingo/plugin/rendered/*.vim | endif  " The Funcref doesn't trigger the autoload in older Vim versions.
		let l:ProcessingFuncref = function('ingo#plugin#rendered#' . substitute(l:ordering, '\s', '', 'g') . '#Filter')
		let l:items = call(l:ProcessingFuncref, [l:items])
	    elseif index(l:renderChoices, l:ordering) != -1
		call a:renderer.handleOption(l:ordering)
	    elseif index(l:additionalChoices, l:ordering) != -1
		return [l:ordering, l:items]
	    else
		break
	    endif
	endwhile
    finally
	let &guioptions = l:save_guioptions
    endtry

    return ['', l:orderingToString[l:ordering]]
endfunction
function! s:AddOrdering( orderingOptions, orderingToItems, orderingToString, option, renderer, items, reorderedItems )
    if a:reorderedItems isnot# a:items && a:reorderedItems ==# a:items ||
    \   index(values(a:orderingToItems), a:reorderedItems) != -1
	return
    endif

    let l:option = substitute(a:option, '&', '', 'g')
    let l:string = call(a:renderer.render, [a:reorderedItems])

    if index(values(a:orderingToString), l:string) != -1
	" Different ordering yields same rendered string; skip.
	return
    endif

    call add(a:orderingOptions, a:option)
    let a:orderingToItems[l:option] = a:reorderedItems
    let a:orderingToString[l:option] = l:string

    call ingo#avoidprompt#EchoAsSingleLine(printf("%s:\t%s", l:option, l:string))
endfunction



"******************************************************************************
"* PURPOSE:
"   Renderer that joins the items on a self.separator, and optionally wraps the
"   result in self.prefix and self.suffix.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"******************************************************************************
let g:ingo#plugin#rendered#JoinRenderer = {
\   'prefix': '',
\   'separator': '',
\   'suffix': '',
\}
function! g:ingo#plugin#rendered#JoinRenderer.options() dict
    return []
endfunction
function! g:ingo#plugin#rendered#JoinRenderer.render( items ) dict
    return self.prefix . join(a:items, self.separator) . self.suffix
endfunction
function! g:ingo#plugin#rendered#JoinRenderer.handleOption( command ) dict
endfunction

"******************************************************************************
"* PURPOSE:
"   Renderer that extracts common substrings and turns these into a Brace
"   Expression, like in Bash. The algorithm's parameters can be tweaked by the
"   user. These tweaks override any defaults in self.braceOptions, which is the
"   configuration passed to ingo#subs#BraceCreation#FromList().
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"******************************************************************************
let g:ingo#plugin#rendered#BraceExpressionRenderer = {
\   'commonLengthOffset': 0,
\   'differingLengthOffset': 0,
\   'braceOptions': {}
\}
function! g:ingo#plugin#rendered#BraceExpressionRenderer.options() dict
    let l:options = ['Longer co&mmon', 'Shor&ter common', 'Longer disti&nct', 'Sho&rter distinct']
    if ! get(self.braceOptions, 'strict', 0) | call add(l:options, '&Strict') | endif
    if ! get(self.braceOptions, 'short', 0)  | call add(l:options, 'S&hort')  | endif
    if has_key(self.braceOptions, 'isIgnoreCase')
	call add(l:options, (self.braceOptions.isIgnoreCase ? 'no ' : '') . '&ignore-case')
    elseif get(self.braceOptions, 'short', 0)
	call add(l:options, 'no &ignore-case')
    else
	call add(l:options, '&ignore-case')
    endif
    return l:options
endfunction
function! g:ingo#plugin#rendered#BraceExpressionRenderer.render( items ) dict
    let l:braceOptions = copy(self.braceOptions)
    let l:braceOptions.minimumCommonLength    = max([1, get(self.braceOptions, 'minimumCommonLength', 1) + self.commonLengthOffset])
    let l:braceOptions.minimumDifferingLength = max([0, get(self.braceOptions, 'minimumDifferingLength', 0) + self.differingLengthOffset])

    return ingo#subs#BraceCreation#FromList(a:items, l:braceOptions)
endfunction
function! g:ingo#plugin#rendered#BraceExpressionRenderer.handleOption( command ) dict
    if a:command ==# 'Strict'
	let self.braceOptions.strict = 1
	let self.braceOptions.short = 0
    elseif a:command ==# 'Short'
	let self.braceOptions.short = 1
	let self.braceOptions.strict = 0
    elseif a:command ==# 'no ignore-case'
	let self.braceOptions.isIgnoreCase = 0
    elseif a:command ==# 'ignore-case'
	let self.braceOptions.isIgnoreCase = 1
    elseif a:command ==# 'Longer common'
	let self.commonLengthOffset += 1
    elseif a:command ==# 'Shorter common'
	let self.commonLengthOffset -= 1
    elseif a:command ==# 'Longer distinct'
	let self.differingLengthOffset += 1
    elseif a:command ==# 'Shorter distinct'
	let self.differingLengthOffset -= 1
    else
	throw 'ASSERT: Invalid render command: ' . string(a:command)
    endif
endfunction



function! ingo#plugin#rendered#ListJoinedOrBraceExpression( what, braceOptions, additionalOptions, items )
"******************************************************************************
"* PURPOSE:
"   Allow interactive reordering, filtering, and eventual rendering of List
"   a:items (and potentially more a:additionalOptions) either as a joined String
"   or as a Bash-like Brace Expression. The separator (and optional prefix /
"   suffix) is queried first, and can be changed during the interaction. Also,
"   there's the option to yank the result to a register.
"* ASSUMPTIONS / PRECONDITIONS:
"   None.
"* EFFECTS / POSTCONDITIONS:
"   None.
"* INPUTS:
"   a:what  Text describing what each element in a:items represents (e.g.
"           "matches").
"   a:braceOptions  Dictionary of parameters for the Brace Expression creation;
"                   cp. ingo#subs#BraceCreation#FromList().
"   a:additionalOptions List of additional options presented to the user. Can
"                       include "&" accelerators; these will be dropped in the
"                       command passed to a:renderer.handleOption().
"   a:items     List of items to be renderer.
"* RETURN VALUES:
"   List of [command, renderedItems]. The command contains "Quit" if the user
"   chose to cancel, and "Yank" if the result was yanked to a register. If an
"   additional option was chosen, command contains the option (without "&"
"   accelerators), and renderedItems the (so far unrendered, but potentially
"   filtered) List of a:items. If an ordering was chosen, command is empty and
"   renderedItems contains the result.
"******************************************************************************
    echohl Question
	let l:separator = input('Enter separator string (or prefix^Mseparator^Msuffix); empty for creation of Brace Expression: ')
    echohl None
    if empty(l:separator)
	let l:renderer = copy(g:ingo#plugin#rendered#BraceExpressionRenderer)
	let l:renderer.braceOptions = a:braceOptions
    else
	let l:renderer = copy(g:ingo#plugin#rendered#JoinRenderer)
	let l:renderer.separator = l:separator
	if l:renderer.separator =~# '^\%(\r\@!.\)*\r\%(\r\@!.\)*\r\%(\r\@!.\)*$'
	    let [l:renderer.prefix, l:renderer.separator, l:renderer.suffix] = split(l:renderer.separator, '\r', 1)
	endif
    endif


    let [l:command, l:result] = ingo#plugin#rendered#List(a:what, l:renderer, ['Change se&parator', '&Yank'] + a:additionalOptions, a:items)
    if l:command ==# 'Quit'
	return [l:command, '']
    elseif l:command ==# 'Yank'
	call ingo#msg#HighlightMsg('Register ([a-zA-Z0-9"*+] <Enter> for default): ', 'Question')
	let l:register = ingo#query#get#Char({'validExpr': '[a-zA-Z0-9"*+\r]'})
	if empty(l:register) | continue | endif
	let l:register = (l:register ==# "\<C-m>" ? '' : l:register)
	let [l:command, l:result] = ingo#plugin#rendered#List('yanked ' . a:what, l:renderer, [], l:result)
	if empty(l:command)
	    call setreg(l:register, l:result)
	endif
	return ['Yank', l:result]
    elseif l:command ==# 'Change separator'
	return ingo#plugin#rendered#ListJoinedOrBraceExpression(a:what, a:braceOptions, a:additionalOptions, a:items)
    elseif empty(l:command)
	return ['', l:result]
    else
	throw 'ASSERT: Invalid command: ' . string(l:command)
    endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
" vim: set ts=8 sts=4 sw=4 noexpandtab ff=unix fdm=syntax :
