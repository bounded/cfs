require 'parslet'
require_relative 'cfs.rb'

module CFS
  class CFSParser < Parslet::Parser
    rule(:v) {
      match('[^:,()]').repeat(1).as(:v)
    }
    rule(:s) { 
      v >> str(':') >> s.as(:s) |
      str('(') >> s.as(:s) >> (str(',') >> s.as(:s)).repeat >> str(')') |
      str('(') >> s >> str(')') |
      v
    }
    root(:s)
  end
  class CFSTransform < Parslet::Transform
    rule(:v => simple(:val)) {
      CFS::Container.new val.to_s
    }
    rule({:v => simple(:val), :s => simple(:c)}){
      if c.name
        r = CFS::Container.new val.to_s
        r.add c
        r
      else
        c.name = val.to_s
        c
      end
    } 
    rule(:s => simple(:c)) {
      c
    }
    rule({:v => simple(:val), :s => sequence(:arr)}) {
      r = CFS::Container.new val.to_s
      arr.each {|x| 
        r.add x
      } 
      r
    }
  end
  class Parser
    def self.parse str
      # pre-processor
      
      c = CFS::Container.new

      str.lines.each {|l|
        l.strip!
        next if l =~ /^[\s]*$/
        r = parse_line l
        c.add r
      }

      # post-processor

      c
    end

    def self.parse_line str
      p = CFS::CFSParser.new
      t = CFS::CFSTransform.new

      r = p.parse str
      r = t.apply r

      if r.is_a? Array
        tmp = CFS::Container.new
        r.each {|x| tmp.add x}
        r = tmp
      end
      r

    end
  end
end
