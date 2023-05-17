class MyParser
  IDNET_N = "n"
  PLUS = "+"
  L_PAREN = "("
  R_PAREN = ")"
  INPUT_END = "$"

  STATES = [
    #     n          +              (           )              $            E
    [[:shift, 2],          nil, [:shift, 3],          nil,          nil,  [:state, 1]], # 0
    [        nil,  [:shift, 4],         nil,          nil,    [:accept],          nil], # 1
    [        nil, [:reduce, 0],         nil, [:reduce, 0], [:reduce, 0],          nil], # 2
    [[:shift, 2],          nil, [:shift, 3],          nil,          nil,  [:state, 5]], # 3
    [[:shift, 6],          nil,         nil,          nil,          nil,          nil], # 4
    [        nil,  [:shift, 4],         nil,  [:shift, 7],          nil,          nil], # 5
    [        nil, [:reduce, 1],         nil, [:reduce, 1], [:reduce, 1],          nil], # 6
    [        nil, [:reduce, 2],         nil, [:reduce, 2], [:reduce, 2],          nil], # 7
  ]
  TOKEN_TO_IDX = {
    IDNET_N => 0,
    PLUS => 1,
    L_PAREN => 2,
    R_PAREN => 3,
    INPUT_END => 4,
    "E" => 5,
  }
  REDUCTION = [
    {"n" => "E"},
    {"E+n" => "E"},
    {"(E)" => "E"},
  ]

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

      idx = TOKEN_TO_IDX.fetch(tok)
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
      pat.chars.reverse.each do |pat_c|
        pop # discard state
        c = peek
        if pat_c == c
          pop # discard the c
        else
          raise "reduce failed"
        end
      end
      action_after_reduction = STATES[peek][TOKEN_TO_IDX.fetch(v)]
      push(v)
      execute(action_after_reduction)
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

    str.chars.each do |c|
      case c
      when IDNET_N, PLUS, L_PAREN, R_PAREN
        tokens << c
      when /\s/
        # do nothing
      else
          raise "unknown char #{c}"
      end
    end

    tokens << INPUT_END

    tokens
  end
end
