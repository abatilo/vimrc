local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

vim.keymap.set('n', '<leader>asp', function()
  pickers.new({}, {
    prompt_title = "Avante Models",
    finder = finders.new_table({
      results = {
        "claude",
        "deepseek",
        "dracarys",
        "openai",
        "qwen",
      }
      -- https://github.com/nvim-telescope/telescope.nvim/blob/master/developers.md#entry-maker
      -- results = vim.tbl_keys(providers),
      -- entry_maker = function(entry)
      --   return {
      --     value = entry,
      --     display = entry,
      --     ordinal = entry,
      --   }
      -- end,
    }),
    sorter = require("telescope.config").values.generic_sorter({}),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        print("Selected provider: " .. selection.value)
        require("avante.api").switch_provider(selection.value)
      end)
      return true
    end,
  }):find()
end)
