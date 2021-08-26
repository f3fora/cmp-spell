# cmp-spell

`spell` source for [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp) based on vim's `spellsuggest`.

## Setup

```lua
require('cmp').setup {
  sources = {
    { name = 'spell' }
  }
}
```

## Credit

- [compe-spell](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_spell/init.lua)
- [nvim-cmp request](https://github.com/hrsh7th/nvim-cmp/issues/69)
