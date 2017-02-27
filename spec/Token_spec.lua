describe('Token', function()
  local Token = require 'Token'

  it('should make the type, lexeme, literal and line available', function()
    local token = Token('type', 'lexeme', 'literal', 'line')
    assert.are.equal('type', token.type)
    assert.are.equal('lexeme', token.lexeme)
    assert.are.equal('literal', token.literal)
    assert.are.equal('line', token.line)
  end)

  it('should be tostringable', function()
    local token = Token('type', 'lexeme', 'literal', 'line')
    assert.are.equal('type lexeme literal', tostring(token))
  end)

  it('should be tostringable even without a literal', function()
    local token = Token('type', 'lexeme', nil, 'line')
    assert.are.equal('type lexeme ', tostring(token))
  end)
end)
