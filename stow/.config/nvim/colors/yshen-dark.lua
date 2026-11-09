-- yshen-dark: dark theme built on mini.base16
vim.o.background = "dark"

local c = {
  bg = "#27211c", bg1 = "#302a24", sel = "#4a4036",
  fg = "#ecdcc4", comment = "#8b7d6c", linenr = "#6b5f52", dim = "#a8967f",
  rose = "#e8879a", amber = "#f4b266", olive = "#a9b665",
  orange = "#e87b52", mauve = "#c4a1d6", blue = "#86a8ba",
}

require("mini.base16").setup({
  palette = {
    base00 = c.bg,      base01 = c.bg1,     base02 = c.sel,    base03 = c.comment,
    base04 = c.dim,     base05 = c.fg,      base06 = "#f3e6d2", base07 = "#faf1e2",
    base08 = c.rose,    base09 = c.orange,  base0A = c.blue,   base0B = c.olive,
    base0C = c.blue,    base0D = c.amber,   base0E = c.mauve,  base0F = c.orange,
  },
})

local function hl(groups, opts)
  for _, g in ipairs(groups) do vim.api.nvim_set_hl(0, g, opts) end
end

hl({ "Keyword", "Conditional", "Repeat", "Statement", "Include",
     "@keyword", "@keyword.return", "@keyword.conditional", "@keyword.repeat",
     "@keyword.operator", "@keyword.import", "@keyword.modifier" }, { fg = c.mauve })
hl({ "@keyword.function" }, { fg = c.mauve, bold = true })
hl({ "Exception", "@keyword.exception" }, { fg = c.rose })
hl({ "Type", "@type", "@type.builtin", "@constructor" }, { fg = c.blue })
hl({ "Function", "@function", "@function.call", "@function.method",
     "@function.method.call", "@function.builtin" }, { fg = c.amber, bold = true })
hl({ "Constant", "Number", "Boolean", "Float", "Operator",
     "@constant", "@constant.builtin", "@number", "@boolean", "@operator" }, { fg = c.orange })
hl({ "String", "@string" }, { fg = c.olive })
hl({ "Delimiter", "@punctuation.bracket", "@punctuation.delimiter" }, { fg = c.dim })
hl({ "Comment", "@comment" }, { fg = c.comment, italic = true })
hl({ "@variable", "@variable.parameter" }, { fg = c.fg })

hl({ "LineNr" }, { fg = c.linenr })
hl({ "CursorLineNr" }, { fg = c.amber, bold = true })
hl({ "CursorLine" }, { bg = c.bg1 })
hl({ "Cursor" }, { bg = c.amber, fg = c.bg })
hl({ "Search", "IncSearch" }, { bg = c.amber, fg = c.bg })
hl({ "StatusLine" }, { fg = c.fg, bg = "#3a332c" })

vim.g.colors_name = "yshen-dark"
