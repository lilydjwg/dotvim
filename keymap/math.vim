" math.vim
"   Author: Charles E. Campbell, Jr.
"   Date:   Mar 04, 2010
"   Version: 3
" ---------------------------------------------------------------------
let g:loaded_math_keymap = "v3"
let b:keymap_name        = "math"

" Keymap Initialization: {{{1
" vim: enc=utf-8
scriptencoding utf-8
loadkeymap

" capitals {{{1
GA	<char-0x0391>   " Α greek capital letter alpha
GB	<char-0x0392>   " Β greek capital letter beta
GC	<char-0x03A8>   " Ψ greek capital letter psi
GD	<char-0x0394>   " Δ greek capital letter delta
GE	<char-0x0395>   " Ε greek capital letter epsilon
GF	<char-0x03A6>   " Φ greek capital letter phi
GG	<char-0x0393>   " Γ greek capital letter gamma
GH	<char-0x0397>   " Η greek capital letter eta
GI	<char-0x0399>   " Ι greek capital letter iota
GJ	<char-0x039E>   " Ξ greek capital letter xi
GK	<char-0x039A>   " Κ greek capital letter kappa
GL	<char-0x039B>   " Λ greek capital letter lambda
GM	<char-0x039C>   " Μ greek capital letter mu
GN	<char-0x039D>   " Ν greek capital letter nu
GO	<char-0x039F>   " Ο greek capital letter omikron
GP	<char-0x03A0>   " Π greek capital letter pi
GR	<char-0x03A1>   " Ρ greek capital letter rho
GS	<char-0x03A3>   " Σ greek capital letter sigma
GT	<char-0x03A4>   " Τ greek capital letter tau
GU	<char-0x0398>   " Θ greek capital letter theta
GV	<char-0x03A9>   " Ω greek capital letter omega
GX	<char-0x03A7>   " Χ greek capital letter chi
GY	<char-0x03A5>   " Υ greek capital letter upsilon
GZ	<char-0x0396>   " Ζ greek capital letter zeta

" lower case {{{1
a	<char-0x03B1>   " α greek small letter alpha
b	<char-0x03B2>   " β greek small letter beta
g	<char-0x03B3>   " γ greek small letter gamma
d	<char-0x03B4>   " δ greek small letter delta
e	<char-0x03F5>   " ϵ greek small letter epsilon
ve	<char-0x03B5>   " ε greek small letter epsilon
z	<char-0x03B6>   " ζ greek small letter zeta
h	<char-0x03B7>   " η greek small letter eta
u	<char-0x03B8>   " θ greek small letter theta
vu	<char-0x03D1>   " ϑ greek small letter theta
i	<char-0x03B9>   " ι greek small letter iota
k	<char-0x03BA>   " κ greek small letter kappa
l	<char-0x03BB>   " λ greek small letter lambda
m	<char-0x03BC>   " μ greek small letter mu
n	<char-0x03BD>   " ν greek small letter nu
j	<char-0x03BE>   " ξ greek small letter xi
o	<char-0x03BF>   " ο greek small letter omicron
p	<char-0x03C0>   " π greek small letter pi
vp	<char-0x03D6>   " ϖ greek small letter pi
r	<char-0x03C1>   " ρ greek small letter rho
vr	<char-0x03F1>   " ϱ greek small letter rho
s	<char-0x03C3>   " σ greek small letter sigma
vs	<char-0x03C2>   " ς greek small letter final sigma
t	<char-0x03C4>   " τ greek small letter tau
y	<char-0x03C5>   " υ greek small letter upsilon
f	<char-0x03C6>   " φ greek small letter phi
vf	<char-0x03D5>   " ϕ greek small letter phi
x	<char-0x03C7>   " χ greek small letter chi
c	<char-0x03C8>   " ψ greek small letter psi
w	<char-0x03C9>   " ω greek small letter omega

