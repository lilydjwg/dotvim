" Test rendering listchar lead value.

call vimtest#SkipAndQuitIf(v:version < 802 || v:version == 802 && ! has('patch2454'), 'Need support for listchar lead setting')

set listchars=tab:>-,lead:^,space:-,trail:.,eol:$

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#option#listchars#Render('    some text    here    '), '----some-text----here----', 'space rendered')
call vimtap#Is(ingo#option#listchars#Render('    some text    here    ', {'isTextAtStart': 1}), '^^^^some-text----here----', 'lead and space rendered')
call vimtap#Is(ingo#option#listchars#Render('    some text    here    ', {'isTextAtStart': 1, 'isTextAtEnd': 1}), '^^^^some-text----here....$', 'lead, space, trail, and eol rendered')

call vimtest#Quit()
