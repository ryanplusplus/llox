describe('parse.parse', function()
  local scan = require 'scan.scan'
  local parse = require 'parse.parse'

  it('should parse boolean literals', function()
    assert.are.same({
      {
        class = 'literal',
        value = false
      }
    }, parse(scan('false;'), load''))

    assert.are.same({
      {
        class = 'literal',
        value = true
      }
    }, parse(scan('true;'), load''))
  end)

  it('should parse number literals', function()
    assert.are.same({
      {
        class = 'literal',
        value = 13
      }
    }, parse(scan('13;'), load''))
  end)

  it('should parse string literals', function()
    assert.are.same({
      {
        class = 'literal',
        value = 'abc'
      }
    }, parse(scan('"abc";'), load''))
  end)

  it('should parse nil literals', function()
    assert.are.same({
      {
        class = 'literal',
        value = nil
      }
    }, parse(scan('nil;'), load''))
  end)

  it('should parse groupings', function()
    assert.are.same({
      {
        class = 'grouping',
        expression = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('(3);'), load''))
  end)

  it('should parse unary minus', function()
    assert.are.same({
      {
        class = 'unary',
        operator = {
          lexeme = '-',
          line = 1,
          type = 'MINUS'
        },
        left = {
          class = 'literal',
          value = 42
        }
      }
    }, parse(scan('-42;'), load''))
  end)

  it('should parse unary negation', function()
    assert.are.same({
      {
        class = 'unary',
        operator = {
          lexeme = '!',
          line = 1,
          type = 'BANG'
        },
        left = {
          class = 'literal',
          value = true
        }
      }
    }, parse(scan('!true;'), load''))
  end)

  it('should parse addition terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '+',
          line = 1,
          type = 'PLUS'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 + 3;'), load''))
  end)

  it('should parse subtraction terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '-',
          line = 1,
          type = 'MINUS'
        },
        left = {
          class = 'literal',
          value = 4
        },
        right = {
          class = 'literal',
          value = 1
        }
      }
    }, parse(scan('4 - 1;'), load''))
  end)

  it('should parse multiplication terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '*',
          line = 1,
          type = 'STAR'
        },
        left = {
          class = 'literal',
          value = 4
        },
        right = {
          class = 'literal',
          value = 1
        }
      }
    }, parse(scan('4 * 1;'), load''))
  end)

  it('should parse division terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '/',
          line = 1,
          type = 'SLASH'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 / 3;'), load''))
  end)

  it('should parse greater than terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '>',
          line = 1,
          type = 'GREATER'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 > 3;'), load''))
  end)

  it('should parse greater or equal to terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '>=',
          line = 1,
          type = 'GREATER_EQUAL'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 >= 3;'), load''))
  end)

  it('should parse less than terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '<',
          line = 1,
          type = 'LESS'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 < 3;'), load''))
  end)

  it('should parse less or equal to terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '<=',
          line = 1,
          type = 'LESS_EQUAL'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 <= 3;'), load''))
  end)

  it('should parse not equal terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '!=',
          line = 1,
          type = 'BANG_EQUAL'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 != 3;'), load''))
  end)

  it('should equal terms', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '==',
          line = 1,
          type = 'EQUAL_EQUAL'
        },
        left = {
          class = 'literal',
          value = 2
        },
        right = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('2 == 3;'), load''))
  end)

  it('should parse complicated expressions', function()
    assert.are.same({
      {
        class = 'binary',
        operator = {
          lexeme = '*',
          line = 1,
          type = 'STAR'
        },
        left = {
          class = 'unary',
          operator = {
            lexeme = '-',
            line = 1,
            type = 'MINUS'
          },
          left = {
            class = 'grouping',
            expression = {
              class = 'binary',
              operator = {
                lexeme = '+',
                line = 1,
                type = 'PLUS'
              },
              left = {
                class = 'literal',
                value = 2
              },
              right = {
                class = 'literal',
                value = 3
              }
            }
          }
        },
        right = {
          class = 'unary',
          operator = {
            lexeme = '!',
            line = 1,
            type = 'BANG'
          },
          left = {
            class = 'literal',
            value = 4
          }
        }
      }
    }, parse(scan('-(2 + 3) * !4;'), load''))
  end)

  it('should parse print statements', function()
    assert.are.same({
      {
        class = 'print',
        value = {
          class = 'literal',
          value = true
        }
      }
    }, parse(scan('print true;'), load''))
  end)

  it('should parse variable declarations', function()
    assert.are.same({
      {
        class = 'var',
        name = {
          lexeme = 'foo',
          line = 1,
          type = 'IDENTIFIER'
        }
      }
    }, parse(scan('var foo;'), load''))
  end)

  it('should parse initialized variable declarations', function()
    assert.are.same({
      {
        class = 'var',
        name = {
          lexeme = 'foo',
          line = 1,
          type = 'IDENTIFIER'
        },
        initializer = {
          class = 'literal',
          value = 4
        }
      }
    }, parse(scan('var foo = 4;'), load''))
  end)

  it('should parse variable expressions', function()
    assert.are.same({
      {
        class = 'variable',
        name = {
          lexeme = 'foo',
          line = 1,
          type = 'IDENTIFIER'
        }
      }
    }, parse(scan('foo;'), load''))
  end)

  it('should parse assignment expressions', function()
    assert.are.same({
      {
        class = 'assign',
        name = {
          lexeme = 'foo',
          line = 1,
          type = 'IDENTIFIER'
        },
        value = {
          class = 'literal',
          value = 4
        }
      }
    }, parse(scan('foo = 4;'), load''))
  end)

  it('should parse blocks', function()
    assert.are.same({
      {
        class = 'block',
        statements = {
          {
            class = 'literal',
            value = 4
          },
          {
            class = 'literal',
            value = 5
          }
        }
      }
    }, parse(scan('{ 4; 5; }')))
  end)

  it('should parse ifs', function()
    assert.are.same({
      {
        class = 'if',
        condition = {
          class = 'literal',
          value = true
        },
        then_branch = {
          class = 'print',
          value = {
            class = 'literal',
            value = 3
          }
        }
      }
    }, parse(scan('if(true) print 3;')))
  end)

  it('should parse if-elses', function()
    assert.are.same({
      {
        class = 'if',
        condition = {
          class = 'literal',
          value = true
        },
        then_branch = {
          class = 'print',
          value = {
            class = 'literal',
            value = 3
          }
        },
        else_branch = {
          class = 'print',
          value = {
            class = 'literal',
            value = 4
          }
        }
      }
    }, parse(scan('if(true) print 3; else print 4;')))
  end)

  it('should parse logical ors', function()
    assert.are.same({
      {
        class = 'logical',
        operator = {
          lexeme = 'or',
          type = 'OR',
          line = 1
        },
        left = {
          class = 'literal',
          value = 1
        },
        right = {
          class = 'literal',
          value = 2
        }
      }
    }, parse(scan('1 or 2;')))
  end)

  it('should parse logical ands', function()
    assert.are.same({
      {
        class = 'logical',
        operator = {
          lexeme = 'and',
          type = 'AND',
          line = 1
        },
        left = {
          class = 'literal',
          value = 1
        },
        right = {
          class = 'literal',
          value = 2
        }
      }
    }, parse(scan('1 and 2;')))
  end)

  it('should require a semicolon after expression statements', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('3'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ';' after expression.")
  end)

  it('should require a semicolon after print statements', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('print 3'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ';' after value.")
  end)

  it('should require a semicolon after variable declarations', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('var a'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ';' after variable declaration.")
  end)

  it('should require a variable name after `var`', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('var'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', 'Expect variable name.')
  end)

  it('should require an open paren after if', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('if'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect '(' after 'if'.")
  end)

  it('should require a close paren after an if condition', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('if(true'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ')' after if condition.")
  end)

  it('should generate an error if a grouping does not include a right paren', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('(3'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ')' after ")
  end)

  it('should generate an error for invalid assignment targets', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('3 = 4;'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EQUAL = ', 'Invalid assignment target.')
  end)

  it('should generate an error for invalid grammar', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('3*'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', 'Expect ')
  end)
end)
