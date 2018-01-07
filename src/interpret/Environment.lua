return function(parent)
  local defined = {}
  local values = {}

  local self

  self = {
    define = function(name, value)
      defined[name] = true
      values[name] = value
    end,

    get = function(name)
      if defined[name.lexeme] then
        return values[name.lexeme]
      elseif parent then
        return parent.get(name.lexeme)
      else
        error({
          token = name,
          message = "Undefined variable '" .. name.lexeme .. "'."
        })
      end
    end,

    get_at = function(distance, name)
      if type(name) == 'string' then
        name = { lexeme = name }
      end

      local env = self
      for i = 1, distance do
        env = env.parent
      end
      return env.values[name.lexeme]
    end,

    set = function(name, value)
      if defined[name.lexeme] then
        values[name.lexeme] = value
      elseif parent then
        parent.set(name.lexeme, value)
      else
        error({
          token = name,
          message = "Undefined variable '" .. name.lexeme .. "'."
        })
      end
    end,

    set_at = function(distance, name, value)
      local env = self
      for i = 1, distance do
        env = env.parent
      end
      env.values[name] = value
    end,

    has = function(name)
      if defined[name] then
        return true
      elseif parent then
        return parent.has(name)
      else
        return false
      end
    end,

    parent = parent,
    values = values
  }

  return self
end
