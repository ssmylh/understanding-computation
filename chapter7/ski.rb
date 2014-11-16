# -*- encoding: utf-8 -*-

class SKISymbol < Struct.new(:name)
  def to_s
    name.to_s
  end
  def inspect
    to_s
  end
  def combinator
    self
  end
  def arguments
    []
  end
  def callable?(*arguments)
    false
  end
  def reducible?
    false
  end
end

class SKICall < Struct.new(:left, :right)
  def to_s
    "#{left}[#{right}]"
  end
  def inspect
    to_s
  end
  def combinator
    left.combinator
  end
  def arguments
    left.arguments + [right]
  end
  def reducible?
    left.reducible? || right.reducible? || combinator.callable?(*arguments)
  end
  def reduce
    if left.reducible?
      SKICall.new(left.reduce, right)
    elsif right.reducible?
      SKICall.new(left, right.reduce)
    else
      combinator.call(*arguments)
    end
  end
end

class SKICombinator < SKISymbol
end

S, K, I = [:S, :K, :I].map { |name| SKICombinator.new(name) }

# S[a][b][c] -> a[c][b[c]]
def S.call(a, b, c)
  SKICall.new(SKICall.new(a, c), SKICall.new(b, c))
end

# K[a][b] -> a
def K.call(a, b)
  a
end

#I[a] -> a
def I.call(a)
  a
end

x = SKISymbol.new(:x)
# puts SKICall.new(SKICall.new(S, K), SKICall.new(I, x))

y, z = SKISymbol.new(:y), SKISymbol.new(:z)
raise "S.call" unless S.call(x, y, z).to_s == "x[z][y[z]]"

expression = SKICall.new(SKICall.new(SKICall.new(S, x), y), z)
raise "combinator" unless expression.combinator == S
raise "arguments" unless expression.arguments == [x, y, z]

def S.callable?(*arguments)
  arguments.length == 3
end

def K.callable?(*arguments)
  arguments.length == 2
end

def I.callable?(*arguments)
  arguments.length == 1
end

swap = SKICall.new(SKICall.new(S, SKICall.new(K, SKICall.new(S, I))), K)
expression = SKICall.new(SKICall.new(swap, x), y)

while expression.reducible?
  puts expression
  expression = expression.reduce
end; puts expression










