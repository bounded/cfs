require_relative './src/cfs_ioparser.rb'
require_relative './src/cfs_fuzzy_parser.rb'

if ARGV.length == 0
  puts "Usage: ruby main.rb DB_PATH [a|q QUERY|e QUERY]"
end

# Load database
db_path = File.expand_path ARGV[0]

db_data = nil
begin
  if File.exists? db_path
    db_data = File.read db_path
  else
    db_data = ""
  end
rescue e
  puts "Error: #{e}"
  exit
end

db = CFS::IOParser.read db_data
fuzzy_parser = CFS::FuzzyParser.new db

# Check switches
switch = ARGV[1]
unless ["c", "q", "a", "e"].include? switch
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

  add = ""
  f = ""
  add += f while f = $stdin.gets
  add_db = fuzzy_parser.literals add
  exit if add_db.empty?

  add_db.each {|x|
    puts "+ " + x.to_s
  }

  db += add_db

  File.open(db_path, "w") {|f|
    f.print (CFS::IOParser.write db)
  }

when "q"
  unless query
    puts "Switch [q]uery needs a query."
    exit
  end
  puts db.filter(fuzzy_parser.containers query)

when "c"
  unless query
    puts "Switch [c]anonical needs a query."
    exit
  end
  puts CFS::IOParser.write(db.filter(fuzzy_parser.containers query))
  
when "e"
  unless query
    puts "Switch [e]dit needs a query."
    exit
  end

  # select the part of the database to edit
  q_db = db.filter(fuzzy_parser.containers query)

  # replace it by this database
  rpl = ""
  f = ""
  rpl += f while f = $stdin.gets
  rpl_db = CFS::IOParser.read rpl

  db_rem = q_db - rpl_db
  unless db_rem.empty?
    db_rem.each {|x|
      puts "- " + x.to_s
    }
  end 

  db_add = rpl_db - q_db
  unless db_add.empty?
    db_add.each {|x|
      puts "+ " + x.to_s
    }
  end 

  if db_rem.empty? and db_add.empty?
    puts "No changes made."
  end

  db -= db_rem
  db += db_add

  File.open(db_path, "w") {|f|
    f.print (CFS::IOParser.write db)
  }
end