" superscripts {{{1
^0 	<char-0x2070>   " ⁰
^1 	<char-0x00B9>   " ¹
^2 	<char-0x00B2>   " ²
^3 	<char-0x00B3>   " ³
^4 	<char-0x2074>   " ⁴
^5  	<char-0x2075>   " ⁵
^6 	<char-0x2076>   " ⁶
^7  	<char-0x2077>   " ⁷
^8 	<char-0x2078>   " ⁸
^9      <char-0x2079>   " ⁹
^+	<char-0x207A>	" ⁺
^-	<char-0x207B>	" ⁻
^<	<char-0x02C2>   " ˂
^>	<char-0x02C3>   " ˃
^/	<char-0x02CA>   " ˊ
^^	<char-0x02C4>   " ˄
^(	<char-0x207D>	" ⁽
^)	<char-0x207E>	" ⁾
^.	<char-0x02D9>   " ˙
^=	<char-0x02ED>	" ˭
^a	<char-0x1D43>	" ᵃ
^b	<char-0x1D47>	" ᵇ
^c	<char-0x1D9C>	" ᶜ
^d	<char-0x1D48>	" ᵈ
^e	<char-0x1D49>	" ᵉ
^f	<char-0x1DA0>	" ᶠ
^g	<char-0x1D4D>	" ᵍ
^h	<char-0x02B0>	" ʰ
^i	<char-0x2071>	" ⁱ
^j	<char-0x02B2>	" ʲ
^k	<char-0x1D4F>	" ᵏ
^l	<char-0x02E1>	" ˡ
^m	<char-0x1D50>	" ᵐ
^n	<char-0x207F>	" ⁿ
^o	<char-0x1D52>	" ᵒ
^p	<char-0x1D56>	" ᵖ
^r	<char-0x02B3>	" ʳ
^s	<char-0x02E2>	" ˢ
^t	<char-0x1D57>	" ᵗ
^u	<char-0x1D58>	" ᵘ
^v	<char-0x1D5B>   " ᵛ
^w	<char-0x02B7>   " ʷ
^x	<char-0x02E3>	" ˣ
^y	<char-0x02B8>   " ʸ
^z	<char-0x1DBB>   " ᶻ
^,	<char-0x02BE>	" ʾ
^A	<char-0x1D2C>	" ᴬ
^B	<char-0x1D2E>	" ᴮ
^D	<char-0x1D30>	" ᴰ
^E	<char-0x1D31>	" ᴱ
^G	<char-0x1D33>	" ᴳ
^H	<char-0x1D34>	" ᴴ
^I	<char-0x1D35>	" ᴵ
^J	<char-0x1D36>	" ᴶ
^K	<char-0x1D37>	" ᴷ
^L	<char-0x1D38>	" ᴸ
^M	<char-0x1D39>	" ᴹ
^N	<char-0x1D3A>	" ᴺ
^O	<char-0x1D3C>	" ᴼ
^P	<char-0x1D3E>	" ᴾ
^R	<char-0x1D3F>	" ᴿ
^T	<char-0x1D40>	" ᵀ
^U	<char-0x1D41>	" ᵁ
^W	<char-0x1D42>	" ᵂ

" subscripts {{{1
_0	<char-0x2080>	" ₀
_1	<char-0x2081>	" ₁
_2	<char-0x2082>	" ₂
_3	<char-0x2083>	" ₃
_4	<char-0x2084>	" ₄
_5	<char-0x2085>	" ₅
_6	<char-0x2086>	" ₆
_7	<char-0x2087>	" ₇
_8	<char-0x2088>	" ₈
_9	<char-0x2089>	" ₉
_+	<char-0x208A>	" ₊
_-	<char-0x208B>	" ₋
_/	<char-0x02CF>	" ˏ
_(	<char-0x208D>	" ₍
_)	<char-0x208E>	" ₎
_^	<char-0x2038>	" ‸
_a	<char-0x2090>	" ₐ
_e	<char-0x2091>	" ₑ
_i	<char-0x1D62>	" ᵢ
_o	<char-0x2092>	" ₒ
_r	<char-0x1D63>	" ᵣ
_u	<char-0x1D64>	" ᵤ
_v	<char-0x1D65>	" ᵥ
_x	<char-0x2093>	" ₓ

" fractions {{{1
F12	<char-0x00BD>	" ½
F13	<char-0x2153>	" ⅓
F23	<char-0x2154>	" ⅔
F14	<char-0x00BC>	" ¼
F34	<char-0x00BE>	" ¾
F15	<char-0x2155>	" ⅕
F25	<char-0x2156>	" ⅖
F35	<char-0x2157>	" ⅗
F45	<char-0x2158>	" ⅘
F16	<char-0x2159>	" ⅙
F56	<char-0x215A>	" ⅚
F18	<char-0x215B>	" ⅛
F38	<char-0x215C>	" ⅜
F58	<char-0x215D>	" ⅝
F78	<char-0x215E>	" ⅞

