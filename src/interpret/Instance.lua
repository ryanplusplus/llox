return function(class)
  return setmetatable({}, {
    __tostring = function()
      return class.name .. ' instance'
    end
  })
end
