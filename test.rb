require "./my_parser"
tests = [
  { input: "n", expected: :accepted },
  { input: "n + n", expected: :accepted },
  { input: "(n)", expected: :accepted },
]

tests.each do |t|
  actual = nil
  rescued = false
  begin
    actual = MyParser.new(t[:input]).parse
  rescue
  rescued = true
  end
  if rescued
    unless t[:expected] == :error
      puts "failed"
      puts "actual: error"
      p t
      puts
      MyParser.new(t[:input], debug: true).parse # To show logs
    end
  else
    unless actual == t[:expected]
      puts "failed"
      puts "actual: #{actual}"
      p t
      puts
      MyParser.new(t[:input], debug: true).parse # To show logs
    end
  end
end
