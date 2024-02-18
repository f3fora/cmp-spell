# cmp-spell

`spell` source for [`nvim-cmp`](https://github.com/hrsh7th/nvim-cmp) based on vim's `spellsuggest`.

`cmp-spell` optionally supports dictionary definitions in the documentation window of `nvim-cmp`.

## Setup

These are the configuration default values.

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
                definition = {
                    enable = false,
                    command = { "" },
                    format = function(_) end
                }
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

### `definition`

These options are related to what is shown in the documentation window for each item.

#### `definition.enable`

If true, definitions for each entry are displayed by running an arbitrary
command (`definition.command`) that retrieves them.

Type: boolean  
Default: `false`

#### `definition.command`

This is the external command to run and retrieve the definition of the word.
The field `${word}` will be replaced by the actual selected completion item.

Type: table of strings  
Default: `{ "" }`

For example, use *WordNet* for a free dictionary

```lua
command = { "wn", "${word}, "-over" }
```

or [sdcv](https://github.com/Dushistov/sdcv) if you have *StarDict*
dictionaries, maybe using [goldendict](https://github.com/xiaoyifang/goldendict-ng).

```lua
command = { "sdcv", "-j", "-n", "${word}"},
```

#### `definition.format`

A function to format the output of `definition.command` before showing it in
the documentation window.

Type: function  
Parameter: Table with the output lines of `definition.command`  
Return: Text string to display in the documentation window  
Default: `function(_) end`

For example, if you are using the *WordNet* example above, the corresponding
format function would be

```lua
format = function(text) return table.concat(text, "\n") end
```

And if you are using *StarDict* dictionaries and want to output Markdown from
the json data, the format function could be something like this:

```lua
format = function (text)
    local md = {}
    local data = vim.fn.json_decode(text)
    if data ~= nil then
        for _, v in ipairs(data) do
            table.insert(md, "# Dictionary: " .. v['dict'] .. "\n")
            table.insert(md, "## Word: " .. v['word'])
            local definition = v['definition']
            -- Remove html tags
            definition = string.gsub(definition, "<.+>", "")
            -- Remove reference to pronunciation WAV files
            definition = string.gsub(definition, "[^%s]*%.wav%s", "")
            -- Swap [] for italics
            definition = string.gsub(definition, "%[([^%]]+)%]", "*%1*")
            table.insert(md, definition .. "\n\n")
        end
    end
    return table.concat(md)
end
```

## Examples

This example configures `cmp-spell` to query definitions from *WordNet*:

```lua
require('cmp').setup({
    sources = {
        name = 'spell',
        keyword_length = 2,
        max_item_count = 8,
        option = {
            -- if this is set to false, fuzzy matching will discard most of
            -- the spelling suggestions, even if they are correct
            keep_all_entries = true,
            definition = {
                enable = true,
                command = { "wn", "${word}", "-over" },
                format = function(text) return table.concat(text, "\n") end
            }
        }
    }
})
```

Or to get definitions from your *StarDict* dictionaries and convert them into
a simplified Markdown format you can display in the documentation window:

```lua
local function format_spell_definition(text)
    local md = {}
    local data = vim.fn.json_decode(text)
    if data ~= nil then
        for _, v in ipairs(data) do
            table.insert(md, "# Dictionary: " .. v['dict'] .. "\n")
            table.insert(md, "## Word: " .. v['word'])
            local definition = v['definition']
            -- Remove html tags
            definition = string.gsub(definition, "<.+>", "")
            -- Remove reference to pronunciation WAV files
            definition = string.gsub(definition, "[^%s]*%.wav%s", "")
            -- Swap [] for italics
            definition = string.gsub(definition, "%[([^%]]+)%]", "*%1*")
            table.insert(md, definition .. "\n\n")
        end
    end
    return table.concat(md)
end

require('cmp').setup({
    sources = {
        name = 'spell',
        keyword_length = 2,
        max_item_count = 8,
        option = {
            -- if this is set to false, fuzzy matching will discard most of
            -- the spelling suggestions, even if they are correct
            keep_all_entries = true,
              definition = {
                enable = true,
                command = { "sdcv", "-j", "-n", "${word}"},
                format = format_spell_definition,
              }
            }
        }
    }
})
```


## Credit

- [compe-spell](https://github.com/hrsh7th/nvim-compe/blob/master/lua/compe_spell/init.lua)
- [nvim-cmp request](https://github.com/hrsh7th/nvim-cmp/issues/69)
