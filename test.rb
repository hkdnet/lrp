require "./my_parser"
tests = [
  { input: "n", expected: :accepted },
  { input: "n + n", expected: :accepted },
  { input: "(n)", expected: :accepted },
]

tests.each do |t|
  actual = MyParser.new(t[:input]).parse
  unless actual == t[:expected]
    puts "failed"
    puts "actual: #{actual}"
    p t
    puts
    MyParser.new(t[:input], debug: true).parse # To show logs
  end
end
