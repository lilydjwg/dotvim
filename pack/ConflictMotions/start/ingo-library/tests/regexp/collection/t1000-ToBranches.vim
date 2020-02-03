" Test conversion of a collection to branches.

call vimtest#StartTap()
call vimtap#Plan(7)

call vimtap#Is(ingo#regexp#collection#ToBranches(''), '', 'empty pattern')
call vimtap#Is(ingo#regexp#collection#ToBranches('^foo bar$'), '^foo bar$', 'no collection')
call vimtap#Is(ingo#regexp#collection#ToBranches('[abcAZ]'), '\%(a\|b\|c\|A\|Z\)', 'simple five-character collection')
call vimtap#Is(ingo#regexp#collection#ToBranches('My [xy] is \([yY]\?\|ey\)'), 'My \%(x\|y\) is \(\%(y\|Y\)\?\|ey\)', 'two simple collections')
call vimtap#Is(ingo#regexp#collection#ToBranches('[abc[:digit:]xyz[:space:][:lower:]]'), '\%(a\|b\|c\|[[:digit:]]\|x\|y\|z\|[[:space:]]\|[[:lower:]]\)', 'collection with multiple character classes')
call vimtap#Is(ingo#regexp#collection#ToBranches('[abcA-EU-Zxyz<->]'), '\%(a\|b\|c\|[A-E]\|[U-Z]\|x\|y\|z\|[<->]\)', 'collection with multiple ranges')
call vimtap#Is(ingo#regexp#collection#ToBranches('[^abc]'), '[^abc]', 'negative collection')

call vimtest#Quit()
