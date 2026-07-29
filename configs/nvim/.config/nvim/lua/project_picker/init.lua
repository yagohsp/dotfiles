local api = vim.api

local M = {}

M.ns = api.nvim_create_namespace("project_picker")

local HL_BORDER = "ProjectPickerBorder"
local HL_TITLE = "ProjectPickerTitle"
local HL_ITEM = "ProjectPickerItem"
local HL_ITEM_SEL = "ProjectPickerItemSel"

function M.setup_highlights()
  vim.api.nvim_set_hl(0, HL_BORDER, { fg = "#908caa" })
  vim.api.nvim_set_hl(0, HL_TITLE, { fg = "#c4a7e7", bold = true })
  vim.api.nvim_set_hl(0, HL_ITEM, { fg = "#e0def4" })
  vim.api.nvim_set_hl(0, HL_ITEM_SEL, { fg = "#e0def4", bg = "#403d52" })
end

local saved_ui = {}

local function center_align(lines)
  local centered = {}
  for _, line in ipairs(lines) do
    local pad = math.max(0, math.floor((vim.o.columns - api.nvim_strwidth(line)) / 2))
    centered[#centered + 1] = string.rep(" ", pad) .. line
  end
  return centered
end

local PROJECT_PAD = 2
local CURSOR_LEFT_OFFSET = 2

local BOX = {
  tl = "╭",
  tr = "╮",
  bl = "╰",
  br = "╯",
  h = "─",
  v = "│",
}

local function box_inner_width(projects)
  local width = api.nvim_strwidth("Projects")
  for _, p in ipairs(projects) do
    width = math.max(width, api.nvim_strwidth(p.name))
  end
  return width + PROJECT_PAD * 4
end

local function box_row(content, total_width)
  local inner = total_width - 2
  local body = string.rep(" ", PROJECT_PAD) .. content
  local pad = inner - api.nvim_strwidth(body)
  if pad < 0 then
    pad = 0
  end
  return BOX.v .. body .. string.rep(" ", pad) .. BOX.v
end

local function box_border(total_width, left, right)
  return left .. string.rep(BOX.h, total_width - 2) .. right
end

---@return string[] centered box lines, number total_width
local function build_project_box(projects)
  local total_width = box_inner_width(projects) + 2
  local lines = {
    box_border(total_width, BOX.tl, BOX.tr),
    box_row("Projects", total_width),
    BOX.v .. string.rep(" ", total_width - 2) .. BOX.v,
  }
  for _, p in ipairs(projects) do
    lines[#lines + 1] = box_row(p.name, total_width)
  end
  lines[#lines + 1] = box_border(total_width, BOX.bl, BOX.br)
  return center_align(lines), total_width
end

local function highlight_box_line(bufnr, lnum0, line)
  local chars = { BOX.tl, BOX.tr, BOX.bl, BOX.br, BOX.h, BOX.v }
  for _, ch in ipairs(chars) do
    local start = 1
    while true do
      local i = line:find(ch, start, true)
      if not i then
        break
      end
      api.nvim_buf_add_highlight(bufnr, M.ns, HL_BORDER, lnum0, i - 1, i - 1 + #ch)
      start = i + #ch
    end
  end
end

local function project_name_col(line, name)
  local idx = line:find(name, 1, true)
  if not idx then
    return PROJECT_PAD + 1
  end
  return idx - 1
end

local function project_cursor_col(line, name)
  return math.max(0, project_name_col(line, name) - CURSOR_LEFT_OFFSET)
end

local function save_ui()
  saved_ui.laststatus = vim.o.laststatus
  saved_ui.showtabline = vim.o.showtabline
  saved_ui.winbar = vim.o.winbar
  saved_ui.cursorline = vim.o.cursorline
end

local function apply_picker_ui()
  vim.o.laststatus = 0
  vim.o.showtabline = 0
  vim.o.winbar = ""
end

local function restore_ui()
  if saved_ui.laststatus then
    vim.o.laststatus = saved_ui.laststatus
  end
  if saved_ui.showtabline then
    vim.o.showtabline = saved_ui.showtabline
  end
  if saved_ui.winbar then
    vim.o.winbar = saved_ui.winbar
  end
  if saved_ui.cursorline ~= nil then
    vim.o.cursorline = saved_ui.cursorline
  end
end

local function set_buf_options(bufnr)
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].buflisted = false
  vim.bo[bufnr].swapfile = false
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].filetype = "dashboard"
  vim.bo[bufnr].modifiable = true
end

local function lock_dashboard_buffer(bufnr)
  vim.bo[bufnr].modifiable = false
  vim.bo[bufnr].modified = false
end

local function set_win_options(winid)
  local wo = vim.wo[winid]
  wo.wrap = false
  wo.number = false
  wo.relativenumber = false
  wo.signcolumn = "no"
  wo.cursorline = false
  if vim.fn.has("nvim-0.9") == 1 then
    wo.stc = ""
  end
end

local function project_index_at_line(state, lnum)
  local idx = lnum - state.project_start + 1
  if idx < 1 or idx > #state.projects then
    return nil
  end
  return idx
end

local function open_mini_files(dir)
  local MiniFiles = require("mini.files")
  MiniFiles.open(dir)
  MiniFiles.reveal_cwd()
  vim.defer_fn(function()
    for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
      if not api.nvim_win_is_valid(win) then
        goto continue
      end
      local buf = api.nvim_win_get_buf(win)
      if vim.bo[buf].filetype == "minifiles" then
        api.nvim_set_current_win(win)
        local pos = api.nvim_win_get_cursor(win)
        local row, col = pos[1], pos[2]
        if row and col then
          api.nvim_win_set_cursor(win, { row, math.max(0, col - CURSOR_LEFT_OFFSET) })
        end
        return
      end
      ::continue::
    end
  end, 20)
end

local function leave_picker(state, cmd, after)
  restore_ui()
  if state.bufnr and api.nvim_buf_is_valid(state.bufnr) then
    api.nvim_buf_delete(state.bufnr, { force = true })
  end
  if cmd then
    vim.cmd(cmd)
  elseif after then
    vim.schedule(after)
  else
    vim.schedule(function()
      if M.can_show_dashboard() then
        M.open(true)
      else
        focus_file_window()
      end
    end)
  end
end

local function select_project(state, idx)
  local entry = state.projects[idx]
  if not entry then
    return
  end
  local path = vim.fn.expand(entry.path)
  if vim.fn.isdirectory(path) ~= 1 then
    vim.notify("Not a directory: " .. path, vim.log.levels.ERROR)
    return
  end
  vim.cmd.cd({ args = { vim.fn.fnameescape(path) } })
  vim.g.project_picker_suppress_autopen = true
  leave_picker(state, nil, function()
    M.close_dashboard()
    open_mini_files(path)
    vim.defer_fn(function()
      vim.g.project_picker_suppress_autopen = nil
    end, 150)
  end)
end

local function clamp_cursor(state)
  local row = api.nvim_win_get_cursor(state.winid)[1]
  if row < state.project_start then
    row = state.project_start
  elseif row > state.project_end then
    row = state.project_end
  end
  local col = state.text_col or 0
  local idx = project_index_at_line(state, row)
  if idx then
    local line = api.nvim_buf_get_lines(state.bufnr, row - 1, row, false)[1] or ""
    col = project_cursor_col(line, state.projects[idx].name)
  end
  api.nvim_win_set_cursor(state.winid, { row, col })
end

local function apply_highlights(state)
  local bufnr = state.bufnr

  for i = 1, state.header_lines do
    api.nvim_buf_add_highlight(bufnr, M.ns, "DashboardHeader", i - 1, 0, -1)
  end

  for i = state.box_start, state.box_end do
    local line = api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1] or ""
    highlight_box_line(bufnr, i - 1, line)
  end

  api.nvim_buf_add_highlight(
    bufnr,
    M.ns,
    HL_TITLE,
    state.title_line - 1,
    state.title_col,
    state.title_col + #"Projects"
  )

  for i = state.project_start, state.project_end do
    local idx = i - state.project_start + 1
    local name = state.projects[idx].name
    local line = api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1] or ""
    local col = project_name_col(line, name)
    api.nvim_buf_add_highlight(bufnr, M.ns, HL_ITEM, i - 1, col, col + #name)
  end
end

local function update_project_selection_hl(state)
  if state.selection_extmark then
    api.nvim_buf_del_extmark(state.bufnr, M.ns, state.selection_extmark)
    state.selection_extmark = nil
  end

  local lnum = api.nvim_win_get_cursor(state.winid)[1]
  local idx = project_index_at_line(state, lnum)
  if not idx then
    return
  end

  local name = state.projects[idx].name
  local line = api.nvim_buf_get_lines(state.bufnr, lnum - 1, lnum, false)[1] or ""
  local col = project_name_col(line, name)
  state.selection_extmark = api.nvim_buf_set_extmark(state.bufnr, M.ns, lnum - 1, col, {
    end_row = lnum - 1,
    end_col = col + #name,
    hl_group = HL_ITEM_SEL,
    priority = 100,
  })
end

local function render(state)
  local header_raw = vim.split(require("project_picker.header"), "\n", { plain = true })
  local header = center_align(header_raw)
  state.header_lines = #header

  local box_lines = build_project_box(state.projects)

  local lines = {}
  vim.list_extend(lines, header)
  lines[#lines + 1] = ""
  vim.list_extend(lines, box_lines)

  local box_offset = state.header_lines + 2
  state.box_start = box_offset
  state.box_end = box_offset + #box_lines - 1
  state.title_line = box_offset + 1
  state.project_start = box_offset + 3
  state.project_end = state.project_start + #state.projects - 1

  api.nvim_buf_set_lines(state.bufnr, 0, -1, false, lines)

  local title_buf_line = api.nvim_buf_get_lines(state.bufnr, state.title_line - 1, state.title_line, false)[1] or ""
  state.title_col = project_name_col(title_buf_line, "Projects")
  if #state.projects > 0 then
    local pline = api.nvim_buf_get_lines(state.bufnr, state.project_start - 1, state.project_start, false)[1] or ""
    state.text_col = project_cursor_col(pline, state.projects[1].name)
  else
    state.text_col = PROJECT_PAD + 1
  end

  api.nvim_buf_clear_namespace(state.bufnr, M.ns, 0, -1)
  apply_highlights(state)

  if #state.projects > 0 then
    api.nvim_win_set_cursor(state.winid, { state.project_start, state.text_col })
    update_project_selection_hl(state)
  end
end

local function attach_keymaps(state)
  local opts = { buffer = state.bufnr, silent = true, nowait = true }

  vim.keymap.set("n", "j", function()
    vim.cmd("normal! j")
    clamp_cursor(state)
    update_project_selection_hl(state)
  end, opts)

  vim.keymap.set("n", "k", function()
    vim.cmd("normal! k")
    clamp_cursor(state)
    update_project_selection_hl(state)
  end, opts)

  vim.keymap.set("n", "<Down>", function()
    vim.cmd("normal! j")
    clamp_cursor(state)
    update_project_selection_hl(state)
  end, opts)

  vim.keymap.set("n", "<Up>", function()
    vim.cmd("normal! k")
    clamp_cursor(state)
    update_project_selection_hl(state)
  end, opts)

  vim.keymap.set("n", "<CR>", function()
    local lnum = api.nvim_win_get_cursor(state.winid)[1]
    local idx = project_index_at_line(state, lnum)
    if idx then
      select_project(state, idx)
    end
  end, opts)

  vim.keymap.set("n", "f", function()
    leave_picker(state, "Telescope find_files")
  end, opts)

  vim.keymap.set("n", "d", function()
    leave_picker(state, "Telescope find_files search_dirs=~/.config/nvim")
  end, opts)

  vim.keymap.set("n", "<Esc>", function()
    leave_picker(state)
  end, opts)
end

--- True only when no normal file buffer is open (listed or shown in a window).
function M.can_show_dashboard()
  if vim.g.project_picker_suppress_autopen then
    return false
  end

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)
    local ft = vim.bo[buf].filetype
    if ft == "minifiles" or ft == "minifiles-help" then
      return false
    end
  end

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if not api.nvim_buf_is_valid(buf) then
      goto continue
    end
    if vim.bo[buf].filetype == "dashboard" then
      goto continue
    end
    if vim.bo[buf].buftype ~= "" then
      goto continue
    end
    if vim.api.nvim_buf_get_name(buf) ~= "" and vim.bo[buf].buflisted then
      return false
    end
    ::continue::
  end

  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "dashboard" then
      goto continue
    end
    if vim.bo[buf].buftype ~= "" then
      goto continue
    end
    if vim.api.nvim_buf_get_name(buf) ~= "" then
      return false
    end
    ::continue::
  end

  return true
end

local function buffer_opens_file(buf)
  if vim.bo[buf].filetype == "dashboard" then
    return false
  end
  if vim.bo[buf].filetype == "minifiles" or vim.bo[buf].filetype == "minifiles-help" then
    return true
  end
  if vim.bo[buf].buftype ~= "" then
    return false
  end
  return vim.api.nvim_buf_get_name(buf) ~= ""
end

function M.close_dashboard()
  if vim.g.project_picker_closing then
    return false
  end
  vim.g.project_picker_closing = true

  local closed = false
  local tab_wins = api.nvim_tabpage_list_wins(0)
  for _, win in ipairs(tab_wins) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "dashboard" then
      if #tab_wins > 1 then
        pcall(api.nvim_win_close, win, true)
      end
      closed = true
    end
  end
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) and vim.bo[buf].filetype == "dashboard" then
      pcall(api.nvim_buf_delete, buf, { force = true })
      closed = true
    end
  end
  if closed then
    restore_ui()
  end

  vim.g.project_picker_closing = false
  return closed
