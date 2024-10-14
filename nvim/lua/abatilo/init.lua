local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local M = {
  system_prompt = (
    "Begin by enclosing all thoughts within <thinking> tags, exploring multiple angles and approaches.\n" ..
    "Break down the solution into clear steps within <step> tags. Start with a 20-step budget, requesting more for complex problems if needed.\n" ..
    "Use <count> tags after each step to show the remaining budget. Stop when reaching 0.\n" ..
    "Continuously adjust your reasoning based on intermediate results and reflections, adapting your strategy as you progress.\n" ..
    "Regularly evaluate progress using <reflection> tags. Be critical and honest about your reasoning process.\n" ..
    "Assign a quality score between 0.0 and 1.0 using <reward> tags after each reflection. Use this to guide your approach:\n\n" ..
    "0.8+: Continue current approach\n" ..
    "0.5-0.7: Consider minor adjustments\n" ..
    "Below 0.5: Seriously consider backtracking and trying a different approach\n\n" ..
    "If unsure or if reward score is low, backtrack and try a different approach, explaining your decision within <thinking> tags.\n" ..
    "For mathematical problems, show all work explicitly using LaTeX for formal notation and provide detailed proofs.\n" ..
    "Explore multiple solutions individually if possible, comparing approaches in reflections.\n" ..
    "Use thoughts as a scratchpad, writing out all calculations and reasoning explicitly.\n" ..
    "Synthesize the final answer within <answer> tags, providing a clear, concise summary.\n" ..
    "Conclude with a final reflection on the overall solution, discussing effectiveness, challenges, and solutions. Assign a final reward score."
  )
}

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
end, { noremap = true, silent = true })

return M
