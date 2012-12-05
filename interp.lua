local look
local variables = setmetatable({}, {
  __index = function() return 0 end
})


function err(message)
  print('Error: ' .. message)
end

function fail(message)
  err(message)
  os.exit(1)
end

function expected(s)
  fail(s .. ' expected')
end

function getchar()
  look = io.stdin:read(1)
end

function match(x)
  if look ~= x then expected('"' .. x .. '"')
  else
    getchar()
    skipwhite()
  end
end

function isalpha(c)
  return string.match(c, '%a')
end

function isdigit(c)
  return string.match(c, '%d')
end

function iswhite(c)
  return c == ' ' or c == '\t'
end

function skipwhite()
  while iswhite(look) do
    getchar()
  end
end

function isaddop(c)
  return c == '+' or c == '-'
end

function getname()
  if not isalpha(look) then
    expected('name')
  end
  name = string.upper(look)
  getchar()
  skipwhite()
  return name
end

function getnum()
  local value = 0
  if not isdigit(look) then
    expected('integer')
  end
  while isdigit(look) do
    value = 10 * value + tonumber(look)
    getchar()
  end
  return value
end

function emit(s)
  io.stdout:write(string.format("\t%s", s))
end

function emitln(s)
  emit(s .. '\n')
end

function init()
  getchar()
  skipwhite()
end

function ident()
  name = getname()
  if look == '(' then
    match('(')
    match(')')
    emitln('BSR ' .. name)
  else
    emitln('MOVE ' .. name .. '(PC),D0')
  end
end

function factor()
  local value
  if look == '(' then
    match('(')
    value = expression()
    match(')')
  elseif isalpha(look) then
    value = variables[getname()]
  else value = getnum()
  end
  return value
end

function term()
  local value = factor()
  while look == '*' or look == '/' do
    if look == '*' then
      match('*')
      value = value * factor()
    elseif look == '/' then
      match('/')
      value = math.floor(value / factor())
    end
  end
  return value
end

function add()
  match('+')
  term()
  emitln('ADD (SP)+,D0')
end

function subtract()
  match('-')
  term()
  emitln('SUB (SP)+,D0')
  emitln('NEG D0')
end

function multiply()
  match('*')
  factor()
  emitln('MULS (SP)+,D0')
end

function divide()
  match('/')
  factor()
  emitln('MOVE (SP)+,D1')
  emitln('DIVS D1,D0')
end

function expression()
  local value
  if isaddop(look) then
    value = 0
  else
    value = term()
    while isaddop(look) do
      if look == '+' then
        match('+')
        value = value + term()
      elseif look == '-' then
        match('-')
        value = value - term()
      end
    end
  end

  return value
end

function assignment()
  name = getname()
  match('=')
  variables[name] = expression()
end

function newline()
  if look == '\n' then
    getchar()
  end
end

function output()
  match('!')
  emitln(variables[getname()])
end

init()
while look ~= '.' do
  if look == '!' then output()
  else assignment()
  end
  newline()
end