end

local function dismiss_dashboard_for_buffer(buf)
  if vim.g.read_from_stdin ~= nil then
    return
  end
  if vim.g.project_picker_opening or vim.g.project_picker_closing then
    return
  end
  if vim.g.project_picker_suppress_autopen then
    return
  end
  if not buffer_opens_file(buf) then
    return
  end
  vim.schedule(function()
    M.close_dashboard()
  end)
end

local function window_can_host_dashboard(winid)
  if not api.nvim_win_is_valid(winid) then
    return false
  end
  if vim.wo[winid].winfixbuf then
    return false
  end
  local buf = api.nvim_win_get_buf(winid)
  local ft = vim.bo[buf].filetype
  if ft == "minifiles" or ft == "minifiles-help" then
    return false
  end
  return true
end

local function pick_dashboard_window()
  local winid = api.nvim_get_current_win()
  if window_can_host_dashboard(winid) then
    return winid
  end
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    if window_can_host_dashboard(win) then
      api.nvim_set_current_win(win)
      return win
    end
  end
  vim.cmd("split")
  return api.nvim_get_current_win()
end

local function focus_file_window()
  for _, win in ipairs(api.nvim_tabpage_list_wins(0)) do
    local buf = api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype ~= "dashboard" and vim.api.nvim_buf_get_name(buf) ~= "" then
      api.nvim_set_current_win(win)
      return true
    end
  end
  return false
