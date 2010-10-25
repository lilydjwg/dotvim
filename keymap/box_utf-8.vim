" Vim Keymap file for box drawings （方框绘图，U+2500 -- U+257f）
" Author:      lilydjwg <lilydjwg@gmail.com>
" Last Change: 2009年12月14日

" All characters are given literally, conversion to another encoding (e.g.,
" UTF-8) should work.
scriptencoding utf8

" Use this short name in the status line.
let b:keymap_name = "box"

" All unicode name abbreviation works, without AND TO or DASH
" Some more:
" - for ─
" = for ━
" | for │
" I or ! for ┃
" 2 for double when d does not

loadkeymap
-	─
=	━
|	│
I	┃
!	┃
lh	─
hh	━
lv	│
hv	┃
lth	┄
hth	┅
ltv	┆
htv	┇
lqh	┈
hqh	┉
lqv	┊
hqv	┋
ldr	┌
dlr	┍
dhr	┎
hdr	┏
ldl	┐
dllh	┑
dhll	┒
hdl	┓
lur	└
ulrh	┕
uhrl	┖
hur	┗
lul	┘
ullh	┙
uhll	┚
hul	┛
lvr	├
vlrh	┝
uhrdl	┞
dhrul	┟
vhrl	┠
dlruh	┡
ulrdh	┢
hvr	┣
lvl	┤
vllh	┥
uhldl	┦
dhlul	┧
vhll	┨
dlluh	┩
ulldh	┪
hvl	┫
ldh	┬
lhrdl	┭
rhldl	┮
dlhh	┯
dhhl	┰
rlldh	┱
llrdh	┲
hdh	┳
luh	┴
lhrul	┵
rhlul	┶
ulhh	┷
uhhl	┸
rlluh	┹
llruh	┺
huh	┻
lvh	┼
lhrvl	┽
rhlvl	┾
vlhh	┿
uhdhl	╀
dhuhl	╁
vhhl	╂
luhrdl	╃
ruhldl	╄
ldhrul	╅
rdhlul	╆
dluhh	╇
uldhh	╈
rllvh	╉
llrvh	╊
hvh	╋
l2h	╌
h2h	╍
ldv	╎
hdv	╏
dh	═
dv	║
dsrd	╒
ddrs	╓
ddr	╔
dsld	╕
ddls	╖
ddl	╗
usrd	╘
udrs	╙
dur	╚
usld	╛
udls	╜
dul	╝
vsrd	╞
vdrs	╟
dvr	╠
vsld	╡
vdls	╢
dvl	╣
dshd	╤
ddhs	╥
ddh	╦
ushd	╧
udhs	╨
duh	╩
vshd	╪
vdhs	╫
dvh	╬
ladr	╭
ladl	╮
laul	╯
laur	╰
ldurll	╱
ldullr	╲
ldc	╳
ll	╴
lu	╵
lr	╶
ld	╷
hl	╸
hu	╹
hr	╺
hd	╻
llhr	╼
luhd	╽
hllr	╾
huld	╿
