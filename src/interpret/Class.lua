local Instance = require 'interpret.Instance'

return function(name)
  local o = {}

  o.name = name

  o.arity = function()
    return 0
  end

  o.call = function(interpret, arguments)
    return Instance(o)
  end

  return setmetatable(o, {
    __tostring = function()
      return name
    end
  })
end
