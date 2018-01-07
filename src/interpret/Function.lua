local Environment = require 'interpret.Environment'

local function Function(node, env)
  return setmetatable({
    arity = function()
      return #node.parameters
    end,

    call = function(interpret, arguments)
      local env = Environment(env)
      for i = 1, #node.parameters do
        env.define(node.parameters[i].lexeme, arguments[i])
      end
      interpret(node.body, env)
    end,

    bind = function(instance)
      local env = Environment(env)
      env.define('this', instance)
      return Function(node, env)
    end
  }, {
    __tostring = function()
      return '<fn ' .. node.name.lexeme .. '>'
    end
  })
end

return Function
