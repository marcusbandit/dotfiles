" Comments
syntax match confComment "#.*$"
syntax match confComment ";.*$"
highlight link confComment Comment

" Section headers
syntax match confHeader "^\[.*\]"
highlight link confHeader Title

" Keys (before =)
syntax match confKey "^\s*[a-zA-Z0-9_\-]*="
highlight link confKey Key

" Values (after =)
syntax match confValue "=\s*[^;#]*" contains=confVariable,confNumber
highlight link confValue String

" Operators
syntax match confOperator "=\s*"
highlight link confOperator Operator

" Match booleans
syntax match confBoolean "\<\(true\|false\)\>"
highlight link confBoolean Boolean

" Match numbers (integers and floats, standalone)
syntax match confNumber "\<\d\+\(\.\d\+\)\?\>"
highlight link confNumber Number

" Match variables starting with $
syntax match confVariable "\$\w\+"
highlight link confVariable Variable

" Match standalone uppercase letters
syntax match confKey "\<\u\>"
highlight link confKey Key

" Match standalone action keys (SUPER, ALT, SHIFT, CONTROL)
syntax match confActionKey "\<\(SUPER\|ALT\|SHIFT\|CTRL\|RETURN\|SPACE\|TAB\|ESCAPE\|LEFT\|RIGHT\|UP\|DOWN\|mouse\|mouse_up\|mouse_down\)\>"
highlight link confActionKey ActionKey

" Match 'bind' keywords
syntax match confBindKeyword "^\s*bind[a-z]*"
highlight link confBindKeyword Keyword

" Match '=' as an operator
syntax match confOperator "=\|-\|+\|*\|/\|%\|{\|}\|,\|;\|:\|<\|>\|&\||"
highlight link confOperator Operator

" Match specific function keywords
syntax keyword confFunction exec workspace movetoworkspace focusmode pseudo togglefloating togglesplit exit killactive movefocus resizewindow movewindow
highlight link confFunction Special

" Define custom colors for Key and Special
highlight Key guifg=#df2c5e guibg=NONE gui=bold
highlight Keyword guifg=#d6a7e8 guibg=NONE gui=bold
highlight Special guifg=#7dcfff guibg=NONE gui=italic
highlight ActionKey guifg=#c8f7c5 guibg=NONE gui=bold
highlight Variable guifg=#d19a66 guibg=NONE gui=bold
highlight Boolean guifg=#58c378 guibg=NONE gui=bold

