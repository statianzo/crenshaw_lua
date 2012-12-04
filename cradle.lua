local look

function err(message)
  print('Error:' .. message .. '\n')
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
  print(string.format("\t%s", s))
end

function emitln(s)
  emit(s .. '\n')
end

function init()
  getchar()
end

init()
