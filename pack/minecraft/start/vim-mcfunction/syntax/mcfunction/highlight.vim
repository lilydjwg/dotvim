hi def link mcError             Error
hi def link mcChatMessage       String
hi def link mcComment           Comment

hi def mcCommand            ctermfg=white ctermbg=Darkgrey        cterm=bold
hi def mcOp                 ctermfg=grey
hi def mcSelector           ctermfg=lightgreen           cterm=bold

hi def mcCoordinate         ctermfg=green
hi def mcCoordinate2        ctermfg=green             cterm=bold
hi def mcCoordinate3        ctermfg=green

hi def mcKeyword                                    cterm=bold
hi def mcValue              ctermfg=lightblue
hi def mcKeyId              ctermfg=yellow      cterm=bold
hi def mcId                 ctermfg=yellow

hi def mcNBTBracket         ctermfg=grey            cterm=underline guisp=blue
hi def mcNBTPath            ctermfg=white           cterm=underline guisp=blue
hi def mcNBTPathDot         ctermfg=grey            cterm=underline guisp=blue
hi def mcNBTValue           ctermfg=lightblue       cterm=underline guisp=blue
hi def mcNBTSpace                                   cterm=underline guisp=blue

if (exists('g:mcJSONMethod') && g:mcJSONMethod =~ '\v\c<%(n%[one]|p%[lugin])>')
        hi mcJSONText cterm=underline guisp=green
endif

" Other settings you may want to change:
" You cannot set items and block differently as there are many that are
" shared, (eg 'dirt' is both a block and an item). Might come later 
" but not for now.

"Items/Blocks not in vanilla MC eg 'ghead', 'lucky_block'
"hi def mcBlock

"Items/Blocks in vanilla MC eg 'apple', 'fire', 'cracked_polished_blackstone_bricks'
"(pls mojang we need infested_cracked_polished_blackstone_brick_slab)
"hi def mcBuiltinBlock

"Entities not in vanilla MC eg 'unicorn', 'bullet'
"hi def mcEntity

"Entities in vanilla MC eg 'wither', 'zombified_piglin'
"hi def mcBuiltinEntity      ctermfg=

"Boolean values
"hi def mcBool

" Top level execute keywords
"execute as @a positioned as @s store entity @s Health byte 1 run kill @s
"        ^^    ^^^^^^^^^^       ^^^^^                         ^^^
hi def mcExecuteKeyword ctermfg=white cterm=bold,italic


" @e[type=zombie]   grass_block[snowy=true]
"    ^^^^                       ^^^^^
"hi def mcFilterKeyword

"Tags
"hi def mcTag


" @e[type=zombie]   grass_block[snowy=true]
"         ^^^^^^                      ^^^^
"hi def mcFilterValue
