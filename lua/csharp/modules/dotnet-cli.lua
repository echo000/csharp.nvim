local M = {}
local logger = require("csharp.log")

local function execute_command(cmd)
  local file = io.popen(cmd .. " 2>&1")
  local output = file:read("*all")
  local success, exit_reason, exit_code = file:close()

  -- If the command was successful, success will be true, and exit_code will be 0
  -- If the command failed, success will be false, and exit_code will be non-zero
  if success then
    exit_code = 0
  elseif exit_reason == "exit" then
    exit_code = exit_code -- This is already set correctly
  else
    exit_code = -1 -- Indeterminate exit code
  end
  return output, exit_code
end

--- @param target string File path to solution or project
--- @param options string[]?
--- @return boolean
function M.build(target, options)
  local command = "dotnet build " .. target

  if options then
    command = command .. " " .. table.concat(options, " ")
  end

  logger.debug("Executing: " .. command, { feature = "dotnet-cli" })

  local output, exit_code = execute_command(command)

  --- @type boolean
  local build_succeded = exit_code == 0

  if build_succeded then
  else
    logger.debug("Build failed", { feature = "dotnet-cli" })
  end

  return build_succeded
end

--- @param options string[]?
function M.run(options)
  local command = "dotnet run"

  if options then
    command = command .. " " .. table.concat(options, " ")
  end

  logger.debug("Executing: " .. command, { feature = "dotnet-cli" })
  local current_window = vim.api.nvim_get_current_win()
  vim.cmd("split | term " .. command)
  vim.api.nvim_set_current_win(current_window)
end

return M
