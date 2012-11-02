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




# convienance entry point for XUI.js
module XUI
  def self.collect foo
    JS::Object.get("x$").call(foo)
  end
end
