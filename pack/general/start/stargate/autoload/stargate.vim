vim9script

import '../import/stargate/workstation.vim' as ws
import '../import/stargate/vim9000.vim' as vim
import '../import/stargate/galaxies.vim'

g:stargate_ignorecase = get(g:, 'stargate_ignorecase', true)
g:stargate_limit = get(g:, 'stargate_limit', 300)
g:stargate_chars = get(g:, 'stargate_chars', 'fjdklshgaewiomc')->split('\zs')
g:stargate_name = get(g:, 'stargate_name', 'Human')
g:stargate_keymaps = get(g:, 'stargate_keymaps', {})

# Initialize highlights
ws.CreateHighlights()

# Apply highlights on a colorscheme change
augroup StargateReapplyHighlights
    autocmd!
    autocmd ColorScheme * ws.CreateHighlights()
augroup END

# Initialize hidden popup windows for stargates hints
ws.CreateLabelWindows()


# Public API functions
export def OKvim(mode: any)
    vim.OkVIM(mode)
enddef

export def Galaxy()
    galaxies.ChangeGalaxy(true)
enddef

# vim: sw=4
