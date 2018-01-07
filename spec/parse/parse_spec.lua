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

  it('should parse this', function()
    assert.are.same({
      {
        class = 'this',
        keyword = {
          lexeme = 'this',
          line = 1,
          type = 'THIS'
        }
      }
    }, parse(scan('this;'), load''))
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

  it('should parse whiles', function()
    assert.are.same({
      {
        class = 'while',
        condition = {
          class = 'literal',
          value = true
        },
        body = {
          class = 'print',
          value = {
            class = 'literal',
            value = 3
          }
        }
      }
    }, parse(scan('while(true) print 3;')))
  end)

  it('should parse fors', function()
    assert.are.same({
      {
        class = 'block',
        statements = {
          {
            class = 'var',
            name = {
              lexeme = 'i',
              line = 1,
              type = 'IDENTIFIER'
            },
            initializer = {
              class = 'literal',
              value = 0
            }
          },
          {
            class = 'while',
            condition = {
              class = 'literal',
              value = false
            },
            body = {
              class = 'block',
              statements = {
                {
                  class = 'print',
                  value = {
                    class = 'literal',
                    value = 3
                  }
                },
                {
                  class = 'assign',
                  name = {
                    lexeme = 'i',
                    line = 1,
                    type = 'IDENTIFIER'
                  },
                  value = {
                    class = 'literal',
                    value = 1
                  }
                }
              }
            }
          }
        }
      }
    }, parse(scan('for(var i = 0; false; i = 1) print 3;')))
  end)

  it('should parse fors without initializers', function()
    assert.are.same({
      {
        class = 'while',
        condition = {
          class = 'literal',
          value = false
        },
        body = {
          class = 'block',
          statements = {
            {
              class = 'print',
              value = {
                class = 'literal',
                value = 3
              }
            },
            {
              class = 'assign',
              name = {
                lexeme = 'i',
                line = 1,
                type = 'IDENTIFIER'
              },
              value = {
                class = 'literal',
                value = 1
              }
            }
          }
        }
      }
    }, parse(scan('for(; false; i = 1) print 3;')))
  end)

  it('should parse fors without conditions', function()
    assert.are.same({
      {
        class = 'block',
        statements = {
          {
            class = 'var',
            name = {
              lexeme = 'i',
              line = 1,
              type = 'IDENTIFIER'
            },
            initializer = {
              class = 'literal',
              value = 0
            }
          },
          {
            class = 'while',
            condition = {
              class = 'literal',
              value = true
            },
            body = {
              class = 'block',
              statements = {
                {
                  class = 'print',
                  value = {
                    class = 'literal',
                    value = 3
                  }
                },
                {
                  class = 'assign',
                  name = {
                    lexeme = 'i',
                    line = 1,
                    type = 'IDENTIFIER'
                  },
                  value = {
                    class = 'literal',
                    value = 1
                  }
                }
              }
            }
          }
        }
      }
    }, parse(scan('for(var i = 0; ; i = 1) print 3;')))
  end)

  it('should parse fors without increments', function()
    assert.are.same({
      {
        class = 'block',
        statements = {
          {
            class = 'var',
            name = {
              lexeme = 'i',
              line = 1,
              type = 'IDENTIFIER'
            },
            initializer = {
              class = 'literal',
              value = 0
            }
          },
          {
            class = 'while',
            condition = {
              class = 'literal',
              value = false
            },
            body = {
              class = 'print',
              value = {
                class = 'literal',
                value = 3
              }
            }
          }
        }
      }
    }, parse(scan('for(var i = 0; false;) print 3;')))
  end)

  it('should parse empty fors', function()
    assert.are.same({
      {
        class = 'while',
        condition = {
          class = 'literal',
          value = true
        },
        body = {
          class = 'print',
          value = {
            class = 'literal',
            value = 3
          }
        }
      }
    }, parse(scan('for(;;) print 3;')))
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

  it('should parse function calls', function()
    assert.are.same({
      {
        class = 'call',
        callee = {
          class = 'variable',
          name = {
            lexeme = 'foo',
            line = 1,
            type = 'IDENTIFIER'
          }
        },
        paren = {
          lexeme = ')',
          line = 1,
          type = 'RIGHT_PAREN'
        },
        arguments = {
          {
            class = 'literal',
            value = 1
          },
          {
            class = 'literal',
            value = true
          }
        }
      }
    }, parse(scan('foo(1, true);')))
  end)

  it('should parse curried function calls', function()
    assert.are.same({
      {
        class = 'call',
        callee = {
          class = 'call',
          callee = {
            class = 'variable',
            name = {
              lexeme = 'foo',
              line = 1,
              type = 'IDENTIFIER'
            }
          },
          paren = {
            lexeme = ')',
            line = 1,
            type = 'RIGHT_PAREN'
          },
          arguments = {
            {
              class = 'literal',
              value = 1
            }
          }
        },
        paren = {
          lexeme = ')',
          line = 1,
          type = 'RIGHT_PAREN'
        },
        arguments = {
          {
            class = 'literal',
            value = true
          }
        }
      }
    }, parse(scan('foo(1)(true);')))
  end)

  it('should parse function definitions', function()
    assert.are.same({
      {
        class = 'function',
        name = {
          lexeme = 'f',
          line = 1,
          type = 'IDENTIFIER'
        },
        parameters = {
          {
            lexeme = 'a',
            line = 1,
            type = 'IDENTIFIER'
          },
          {
            lexeme = 'b',
            line = 1,
            type = 'IDENTIFIER'
          }
        },
        body = {
          class = 'block',
          statements = {
            {
              class = 'print',
              value = {
                class = 'variable',
                name = {
                  lexeme = 'a',
                  line = 1,
                  type = 'IDENTIFIER'
                }
              }
            },
            {
              class = 'print',
              value = {
                class = 'variable',
                name = {
                  lexeme = 'b',
                  line = 1,
                  type = 'IDENTIFIER'
                }
              }
            },
          }
        }
      }
    }, parse(scan('fun f(a, b) { print a; print b; }')))
  end)

  it('should parse class definitions', function()
    assert.are.same({
      {
        class = 'class',
        name = {
          lexeme = 'MyClass',
          line = 1,
          type = 'IDENTIFIER'
        },
        methods = {
          {
            class = 'function',
            name = {
              lexeme = 'foo',
              line = 1,
              type = 'IDENTIFIER'
            },
            parameters = {},
            body = {
              class = 'block',
              statements = {
                {
                  class = 'print',
                  value = {
                    class = 'literal',
                    value = 'foo'
                  }
                }
              }
            }
          },
          {
            class = 'function',
            name = {
              lexeme = 'bar',
              line = 1,
              type = 'IDENTIFIER'
            },
            parameters = {},
            body = {
              class = 'block',
              statements = {
                {
                  class = 'print',
                  value = {
                    class = 'literal',
                    value = 'bar'
                  }
                }
              }
            }
          }
        }
      }
    }, parse(scan('class MyClass { foo() { print "foo"; } bar() { print "bar"; } }')))
  end)

  it('should parse gets', function()
    assert.are.same({
      {
        class = 'class',
        name = {
          lexeme = 'MyClass',
          line = 1,
          type = 'IDENTIFIER'
        },
        methods = {}
      },
      {
        class = 'var',
        initializer = {
          class = 'call',
          arguments = {},
          callee = {
            class = 'variable',
            name = {
              lexeme = 'MyClass',
              line = 1,
              type = 'IDENTIFIER'
            }
          },
          paren = {
            lexeme = ')',
            line = 1,
            type = 'RIGHT_PAREN'
          }
        },
        name = {
          lexeme = 'o',
          line = 1,
          type = 'IDENTIFIER'
        }
      },
      {
        class = 'print',
        value = {
          class = 'get',
          name = {
            lexeme = 'foo',
            line = 1,
            type = 'IDENTIFIER'
          },
          object = {
            class = 'variable',
            name = {
              lexeme = 'o',
              line = 1,
              type = 'IDENTIFIER'
            }
          }
        }
      }
    }, parse(scan('class MyClass {} var o = MyClass(); print o.foo;')))
  end)

  it('should parse sets', function()
    assert.are.same({
      {
        class = 'class',
        name = {
          lexeme = 'MyClass',
          line = 1,
          type = 'IDENTIFIER'
        },
        methods = {}
      },
      {
        class = 'var',
        initializer = {
          class = 'call',
          arguments = {},
          callee = {
            class = 'variable',
            name = {
              lexeme = 'MyClass',
              line = 1,
              type = 'IDENTIFIER'
            }
          },
          paren = {
            lexeme = ')',
            line = 1,
            type = 'RIGHT_PAREN'
          }
        },
        name = {
          lexeme = 'o',
          line = 1,
          type = 'IDENTIFIER'
        }
      },
      {
        class = 'set',
        object = {
          class = 'variable',
          name = {
            lexeme = 'o',
            line = 1,
            type = 'IDENTIFIER'
          }
        },
        name = {
          lexeme = 'foo',
          line = 1,
          type = 'IDENTIFIER'
        },
        value = {
          class = 'literal',
          value = 3
        }
      }
    }, parse(scan('class MyClass {} var o = MyClass(); o.foo = 3;')))
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

  it('should require an open paren after while', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('while'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect '(' after 'while'.")
  end)

  it('should require a close paren after a while condition', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('while(true'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ')' after condition.")
  end)

  it('should require an open paren after for', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('for'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect '(' after 'for'.")
  end)

  it('should require a semicolon after the loop condition in a for', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('for(; true'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ';' after loop condition.")
  end)

  it('should require closing paren after a for clause', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('for(;; i = i + 1'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ')' after for clauses.")
  end)

  it('should generate an error if a grouping does not include a right paren', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('(3'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', "Expect ')' after expression.")
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

  it('should generate an error for too many arguments', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    parse(scan('foo(1, 2, 3, 4, 5, 6, 7, 8, 9);'), error_reporter)
    assert.spy(error_spy).was_called_with('NUMBER 9 9', 'Cannot have more than 8 arguments.')
  end)

  it('should require functions to be named', function()
    assert.has_error(function()
      parse(scan('fun () {}'))
    end)
  end)

  it('should require left paren to follow function names', function()
    assert.has_error(function()
      parse(scan('fun a) {}'))
    end)
  end)

  it('should not allow more than 8 parameters for a function', function()
    assert.has_error(function()
      parse(scan('fun foo(a, b, c, d, e, f, g, h, i) {}'))
    end)
  end)

  it('should require valid identifiers as parameter names', function()
    assert.has_error(function()
      parse(scan('fun foo(1) {}'))
    end)
  end)

  it('should require valid identifiers as parameter names', function()
    assert.has_error(function()
      parse(scan('fun foo(1) {}'))
    end)
  end)

  it('should require a right paren after parameter list', function()
    assert.has_error(function()
      parse(scan('fun foo(a {}'))
    end)
  end)

  it('should require a left brace to open a function body', function()
    assert.has_error(function()
      parse(scan('fun foo(a) }'))
    end)
  end)

  it('should require classes to be named', function()
    assert.has_error(function()
      parse(scan('class { }'))
    end)
  end)

  it('should require a left brace to open a class body', function()
    assert.has_error(function()
      parse(scan('class Foo }'))
    end)
  end)

  it('should require a right brace to close a class body', function()
    assert.has_error(function()
      parse(scan('class Foo { '))
    end)
  end)

  it('should require a property name when getting a property', function()
    assert.has_error(function()
      parse(scan('class Foo { } var foo = Foo(); foo.;'))
    end)
  end)

  it('should generate an error for invalid grammar', function()
    local error_spy = spy.new(load'')
    local error_reporter = function(token, message)
      error_spy(tostring(token), message)
    end

    assert.has_error(function()
      parse(scan('3*'), error_reporter)
    end)
    assert.spy(error_spy).was_called_with('EOF  ', 'Expect expression.')
  end)
end)
