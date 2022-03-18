" Test estimation of matched characters in nested branches.

call vimtest#StartTap()
call vimtap#Plan(3)

call vimtap#Is(ingo#regexp#length#Project('a\|x\%(y\|uuu\|vv\)z'), [1, 5], 'nested branch in second branch')
call vimtap#Is(ingo#regexp#length#Project('\%(me\|you\|everyone\)\|x\%(y\|uuu\|vv\)z'), [2, 8], 'nested branch in both branches')
call vimtap#Is(ingo#regexp#length#Project('\%(me\|you\|everyone\)\|ga\%(y\|uuu\|\%(no\|nono\|nonnnnnno\)\)zzy'), [2, 14], 'nested branch in both branches, second doubly nested')

call vimtest#Quit()
