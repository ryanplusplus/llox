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

    has = function(name)
      return defined[name]
    end
  }
end
