local M = {}

local function term_bottom(cmd)
  local h = math.floor(vim.o.lines / 2)
  vim.cmd("botright " .. h .. "split | terminal " .. cmd)
end

function M.run_file()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file to run", vim.log.levels.WARN)
    return
  end

  local ft = vim.bo.filetype
  local cmd

  -- helpers for compiled languages
  local function temp_exe(name)
    local out = vim.fn.fnamemodify(file, ":t:r")
    local exe = vim.fn.tempname() .. "_" .. out .. (vim.fn.has("win32") == 1 and ".exe" or "")
    return exe
  end

  if ft == "python" then
    cmd = "python " .. vim.fn.fnameescape(file)

  elseif ft == "javascript" then
    cmd = "node " .. vim.fn.fnameescape(file)

  elseif ft == "sh" or ft == "bash" then
    cmd = "bash " .. vim.fn.fnameescape(file)

  elseif ft == "lua" then
    cmd = "lua " .. vim.fn.fnameescape(file)

  elseif ft == "c" then
    local exe = temp_exe()
    -- gcc or clang
    cmd = ("gcc %s -O2 -g -o %s && %s")
      :format(vim.fn.fnameescape(file), vim.fn.fnameescape(exe), vim.fn.fnameescape(exe))

  elseif ft == "cpp" then
    local exe = temp_exe()
    -- g++ or clang++
    cmd = ("g++ %s -std=c++20 -O2 -g -o %s && %s")
      :format(vim.fn.fnameescape(file), vim.fn.fnameescape(exe), vim.fn.fnameescape(exe))

  elseif ft == "cs" then
    -- run C# project in current working directory (recommended)
    cmd = "dotnet run"
  
  elseif ft == "java" then
    local dir = vim.fn.fnamemodify(file, ":p:h")
    local filename = vim.fn.fnamemodify(file, ":t")
    local classname = vim.fn.fnamemodify(file, ":t:r")

    -- detect package name from file
    local package = nil
    for line in io.lines(file) do
      local p = line:match("^%s*package%s+([%w%.]+)%s*;")
      if p then
        package = p
        break
      end
    end

    -- move to project root (one folder above dir)
    local root = vim.fn.fnamemodify(dir, ":h")

    if package then
      cmd = ("cd %s && javac -d . %s/%s && java %s.%s")
        :format(
          vim.fn.fnameescape(root),
          vim.fn.fnameescape(vim.fn.fnamemodify(dir, ":t")),
          vim.fn.fnameescape(filename),
          package,
          classname
        )
    else
      cmd = ("cd %s && javac %s && java %s")
        :format(
          vim.fn.fnameescape(dir),
          vim.fn.fnameescape(filename),
          classname
        )
    end
  else
    vim.notify("No runner configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  term_bottom(cmd)
end

return M

