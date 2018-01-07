local Instance = require 'interpret.Instance'

return function(name, methods)
  local o = setmetatable({}, {
    __tostring = function()
      return name
    end
  })

  o.name = name

  o.arity = function()
    return 0
  end

  o.call = function(interpret, arguments)
    return Instance(o)
  end

  o.find_method = function(instance, name)
    return methods[name]
  end

  return o
end
