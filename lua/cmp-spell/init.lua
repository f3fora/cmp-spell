local source = {}

local defaults = {
    keep_all_entries = false,
    enable_in_context = function()
        return true
    end,
    definition = {
      enable = false,
      command = { "" },
      format = function(_) end
    }
}

function source.new()
    return setmetatable({}, { __index = source })
end

function source:is_available()
    return vim.wo.spell
end

function source:get_keyword_pattern()
    return [[\K\+]]
end

local function validate_option(params)
    local option = vim.tbl_deep_extend('keep', params.option, defaults)
    vim.validate({
        keep_all_entries = { option.keep_all_entries, 'boolean' },
        enable_in_context = { option.enable_in_context, 'function' },
        definition = { option.definition, 'table' },
        definition_enable = { option.definition.enable, 'boolean' },
        definition_command = { option.definition.command, 'table' },
        definition_format = { option.definition.format, 'function' }
    })
    return option
end

local function len_to_loglen(len)
    return math.ceil(math.log10(len + 1))
end

local function number_to_text(input, number, loglen)
    return string.format(input .. '%0' .. loglen .. 'd', number)
end

local function candidates(input, option)
    local items = {}
    local entries = vim.fn.spellsuggest(input)
    local offset
    local loglen
    if vim.tbl_isempty(vim.spell.check(input)) then
        offset = 1
        loglen = len_to_loglen(#entries + offset)

        items[offset] = {
            label = input,
            filterText = input,
            -- insertText = input,
            sortText = number_to_text(input, offset, loglen),
            -- If the current word is spelled correctly, preselect it.
            preselect = true,
        }
    else
        offset = 0
        loglen = len_to_loglen(#entries + offset)
    end

    for k, v in ipairs(entries) do
        items[k + offset] = {
            label = v,
            -- Using the `input` word as filterText, all suggestions are displayed in completion menu.
            filterText = option.keep_all_entries and input or v,
            -- insertText = v,
            -- To keep the order of suggestions, add the index at the end of sortText and trick the compare algorithms.
            -- TODO: Add a custom compare function.
            sortText = option.keep_all_entries and number_to_text(input, k + offset, loglen) or v,
            preselect = false,
        }
    end
    return items
end

local option

function source:complete(params, callback)
    option = validate_option(params)

    local input = string.sub(params.context.cursor_before_line, params.offset)
    if option.enable_in_context(params) then
        callback({ items = candidates(input, option), isIncomplete = true })
    else
        callback({ items = {}, isIncomplete = true })
    end
end

local function run_job(cmd)
  local result = {}
  local id = vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      for _, v in ipairs(data) do
        table.insert(result, v)
      end
    end,
    stdout_buffered = true
  })
  vim.fn.jobwait({ id })
  return result
end

function source:resolve(item, callback)
  if item.documentation == nil and option.definition.enable then
    local command = vim.tbl_map(function(c)
      return c:gsub("${word}", item.label)
    end, option.definition.command)
    local result = run_job(command)
    local text = option.definition.format(result)
    item.documentation = text
  end
  callback(item)
end

local debug_name = 'spell'
function source:get_debug_name()
    return debug_name
end

return source
