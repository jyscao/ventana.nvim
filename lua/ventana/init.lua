local M = {}

local layout_tree = require("ventana.layout-tree")
local resize = require("ventana.resize")

local function _swap_split_types(lotr)
  if lotr.type ~= "leaf" then
    lotr.type = ({ col = "row", row = "col", })[lotr.type]
    for _, child in ipairs(lotr.children) do
      _swap_split_types(child)
    end
  end
end

-- flips the windows along the main diagonal, akin to a matrix transpose
function M.transpose()
  local active_winnr = vim.fn.tabpagewinnr(vim.fn.tabpagenr())

  local lotr = layout_tree.get()
  if lotr == nil then   -- user has floating window(s) open, so perform noop
    return
  end

  local resize_cmd = resize.get_cmd_for_transposed(lotr)

  -- perform the splits transpose operation & render the new layout
  _swap_split_types(lotr)
  layout_tree.set(lotr)

  vim.fn.execute(active_winnr .. 'wincmd w')
  vim.cmd(resize_cmd)
end

local function _update_winnr_after_shift(lotr, n_wins, last_len)
  if lotr.type == "leaf" then
    local updated_winnr = (lotr.winnr + last_len) % n_wins
    lotr.winnr = updated_winnr == 0 and n_wins or updated_winnr
  else
    for _, child in ipairs(lotr.children) do
      _update_winnr_after_shift(child, n_wins, last_len)
    end
  end
end

local function _shift_top_splits(lotr)
  if lotr.type ~= "leaf" then
    -- update winnr of each leaf (window); this must be done before the
    -- actual shifts, otherwise the children indices would be incorrect
    local last_child = lotr.children[#lotr.children]
    local last_len = last_child.type == "leaf" and 1 or #last_child.children
    local n_wins = layout_tree.get_num_normal_wins()
    _update_winnr_after_shift(lotr, n_wins, last_len)

    -- shift the top level splits in the layout
    local last_win = table.remove(lotr.children)
    table.insert(lotr.children, 1, last_win)
  end
end

-- TODO: handle case where same buffer is opened in multiple windows
local function get_win_by_bufnr(lotr, bufnr)
  if lotr.type == "leaf" then
    if lotr.bufnr == bufnr then
      return lotr.winid, lotr.winnr
    end
  else
    for _, child in ipairs(lotr.children) do
      local winid, winnr = get_win_by_bufnr(child, bufnr)
      if winid and winnr then
        return winid, winnr
      end
    end
  end
end

-- shifts the windows in the top level splits
function M.shift(maintain_layout_if_possible)
  local resize_cmd
  local active_bufnr = vim.fn.winbufnr(0)
  local lotr = layout_tree.get()
  if lotr == nil then   -- user has floating window(s) open, so perform noop
    return
  end

  local maintain_linear_layout = maintain_layout_if_possible and layout_tree.is_linear_layout(lotr)
  if maintain_linear_layout then
    -- getting resize_cmd here maintains the window sizes of the entire layout; this only 
    -- works for linear layouts, i.e. layouts w/ a single row or col of leaf windows only
    resize_cmd = resize.get_cmd(lotr)
  end

  -- perform the splits shifting operations & render the new layout
  _shift_top_splits(lotr)
  layout_tree.set(lotr)

  if not maintain_linear_layout then
    -- getting resize_cmd here maintains the window size for each visible buffer
    resize_cmd = resize.get_cmd(lotr)
  end

  local _, winnr = get_win_by_bufnr(lotr, active_bufnr)
  vim.fn.execute(winnr .. 'wincmd w')
  vim.cmd(resize_cmd)
end

return M