end
---@param manual boolean|nil When true, skip argc check (still requires no open files).
function M.open(manual)
  if not manual and vim.fn.argc() > 0 then
    return
  end

  if not M.can_show_dashboard() then
    return
  end

  if vim.g.project_picker_opening then
    return
  end
  vim.g.project_picker_opening = true

  local function finish_open()
    vim.g.project_picker_opening = false
  end

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(win)
    if vim.bo[buf].filetype == "dashboard" then
      vim.api.nvim_set_current_win(win)
      finish_open()
      return
    end
  end

  local projects = require("project_picker.projects")
  if #projects == 0 then
    vim.notify("project_picker.projects is empty", vim.log.levels.ERROR)
    finish_open()
    return
  end

  save_ui()
  apply_picker_ui()

  local winid = pick_dashboard_window()
  api.nvim_set_current_win(winid)

  local bufnr
  local cur_buf = api.nvim_win_get_buf(winid)
  if vim.api.nvim_buf_get_name(cur_buf) == "" and vim.bo[cur_buf].modifiable then
    bufnr = cur_buf
  else
    bufnr = api.nvim_create_buf(false, true)
    api.nvim_win_set_buf(winid, bufnr)
  end

  local state = {
    bufnr = bufnr,
    winid = winid,
    projects = projects,
  }

  set_buf_options(bufnr)
  set_win_options(state.winid)
  render(state)
  lock_dashboard_buffer(bufnr)
  attach_keymaps(state)

  api.nvim_create_autocmd("VimResized", {
    group = api.nvim_create_augroup("ProjectPickerResize", { clear = true }),
    buffer = bufnr,
    callback = function()
      vim.bo[bufnr].modifiable = true
      render(state)
      lock_dashboard_buffer(bufnr)
      clamp_cursor(state)
      update_project_selection_hl(state)
    end,
  })

  api.nvim_create_autocmd("BufLeave", {
    once = true,
    buffer = bufnr,
    callback = function()
      restore_ui()
    end,
  })

  finish_open()
