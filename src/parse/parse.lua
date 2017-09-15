return function(tokens, error_reporter)
  local current = 1

  local function ParseError(token, message)
    error_reporter(token, message)
    return 'parse_error'
  end

  local function peek()
    return tokens[current]
  end

  local function previous()
    return tokens[current - 1]
  end

  local function at_end()
    return peek().type == 'EOF'
  end

  local function check(type)
    if at_end() then return false end
    return peek().type == type
  end

  local function advance()
    if not at_end() then
      current = current + 1
    end
    return previous()
  end

  local function match(types)
    for _, type in ipairs(types) do
      if check(type) then
        advance()
        return true
      end
    end

    return false
  end

  local function consume(type, message)
    if check(type) then return advance() end
    error(ParseError(peek(), message))
  end

  local function synchronize()
    advance();

    while not at_end() do
      if previous().type == 'SEMICOLON' then return end

      if peek().type == 'CLASS' or
        peek().type == 'FUN' or
        peek().type == 'VAR' or
        peek().type == 'FOR' or
        peek().type == 'IF' or
        peek().type == 'WHILE' or
        peek().type == 'PRINT' or
        peek().type == 'RETURN' then
        return
      end

      advance()
    end
  end

  local function LeftAssociativeBinary(token_types, expression_type)
    return function()
      local expr = expression_type()

      while match(token_types) do
        expr = {
          class = 'binary',
          operator = previous(),
          left = expr,
          right = expression_type()
        }
      end

      return expr
    end
  end

  local expression
  local declaration

  local function primary()
    if match({ 'FALSE' }) then return { class = 'literal', value = false } end
    if match({ 'TRUE' }) then return { class = 'literal', value = true } end
    if match({ 'NIL' }) then return { class = 'literal', value = nil } end
    if match({ 'NUMBER', 'STRING' }) then return { class = 'literal', value = previous().literal } end
    if match({ 'IDENTIFIER' }) then
      return {
        class = 'variable',
        name = previous()
      }
    end
    if match({ 'LEFT_PAREN' }) then
      local expr = expression()
      consume('RIGHT_PAREN', "Expect ')' after expression.")
      return {
        class = 'grouping',
        expression = expr
      }
    end

    error(ParseError(peek(), 'Expect expression.'))
  end

  local function finish_call(callee)
    local arguments = {}
    if not check('RIGHT_PAREN') then
      repeat
        if #arguments >= 8 then
          ParseError(peek(), 'Cannot have more than 8 arguments.')
        end
        table.insert(arguments, expression())
      until not match({ 'COMMA' })
    end

    local paren = consume('RIGHT_PAREN', "Expect ')' after arguments.")

    return {
      class = 'call',
      callee = callee,
      paren = paren,
      arguments = arguments
    }
  end

  local function call()
    local expr = primary()

    while true do
      if match({ 'LEFT_PAREN' }) then
        expr = finish_call(expr)
      else
        break
      end
    end

    return expr
  end

  local function unary()
    if match({ 'BANG', 'MINUS' }) then
      return {
        class = 'unary',
        operator = previous(),
        left = unary()
      }
    end

    return call()
  end

  local factor = LeftAssociativeBinary({ 'SLASH', 'STAR' }, unary)
  local term = LeftAssociativeBinary({ 'MINUS', 'PLUS' }, factor)
  local comparison = LeftAssociativeBinary({ 'GREATER', 'GREATER_EQUAL', 'LESS', 'LESS_EQUAL' }, term)
  local equality = LeftAssociativeBinary({ 'BANG_EQUAL', 'EQUAL_EQUAL' }, comparison)

  local function and_expression()
    local expression = equality()

    while match({ 'AND' }) do
      local operator = previous()
      local right = equality()
      expression = {
        class = 'logical',
        operator = operator,
        left = expression,
        right = right
      }
    end

    return expression
  end

  local function or_expression()
    local expression = and_expression()

    while match({ 'OR' }) do
      local operator = previous()
      local right = and_expression()
      expression = {
        class = 'logical',
        operator = operator,
        left = expression,
        right = right
      }
    end

    return expression
  end

  local function assignment()
    local expression = or_expression()

    if match({ 'EQUAL' }) then
      local equals = previous()
      local value = assignment()

      if expression.class == 'variable' then
        local name = expression.name
        return {
          class = 'assign',
          name = name,
          value = value
        }
      end

      error(ParseError(equals, 'Invalid assignment target.'))
    end

    return expression
  end

  expression = assignment

  local statement

  local function var_declaration()
    local name = consume('IDENTIFIER', 'Expect variable name.')

    local initializer do
      if match({ 'EQUAL' }) then
        initializer = expression()
      end
    end

    consume('SEMICOLON', "Expect ';' after variable declaration.")

    return {
      class = 'var',
      name = name,
      initializer = initializer
    }
  end

  local function for_statement()
    consume('LEFT_PAREN', "Expect '(' after 'for'.")

    local initializer
    if match({ 'VAR' }) then
      initializer = var_declaration()
    elseif not match({ 'SEMICOLON' }) then
      initializer = expression_statement()
    end

    local condition
    if not check('SEMICOLON') then
      condition = expression()
    end
    consume('SEMICOLON', "Expect ';' after loop condition.")

    local increment
    if not check('RIGHT_PAREN') then
      increment = expression()
    end
    consume('RIGHT_PAREN', "Expect ')' after for clauses.")

    local body = statement()

    if increment then
      body = {
        class = 'block',
        statements = { body, increment }
      }
    end

    if not condition then
      condition = {
        class = 'literal',
        value = true
      }
    end
    body = {
      class = 'while',
      condition = condition,
      body = body
    }

    if initializer then
      body = {
        class = 'block',
        statements = { initializer, body }
      }
    end

    return body
  end

  local function if_statement()
    consume('LEFT_PAREN', "Expect '(' after 'if'.")
    local condition = expression()
    consume('RIGHT_PAREN', "Expect ')' after if condition.")

    local then_branch = statement()
    local else_branch

    if match({ 'ELSE' }) then
      else_branch = statement()
    end

    return {
      class = 'if',
      condition = condition,
      then_branch = then_branch,
      else_branch = else_branch
    }
  end

  local function print_statement()
    local value = expression()
    consume('SEMICOLON', "Expect ';' after value.")
    return {
      class = 'print',
      value = value
    }
  end

  local function while_statement()
    consume('LEFT_PAREN', "Expect '(' after 'while'.")
    local condition = expression()
    consume('RIGHT_PAREN', "Expect ')' after condition.")
    local body = statement()

    return {
      class = 'while',
      condition = condition,
      body = body
    }
  end

  local function expression_statement()
    local expression = expression()
    consume('SEMICOLON', "Expect ';' after expression.")
    return expression
  end

  local function block()
    local statements = {}

    while not check('RIGHT_BRACE') and not at_end() do
      table.insert(statements, declaration())
    end

    consume('RIGHT_BRACE', "Expect '}' after block.")

    return {
      class = 'block',
      statements = statements
    }
  end

  statement = function()
    if match({ 'FOR' }) then return for_statement() end
    if match({ 'IF' }) then return if_statement() end
    if match({ 'PRINT' }) then return print_statement() end
    if match({ 'WHILE' }) then return while_statement() end
    if match({ 'LEFT_BRACE' }) then return block() end
    return expression_statement()
  end

  local function _function(kind)
    local name = consume('IDENTIFIER', 'Expect ' .. kind .. ' name.')

    consume('LEFT_PAREN', "Expect '(' after " .. kind .. " name.");

    local parameters = {} do
      if not check('RIGHT_PAREN') then
        repeat
          if #parameters >= 8 then
            ParseError(peek(), 'Cannot have more than 8 parameters.')
          end
          table.insert(parameters, consume('IDENTIFIER', 'Expect parameter name.'))
        until not match({ 'COMMA' })
      end
    end

    consume('RIGHT_PAREN', "Expect ')' after parameters.")
    consume('LEFT_BRACE', "Expect '{' before " .. kind .. " body.")

    local body = block()

    return {
      class = 'function',
      name = name,
      parameters = parameters,
      body = body
    }
  end

  declaration = function()
    local ok, result = pcall(function()
      if match({ 'FUN' }) then
        return _function('function')
      elseif match({ 'VAR' }) then
        return var_declaration()
      else
        return statement()
      end
    end)

    if not ok then
      synchronize()
      -- fixme should be `return nil` but causes tests to fail (probably because implementation is incomplete)
      error(result)
    end

    return result
  end

  local statements = {}

  while not at_end() do
    local success, ast = pcall(function()
      return declaration()
    end)

    if success then
      table.insert(statements, ast)
    else
      if ast == 'parse_error' then return end
      error(ast)
    end
  end

  return statements
end
