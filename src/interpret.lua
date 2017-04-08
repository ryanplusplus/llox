local function visit(node)
  return ({
    unary = function()
      return ({
        MINUS = function()
          return -visit(node.left)
        end,
        BANG = function()
          return not visit(node.left)
        end
      })[node.operator.type]()
    end,

    binary = function()
      local left, right = visit(node.left), visit(node.right)
      return ({
        PLUS = function()
          if type(left) == 'number' and type(right) == 'number' then
            return left + right
          elseif type(left) == 'string' and type(right) == 'string' then
            return left .. right
          else
          -- ?
          end
        end,
        MINUS = function() return left - right end,
        STAR = function() return left * right end,
        SLASH = function() return left / right end,
        GREATER = function() return left > right end,
        GREATER_EQUAL = function() return left >= right end,
        LESS = function() return left < right end,
        LESS_EQUAL = function() return left <= right end,
        EQUAL_EQUAL = function() return left == right end,
        BANG_EQUAL = function() return left ~= right end
      })[node.operator.type]()
    end,

    grouping = function()
      return visit(node.expression)
    end,

    literal = function()
      return node.value
    end
  })[node.class]()
end

return visit
