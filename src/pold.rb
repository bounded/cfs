module CFS
  module Parser
    # expects:
    # a a1, b b1 b2, c, d, e: literal
    # returns CFS::Literal
    #
    # you can escape blank, comma and colon by using \
    # alternatively, put them into quotes
    def self.parse_l str

      t = CFS::Tokenizer::tokenize(str)

      if t.length == 1
        return (CFS::Literal.new t[0])
      end
      
      if !t.include? :colon
        return (CFS::Literal.new str.strip)
      end

      cs = parse_cs str

      l = CFS::Literal.new t.last
      l.container = cs
      l
    end

    # expects:
    # a a1, b b1 b2, c, d, e
    def self.parse_cs str
      t = CFS::Tokenizer::tokenize str

      cs = []
      ci = []
      t.each {|x|
        if x == :comma
          cs << (CFS::Container.new ci) unless ci.empty?
          ci = []
        elsif x == :colon
          break
        else
          ci << x
        end
      }
      cs << (CFS::Container.new ci) unless ci.empty?
      cs
    end
  end

end
