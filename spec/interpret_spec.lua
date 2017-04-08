describe('interpret', function()
  local scan = require 'scan'
  local parse = require 'parse'
  local interpret = require 'interpret'

  local function ast_for(s)
    return parse(scan(s))
  end

  it('should interpret literals', function()
    assert.are.equal(3, interpret(ast_for('3')))
    assert.are.equal(true, interpret(ast_for('true')))
    assert.are.equal('hello', interpret(ast_for('"hello"')))
  end)

  it('should intrepret groupings', function()
    assert.are.equal(3, interpret(ast_for('(3)')))
  end)

  it('should interpret unary arithmetic negation', function()
    assert.are.equal(-3, interpret(ast_for('-3')))
  end)

  it('should intrepret unary logical negation', function()
    assert.are.equal(false, interpret(ast_for('!true')))
  end)

  it('should evaluate sums', function()
    assert.are.equal(7, interpret(ast_for('3 + 4')))
  end)

  it('should intrepret differences', function()
    assert.are.equal(-1, interpret(ast_for('3 - 4')))
  end)

  it('should evaluate products', function()
    assert.are.equal(12, interpret(ast_for('3 * 4')))
  end)

  it('should evaluate quotients', function()
    assert.are.equal(3 / 4, interpret(ast_for('3 / 4')))
  end)

  it('should evaluation string concatenation', function()
    assert.are.equal('hello, world', interpret(ast_for('"hello" + ", world"')))
  end)

  it('should evaluate greater than comparisons', function()
    assert.are.equal(true, interpret(ast_for('4 > 3')))
    assert.are.equal(false, interpret(ast_for('1 > 3')))
    assert.are.equal(false, interpret(ast_for('3 > 3')))
  end)

  it('should evaluate greater than or equal comparisons', function()
    assert.are.equal(true, interpret(ast_for('4 >= 3')))
    assert.are.equal(false, interpret(ast_for('1 >= 3')))
    assert.are.equal(true, interpret(ast_for('3 >= 3')))
  end)

  it('should evaluate less than comparisons', function()
    assert.are.equal(false, interpret(ast_for('4 < 3')))
    assert.are.equal(true, interpret(ast_for('1 < 3')))
    assert.are.equal(false, interpret(ast_for('3 < 3')))
  end)

  it('should evaluate less than or equal comparisons', function()
    assert.are.equal(false, interpret(ast_for('4 <= 3')))
    assert.are.equal(true, interpret(ast_for('1 <= 3')))
    assert.are.equal(true, interpret(ast_for('3 <= 3')))
  end)

  it('should evaluate equality expressionss', function()
    assert.are.equal(false, interpret(ast_for('4 == 3')))
    assert.are.equal(true, interpret(ast_for('3 == 3')))
    assert.are.equal(false, interpret(ast_for('"3" == 3')))
    assert.are.equal(false, interpret(ast_for('3 == "3"')))
    assert.are.equal(false, interpret(ast_for('false == true')))
    assert.are.equal(true, interpret(ast_for('false == false')))
    assert.are.equal(true, interpret(ast_for('true == true')))
    assert.are.equal(false, interpret(ast_for('"hello" == "goodbye"')))
    assert.are.equal(true, interpret(ast_for('"hello" == "hello"')))
  end)

  it('should evaluate inequality expressionss', function()
    assert.are.equal(true, interpret(ast_for('4 != 3')))
    assert.are.equal(false, interpret(ast_for('3 != 3')))
    assert.are.equal(true, interpret(ast_for('"3" != 3')))
    assert.are.equal(true, interpret(ast_for('3 != "3"')))
    assert.are.equal(true, interpret(ast_for('false != true')))
    assert.are.equal(false, interpret(ast_for('false != false')))
    assert.are.equal(false, interpret(ast_for('true != true')))
    assert.are.equal(true, interpret(ast_for('"hello" != "goodbye"')))
    assert.are.equal(false, interpret(ast_for('"hello" != "hello"')))
  end)
end)
