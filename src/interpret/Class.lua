return function(name)
  return setmetatable({}, {
    __tostring = function() return name end
  })
end
