
# Navigation
function ..    ; cd .. ; end
function ...   ; cd ../.. ; end
function ....  ; cd ../../.. ; end
function ..... ; cd ../../../.. ; end

alias -s ls "exa --icons"

# Utilities
function grep     ; command grep --color=auto $argv ; end
