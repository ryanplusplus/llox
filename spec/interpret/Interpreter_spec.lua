describe('interpret.Interpreter', function()
  local scan = require 'scan.scan'
  local parse = require 'parse.parse'
  local Interpreter = require 'interpret.Interpreter'
  local Resolver = require 'resolve.Resolver'

  local match = require 'luassert.match'
  assert:register('matcher', 'tostringable_to', function(state, arguments)
    return function(value)
      return arguments[1] == tostring(value)
    end
  end)

  before_each(function()
    _G._print = _G.print
  end)

  after_each(function()
    _G.print = _G._print
  end)

  local function ast_for(s)
    return parse(scan(s))
  end

  local function interpret(statements, error_reporter)
    local interpreter = Interpreter(error_reporter)
    local resolver = Resolver(interpreter, error_reporter)
    resolver.resolve(statements)
    return interpreter.interpret(statements)
  end

  local function should_generate_error_for(s, expected_error)
    local error_reporter = spy.new(load'')
    interpret(ast_for(s), error_reporter)
    assert.spy(error_reporter).was_called_with(expected_error)
  end

  it('should interpret literals', function()
    assert.are.equal(3, interpret(ast_for('3;')))
    assert.are.equal(true, interpret(ast_for('true;')))
    assert.are.equal('hello', interpret(ast_for('"hello";')))
  end)

  it('should intrepret groupings', function()
    assert.are.equal(3, interpret(ast_for('(3);')))
  end)

  it('should interpret unary arithmetic negation', function()
    assert.are.equal(-3, interpret(ast_for('-3;')))

    should_generate_error_for('-"hello";', {
      token = { lexeme = '-', line = 1, type = 'MINUS' },
      message = 'Operand must be a number.'
    })
  end)

  it('should intrepret unary logical negation', function()
    assert.are.equal(false, interpret(ast_for('!true;')))

    should_generate_error_for('!3;', {
      token = { lexeme = '!', line = 1, type = 'BANG' },
      message = 'Operand must be a boolean.'
    })
  end)

  it('should interpret sums', function()
    assert.are.equal(7, interpret(ast_for('3 + 4;')))

    should_generate_error_for('3 + "hello";', {
      token = { lexeme = '+', line = 1, type = 'PLUS' },
      message = 'Operands must be two numbers or two strings.'
    })
  end)

  it('should intrepret differences', function()
    assert.are.equal(-1, interpret(ast_for('3 - 4;')))

    should_generate_error_for('3 - "4";', {
      token = { lexeme = '-', line = 1, type = 'MINUS' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" - 4;', {
      token = { lexeme = '-', line = 1, type = 'MINUS' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret products', function()
    assert.are.equal(12, interpret(ast_for('3 * 4;')))

    should_generate_error_for('3 * "4";', {
      token = { lexeme = '*', line = 1, type = 'STAR' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" * 4;', {
      token = { lexeme = '*', line = 1, type = 'STAR' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret quotients', function()
    assert.are.equal(3 / 4, interpret(ast_for('3 / 4;')))

    should_generate_error_for('3 / "4";', {
      token = { lexeme = '/', line = 1, type = 'SLASH' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" / 4;', {
      token = { lexeme = '/', line = 1, type = 'SLASH' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret string concatenation', function()
    assert.are.equal('hello, world', interpret(ast_for('"hello" + ", world";')))

    should_generate_error_for('"hello" + 3;', {
      token = { lexeme = '+', line = 1, type = 'PLUS' },
      message = 'Operands must be two numbers or two strings.'
    })
  end)

  it('should interpret greater than comparisons', function()
    assert.are.equal(true, interpret(ast_for('4 > 3;')))
    assert.are.equal(false, interpret(ast_for('1 > 3;')))
    assert.are.equal(false, interpret(ast_for('3 > 3;')))

    should_generate_error_for('3 > "4";', {
      token = { lexeme = '>', line = 1, type = 'GREATER' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" > 4;', {
      token = { lexeme = '>', line = 1, type = 'GREATER' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret greater than or equal comparisons', function()
    assert.are.equal(true, interpret(ast_for('4 >= 3;')))
    assert.are.equal(false, interpret(ast_for('1 >= 3;')))
    assert.are.equal(true, interpret(ast_for('3 >= 3;')))

    should_generate_error_for('3 >= "4";', {
      token = { lexeme = '>=', line = 1, type = 'GREATER_EQUAL' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" >= 4;', {
      token = { lexeme = '>=', line = 1, type = 'GREATER_EQUAL' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret less than comparisons', function()
    assert.are.equal(false, interpret(ast_for('4 < 3;')))
    assert.are.equal(true, interpret(ast_for('1 < 3;')))
    assert.are.equal(false, interpret(ast_for('3 < 3;')))

    should_generate_error_for('3 < "4";', {
      token = { lexeme = '<', line = 1, type = 'LESS' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" < 4;', {
      token = { lexeme = '<', line = 1, type = 'LESS' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret less than or equal comparisons', function()
    assert.are.equal(false, interpret(ast_for('4 <= 3;')))
    assert.are.equal(true, interpret(ast_for('1 <= 3;')))
    assert.are.equal(true, interpret(ast_for('3 <= 3;')))

    should_generate_error_for('3 <= "4";', {
      token = { lexeme = '<=', line = 1, type = 'LESS_EQUAL' },
      message = 'Operands must be numbers.'
    })

    should_generate_error_for('"3" <= 4;', {
      token = { lexeme = '<=', line = 1, type = 'LESS_EQUAL' },
      message = 'Operands must be numbers.'
    })
  end)

  it('should interpret equality expressions', function()
    assert.are.equal(false, interpret(ast_for('4 == 3;')))
    assert.are.equal(true, interpret(ast_for('3 == 3;')))
    assert.are.equal(false, interpret(ast_for('"3" == 3;')))
    assert.are.equal(false, interpret(ast_for('3 == "3";')))
    assert.are.equal(false, interpret(ast_for('false == true;')))
    assert.are.equal(true, interpret(ast_for('false == false;')))
    assert.are.equal(true, interpret(ast_for('true == true;')))
    assert.are.equal(false, interpret(ast_for('"hello" == "goodbye";')))
    assert.are.equal(true, interpret(ast_for('"hello" == "hello";')))
  end)

  it('should interpret inequality expressions', function()
    assert.are.equal(true, interpret(ast_for('4 != 3;')))
    assert.are.equal(false, interpret(ast_for('3 != 3;')))
    assert.are.equal(true, interpret(ast_for('"3" != 3;')))
    assert.are.equal(true, interpret(ast_for('3 != "3";')))
    assert.are.equal(true, interpret(ast_for('false != true;')))
    assert.are.equal(false, interpret(ast_for('false != false;')))
    assert.are.equal(false, interpret(ast_for('true != true;')))
    assert.are.equal(true, interpret(ast_for('"hello" != "goodbye";')))
    assert.are.equal(false, interpret(ast_for('"hello" != "hello";')))
  end)

  it('should interpret print statements', function()
    _G.print = spy.new(load'')
    interpret(ast_for('print 3;'))
    assert.spy(_G.print).was_called_with(3)
  end)

  it('should interpret variable declaration and use', function()
    _G.print = spy.new(load'')
    interpret(ast_for('var a = 42; print a;'))
    assert.spy(_G.print).was_called_with(42)
  end)

  it('should interpret variable assignments', function()
    _G.print = spy.new(load'')
    interpret(ast_for('var a = 42; a = 5; print a;'))
    assert.spy(_G.print).was_called_with(5)
  end)

  it('should allow variables to be nil', function()
    _G.print = spy.new(load'')
    interpret(ast_for('var a = nil; print a;'))
    assert.spy(_G.print).was_called_with(nil)
  end)

  it('should implement block scope for variables', function()
    _G.print = spy.new(load'')
    interpret(ast_for([[
      var a = 42;
      {
        var a = 5;
        print a;
      }
      print a;
    ]]))
    assert.spy(_G.print).was_called_with(5)
    assert.spy(_G.print).was_called_with(42)
  end)

  it('should interpret ifs that are true', function()
    _G.print = spy.new(load'')
    interpret(ast_for('if(true) print 5;'))
    assert.spy(_G.print).was_called_with(5)
  end)

  it('should interpret ifs that are false', function()
    _G.print = spy.new(load'')
    interpret(ast_for('if(false) print 5;'))
    assert.spy(_G.print).was_not_called()
  end)

  it('should interpret if-elses that are false', function()
    _G.print = spy.new(load'')
    interpret(ast_for('if(false) print 5; else print 21;'))
    assert.spy(_G.print).was_called_with(21)
  end)

  it('should interpret whiles', function()
    _G.print = spy.new(load'')
    interpret(ast_for('var a = 1; while(a < 3) { print a; a = a + 1; } print "out";'))
    assert.spy(_G.print).was_called_with(1)
    assert.spy(_G.print).was_called_with(2)
    assert.spy(_G.print).was_called_with('out')
  end)

  it('should interpret fors', function()
    _G.print = spy.new(load'')
    interpret(ast_for('for(var a = 1; a < 3; a = a + 1) { print a; } print "out";'))
    assert.spy(_G.print).was_called_with(1)
    assert.spy(_G.print).was_called_with(2)
    assert.spy(_G.print).was_called_with('out')
  end)

  it('should interpret logical ors', function()
    _G.print = spy.new(load'')

    interpret(ast_for('print (3 or 5);'))
    assert.spy(_G.print).was_called_with(3)

    interpret(ast_for('print (false or 4);'))
    assert.spy(_G.print).was_called_with(4)
  end)

  it('should interpret logical ands', function()
    _G.print = spy.new(load'')

    interpret(ast_for('print (3 and 4);'))
    assert.spy(_G.print).was_called_with(4)

    interpret(ast_for('print (false and 4);'))
    assert.spy(_G.print).was_called_with(false)
  end)

  it('should error for undefined variables', function()
    should_generate_error_for('print a;', {
      token = { lexeme = 'a', line = 1, type = 'IDENTIFIER' },
      message = "Undefined variable 'a'."
    })

    should_generate_error_for('a = 4;', {
      token = { lexeme = 'a', line = 1, type = 'IDENTIFIER' },
      message = "Undefined variable 'a'."
    })
  end)

  it('should interpret function calls', function()
    _G.print = spy.new(load'')

    interpret(ast_for('print(clock());'))
    assert.spy(_G.print).was_called()
  end)

  it('should interpret function definitions', function()
    _G.print = spy.new(load'')

    interpret(ast_for('fun f(a) { print a; } f(1);'))
    assert.spy(_G.print).was_called_with(1)
  end)

  it('should interpret recursive function calls', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      fun fibonacci(n) {
        if (n <= 1) return n;
        return fibonacci(n - 2) + fibonacci(n - 1);
      }

      print fibonacci(6);
    ]]))
    assert.spy(_G.print).was_called_with(8)
  end)

  it('should support closures', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      fun makeCounter() {
        var i = 0;
        fun count() {
          i = i + 1;
          print i;
        }

        return count;
      }

      var counter = makeCounter();
      counter();
      counter();
    ]]))
    assert.spy(_G.print).was_called_with(2)
    assert.spy(_G.print).was_called_with(1)
  end)

  it('should interpret return statements', function()
    _G.print = spy.new(load'')

    interpret(ast_for('fun f(a) { return a; } print(f(1));'))
    assert.spy(_G.print).was_called_with(1)
  end)

  it('should interpret class declarations', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      class DevonshireCream {
        serveOn() {
          return "Scones";
        }
      }

      print DevonshireCream;
    ]]))
    assert.spy(_G.print).was_called_with(match.is_tostringable_to('DevonshireCream'))
  end)

  it('should interpret getting and setting fields', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      class MyClass {}
      var o = MyClass();
      o.foo = 3;
      print o.foo;
    ]]))
    assert.spy(_G.print).was_called_with(3)
  end)

  it('should only allow property lookup on objects', function()
    local code = [[
      var o = 3;
      print o.foo;
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'foo', line = 2, type = 'IDENTIFIER' },
      message = 'Only instances have properties.'
    })
  end)

  it('should only allow setting fields on objects', function()
    local code = [[
      var o = 3;
      o.foo = 4;
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'foo', line = 2, type = 'IDENTIFIER' },
      message = 'Only instances have fields.'
    })
  end)

  it('should allow methods to be called', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      class Bacon {
        eat() {
          print "Crunch crunch crunch!";
        }
      }

      Bacon().eat();
    ]]))
    assert.spy(_G.print).was_called_with('Crunch crunch crunch!')
  end)

  it('should resolve this correctly within a method', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      class Cake {
        taste() {
          var adjective = "delicious";
          print "The " + this.flavor + " cake is " + adjective + "!";
        }
      }

      var cake = Cake();
      cake.flavor = "German chocolate";
      cake.taste();
    ]]))
    assert.spy(_G.print).was_called_with('The German chocolate cake is delicious!')
  end)

  it('should allow inherited methods to be called', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      class Doughnut {
        cook() {
          print "Fry until golden brown.";
        }
      }

      class BostonCream < Doughnut {}

      BostonCream().cook();
    ]]))
    assert.spy(_G.print).was_called_with('Fry until golden brown.')
  end)

  it('should allow methods to be called on the superclass via super', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      class Doughnut {
        cook() {
          print "Fry until golden brown.";
        }
      }

      class BostonCream < Doughnut {
        cook() {
          super.cook();
          print "Pipe full of custard and coat with chocolate.";
        }
      }

      BostonCream().cook();
    ]]))
    assert.spy(_G.print).was_called_with('Fry until golden brown.')
    assert.spy(_G.print).was_called_with('Pipe full of custard and coat with chocolate.')
  end)

  it('should properly resolve scope', function()
    _G.print = spy.new(load'')

    interpret(ast_for([[
      var a = "global";
      {
        fun showA() {
          print a;
        }

        showA();
        var a = "block";
        showA();
      }
    ]]))
    assert.spy(_G.print).was_called_with('global')
    assert.spy(_G.print).was_called_with('global')
  end)

  it('should not allow a variable to be re-declared', function()
    local code = [[
      fun bad() {
        var a = "first";
        var a = "second";
      }
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'a', line = 3, type = 'IDENTIFIER' },
      message = 'Variable with this name already declared in this scope.'
    })
  end)

  it('should not allow a top-level return', function()
    should_generate_error_for('return "top level";', {
      token = { lexeme = 'return', line = 1, type = 'RETURN' },
      message = 'Cannot return from top-level code.'
    })
  end)

  it('should not allow a return from an initializer', function()
    local code = [[
      class Foo {
        init() {
          return "something else";
        }
      }
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'return', line = 3, type = 'RETURN' },
      message = 'Cannot return a value from an initializer.'
    })
  end)

  it('should not allow this to be used outside of a class', function()
    should_generate_error_for('print this;', {
      token = { lexeme = 'this', line = 1, type = 'THIS' },
      message = "Cannot use 'this' outside of a class."
    })
  end)

  it('should require superclasses to be classes', function()
    local code = [[
      var Bar = 3;
      class Foo < Bar {}
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'Foo', line = 2, type = 'IDENTIFIER' },
      message = 'Superclass must be a class.'
    })
  end)

  it('should error for an invalid superclass method', function()
    local code = [[
      class Doughnut {
        cook() {
          print "Fry until golden brown.";
        }
      }

      class BostonCream < Doughnut {
        cook() {
          super.foo();
          print "Pipe full of custard and coat with chocolate.";
        }
      }

      BostonCream().cook();
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'foo', line = 9, type = 'IDENTIFIER' },
      message = "Undefined property 'foo'."
    })
  end)

  it('should error for super used outside of a class', function()
    local code = [[
      super.foo();
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'super', line = 1, type = 'SUPER' },
      message = "Cannot use 'super' outside of a class."
    })
  end)

  it('should error for super used in a class with no superclass', function()
    local code = [[
      class Foo {
        init() {
          super.foo();
        }
      }
    ]]

    should_generate_error_for(code, {
      token = { lexeme = 'super', line = 3, type = 'SUPER' },
      message = "Cannot use 'super' in a class with no superclass."
    })
  end)
end)
