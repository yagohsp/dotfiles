local M = {}

function M.jump_to_method(direction)
    local params = { textDocument = vim.lsp.util.make_text_document_params() }
    vim.lsp.buf_request(0, 'textDocument/documentSymbol', params, function(_, result)
        if not result or vim.tbl_isempty(result) then
            return
        end

        local function flatten_symbols(symbols, parent_level)
            local methods = {}
            for _, symbol in ipairs(symbols) do
                if symbol.kind == 12 then -- 12 = Method
                    table.insert(methods, { symbol = symbol, parent_level = parent_level })
                end
                if symbol.children then
                    local child_methods = flatten_symbols(symbol.children, symbol)
                    vim.list_extend(methods, child_methods)
                end
            end
            return methods
        end

        local methods = flatten_symbols(result, nil)

        table.sort(methods, function(a, b)
            return a.symbol.range.start.line < b.symbol.range.start.line
        end)

        local current_line = vim.fn.line('.') - 1
        local target_method = nil

        for _, method_entry in ipairs(methods) do
            local method = method_entry.symbol
            if direction == "next" and method.range.start.line > current_line then
                local current_parent_level = nil
                for _, previous in ipairs(methods) do
                    if previous.symbol.range.start.line <= current_line then
                        current_parent_level = previous.parent_level
                    end
                end

                if method_entry.parent_level == current_parent_level then
                    target_method = method
                    break
                end
            elseif direction == "previous" and method.range.start.line < current_line then
                local current_parent_level = nil
                for _, previous in ipairs(methods) do
                    if previous.symbol.range.start.line >= current_line then
                        current_parent_level = previous.parent_level
                    end
                end

                if method_entry.parent_level == current_parent_level then
                    target_method = method
                end
            end
        end

        if target_method then
            vim.api.nvim_win_set_cursor(0, { target_method.range.start.line + 1, target_method.range.start.character })
        end
    end)
end

function M.fold_at_level(n)
    local parser = vim.treesitter.get_parser(0)
    if not parser then
        return
    end

    local tree = parser:parse()[0]
    local root = tree:root()

    for node in root:iter_children() do
        local type = node:type()

        if type == "function_declaration" or type == "method_declaration" then
            local start_row, _, _, _ = node:range()


            vim.api.nvim_win_set_cursor(0, { start_row + 1, 0 })
            vim.cmd("normal! zM")
        end
    end
end

return M
