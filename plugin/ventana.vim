if exists('g:loaded_ventana')
  finish
endif

"" export interfaces
nnoremap <Plug>VentanaTranspose           ':lua require("ventana").transpose'
nnoremap <Plug>VentanaShift               ':lua require("ventana").shift'
nnoremap <Plug>VentanaShiftMaintainLinear ':lua require("ventana").shift(true)<CR>'

let g:loaded_ventana= 1
