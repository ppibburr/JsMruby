def __dom_ready__
  JS::DOM.ready
end


# direct to console
def p *o
  o.each do |x|
     x = x.inspect unless x.is_a?(String)
    JsObj.get("console").log x
  end
end

# direct to console
def puts str
  str = str.to_s unless str.is_a?(String)
  JsObj.get("console").log str
end

# duh
def alert msg
  JsObj.get('Ruby.Util.alert').call(msg)
end

def prompt msg,value=""
  JsObj.get('Ruby.Util.prompt').call(msg,value)
end

def confirm msg
  JsObj.get('Ruby.Util.confirm').call(msg)
end

# requires file at path, path
# path, String, url to file
#
# NOTE, will evalutate every time! 
#
# returns nil
def require path
  JsObj.get("Ruby.require").call path
  nil
rescue
  super
end

def document
  JS::DOM.document
end

class Timer
  attr_accessor :interval,:repeat,:function
  def initialize int,bool=false,&b
    @interval = int
    @repeat = bool
    @function = b
  end
  def stop
    @repeat = false
  end
  def start
    tb = Proc.new do
      @function.call(self)
      start() if @repeat
    end
    JS::Object.get("window").setTimeout(tb,@interval)
  end
end

# convienance entry point for XUI.js
module XUI
  def self.collect foo
    q=JS::Object.get("x$").call(foo)
    q.extend Helper
    q
  end
  
  module Helper
    # get computed values and set styles to it, xui.js 'tween' is buggy, this fixes
    def tween *props,&cb
      p0 = props[0] || {}
      props = p0.to_hash
      emile = [:duration,:after,:easing]
     
      props.each_pair do |k,v|
	next if emile.index(k)
	if ["top","left","z-index"].index(k.to_s)
	  getStyle('position').each_with_index do |q,i|
	    self.send(i.to_s).style.position = "absolute"
	  end
         
	  getStyle("#{k}").each_with_index() do |q,i|
	    bool = [0,1,2,3,4,5,6,7,8,9].find do |t|
	      q.index(t.to_s)
	    end
	    
	    if !bool
	      top = XUI::Helper.absPos(self.send(i.to_s),:top)
	      left = XUI::Helper.absPos(self.send(i.to_s),:left)
	      self.send(i.to_s).style.top = ("#{top}px")
	      self.send(i.to_s).style.left = ("#{left}px")              
	    end
	  end
	end

	q = getStyle("#{k}").map do |s| s end
	
	# TODO: hyphenize k, versus camelCase
	q.each_with_index do |s,i|
	  if s == "rgba(0, 0, 0, 0)"
	    val = JS::Object.get("window").getComputedStyle(self[i.to_s],true).getPropertyValue("#{k}")
	    self.send(i.to_s).style.send(k.to_s+"=",val.to_s)
	  end
	end
      end

      super(props,&cb)
    end
    
    def self.absPos( o, tl )
      val = 0;
      while ( o.nodeName != "BODY" )
	val +=  (tl == :top ? o.offsetTop : o.offsetLeft).to_f;
	o = o.parentNode;
      end
      return val;
    end
  end
end

