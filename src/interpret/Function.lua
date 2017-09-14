--[[
package com.craftinginterpreters.lox;

import java.util.List;

class LoxFunction implements LoxCallable {
  private final Stmt.Function declaration;

  LoxFunction(Stmt.Function declaration) {
    this.declaration = declaration;
  }

  @Override
  public Object call(Interpreter interpreter, List<Object> arguments) {
    Environment environment = new Environment(interpreter.globals);
    for (int i = 0; i < declaration.parameters.size(); i++) {
      environment.define(declaration.parameters.get(i).lexeme,
          arguments.get(i));
    }

    interpreter.executeBlock(declaration.body, environment);
    return null;
  }

  @Override
  public int arity() {
    return declaration.parameters.size();
  }

  @Override
  public String toString() {
    return "<fn " + declaration.name.lexeme + ">";
  }
}
]]

local Environment = require 'interpret.Environment'

return function(node, env)
  return setmetatable({
    arity = function()
      return #node.parameters
    end,

    call = function(interpret, arguments)
      local env = Environment(env)
      for i = 1, #node.parameters do
        env.define(node.parameters[i].lexeme, arguments[i])
      end
      interpret(node.body, env)
    end
  }, {
    __tostring = function()
      return '<fn ' .. node.name.lexeme .. '>'
    end
  })
end
