class JS
  def self.method_missing m,*o,&b
    JsObj.get(m.to_s).call(*o,&b)
  rescue
    nil
  end
end
class File
  def self.read path
    JsObj.get("Ruby.File.read").call path
  end
end
class Object
  def popup o
    JS.method_missing :popup,o
    o
  end
  
  def require path
    JsObj.get("Ruby.require").call path
    nil
  rescue
    super
  end
end
