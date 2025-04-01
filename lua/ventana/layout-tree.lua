local M = {}  -- helper module for window layout management

local function tab_contains_floating_wins()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then   -- floating windows have relative positioning
      return true
    end
  end
  return false
end

-- gets the count of focusable non-floating windows
function M.get_num_normal_wins()
  local normal_wins = vim.fn.filter(
    vim.api.nvim_tabpage_list_wins(vim.api.nvim_get_current_tabpage()),
    function(_, winid)
      local win_config = vim.api.nvim_win_get_config(winid)
      return win_config.relative == "" and win_config.focusable
    end
  )
  return #normal_wins
end

-- add additional info to leafs
local function gen_layout_tree(winlayout)
  if winlayout[1] == "leaf" then
    local type, winid = unpack(winlayout)

    local l = {
      type  = type,
      bufnr = vim.fn.winbufnr(winid),
      winnr = vim.fn.win_id2win(winid),
      winid = winid,
      win_dims = { vim.fn.winheight(winid), vim.fn.winwidth(winid) }  -- window dimensions: { n_rows, n_cols }
    }
    return l
  else
    local children = {}
    for _, child in ipairs(winlayout[2]) do
      table.insert(children, gen_layout_tree(child))
    end
    return { type = winlayout[1], children = children }
  end
end

function M.get()
  if tab_contains_floating_wins() then
    print('Usage Warning: please first close your floating window(s)')
    return
  end

  -- An example of vim.fn.winlayout()'s return structure:
  -- {
  --   "row", {
  --     { "leaf", <winid> },
  --     { "col",
  --       {
  --         { "leaf", <winid> },
  --         { "leaf", <winid> },
  --       }
  --     },
  --   }
  -- }
  local winlayout = vim.fn.winlayout()
  return gen_layout_tree(winlayout)
end

function M.is_linear_layout(lotr)
  if lotr.type == "row" or lotr.type == "col" then
    for _, child in ipairs(lotr.children) do
      if child.type ~= "leaf" then
        return false
      end
    end
  end
  return true   -- NOTE: if `lotr.type == "leaf"`, `true` will be returned
end

local function apply_layout_tree(lotr)
  if lotr.type == "leaf" then
    -- open the previous buffer
    if vim.fn.bufexists(lotr.bufnr) then
      vim.cmd.buffer(lotr.bufnr)
    end
  else
    -- split cols or rows, split n-1 times
    local split_method = ({
      row = "rightbelow vsplit",
      col = "rightbelow split",
    })[lotr.type]
    local wins = { vim.fn.win_getid() }

    for i in ipairs(lotr.children) do
      if i ~= 1 then
        vim.cmd(split_method)
        table.insert(wins, vim.fn.win_getid())
      end
    end

    -- recurse into child windows
    for idx, win in ipairs(wins) do
      vim.fn.win_gotoid(win)
      apply_layout_tree(lotr.children[idx])
    end
  end
end

function M.set(lotr)
  -- make a new window and set it as the only one
  vim.cmd.new()
  vim.cmd.only()
  local tmp_buf = vim.api.nvim_get_current_buf()

  -- apply provided layout-tree
  apply_layout_tree(lotr)

  -- delete temporary buffer
  vim.cmd.bdelete(tmp_buf)
end

return M