" arrows {{{1
-<	<char-0x27F5>	" ⟵
->	<char-0x27F6>	" ⟶
<->	<char-0x2194>	" ↔
=<	<char-0x27F8>	" ⟸
=>	<char-0x27F9>	" ⟹
IFF	<char-0x27FA>	" ⟺
|-<	<char-0x21A4>	" ↤
|->	<char-0x21A6>	" ↦
|=<	<char-0x27FD>	" ⟽
|=>	<char-0x27FE>	" ⟾

" grouping {{{1
[[	<char-0x27E6>	" ⟦
]]	<char-0x27E7>	" ⟧
2[	<char-0x27E6>	" ⟦
2]	<char-0x27E7>	" ⟧
B<	<char-0x27E8>	" ⟨   (big left angle)
B>	<char-0x27E9> 	" ⟩   (big right angle)
"B<	<char-0x2329>	" 〈  (deprecated, big left angle)
"B>	<char-0x232A> 	" 〉  (deprecated, big right angle)
U(	<char-0x239B>	" ⎛
M(	<char-0x239C>	" ⎜
B(	<char-0x239D>	" ⎝
U)	<char-0x239E>	" ⎞
M)	<char-0x239F>	" ⎟
B)	<char-0x23A0>	" ⎠
U[	<char-0x23A1>	" ⎡
M[	<char-0x23A2>	" ⎢
B[	<char-0x23A3>	" ⎣
U]	<char-0x23A4>	" ⎤
M]	<char-0x23A5>	" ⎥
B]	<char-0x23A6>	" ⎦
U{	<char-0x23A7>	" ⎧
M{	<char-0x23A8>	" ⎨
B{	<char-0x23A9>	" ⎩
U}	<char-0x23AB>	" ⎫
M}	<char-0x23AC>   " ⎬
B}	<char-0x23AD>	" ⎭
V(	<char-0xFE35>	" ︵
V)	<char-0xFE36>	" ︶
V{	<char-0xFE37>	" ︷
V}	<char-0xFE38>	" ︸
V[	<char-0xFE39>	" ︹
V]	<char-0xFE3A>	" ︺
V<	<char-0xFE3F>	" ︿
V>	<char-0xFE40>	" ﹀

" miscellaneous symbols {{{1
ARC	<char-0x2312>	" ⌒  (arc)
QED	<char-0x220E>	" ∎ (qed, as in end-of-proof)
TBUL	<char-0x2023>   " ‣ (triangular bullet)
INF	<char-0x221E>	" ∞ (infinity)
ANG	<char-0x2221>	" ∡ (angle)
|...	<char-0x22EE>	" ⋮ (vertical ellipsis)
...	<char-0x22EF>	" ⋯ (horizontal ellipsis)
/...	<char-0x22F0>	" ⋰ (up right diagonal ellipsis)
\\...	<char-0x22F1>	" ⋱ (down left diagonal ellipsis)
DU	<char-0x2801>	" ⠁ (dot up)
DM	<char-0x2802>	" ⠂ (dot middle)
DD	<char-0x2840>	" ⡀ (dot down)
LC	<char-0x2308>	" ⌈ (left ceiling)
RC	<char-0x2309>	" ⌉ (right ceiling)
LF	<char-0x230A>	" ⌊ (left floor)
RF	<char-0x230B>	" ⌋ (right floor)
__	<char-0x23AF>	" ⎯ (horizontal line extension)
--	<char-0x2500>	" ─ (light horizontal)
==	<char-0x2550>	" ═ (double horizontal)
HB	<char-0x2015>	" ― (horizontal bar)
VB	<char-0x2503>	" ┃ (vertical bar)
BB	<char-0x2016>   " ‖ (double vertical bar)
SH	<char-0x210B>	" ℋ (script H)
SI	<char-0x2111>	" ℑ (script I)
SL	<char-0x2112>	" ℒ (script L)
SR	<char-0x211C>	" ℜ (script R)


