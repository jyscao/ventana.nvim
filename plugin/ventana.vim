if exists('g:loaded_ventana')
  finish
endif

"" define mappable commands
command! VentanaTranspose           lua require('ventana').transpose()
command! VentanaShift               lua require('ventana').shift()
command! VentanaShiftMaintainLinear lua require('ventana').shift(true)

let g:loaded_ventana= 1
