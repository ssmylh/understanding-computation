# -*- encoding: utf-8 -*-

ZERO = -> p { -> x { x } }
ONE = -> p { -> x { p[x] } }
TWO = -> p { -> x { p[p[x]] } }
THREE = -> p { -> x { p[p[p[x]]] } }
FIVE = -> p { -> x { p[p[p[p[p[x]]]]] } }
FIFTEEN = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]] } }
HUNDRED = -> p { -> x { p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[p[x]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]]] } }

def to_integer(proc)
  proc[-> n { n + 1 }][0]
end

TRUE = -> x { -> y { x }}
FALSE = -> x { -> y { y }}

def to_bool(proc)
  IF[proc][true][false]
end

# IF = -> b {
#   -> x {
#     -> y {
#       b[x][y]
#     }
#   }
# }


# IF = -> b {
#   -> x {
#     b[x]
#   }
# }

IF = -> b { b }

IS_ZERO = -> n { n[-> x{ FALSE }][TRUE] }
raise "IS_ZERO" unless to_bool(IS_ZERO[ZERO])

PAIR = -> x { -> y { -> f { f[x][y] }}}
LEFT = -> p { p[-> x { -> y { x }}] }
RIGHT = -> p { p[-> x { -> y { y }}] }

my_pair = PAIR[ONE][TWO]
raise "LEFT" unless to_integer(LEFT[my_pair]) == 1

INCREMENT = -> n {
  -> p {
    -> x {
      p[n[p][x]]
    }
  }
}

raise "INCREMENT" unless to_integer(INCREMENT[ZERO]) == 1
raise "INCREMENT" unless to_integer(INCREMENT[FIVE]) == 6

SLIDE = -> p {
  PAIR[RIGHT[p]][INCREMENT[RIGHT[p]]]
}
DECREMENT = -> n {
  LEFT[n[SLIDE][PAIR[ZERO][ZERO]]]
}

raise "DECREMENT" unless to_integer(DECREMENT[THREE]) == 2

ADD = -> m {
  -> n {
    n[INCREMENT][m]
  }
}
# m - n
SUBTRACT = -> m {
  -> n {
    n[DECREMENT][m]
  }
}
MULTIPLY = -> m {
  -> n {
    n[ADD[m]][ZERO]
  }
}
# m ^ n
POWER = -> m {
  -> n {
    n[MULTIPLY[m]][ONE]
  }
}

raise "ADD" unless to_integer(ADD[ONE][FIVE]) == 6
raise "POWER" unless to_integer(POWER[FIVE][THREE]) == 125

IS_LESS_OR_EQUAL = -> m {
  -> n {
    IS_ZERO[SUBTRACT[m][n]]
  }
}

raise "IS_LESS_OR_EQUAL" unless to_bool(IS_LESS_OR_EQUAL[ONE][TWO])

# Yコンビネータ
# f = F(f), f = Y(F)
# Y(F) = F(Y(F))
# Y = (λg.(λx.g(x x)) (λx.g(x x)))
# Y F
#   = (λg.(λx.g(x x)) (λx.g(x x))) F
#   = (λx.F(x x)) (λx.F(x x))  λgのβ簡約
#   = (λy.F(y y)) (λx.F(x x))  α変換
#   = F(F(λx.F(x x) (λx.F(x x))  λyのβ簡約 F(y y)のyにF(x x)を
#   = F (Y F)
#
Y = -> f {
  -> x { f[x[x]] }[-> x { f[x[x]] }]
}

# Zコンビネータ
Z = -> f {
  -> x { f[-> y { x[x][y] }] }[-> x { f[-> y { x[x][y] }] }]
}

# Mod
MOD = Z[-> f {
  -> m {
    -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][
        -> x {
          f[SUBTRACT[m][n]][n][x]
        }
      ][
        m
      ]
    }
  }
}]

raise "MOD" unless to_integer(MOD[THREE][TWO]) == 1

# List
EMPTY = PAIR[TRUE][FALSE]
UNSHIFT = -> l {
  -> x {
    PAIR[FALSE][PAIR[x][l]]
  }
}
IS_EMPTY = LEFT
FIRST = -> l {
  LEFT[RIGHT[l]]
}
REST = -> l {
  RIGHT[RIGHT[l]]
}
def to_array(proc)
  array = []
  until to_bool(IS_EMPTY[proc])
    array.push(FIRST[proc])
    proc = REST[proc]
  end
  array
end

