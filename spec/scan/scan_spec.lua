describe('scan', function()
  local scan = require 'scan.scan'
  local Token = require 'scan.Token'

  local function input(s)
    return {
      should_generate_tokens = function(expected)
        assert.are.same(expected, scan(s, load''))
      end
    }
  end

  it('should scan an empty string', function()
    input('').should_generate_tokens({
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan parens', function()
    input('()').should_generate_tokens({
      Token('LEFT_PAREN', '(', nil, 1),
      Token('RIGHT_PAREN', ')', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan braces', function()
    input('{}').should_generate_tokens({
      Token('LEFT_BRACE', '{', nil, 1),
      Token('RIGHT_BRACE', '}', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan commas', function()
    input(',').should_generate_tokens({
      Token('COMMA', ',', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan dots', function()
    input('.').should_generate_tokens({
      Token('DOT', '.', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan minuses', function()
    input('-').should_generate_tokens({
      Token('MINUS', '-', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan pluses', function()
    input('+').should_generate_tokens({
      Token('PLUS', '+', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan semicolons', function()
    input(';').should_generate_tokens({
      Token('SEMICOLON', ';', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan stars', function()
    input('*').should_generate_tokens({
      Token('STAR', '*', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan bang equals', function()
    input('!=').should_generate_tokens({
      Token('BANG_EQUAL', '!=', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan bangs', function()
    input('!').should_generate_tokens({
      Token('BANG', '!', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan equal equals', function()
    input('==').should_generate_tokens({
      Token('EQUAL_EQUAL', '==', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan equals', function()
    input('=').should_generate_tokens({
      Token('EQUAL', '=', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan less equals', function()
    input('<=').should_generate_tokens({
      Token('LESS_EQUAL', '<=', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan lesses', function()
    input('<').should_generate_tokens({
      Token('LESS', '<', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan greater equals', function()
    input('>=').should_generate_tokens({
      Token('GREATER_EQUAL', '>=', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan greaters', function()
    input('>').should_generate_tokens({
      Token('GREATER', '>', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan slashes', function()
    input('/').should_generate_tokens({
      Token('SLASH', '/', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan comments', function()
    input('// blah blah blah').should_generate_tokens({
      Token('EOF', '', nil, 1)
    })
  end)

  it('should end comments after a newline', function()
    input('// blah blah blah\n,').should_generate_tokens({
      Token('COMMA', ',', nil, 2),
      Token('EOF', '', nil, 2)
    })
  end)

  it('should delimit tokens with whitespace', function()
    input('/ /\t,\r.').should_generate_tokens({
      Token('SLASH', '/', nil, 1),
      Token('SLASH', '/', nil, 1),
      Token('COMMA', ',', nil, 1),
      Token('DOT', '.', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan strings', function()
    input('"abc"').should_generate_tokens({
      Token('STRING', '"abc"', 'abc', 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should detect unterminated strings', function()
    local error_reporter = spy.new(load'')
    scan('"abc', error_reporter)
    assert.spy(error_reporter).was_called_with(1, 'Unterminated string.')
  end)

  it('should scan tokens from multiple lines', function()
    input('/\n/').should_generate_tokens({
      Token('SLASH', '/', nil, 1),
      Token('SLASH', '/', nil, 2),
      Token('EOF', '', nil, 2)
    })
  end)

  it('should detect unexpected characters', function()
    local error_reporter = spy.new(load'')
    scan('^', error_reporter)
    assert.spy(error_reporter).was_called_with(1, 'Unexpected character.')
  end)

  it('should scan numbers', function()
    input('9 1.2 .3 1.').should_generate_tokens({
      Token('NUMBER', '9', 9, 1),
      Token('NUMBER', '1.2', 1.2, 1),
      Token('DOT', '.', nil, 1),
      Token('NUMBER', '3', 3, 1),
      Token('NUMBER', '1', 1, 1),
      Token('DOT', '.', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan identifiers', function()
    input('a a9 _1').should_generate_tokens({
      Token('IDENTIFIER', 'a', nil, 1),
      Token('IDENTIFIER', 'a9', nil, 1),
      Token('IDENTIFIER', '_1', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should scan keywords', function()
    input('and class else false for fun if nil or print return super this true var while').should_generate_tokens({
      Token('AND', 'and', nil, 1),
      Token('CLASS', 'class', nil, 1),
      Token('ELSE', 'else', nil, 1),
      Token('FALSE', 'false', nil, 1),
      Token('FOR', 'for', nil, 1),
      Token('FUN', 'fun', nil, 1),
      Token('IF', 'if', nil, 1),
      Token('NIL', 'nil', nil, 1),
      Token('OR', 'or', nil, 1),
      Token('PRINT', 'print', nil, 1),
      Token('RETURN', 'return', nil, 1),
      Token('SUPER', 'super', nil, 1),
      Token('THIS', 'this', nil, 1),
      Token('TRUE', 'true', nil, 1),
      Token('VAR', 'var', nil, 1),
      Token('WHILE', 'while', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)

  it('should allow identifiers with a keyword prefix', function()
    input('orchid').should_generate_tokens({
      Token('IDENTIFIER', 'orchid', nil, 1),
      Token('EOF', '', nil, 1)
    })
  end)
end)