" operators {{{1
O.	<char-0x2A00>	" ⨀
O+	<char-0x2A01>	" ⨁
Ox	<char-0x2A02>	" ⨂
U.	<char-0x2A03>	" ⨃
U+	<char-0x2A04>	" ⨄
IN	<char-0x2229>	" ∩ (intersection)
UN	<char-0x222A>	" ∪ (union)
CAP	<char-0x2229>	" ∩ (cup == union)
CUP	<char-0x222A>	" ∪ (cap == intersection)
SQCAP	<char-0x2293>	" ⨅ (square cap)
SQCUP	<char-0x2294>	" ⨆ (square cup)
X	<char-0x2A09>	" ⨉ (big multiply)
MUL	<char-0x00D7>	" × (multiply)
1S	<char-0x222B>	" ∫
2S	<char-0x222C>	" ∬
3S	<char-0x222D>	" ∭
4S	<char-0x2A0C>	" ⨌
S-	<char-0x2A0D>	" ⨍
S=	<char-0x2A0E>	" ⨎
S/	<char-0x2A0F>	" ⨏
So	<char-0x222E>	" ∮
SSo	<char-0x222F>	" ∯
SSSo	<char-0x2230>	" ∰
Scw     <char-0x2232>	" ∲ (clockwise contour integral)
Sccw    <char-0x2233>	" ∳ (counter-clockwise contour integral)
US	<char-0x2320>	" ⌠ (upper integral)
MS	<char-0x23AE>	" ⎮ (middle integral)
BS	<char-0x2321>	" ⌡ (bottom integral)
PD	<char-0x2202>	" ∂
JN	<char-0x2A1D>	" ⨝ (join)
TF	<char-0x2234>	" ∴ (therefore)
BC	<char-0x2235>	" ∵ (because)
PAR	<char-0x2225>	" ∥ (parallel to)
NPAR	<char-0x2226>	" ∦ (not parallel to)
SUM	<char-0x2211>	" ∑ (summation)
USUM	<char-0x23B2>   " ⎲
BSUM	<char-0x23B3>   " ⎳
PRD	<char-0x220F>	" ∏ (product)
RING	<char-0x2218>	" ∘ (ring)
BU	<char-0x2219>	" ∙ (bullet)
AST	<char-0x2217>	" ∗ (asterisk operator)
LA	<char-0x204E>	" ⁎ (low asterisk)
SQRT	<char-0x221A>	" √ (square root)
CUBR	<char-0x221B>	" ∛ (cube root)
FORR	<char-0x221C>	" ∜ (fourth root)
DEL	<char-0x2206>	" ∆ (delta, increment)
GRAD	<char-0x2207>	" ∇ (grad, nabla)
NAB	<char-0x2207>	" ∇ (nabla)
DIAM	<char-0x22C4>	" ⋄ (diamond operator)
R/	<char-0x2215>	" ∕ (right division slash)
L/	<char-0x2216>	" ∖ (left division slash)
P1	<char-0x2032>	" ′ (prime)
P2	<char-0x2033>	" ″ (double prime)
P3	<char-0x2034>	" ‴ (triple prime)

" relationals {{{1
<=	<char-0x2264>	" ≤
>=	<char-0x2265>	" ≥
<~	<char-0x2A9D>	" ⪝
>~	<char-0x2A9E>	" ⪞
<<	<char-0x27EA>	" ⟪ (much less than)
>>	<char-0x27EB>	" ⟫ (much greater than)
~	<char-0x223c>	" ∼ (tilde operator)
N~	<char-0x2241>	" ≁ (not tilde)
R~	<char-0x223d>	" ∽ (reversed tilde operator)
-~	<char-0x2242>	" ≂ (minus over tilde)
~-	<char-0x2243>	" ≃ (tilde over minus)
=~	<char-0x2245>	" ≅ (approximately equal to)
!~-	<char-0x2244>	" ≄ (not approximately equal to)
~~	<char-0x2248>	" ≈ (almost equal to)
=.	<char-0x2250>	" ≐ (approaches the limit)
EST	<char-0x2259>	" ≙ (estimates)
!~~	<char-0x2249>	" ≉ (not almost equal to)
<>	<char-0x2276>	" ≶ (lesser-than over greater-than)
><	<char-0x2277>	" ≷ (greater-than over lesser-than)
!=	<char-0x2260>	" ≠ (not equal)
!<	<char-0x226E>	" ≮ (not less than)
!>	<char-0x226F>	" ≯ (not greater than)
!<=     <char-0x2270>	" ≰ (not less than or equal)
!>=     <char-0x2271>	" ≱ (not greater than or equal)
ID	<char-0x2261>	" ≡ (identical to)
EQV     <char-0x224D>	" ≍
JOIN	<char-0x22C8>	" ⋈  (join)
NID	<char-0x2262>	" ≢ (not identical to)
O+	<char-0x2295>	" ⊕ (O-plus)
O-	<char-0x2296>	" ⊖ (O-minus)
Ox	<char-0x2297>	" ⊗ (O-times)
O/	<char-0x2298>	" ⊘ (O-division)
O.	<char-0x2299>	" ⊙ (O-dot)
Oo	<char-0x229A>	" ⊚ (O-ring)
+-	<char-0x00B1>	" ± (plus-minus)
-+	<char-0x2213>	" ∓ (minus-plus)
PERP	<char-0x22A5>	" ⊥ (perpendicular)
PROP	<char-0x221D>	" ∝ (proportional)
PREC	<char-0x227A>	" ≺ (precedes)
SUCC	<char-0x227B>	" ≻ (succeeds)

