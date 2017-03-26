describe('tostring_visitor', function()
  local tostring_visitor = require 'tostring_visitor'

  it('should print literal nodes', function()
    local node = { class = 'literal', value = 'hello' }
    assert.are.equal('hello', tostring_visitor(node))
  end)

  it('should print grouping nodes', function()
    local node = { class = 'grouping', expression = { class = 'literal', value = 3 } }
    assert.are.equal('(group 3)', tostring_visitor(node))
  end)

  it('should print unary nodes', function()
    local node = { class = 'unary', operator = { lexeme = '-' }, left = { class = 'literal', value = 4 } }
    assert.are.equal('(- 4)', tostring_visitor(node))
  end)

  it('should print binary nodes', function()
    local node = {
      class = 'binary',
      operator = { lexeme = '*' },
      left = { class = 'literal', value = 3 },
      right = { class = 'literal', value = 4 }
    }
    assert.are.equal('(* 3 4)', tostring_visitor(node))
  end)

  it('should print a mix of nodes', function()
    local node = {
      class = 'binary',
      operator = { lexeme = '*' },
      left = {
        class = 'grouping',
        expression = {
          class = 'binary',
          operator = { lexeme = '+' },
          left = {
            class = 'unary',
            operator = { lexeme = '-' },
            left = { class = 'literal', value = 3 }
          },
          right = { class = 'literal', value = 5 }
        }
      },
      right = { class = 'literal', value = 4 }
    }
    assert.are.equal('(* (group (+ (- 3) 5)) 4)', tostring_visitor(node))
  end)
end)
