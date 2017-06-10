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
      consume('RIGHT_PAREN', "Expect ')' after ")
      return {
        class = 'grouping',
        expression = expr
      }
    end

    error(ParseError(peek(), 'Expect '))
  end

  local function unary()
    if match({ 'BANG', 'MINUS' }) then
      return {
        class = 'unary',
        operator = previous(),
        left = unary()
      }
    end

    return primary()
  end

  local factor = LeftAssociativeBinary({ 'SLASH', 'STAR' }, unary)
  local term = LeftAssociativeBinary({ 'MINUS', 'PLUS' }, factor)
  local comparison = LeftAssociativeBinary({ 'GREATER', 'GREATER_EQUAL', 'LESS', 'LESS_EQUAL' }, term)
  local equality = LeftAssociativeBinary({ 'BANG_EQUAL', 'EQUAL_EQUAL' }, comparison)

  expression = equality

  -- private Stmt printStatement() {
  --     Expr value = expression();
  --     consume(SEMICOLON, "Expect ';' after value.");
  --     return new Stmt.Print(value);
  --   }

  local function print_statement()
    local value = expression()
    consume('SEMICOLON', "Expect ';' after value.")
    return {
      class = 'print',
      value = value
    }
  end

  local function expression_statement()
    local expression = expression()
    consume('SEMICOLON', "Expect ';' after expression.")
    return expression
  end

  local function statement()
    if match({ 'PRINT' }) then return print_statement() end
    return expression_statement()
  end

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

  local function declaration()
    local ok, result = pcall(function()
      if match({ 'VAR' }) then
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