" sets {{{1
SUB	<char-0x2282>	" ⊂ (subset of)
ESUB	<char-0x2286>	" ⊆ (equal to or subset of)
NSUB	<char-0x2284>	" ⊄ (not subset of)
NESUB	<char-0x2288>	" ⊈ (not equal to or subset of)
SUP	<char-0x2283>	" ⊃ (superset of)
ESUP	<char-0x2287>	" ⊇ (equal to or superset of)
NSUP	<char-0x2285>	" ⊅ (not superset of)
NESUP	<char-0x2289>	" ⊉ (not equal to or superset of)
LAND	<char-0x2227>	" ∧ (logical and)
LOR	<char-0x2228>	" ∨ (logical or)
EX	<char-0x2203>	" ∃ (there exists)
NEX	<char-0x2204>	" ∄ (not exists)
EMP	<char-0x2205>	" ∅ (empty set)
EL	<char-0x2208>	" ∈ (element of)
NEL	<char-0x2209>	" ∉ (not element of)
CC	<char-0x2102>	" ℂ (complex numbers)
HH	<char-0x210D>	" ℍ
LL	<char-0x2112>	" ℒ (Lagrangian operator)
NN	<char-0x2115>	" ℕ (natural numbers, {1,2,3,4,...})
RR	<char-0x211D>	" ℝ (real numbers)
QQ	<char-0x211A>	" ℚ (rational fractions, p/q, where p,q ∈ ℤ)
ZZ	<char-0x2124>	" ℤ (integers, {...,-4,-3,-2,-1,0,1,2,3,4,...})
ALL	<char-0x2200>	" ∀ (all)
*       <char-0x2217>	" ∗

" ---------------------------------------------------------------------
"  box characters: {{{1
B-	<char-0x2500>	" ─
B|	<char-0x2502>	" │
DSH-	<char-0x2504>	" ┄
DSH|	<char-0x2506>	" ┆
BUL	<char-0x250C>	" ┌
BDL	<char-0x2514>	" └
BUR	<char-0x2510>	" ┐
BDR	<char-0x2518>	" ┘
C+	<char-0x253C>	" ┼
Cl	<char-0x2524>	" ┤
Cr	<char-0x251C>	" ├
Cd	<char-0x252C>	" ┬
Cu	<char-0x2534>	" ┴
HB-	<char-0x2501>	" ━
HB|	<char-0x2503>	" ┃
HD-	<char-0x2505>	" ┅
HD|	<char-0x2507>	" ┇
HBUL	<char-0x250F>	" ┏
HBDL	<char-0x2517>	" ┗
HBUR	<char-0x2513>	" ┓
HBDR	<char-0x251B>	" ┛
HC+	<char-0x254B>	" ╋
HCl	<char-0x252B>	" ┫
HCr	<char-0x2523>	" ┣
HCd	<char-0x2533>	" ┳
HCu	<char-0x253B>	" ┻
D-	<char-0x2550>	" ═
D|	<char-0x2551>	" ║
DUL	<char-0x2554>	" ╔
DDL	<char-0x255A>	" ╚
DUR	<char-0x2557>	" ╗
DDR	<char-0x255D>	" ╝

" ---------------------------------------------------------------------
"  Modeline: {{{1
" vim: ts=8 fdm=marker fenc=utf8
