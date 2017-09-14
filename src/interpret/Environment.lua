return function(parent)
  local defined = {}
  local values = {}

  return {
    define = function(name, value)
      defined[name] = true
      values[name] = value
    end,

    get = function(name)
      if defined[name] then
        return values[name]
      else
        return parent.get(name)
      end
    end,

    set = function(name, value)
      if defined[name] then
        values[name] = value
      else
        parent.set(name, value)
      end
    end,

    has = function(name)
      if defined[name] then
        return true
      elseif parent then
        return parent.has(name)
      else
        return false
      end
    end
  }
end
