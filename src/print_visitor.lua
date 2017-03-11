local function visit(node)
  return ({
    unary = function()
      return '(' .. node.operator .. ' ' .. visit(node.left) .. ')'
    end,
    binary = function()
      return '(' .. node.operator .. ' ' .. visit(node.left) .. ' ' .. visit(node.right) .. ')'
    end,
    grouping = function()
      return '(group ' .. visit(node.expression) .. ')'
    end,
    literal = function()
      return tostring(node.value)
    end
  })[node.class]()
end

return visit
