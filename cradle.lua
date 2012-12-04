local look

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
  if look == x then getchar()
  else expected('"' .. x .. '"')
  end
end

function isalpha(c)
  return string.match(c, '%a')
end

function isdigit(c)
  return string.match(c, '%d')
end

function iswhite(c)
  return string.match(c, '%s')
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
  return name
end

function getnum()
  if not isdigit(look) then
    expected('integer')
  end
  prev = look
  getchar()
  return prev
end

function emit(s)
  io.stdout:write(string.format("\t%s", s))
end

function emitln(s)
  emit(s .. '\n')
end

function init()
  getchar()
end

function factor()
  if look == '(' then
    match('(')
    expression()
    match(')')
  else
    emitln('MOVE #' .. getnum() .. ',D0')
  end
end

function term()
  factor()
  while look == '*' or look == '/' do
    emitln('MOVE D0,-(SP)')
    if look == '*' then multiply()
    elseif look == '/' then divide()
    else expected('mulop')
    end
  end
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
  if isaddop(look) then
    emitln('CLR D0')
  else
    term()
  end
  while look == '+' or look == '-' do
    emitln('MOVE D0,-(SP)')
    if look == '+' then add()
    elseif look == '-' then subtract()
    else expected('addop')
    end
  end
end

init()
expression()
