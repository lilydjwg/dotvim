" Test joining of lines with trailing whitespace and indentation.

call append(0, ['4space  ', '  trailing and indented'])
call ingo#join#Lines(1, 1, '')

call append(0, ["tab\t", "\ttrailing and indented"])
call ingo#join#Lines(1, 1, '')

call append(0, ['softtabstop  ', "  \t    trailing and indented"])
call ingo#join#Lines(1, 1, '')

call append(0, ['4space  ', '  trailing and indented with space separator'])
call ingo#join#Lines(1, 1, ' ')

call append(0, ["tab\t", "\ttrailing and indented with space separator"])
call ingo#join#Lines(1, 1, ' ')

call append(0, ['softtabstop  ', "  \t    trailing and indented with space separator"])
call ingo#join#Lines(1, 1, ' ')

call append(0, ['4space  ', '  trailing and indented with ;; separator'])
call ingo#join#Lines(1, 1, ';;')

call append(0, ["tab\t", "\ttrailing and indented with ;; separator"])
call ingo#join#Lines(1, 1, ';;')

call append(0, ['softtabstop  ', "  \t    trailing and indented with ;; separator"])
call ingo#join#Lines(1, 1, ';;')

call vimtest#SaveOut()
call vimtest#Quit()
