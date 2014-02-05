require './src/cfs_fuzzy_parser.rb'

if ARGV.length == 0
  puts "Usage: ruby main.rb DB_PATH [a|q QUERY|e QUERY]"
end

# Load database
db_path = ARGV[0]

db_data = nil
begin
  db_data = File.read db_path
rescue
  puts "Invalid database path."
  exit
end

db = (CFS::FuzzyParser.new).literals db_data
parser = CFS::FuzzyParser.new db

# Check switches
switch = ARGV[1]
unless ["q", "a", "e"].include? switch
  puts "Invalid switch passed. Use [a]dd, [q]uery or [e]dit."
  exit
end

# Get query (if available)
query = ARGV[2..-1].join " " if ARGV.length > 2

case switch
when "a"
  if query
    puts "Switch [a]dd needs no query."
    exit
  end

when "q"
  unless query
    puts "Enter query:"
    query = gets.chomp.strip
  end

  
when "e"
  unless query
    puts "Enter query:"
    query = gets.chomp.strip
  end

  puts "Enter replacement:"
end
