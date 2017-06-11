local function Scope(parent)
  return {
    parent = parent,
    defined = {},
    values = {}
  }
end

return function()
  local scope = Scope()

  local function scope_with(name)
    local _scope = scope

    while _scope do
      if _scope.defined[name] then
        return _scope
      else
        _scope = _scope.parent
      end
    end
  end

  return {
    define = function(name, value)
      scope.defined[name] = true
      scope.values[name] = value
    end,

    get = function(name)
      return scope_with(name).values[name]
    end,

    set = function(name, value)
      scope_with(name).values[name] = value
    end,

    has = function(name)
      return scope_with(name) ~= nil
    end,

    add_scope = function()
      scope = Scope(scope)
    end,

    remove_scope = function()
      scope = scope.parent
    end
  }
end
