require './src/cfs_ioparser.rb'
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

db = CFS::IOParser.read db_data
parser = CFS::FuzzyParser.new db

# Check switches
switch = ARGV[1]
unless ["q", "a", "e"].include? switch
  puts "Invalid switch passed. Use [a]dd, [q]uery or [e]dit."
  exit
end

# Get query 
query = ARGV[2]

case switch
when "a"
  if query
    puts "Switch [a]dd needs no query."
    exit
  end

  puts "Enter data:"
  rpl = ""
  f = ""
  rpl += f while f = $stdin.gets
  rpl_db = parser.literals rpl

  db += rpl_db

  File.open(db_path, "w") {|f|
    f.print (CFS::IOParser.write db)
  }

when "q"
  unless query
    puts "Switch [q]uery needs a query."
    exit
  end
  puts db.filter(parser.containers query)
  
when "e"
  unless query
    puts "Switch [e]dit needs a query."
    exit
  end

  db -= db.filter(parser.containers query)

  puts "Enter replacement:"
  rpl = ""
  f = ""
  rpl += f while f = $stdin.gets
  rpl_db = parser.literals rpl

  db += rpl_db

  File.open(db_path, "w") {|f|
    f.print (CFS::IOParser.write db)
  }
end
