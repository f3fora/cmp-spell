local source = {}

function source.new()
    return setmetatable({}, { __index = source })
end

function source:is_available()
    return vim.wo.spell
end

function source:get_keyword_pattern()
    return [[\K\+]]
end

local function candidates(entries)
    local items = {}
    for k, v in ipairs(entries) do
        items[k] = { label = v }
    end
    return items
end

function source:complete(request, callback)
    local input = string.sub(request.context.cursor_before_line, request.offset)
    callback({ items = candidates(vim.fn.spellsuggest(input)), isIncomplete = true })
end

return source
