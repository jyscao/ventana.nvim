if exists('g:loaded_ventana')
  finish
endif

command! VentanaTranspose lua require('ventana').transpose()
command! VentanaShift     lua require('ventana').shift()

let g:loaded_ventana= 1
