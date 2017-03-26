describe('parse', function()
  local scan = require 'scan'
  local parse = require 'parse'

  it('should parse boolean literals', function()
    assert.are.same({
      class = 'literal',
      value = false
    }, parse(scan('false'), load''))

    assert.are.same({
      class = 'literal',
      value = true
    }, parse(scan('true'), load''))
  end)

  it('should parse number literals', function()
    assert.are.same({
      class = 'literal',
      value = 13
    }, parse(scan('13'), load''))
  end)

  it('should parse string literals', function()
    assert.are.same({
      class = 'literal',
      value = 'abc'
    }, parse(scan('"abc"'), load''))
  end)

  it('should parse nil literals', function()
    assert.are.same({
      class = 'literal',
      value = nil
    }, parse(scan('nil'), load''))
  end)

  it('should parse groupings', function()
    assert.are.same({
      class = 'grouping',
      expression = {
        class = 'literal',
        value = 3
      }
    }, parse(scan('(3)'), load''))
  end)

  it('should parse unary minus', function()
    assert.are.same({
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
    }, parse(scan('-42'), load''))
  end)

  it('should parse unary negation', function()
    assert.are.same({
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
    }, parse(scan('!true'), load''))
  end)

  it('should parse addition terms', function()
    assert.are.same({
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
    }, parse(scan('2 + 3'), load''))
  end)

  it('should parse subtraction terms', function()
    assert.are.same({
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
    }, parse(scan('4 - 1'), load''))
  end)

  it('should parse multiplication terms', function()
    assert.are.same({
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
    }, parse(scan('4 * 1'), load''))
  end)

  it('should parse division terms', function()
    assert.are.same({
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
    }, parse(scan('2 / 3'), load''))
  end)

  it('should parse greater than terms', function()
    assert.are.same({
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
    }, parse(scan('2 > 3'), load''))
  end)

  it('should parse greater or equal to terms', function()
    assert.are.same({
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
    }, parse(scan('2 >= 3'), load''))
  end)

  it('should parse less than terms', function()
    assert.are.same({
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
    }, parse(scan('2 < 3'), load''))
  end)

  it('should parse less or equal to terms', function()
    assert.are.same({
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
    }, parse(scan('2 <= 3'), load''))
  end)

  it('should parse not equal terms', function()
    assert.are.same({
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
    }, parse(scan('2 != 3'), load''))
  end)

  it('should equal terms', function()
    assert.are.same({
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
    }, parse(scan('2 == 3'), load''))
  end)

  it('should parse complicated expressions', function()
    assert.are.same({
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
    }, parse(scan('-(2 + 3) * !4'), load''))
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
