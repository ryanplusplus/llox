return function()
  local defined = {}
  local values = {}

  return {
    define = function(name, value)
      defined[name] = true
      values[name] = value
    end,

    get = function(name)
      return values[name]
    end,

    set = function(name, value)
      values[name] = value
    end,

    has = function(name)
      return defined[name]
    end
  }
end
