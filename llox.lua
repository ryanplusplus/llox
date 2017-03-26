package.path = package.path .. ';src/?.lua'

local scan = require 'scan'
local parse = require 'parse'
local tostring_visitor = require 'tostring_visitor'

local had_error

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

local function run(source)
  local tokens = scan(source, general_error)
  local ast = parse(tokens, parse_error)
  if not had_error then
    print(tostring_visitor(ast))
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