my_list = UNSHIFT[
  UNSHIFT[
    UNSHIFT[EMPTY][THREE]
  ][TWO]
][ONE]
raise "List FIRST" unless to_integer(FIRST[my_list]) == 1
raise "List REST" unless to_integer(FIRST[REST[my_list]]) == 2
raise "List IS_EMPTY for EMPTY" unless to_bool(IS_EMPTY[EMPTY])
raise "List IS_EMPTY for Non-EMPTY" unless to_bool(IS_EMPTY[my_list]) == false

# Range
# def range(m, n)
#   if m <= n
#     range(m + 1, n).unshift(m)
#   else
#     []
#   end
# end
RANGE = Z[-> f {
  -> m {
    -> n {
      IF[IS_LESS_OR_EQUAL[m][n]][
        -> x {
          UNSHIFT[f[INCREMENT[m]][n]][m][x]
        }
      ][
        EMPTY
      ]
    }
  }
}]

my_range = RANGE[TWO][FIVE]
raise "RANGE" unless to_array(my_range).map { |p| to_integer(p) } == [2,3,4,5]

# Fold
# def fold_left(array, acc, proc)
#   _array = array.dup
#   def go(array, acc, proc)
#     if array.empty?
#       acc
#     else
#       e = array.shift
#       acc = proc[acc][e]
#       go(array, acc, proc)
#     end
#   end
#   go(_array, acc, proc)
# end
# raise "fold_left" unless fold_left([1,2,3,4,5], 0, -> acc { -> x { acc + x } }) == 15
FOLD = Z[-> f {
  -> l {
    -> x {
      -> g {
        IF[IS_EMPTY[l]][
          x
        ][
          -> y {
            ( g[f[REST[l]][x][g]][FIRST[l]] )[y]
          }
        ]
      }
    }
  }
}]
raise "FOLD" unless to_integer(FOLD[RANGE[ONE][FIVE]][ZERO][ADD]) == 15

MAP = -> k {
  -> f {
    FOLD[k][EMPTY][
      -> l {
        -> x {
          UNSHIFT[l][f[x]]
        }
      }
    ]
  }
}
raise "MAP" unless to_array(MAP[my_list][INCREMENT]).map { |e| to_integer(e) } == [2,3,4]

# String
TEN = MULTIPLY[TWO][FIVE]
B = TEN
F = INCREMENT[B]
I = INCREMENT[F]
U = INCREMENT[I]
ZED = INCREMENT[U]
FIZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][I]][F]
BUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[EMPTY][ZED]][ZED]][U]][B]
FIZZBUZZ = UNSHIFT[UNSHIFT[UNSHIFT[UNSHIFT[BUZZ][ZED]][ZED]][I]][F]

def to_char(c)
  '0123456789BFiuz'.slice(to_integer(c))
end
def to_string(s)
  to_array(s).map { |c| to_char(c) }.join
end

DIV = Z[ -> f {
  -> m {
    -> n {
      IF[IS_LESS_OR_EQUAL[n][m]][
        -> x {
          INCREMENT[f[SUBTRACT[m][n]][n]][x]
        }
      ][
        ZERO
      ]
    }
  }
}]
raise "DIV" unless to_integer(DIV[INCREMENT[THREE]][TWO]) == 2

PUSH = -> l {
  -> x {
    FOLD[l][UNSHIFT[EMPTY][x]][UNSHIFT]
  }
}
raise "PUSH" unless to_array(PUSH[my_list][INCREMENT[THREE]]).map { |e| to_integer(e) } == [1,2,3,4]

TO_DIGITS = Z[-> f {
  -> n {
    PUSH[
      IF[IS_LESS_OR_EQUAL[n][DECREMENT[TEN]]][
        EMPTY
      ][
        -> x {
          f[DIV[n][TEN]][x]
        }
      ]
    ][MOD[n][TEN]]
  }
}]
# too slow
#raise "TO_DIGITS" unless to_array(TO_DIGITS[POWER[FIVE][THREE]]).map { |e| to_integer(e) } == [1,2,5]

# solution = MAP[RANGE[ONE][HUNDRED]][-> n {
#   IF[IS_ZERO[MOD[n][FIFTEEN]]][
#     FIZZBUZZ
#   ][IF[IS_ZERO[MOD[n][THREE]]][
#     FIZZ
#   ][IF[IS_ZERO[MOD[n][FIVE]]][
#     BUZZ
#   ][
#     TO_DIGITS[n]
#   ]]]
# }]
# to_array(solution).each do |p|
#   puts to_string(p)
# end;

MOD2 = -> m {
  -> n {
    m[-> x {
      IF[IS_LESS_OR_EQUAL[n][x]][
        SUBTRACT[x][n]
      ][
        x
      ]
    }][m]
  }
}
puts to_integer(MOD2[FIVE][TWO])
