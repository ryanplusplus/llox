local function Scope(parent)
  local scope = {
    parent = parent,
    defined = {},
    values = {}
  }

  scope.with = function(name)
    if scope.defined[name] then
      return scope
    elseif scope.parent then
      return scope.parent.with(name)
    end
  end

  return scope
end

return function()
  local scope = Scope()

  return {
    define = function(name, value)
      scope.defined[name] = true
      scope.values[name] = value
    end,

    get = function(name)
      return scope.with(name).values[name]
    end,

    set = function(name, value)
      scope.with(name).values[name] = value
    end,

    has = function(name)
      return scope.with(name) ~= nil
    end,

    add_scope = function()
      scope = Scope(scope)
    end,

    remove_scope = function()
      scope = scope.parent
    end
  }
end
