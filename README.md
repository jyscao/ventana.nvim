# Ventana.nvim

Ventana.nvim provides 2 main commands: `VentanaTranspose` & `VentanaShift`, whose actions can be
seen in the preview GIFs below.

#### `VentanaTranspose`

Flips all your windows along the main diagonal running from the top left corner to the bottom right
corner, much like the matrix transpose operation in linear algebra.

![ventana-transpose](https://github.com/jyscao/ventana.nvim/assets/12605746/ef5e2bcd-8f2b-4af8-9de0-a8ed39c5f439)



#### `VentanaShift`

An improved version of Vim's built-in `CTRL-W r` window rotation command, which only works for
linear windows on the same split level. If you try to do the rotation against a split that has
sub-splits of its own, you'd encounter the `E443: Cannot rotate when another window is split`
error. This command shifts your top level splits as you'd expect them to.



##### `VentanaShiftMaintainLinear`

There is also a 3rd bonus command `VentanaShiftMaintainLinear`, which is like `VentanaShift`, but
instead of keeping the sizes of each window-buffer pair the same, it maintains the exact layout
of each window's position & size, and only shuffles the buffers across them. This only works for
"linear" layouts, which are layouts containing a single row or column of leaf windows only.

![ventana-shift-maintain-linear](https://github.com/jyscao/ventana.nvim/assets/12605746/8b0ba557-6cc4-4c57-ba8e-d8af5769e783)



### Requirements

Personally I'm on Neovim v0.10, but any version that has the
[`winlayout()`](https://neovim.io/doc/user/builtin.html#winlayout()) function should suffice. You
can check its existence with the command `:echo winlayout()`.

### Installation

The plugin can be installed in the usual manner using your package manager of choice. For example,
with `lazy.nvim`:

```lua
{ 'jyscao/ventana.nvim' }
```



### Configuration

There is no real configuration of as of now, although that may change in the near future should I
add additional features.

No default mappings are provided, but here are the mappings I personally use:

```lua
vim.keymap.set("n", "<C-w><C-t>", "<Cmd>VentanaTranspose<CR>")
vim.keymap.set("n", <C-w><C-f>",  "<Cmd>VentanaShift<CR>")
vim.keymap.set("n", <C-w>f",      "<Cmd>VentanaShiftMaintainLinear<CR>")
```



### Known Issues

* temporary buffers, such as those used for [vim-fugitive](https://github.com/tpope/vim-fugitive)'s
commit & [linediff.vim](https://github.com/AndrewRadev/linediff.vim)'s diffing, cannot be properly
restored
* when shifting 2 or more windows that have the same buffer open, the active window cannot be
reliably returned to its pre-shift state; I do plan on fixing this at some point

Finally, just a note that even though I do use this plugin myself everyday, and find it to be a
good addition to my workflow, I make no guarantees about its correctness. Should you encounter a
bug, please open an issue.



### Acknowledgments

Much of the implementation details, especially for getting
and setting the windows layout tree, have been borrowed from
[nvim-dbee](https://github.com/kndndrj/nvim-dbee/blob/master/lua/dbee/utils/layout.lua),
which in turn owes its underlying logic to [this excellent
answer](https://vi.stackexchange.com/a/22545/24816) on the Vi and Vim StackExchange.