end

function M.setup()
  api.nvim_create_augroup("ProjectPicker", { clear = true })

  M.setup_highlights()
  api.nvim_create_autocmd("ColorScheme", {
    group = "ProjectPicker",
    callback = M.setup_highlights,
  })

  api.nvim_create_autocmd("BufModifiedSet", {
    group = "ProjectPicker",
    callback = function(event)
      if not event.modified then
        return
      end
      if vim.bo[event.buf].filetype ~= "dashboard" then
        return
      end
      vim.bo[event.buf].modified = false
    end,
  })

  api.nvim_create_autocmd("User", {
    group = "ProjectPicker",
    pattern = { "MiniFilesExplorerOpen", "MiniFilesExplorerClose" },
    callback = function()
      vim.schedule(function()
        M.close_dashboard()
      end)
    end,
  })

  api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
    group = "ProjectPicker",
    callback = function(args)
      local buf = args.buf or api.nvim_get_current_buf()
      dismiss_dashboard_for_buffer(buf)

      if args.event == "WinEnter" or buf ~= api.nvim_get_current_buf() then
        return
      end

      if vim.g.read_from_stdin ~= nil then
        return
      end
      if buffer_opens_file(buf) then
        return
      end

      if vim.bo[buf].buftype ~= "" then
        return
      end
      if vim.bo[buf].filetype == "dashboard" then
        return
      end
      if api.nvim_buf_get_name(buf) ~= "" then
        return
      end
      if vim.g.project_picker_opening then
        return
      end
      if not M.can_show_dashboard() then
        return
      end
      vim.schedule(function()
        M.open(true)
      end)
    end,
  })

  api.nvim_create_autocmd("BufReadPost", {
    group = "ProjectPicker",
    callback = function(args)
      dismiss_dashboard_for_buffer(args.buf)
    end,
  })

  api.nvim_create_autocmd("VimEnter", {
    group = "ProjectPicker",
    callback = function()
      for _, v in pairs(vim.v.argv) do
        if v == "-" then
          vim.g.read_from_stdin = 1
          break
        end
      end
    end,
  })

  api.nvim_create_user_command("Dashboard", function()
    M.open(true)
  end, { desc = "Open project picker" })

  api.nvim_create_autocmd("UIEnter", {
    group = "ProjectPicker",
    once = true,
    callback = function()
      if vim.g.read_from_stdin ~= nil then
        return
      end
      if vim.fn.argc() ~= 0 then
        return
      end
      if api.nvim_buf_get_name(0) ~= "" then
        return
      end
      if vim.bo.filetype == "dashboard" then
        return
      end
      if not M.can_show_dashboard() then
        return
      end
      M.open()
    end,
  })
end

return M
