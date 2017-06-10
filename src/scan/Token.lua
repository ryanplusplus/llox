return function(type, lexeme, literal, line)
  return setmetatable({
    type = type,
    lexeme = lexeme,
    literal = literal,
    line = line
  }, {
    __tostring = function()
      return type .. ' ' .. lexeme .. ' ' .. (literal or '')
    end
  })
end
