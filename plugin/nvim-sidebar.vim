if exists('g:loaded_nvim_sidebar') | finish | endif " prevent loading file twice

command! -nargs=* Sidebar call luaeval("require('nvim-sidebar').execute(_A)", [<f-args>])

let g:loaded_nvim_sidebar = 1
