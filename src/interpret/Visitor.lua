local switch = require 'util.switch'

local function check_types(expected, token, ...)
  local operands = { ... }
  for _, operand in ipairs(operands) do
    if type(operand) ~= expected then
      error({
        token = token,
        message = #operands > 1 and
        'Operands must be ' .. expected .. 's.' or
        'Operand must be a ' .. expected .. '.'
      })
    end
  end
end

return function(env)
  local function visit(node)
    return ({
      unary = function()
        local left = visit(node.left)
        return switch(node.operator.type, {
          MINUS = function()
            check_types('number', node.operator, left)
            return -left
          end,
          BANG = function()
            check_types('boolean', node.operator, left)
            return not left
          end
        })
      end,

      binary = function()
        local left, right = visit(node.left), visit(node.right)

        return switch(node.operator.type, {
          PLUS = function()
            if type(left) == 'number' and type(right) == 'number' then
              return left + right
            elseif type(left) == 'string' and type(right) == 'string' then
              return left .. right
            end

            error({
              token = node.operator,
              message = 'Operands must be two numbers or two strings.'
            })
          end,
          EQUAL_EQUAL = function() return left == right end,
          BANG_EQUAL = function() return left ~= right end,
          [switch.default] = function()
            check_types('number', node.operator, left, right)
            return switch(node.operator.type, {
              MINUS = function() return left - right end,
              STAR = function() return left * right end,
              SLASH = function() return left / right end,
              GREATER = function() return left > right end,
              GREATER_EQUAL = function() return left >= right end,
              LESS = function() return left < right end,
              LESS_EQUAL = function() return left <= right end,
            })
          end
        })
      end,

      grouping = function()
        return visit(node.expression)
      end,

      literal = function()
        return node.value
      end,

      print = function()
        print(visit(node.value))
      end,

      var = function()
        env.define(node.name.lexeme, visit(node.initializer))
      end,

      variable = function()
        if env.has(node.name.lexeme) then
          return env.get(node.name.lexeme)
        else
          error({
            token = node.name,
            message = "Undefined variable '" .. node.name.lexeme .. "'."
          })
        end
      end,

      assign = function()
        if env.has(node.name.lexeme) then
          env.set(node.name.lexeme, visit(node.value))
        else
          error({
            token = node.name,
            message = "Undefined variable '" .. node.name.lexeme .. "'."
          })
        end
      end,

      block = function()
        env.add_scope()

        pcall(function()
          for _, statement in ipairs(node.statements) do
            visit(statement)
          end
        end)

        env.remove_scope()
      end
    })[node.class]()
  end

  return {
    visit = visit
  }
end
