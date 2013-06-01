syn include @HTML syntax/html.vim
syn match PinpointHTML  /<\/\{0,1}\a\+>/  contains=@HTML

unlet b:current_syntax

syn match PinpointComment /^#.*$/ 

syn region PinpointHead start=/\%^/ end=/..\(\n^-\+.*$\)\@=/ transparent keepend

syn match PinpointNewSlide /^-\+.*$/

syn region PinpointTag matchgroup=PinpointTagPars start=/\[/ end=/\]/ contained containedin=PinpointHead,PinpointNewSlide

hi link PinpointComment Comment
hi link PinpointBang Comment
hi link PinpointNewSlide Title
hi link PinpointTagPars Identifier
hi link PinpointTag Special

let b:current_syntax="pinpoint"
