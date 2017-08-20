local Visitor = require 'interpret.Visitor'
local Environment = require 'interpret.Environment'

return function(error_reporter)
  local env = Environment()
  local visitor = Visitor(env)

  env.define('clock', {
    arity = function()
      return 0
    end,

    call = function()
      return os.time()
    end
  })

  return {
    interpret = function(statements)
      local ok, result

      for _, statement in ipairs(statements) do
        ok, result = pcall(function()
          return visitor.visit(statement)
        end)

        if not ok then error_reporter(result) end
      end

      return result
    end
  }
end
