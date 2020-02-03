set omnifunc=
let b:disable_omnifunc=1

syn region markdownCode matchgroup=markdownCodeDelimiter start="^\~\~\~\~.*$" end="^\~\~\~\~$" keepend
