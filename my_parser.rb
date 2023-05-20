class MyParser
  IDENT_N = "n"
  PLUS = "+"
  L_PAREN = "("
  R_PAREN = ")"
  INPUT_END = "$"

  Literal = Data.define(:token) do
    def str
      token.str
    end
  end
  Add = Data.define(:token, :lhs, :rhs) do
    def str
      token.str
    end
  end

  STATES = [
    #     n          +              (           )              $            E
    [[:shift, 2],          nil, [:shift, 3],          nil,          nil,  [:shift, 1]], # 0
    [        nil,  [:shift, 4],         nil,          nil,    [:accept],          nil], # 1
    [        nil, [:reduce, 0],         nil, [:reduce, 0], [:reduce, 0],          nil], # 2
    [[:shift, 2],          nil, [:shift, 3],          nil,          nil,  [:shift, 5]], # 3
    [[:shift, 6],          nil,         nil,          nil,          nil,          nil], # 4
    [        nil,  [:shift, 4],         nil,  [:shift, 7],          nil,          nil], # 5
    [        nil, [:reduce, 1],         nil, [:reduce, 1], [:reduce, 1],          nil], # 6
    [        nil, [:reduce, 2],         nil, [:reduce, 2], [:reduce, 2],          nil], # 7
  ]
  TOKEN_TO_IDX = {
    IDENT_N => 0,
    PLUS => 1,
    L_PAREN => 2,
    R_PAREN => 3,
    INPUT_END => 4,
  }
  REDUCTION = [
    {
      token_strings: ["n"],
      reduce: ->(tokens) {
        Literal.new(token: tokens.first)
      },
    },
    {
      token_strings: ["E", "+", "n"],
      reduce: ->(tokens) { Add.new(token: tokens[1], lhs: tokens[0], rhs: tokens[2]) },
    },
    {
      token_strings: ["(", "E", ")"],
      reduce: ->(tokens) { tokens[1] },
    },
  ]
  Token = Data.define(:str, :beg, :fin)

  def initialize(str, debug: false)
    @str = str
    @tokens = lex(str) # I
    @stack = [0]       # S
    @debug = debug
  end

  def parse
    loop do
      tok = @tokens.first
      if @debug
        puts "----"
        puts "rest tokens: #{@tokens.inspect}"
        p self
      end
      idx =
        case tok
        in Token
          TOKEN_TO_IDX.fetch(tok.str)
        in Literal | Add
          5
        end
      action = STATES[peek][idx]
      return :rejected if action.nil?

      ret = execute(action)
      return ret if ret == :accepted
    end
  end

  def inspect
    "<Parser stack=#{@stack.inspect}>"
  end

  private

  def execute(action)
    p action if @debug
    case action
    in [:shift, nx]
      push(@tokens.shift)
      push(nx)
    in [:state, nx]
      push(nx)
    in [:reduce, ri]
      rule = REDUCTION[ri]
      pat, v = rule.first
      reduced = []
      rule[:token_strings].reverse.each do |pat_c|
        pop # discard state
        c = peek
        if pat_c == "E"
          if c.is_a?(Literal) || c.is_a?(Add)
            reduced << pop
          else
            raise "reduce failed"
          end
        else
          if pat_c == c.str
            reduced << pop
          else
            raise "reduce failed"
          end
        end
      end

      reduced.reverse!

      new_token = rule[:reduce].call(reduced)
      @tokens.unshift(new_token)
    in [:accept]
      return :accepted
    end
  end

  def push(e)
    @stack.push(e)
  end

  def pop
    @stack.pop
  end

  def peek
    @stack.last
  end

  def lex(str)
    tokens = []

    line = 1
    col = 0

    str.chars.each do |c|
      case c
      when IDENT_N, PLUS, L_PAREN, R_PAREN
        tokens << Token.new(str: c, beg: [line, col], fin: [line, col + 1])
      when /\n/
        line += 1
        col = 0
      when /\s/
        # do nothing
      else
          raise "unknown char #{c}"
      end
      col += 1
    end

    tokens << Token.new(str: INPUT_END, beg: [line, col], fin: [line, col + 1])

    tokens
  end
end
