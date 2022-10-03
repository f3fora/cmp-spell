# cmp-spell

`spell` source for [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp) based on vim's `spellsuggest`.

## Setup

```lua
require('cmp').setup({
    sources = {
        {
            name = 'spell',
            option = {
                keep_all_entries = false,
                enable_in_context = function()
                    return true
                end,
            },
        },
    },
})
```

Setting `spell` (and `spelllang`) is mandatory to use `spellsuggest`.

```lua
vim.opt.spell = true
vim.opt.spelllang = { 'en_us' }
```

## Options

### `keep_all_entries`

If true, all `vim.fn.spellsuggest` results are displayed in `nvim-cmp` menu. Otherwise, they are being filtered to only include fuzzy matches.

Type: boolean  
Default: `false`

### `enable_in_context`

'nvim-cmp' menu is populated only when the function returns true.

For example, one can enable this source only when in a `@spell` treesitter capture. See `:help treesitter-highlight-spell`.

```lua
enable_in_context = function()
    return require('cmp.config.context').in_treesitter_capture('spell')
end,
```

Type: function  
Return: boolean  
Default:

```lua
enable_in_context = function()
    return true
end,
```

Note: this option will be removed when hrsh7th/nvim-cmp#632 is implemented.

## Credit

- [compe-spell](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_spell/init.lua)
- [nvim-cmp request](https://github.com/hrsh7th/nvim-cmp/issues/69)
