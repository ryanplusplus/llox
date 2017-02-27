package.path = package.path .. ';src/?.lua'

local scan = require 'scan'

local had_error

local function report(line, where, message)
  io.stderr:write('[line ' .. line .. '] Error' .. where .. ': ' .. message .. '\n')
  had_error = true
end

local function err(line, message)
  report(line, '', message)
end

local function run(source)
  for token in scan(source, err) do
    print(tostring(token))
  end
end

local function read_file(path)
  local f = io.open(file, 'r')
  assert(f, 'file ' .. file .. ' does not exist or cannot be opened')
  local contents = f:read('*all')
  f:close()
  return contents
end

local function run_file(path)
  run(read_file(path))
  if had_error then
    os.exit(65)
  end
end

local function run_prompt()
  while true do
    io.write('> ')
    run(io.read())
    had_error = false
  end
end

if #arg > 1 then
  print('Usage: lox [script]')
elseif #arg == 1 then
  run_file(arg[1])
else
  run_prompt()
end
