require './src/cfs.rb'
require './src/cfs_parser.rb'
require './src/cfs_fuzzy_parser.rb'

input = File.read "input"
db = CFS::Database.new

input.split("\n").map{|x| x.strip}.delete_if{|x| x.empty?}.each {|l|
  db.add (CFS::Parser::parse_l l)
}

parser = CFS::FuzzyParser.new db

puts "#" * 8
puts "Database:"
puts db.to_s
puts "#" * 8
puts "Enter filter:"

while f = gets
  break unless f

  f.chomp!
  f.strip!

  q = parser.query f
  puts "Parsed query: [#{q.map{|x| x.inspect}.join(", ")}]"
  puts 
  puts "Result:"
  puts (db.filter q).to_s
  puts "#" * 8
  puts "Enter filter (end with CTRL-D):"
end
