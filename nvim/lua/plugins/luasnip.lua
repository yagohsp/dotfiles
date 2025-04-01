return {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = {
        "saadparwaiz1/cmp_luasnip",
        "rafamadriz/friendly-snippets",
    },
    config = function()
        local ls = require("luasnip")

        vim.keymap.set({ "i", "s" }, "<A-j>", function() ls.jump(1) end, { silent = true })
        vim.keymap.set({ "i", "s" }, "<A-k>", function() ls.jump(-1) end, { silent = true })

        local s = ls.snippet
        local t = ls.text_node
        local i = ls.insert_node
        local f = ls.function_node

        for _, filetype in ipairs({ "typescriptreact", "javascriptreact", "typescript", "javascript" }) do
            ls.add_snippets(filetype, {
                s("props", {
                    t({ "type PropsType = {", "" }),
                    i(1, "\tchildren: ReactNode"),
                    t({ "", "}" }),
                }),
                s("clog", {
                    t("console.log("),
                    i(1, "message"),
                    t(")"),
                }),
                s("dlog", {
                    t("console.debug("),
                    i(1, "message"),
                    t(")"),
                }),
                s("stt", {
                    t("const ["),
                    i(1, "state"),
                    t(", set"),
                    f(function(args) return args[1][1]:gsub("^%l", string.upper) end, { 1 }),
                    t("] = useState("),
                    i(2, "initialValue"),
                    t(")"),
                }),
            })
        end
    end
}
