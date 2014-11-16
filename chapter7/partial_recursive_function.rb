# -*- encoding: utf-8 -*-

def zero
  0
end

def increment(n)
  n + 1
end

def two
  increment(increment(zero))
end

def three
  increment(two)
end

def recurce(f, g, *values)
  *other_values, last_value = values
  if last_value.zero?
    send(f, *other_values)
  else
    easier_last_values = last_value - 1
    easier_values = other_values + [easier_last_values]

    easier_result = recurce(f, g, *easier_values)
    puts "last_value : #{last_value}"
    puts "easier_result : #{easier_result}"
    send(g, *easier_values, easier_result)
  end
end

def easier_x(easier_x, easier_result)
  easier_x
end

def decrement(n)
  recurce(:zero, :easier_x, n)
end

puts send(:zero, *[])

