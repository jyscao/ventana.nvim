if exists('g:loaded_ventana')
  finish
endif

try
  call winlayout()
catch /^Vim\%((\a\+)\)\=:E117:/   " E117: Unknown function
  echoerr "ventana.nvim requires a version of Neovim with the winlayout() function"
  finish
endtry

"" define mappable commands
command! VentanaTranspose           lua require('ventana').transpose()
command! VentanaShift               lua require('ventana').shift()
command! VentanaShiftMaintainLinear lua require('ventana').shift(true)

let g:loaded_ventana = 1
