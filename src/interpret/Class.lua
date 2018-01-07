local Instance = require 'interpret.Instance'

return function(name, methods)
  local o = setmetatable({}, {
    __tostring = function()
      return name
    end
  })

  o.name = name

  o.arity = function()
    return methods.init and methods.init.arity() or 0
  end

  o.call = function(interpret, arguments)
    local instance = Instance(o)
    if methods.init then
      methods.init.bind(instance).call(interpret, arguments)
    end
    return Instance(o)
  end

  o.find_method = function(instance, name)
    if methods[name] then
      return methods[name].bind(instance)
    end
  end

  return o
end
