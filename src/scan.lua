local Token = require 'Token'
local switch = require 'util.switch'

local keywords = {
  ['and'] = 'AND',
  ['class'] = 'CLASS',
  ['else'] = 'ELSE',
  ['false'] = 'FALSE',
  ['for'] = 'FOR',
  ['fun'] = 'FUN',
  ['if'] = 'IF',
  ['nil'] = 'NIL',
  ['or'] = 'OR',
  ['print'] = 'PRINT',
  ['return'] = 'RETURN',
  ['super'] = 'SUPER',
  ['this'] = 'THIS',
  ['true'] = 'TRUE',
  ['var'] = 'VAR',
  ['while'] = 'WHILE'
}

return function(source, error_reporter)
  local start = 1
  local current = 1
  local line = 1
  local tokens = {}

  local function at_end()
    return current > #source
  end

  local function advance()
    current = current + 1
    return source:sub(current - 1, current - 1)
  end

  local function add_token(type, literal, text)
    text = text or source:sub(start, current - 1)
    table.insert(tokens, Token(type, text, literal, line))
  end

  local function TokenAdder(type, literal)
    return function() add_token(type, literal) end
  end

  local function match(expected)
    if at_end() then return false end
    if source:sub(current, current) ~= expected then return false end
    current = current + 1
    return true
  end

  local function peek()
    return source:sub(current, current) or '\0'
  end

  local function peek_next()
    return source:sub(current + 1, current + 1) or '\0'
  end

  local function add_slash()
    if match('/') then
      while peek() ~= '\n' and not at_end() do
        advance()
      end
    else
      add_token('SLASH')
    end
  end

  local function add_string()
    while peek() ~= '"' and not at_end() do
      if peek() == '\n' then line = line + 1 end
      advance()
    end

    if at_end() then
      error_reporter(line, 'Unterminated string.')
      return
    end

    advance()

    add_token('STRING', source:sub(start + 1, current - 2))
  end

  local function is_digit(c)
    return c:match('%d')
  end

  local function add_number()
    while is_digit(peek()) do advance() end

    if peek() == '.' and is_digit(peek_next()) then
      advance()
      while is_digit(peek()) do advance() end
    end

    add_token('NUMBER', tonumber(source:sub(start, current - 1)))
  end

  local function is_alpha(c)
    return c:match('[%a_]')
  end

  local function is_alphanumeric(c)
    return is_alpha(c) or is_digit(c)
  end

  local function add_identifier()
    while is_alphanumeric(peek()) do advance() end

    local text = source:sub(start, current - 1)
    add_token(keywords[text] or 'IDENTIFIER')
  end

  local function scan_token()
    switch(advance(), {
      ['('] = TokenAdder('LEFT_PAREN'),
      [')'] = TokenAdder('RIGHT_PAREN'),
      ['{'] = TokenAdder('LEFT_BRACE'),
      ['}'] = TokenAdder('RIGHT_BRACE'),
      [','] = TokenAdder('COMMA'),
      ['.'] = TokenAdder('DOT'),
      ['-'] = TokenAdder('MINUS'),
      ['+'] = TokenAdder('PLUS'),
      [';'] = TokenAdder('SEMICOLON'),
      ['*'] = TokenAdder('STAR'),
      ['!'] = function() add_token(match('=') and 'BANG_EQUAL' or 'BANG') end,
      ['='] = function() add_token(match('=') and 'EQUAL_EQUAL' or 'EQUAL') end,
      ['<'] = function() add_token(match('=') and 'LESS_EQUAL' or 'LESS') end,
      ['>'] = function() add_token(match('=') and 'GREATER_EQUAL' or 'GREATER') end,
      ['/'] = add_slash,
      [' '] = load'',
      ['\r'] = load'',
      ['\t'] = load'',
      ['\n'] = function() line = line + 1 end,
      ['"'] = add_string,
      [switch.default] = function(c)
        if is_digit(c) then
          add_number()
        elseif is_alpha(c) then
          add_identifier()
        else
          error_reporter(line, 'Unexpected character.')
        end
      end
    })
  end

  while not at_end() do
    start = current
    scan_token()
  end

  add_token('EOF', nil, '')

  return tokens
end
