local source = {}

source.new = function()
    return setmetatable({}, { __index = source })
end

source.is_available = function(_)
    return vim.wo.spell
end

source.get_keyword_pattern = function(_)
    return [[\w\+]]
end

local candidates = function(entries)
    local items = {}
    for k, v in ipairs(entries) do
        items[k] = { label = v }
    end
    return items
end

source.complete = function(_, request, callback)
    local input = string.sub(request.context.cursor_before_line, request.offset)
    callback({ items = candidates(vim.fn.spellsuggest(input)), isIncomplete = true })
end

return source
