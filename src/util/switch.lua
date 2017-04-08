local default_case = {}

local function switch(value, cases)
  local default = cases[default_case] or load''
  return setmetatable(cases, {
    __index = function()
      return default
    end
  })[value](value)
end

return setmetatable({
  default = default_case
}, {
  __call = function(_, ...) return switch(...) end
})
