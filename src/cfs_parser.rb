require 'parslet'
require_relative 'cfs.rb'

module CFS
  class CFSParser < Parslet::Parser
    rule(:v) {
      match('[^:,()"\']').repeat(1).as(:v) |

      (
        str("'") >> (
          str('\\') >> any |
          str("'").absent? >> any
        ) .repeat(1).as(:v) >> str("'")
      ) |

      (
        str('"') >> (
          str('\\') >> any |
          str('"').absent? >> any
        ) .repeat(1).as(:v) >> str('"')
      )
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
      CFS::Container.new (CFS::Parser.process_value val)
    }
    rule({:v => simple(:val), :s => simple(:c)}){
      if c.name
        r = CFS::Container.new (CFS::Parser.process_value val)
        r.add c
        r
      else
        c.name = (CFS::Parser.process_value val)
        c
      end
    } 
    rule(:s => simple(:c)) {
      c
    }
    rule({:v => simple(:val), :s => sequence(:arr)}) {
      r = CFS::Container.new (CFS::Parser.process_value val)
      arr.each {|x| 
        r.add x
      } 
      r
    }
    rule({:s => sequence(:arr)}) {
      if arr.length == 1
        arr[0]
      else
        r = CFS::Container.new
        arr.each {|x|
          r.add x
        }
        r
      end
    }
  end
  class Parser
    def self.parse str
      c = CFS::Container.new

      # Pre-processing
      str = str.lines.map {|x| x.strip }.join("\n")
      
      # a:
      # b
      # c
      # =>
      # a:b
      # a:c
      tmp = str.split "\n"
      tmp.each_with_index {|l,i|
        if l =~ /^(.*:)[\s]*$/
          prefix = $1
          tmp[i] = ""
          i += 1
          while tmp[i]
            break if tmp[i] =~ /^\s*$/
            tmp[i] = prefix + '(' + tmp[i] + ')'
            i += 1
          end 
        end
      }

      str = tmp.join "\n"
      
      # a:b, c:d
      # => (a:b, c:d)
      str = str.lines.map {|l|
        l.strip!
        if l.include? ','
          "(" + l + ")"
        else
          l
        end
      }.join("\n")

      # Parse
      
      str.lines.each {|l|
        l.strip!
        next if l =~ /^[\s]*$/
        r = parse_line l
        c.add r
      }

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
    def self.process_value val
      # post-processing
      val.to_s.strip
    end
  end
end
