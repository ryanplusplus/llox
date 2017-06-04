package.path = package.path .. ';src/?.lua'

local scan = require 'scan'
local parse = require 'parse'
local interpret = require 'interpret'

local had_error, had_runtime_error

local function report(line, where, message)
  io.stderr:write('[line ' .. line .. '] Error' .. where .. ': ' .. message .. '\n')
  had_error = true
end

local function general_error(line, message)
  report(line, '', message)
end

local function parse_error(token, message)
  if token.type == 'EOF' then
    report(token.line, ' at end', message)
  else
    report(token.line, " at '" .. token.lexeme .. "'", message)
  end
end

local function runtime_error(err)
  io.stderr:write(err.message .. '\n[line ' .. err.token.line .. ']\n')
  had_runtime_error = true
end

local function run(source)
  local tokens = scan(source, general_error)
  if had_error then return end
  local statements = parse(tokens, parse_error)
  if had_error then return end
  interpret(statements, runtime_error)
  if had_runtime_error then return end
end

local function read_file(path)
  local f = io.open(path, 'r')
  assert(f, 'file ' .. path .. ' does not exist or cannot be opened')
  local contents = f:read('*all')
  f:close()
  return contents
end

local function run_file(path)
  run(read_file(path))
  if had_error then
    os.exit(65)
  end
  if had_runtime_error then
    os.exit(70)
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
