describe('util.switch', function()
  local switch = require 'util.switch'

  it('should call the corresponding function with the switched value', function()
    local f = spy.new(load'')

    switch('hello', {
      goodbye = error,
      hello = f
    })

    assert.spy(f).was_called_with('hello')
  end)

  it('should not call any functions if no value matches', function()
    switch('hello', {
      goodbye = error
    })
  end)

  it('should allow a default case to be provided', function()
    local f = spy.new(load'')

    switch('lua', {
      goodbye = error,
      hello = error,
      [switch.default] = f
    })

    assert.spy(f).was_called_with('lua')
  end)
end)
