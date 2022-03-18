" Test removing character classes and similar.

scriptencoding utf-8

call vimtest#StartTap()
call vimtap#Plan(11)

call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('foobar'), 'foobar', 'no character classes')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('\i\I\k\K\f\F\p\P\s\S\d\D\x\X\o\O\w\W\h\H\a\A\l\L\u\U'), '𝑖𝐼𝑘𝐾𝑓𝐹𝑝𝑃𝑠𝑆𝑑𝐷𝑥𝑋𝑜𝑂𝑤𝑊𝑕𝐻𝑎𝐴𝑙𝐿𝑢𝑈', 'all character classes')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('[^[:lower:]]oo[[:alpha:]]ar[[:space:][:xdigit:]]'), '𝐿oo𝑎ar…', 'collection classes')

call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('f\k\kbar'), 'f𝑘𝑘bar', 'a character class')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('fo[abcopq]!'), 'fo…!', 'simple collection')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('fo[[:alnum:]xyz][^a-z]!'), 'fo……!', 'multiple collections')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('fo\_[abcopq]!'), 'fo…!', 'collection including EOL')

call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('[[]foo[]]b[a]r[^!]'), '[foo]bar…', 'single-literal collections')

call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('foo\%[bar]quux'), 'foobarquux', 'optional sequence')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('r\%[[eo]ad]'), "r…ad", 'optional sequence with character class inside')
call vimtap#Is(ingo#regexp#deconstruct#TranslateCharacterClasses('index\%[[[]0[]]]'), 'index[0]', 'optional sequence with square brackets')

call vimtest#Quit()
