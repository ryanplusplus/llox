local switch = require 'util.switch'

return function(interpreter)
  local scopes = {}

  local function begin_scope()
    table.insert(scopes, {})
  end

  local function end_scope()
    table.remove(scopes)
  end

  local function declare(name)
    if #scopes == 0 then return end
    scopes[#scopes][name.lexeme] = false
  end

  local function define(name)
    if #scopes == 0 then return end
    scopes[#scopes][name.lexeme] = true
  end

  local function resolve_local(node, name)
    for i = #scopes, 1, -1 do
      if scopes[i][name.lexeme] ~= nil then
        interpreter.resolve(node, #scopes - i)
        return
      end
    end
  end

  local visit

  local function resolve_function(node, type)
    begin_scope()
    for _, parameter in ipairs(node.parameters) do
      declare(parameter)
      define(parameter)
    end
    visit(node.body)
    end_scope()
  end

  visit = function(node)
    return switch(node.class, {
      block = function()
        begin_scope()
        for _, statement in ipairs(node.statements) do
          visit(statement)
        end
        end_scope()
      end,

      var = function()
        declare(node.name)
        if node.initializer ~= nil then
          visit(node.initializer)
        end
        define(node.name)
      end,

      variable = function()
        if #scopes > 0 and scopes[#scopes][node.name.lexeme] == false then
          error({
            token = node.name,
            message = 'Cannot read local variable in its own initializer.'
          })
        end
        resolve_local(node, node.name)
      end,

      assign = function()
        visit(node.value)
        resolve_local(node, node.name)
      end,

      ['function'] = function()
        declare(node.name)
        define(node.name)
        resolve_function(node, 'function')
      end,

      expression = function()
        visit(node.expression)
      end,

      ['if'] = function()
        visit(node.condition)
        visit(node.then_branch)
        if node.else_branch then
          visit(node.else_branch)
        end
      end,

      print = function()
        visit(node.value)
      end,

      ['return'] = function()
        visit(node.value)
      end,

      ['while'] = function()
        visit(node.condition)
        visit(node.body)
      end,

      binary = function()
        visit(node.left)
        visit(node.right)
      end,

      call = function()
        visit(node.callee)
        for _, argument in ipairs(node.arguments) do
          visit(argument)
        end
      end,

      grouping = function()
        visit(node.expression)
      end,

      literal = function()
      end,

      logical = function()
        visit(node.left)
        visit(node.right)
      end,

      unary = function()
        visit(node.left)
      end
    })
  end

  return {
    resolve = function(statements)
      for _, statement in ipairs(statements) do
        visit(statement)
      end
    end
  }
end
