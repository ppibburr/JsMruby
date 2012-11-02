class Hash
  def each_pair &b
    keys.each do |k|
      b.call(k,self[k])
    end
  end
end

class Proc
  # used to turn Proc's into JsFunc's
  def to_js
    this = self
    prc = Proc.new() do |*o| 
      a = o.map do |e| JS::Object.cast(e) end
      this.call(*a) 
    end
    JS::PROCS << [prc,self]
    JsObj.get("Ruby.Util.wrap_proc").call(prc)
  end
end

class String
  def first
    self[0]
  end
  
  def last
    self[length-1]
  end
  
  def remove_first
    splice(1..length)
  end
  
  def remove_last
    splice(0..length-2)
  end
  
  def splice range
    self[range]
  end
end

# class Method
#   def to_js
#     to_proc.to_js
#   end
# end

class Numeric
  # converts to String, suffixed with "px"
  def px
    self.to_s+"px"
  end

  # converts to String, suffixed with "%"
  def pct
    self.to_s+"%"
  end
  
  # converts to String, suffixed with "em"
  def em
    self.to_s+"em"
  end
end
