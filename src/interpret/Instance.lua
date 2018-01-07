return function(class)
  local fields = {}

  local o = setmetatable({}, {
    __tostring = function()
      return class.name .. ' instance'
    end
  })

  o.is_object = true

  o.get = function(name)
    if fields[name.lexeme] then return fields[name.lexeme] end

    local method = class.find_method(o, name.lexeme)
    if method then return method end

    error({
      token = name,
      message = "Undefined property '" .. name.lexeme .. "'."
    })
  end

  o.set = function(name, value)
    fields[name.lexeme] = value
  end

  return o
end
