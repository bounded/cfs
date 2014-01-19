require './src/cfs_parser.rb'
require './src/cfs.rb'

input = File.read "input"
db = CFS::Database.new

input.split("\n").map{|x| x.strip}.delete_if{|x| x.empty?}.each {|l|
  db.add (CFS::Parser::parse_l l)
}

puts "#" * 8
puts "Database:"
puts db.to_s
puts "#" * 8
puts "Enter filter:"

while f = gets
  break unless f

  f.chomp!
  f.strip!

  puts (db.filter (CFS::Parser::parse_cs f)).to_s
  puts "#" * 8
  puts "Enter filter:"
end
