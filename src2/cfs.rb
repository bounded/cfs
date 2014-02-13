module CFS

  # saves data as
  # parent => children
  class Database < Hash
    def add l, ps
      ps.each {|p|
        if member? p
          self[p] << l
        else
          self[p] = [l]
        end
      }
      unless member? l
        self[l] = []
      end
    end
  end 

  DEBUG = false

  def self.debug str
    puts str if DEBUG
  end

end
