# 'compiled' ruby js ...



# common.rb

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


# classes/file.rb

# Minimal File Class
class File
  # reads contents of file at path, path
  # path, String, url of file
  #
  # returns String, file contents
  def self.read path
    JsObj.get("Ruby.File.read").call path
  end
end


# classes/monkey.rb

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


# core.rb


module JS
  PROCS = []

  # shorthand to JS::Object.get
  def self.method_missing m,*o,&b
    JS::Object.get(m.to_s)
  rescue
    nil
  end
  
  # An array like collection of elements.
  # allows to manipulate or retrieve properties of numerous elements at once
  #
  # Modeled after XUI.js
  class Collection
    # array, list of elements to set the collection to
    def initialize array
      @array = array
    end
    
    # retrieves element at index i
    # i, Integer
    def [] i
      @array[i]
    end
    
    # retrieves element at index i
    # i, optional, Integer, defaults to 0
    def element i=0
      @array[i]
    end
    
    # defines events on all elements in collection
    # event, String, name of event minus 'on'
    #  ie, col.on("click") do ... end, sets "onclick" to block, b
    # b, block to use for event
    #
    # returns self
    def on event,&b
      each do |e|  
        e.on event,&b
      end
      self
    end
    
    # sets property k to value of v
    # returns self
    def set(k,v)
      each do |e|
        e.set k,v
      end
      self
    end
    
    # returns an array of the value k of all elements
    # indices match the collection order
    def get(k)
      a = []
      each do |e|
        a << e.get(k)
      end
      a
    end
    
    # enumerate over all elements in the collection
    def each
      if block_given?
        @array.each do |e|
          yield e
        end
      end
    end
    
    # returns new JS::Collection of elements within the collection that have the class 'name'
    # name, String, class name
    def has_class?(name)
      a = []
      
      each do |e|
        if e.get("className").split(" ").index(name)
          a << e
        end
      end
      
      JS::Collection.new(a)
    end
    
    # returns new JS::Collection of elements within the collection that DO NOT have the class 'name'
    # name, String, class name
    def without_class?(name)
      a = []
      
      each do |e|
        if !e.get("className").split(" ").index(name)
          a << e
        end
      end
      
      JS::Collection.new(a)
    end   
    
    # Returns a JS::Collection::Style object
    def style
      Style.new(self)
    end
    
    # Object to manage the retrieval and setting of style values 
    class Style
      # col, JS::Collection
      def initialize col
        @collection = col
      end
     
      # returns an array of all style objects of the elements in the managed collection
      # return Array
      def to_a
        a = []
      
        @collection.each do |e|
          a << e.style 
        end
        
        return a
      end
      
      # TODO: implement.
      # retrieves the computed value of a style property
      def computed prop
        a = []
        
        # dummy lookup
        @collection.each do |e|
          a << e.style[prop.to_s] 
        end
        
        a
      end
      
      # sets properties from keys and thier values in Hash, hash
      # hash, Hash, properties and values
      #
      # returns self
      def apply hash
        hash.each_key do |k|
          send k.to_s+"=",hash[k]
        end
        self
      end
      
      # returns self when setting values
      # returns value when retrieving values
      #
      # sends method m, String|Symbol on the style objects of each element in the managed collection
      # o, varargs, optional, used when setting values, and only the first index 
      def method_missing(m,*o)
        if m.to_s.last == "="
          @collection.each do |e|
            e.style[m.to_s.remove_last] = o[0]
          end
          
          return self
        else
          a = []

          @collection.each do |e|
            a << e.style[m.to_s]
          end
          
          return a
        end
      end
    end
  end
  
  # FIXME: passing aString.remove_[first|last] to document lookup functions
  #        will not return any items
  #
  # JS.collect(selector)
  # 
  #  where selector is:
  #    string
  #      starts with '#', lookup by id, returns collection of element of id
  #                  '.', lookup by class name, returns collection of elements of class
  #      else lookup by tag name. JS.collect("div") returns collection of div elements
  #    symbol, lookup by id
  #
  # returns JS::Collection
  def self.collect str
    # lookup by id
    if str.is_a?(Symbol)
      ele = document.getElementById(str.to_s)
      return Collection.new([JS::DOM::Element.wrap(ele)])
    
    # lookup by id
    elsif str.first == "#"
      id  = str.remove_first
      ele = document.getElementById(id)
      return Collection.new([JS::DOM::Element.wrap(ele)])
      
    # lookup by class name  
    elsif str.first == "."
      name = str.remove_first
      list = document.getElementsByClassName(name)
      p list[0]
      a = []
      
      for i in 0..list.length-1
        a << JS::DOM::Element.wrap(list[i])
      end
      
      return Collection.new(a)
    
    # lookup by tag name
    else
      list = document.getElementsByTagName(str)
      a = []
      
      for i in 0..list.length-1
        a << JS::DOM::Element.wrap(list[i])
      end
      
      return Collection.new(a)
    end
    return nil
  end
  
  # some convienance lives here
  module DOM
    # sets the block to be executed when domReady
    # invoker provide by XUI.js' x$.ready()
    def self.on_ready &b
      @on_ready = b
    end
    
    # invoke the block
    def self.ready
      @on_ready.call
    end
    
    # retrieves the document
    def self.document
      JS::Object.get("document")
    end
    
    # convienance wrapper for DOMElement's
    class Element
      # JS::Element.new(tagname, parent=nil)
      # JS::Element.new(:from=>object)
      #
      # the former makes a element of tagname.
      #   appends it to parent, if parent is !nil
      #
      # the latter wraps an existing element
      def initialize *o
        if o[0].is_a?(Hash)
          @element = o[0][:from]
        else
          tag = o[0]
          parent = o[1]
          @element = JS.document.createElement(tag)
          if parent
            parent.appendChild(@element)
          end
        end
      end
      
      def to_js
        @element.is_a?(JS::Object) ? @element.to_js : @element
      end
      
      # wraps an existing element
      # JS::Element.wrap(someObject)
      #
      # element, JS::Object of a element
      def self.wrap element
        new :from=>element
      end
      
      # invoke the elements methods
      def method_missing m,*o,&b
        @element.send m,*o,&b
      end
      
      # define events
      #
      # event, String, name of event minus "on" prefix
      # b, block to execute when event is triggered
      def on event,&b
        @element.set "on#{event}",&b
      end
    end
  end
  
  # returns Window object
  def self.this
    JS::Object.get("window")
  end
  
  # Wraps JsObj's and JsFunc's
  # Provide nice hash like features to JsObj and JsFunc
  # Treats functions as objects
  #   can set, retrieve properties
  # functions can be called with 'call'
  class Object
    # return the wrapped object
    def to_js
      @object
    end
  
    # mangles o, by replacing items that respond_to? 'to_js' by calling 'to_js'
    # returns a JS::Objects when needed
    #   otherwise the native types, Strings, arrays, Integers , etc
    def method_missing m,*o,&b
      o.find_all do |q| q.respond_to?(:to_js) end.each do |q|
        o[o.index(q)] = q.to_js
      end
      
      o << (b.to_js) if b


      ret = to_js.send m,*o
      
      JS::Object.cast(ret)
    end
    
    # 'extends' the properties of the wrapped object to those defined in hash
    #
    #  hash, Hash
    #
    # returns nil
    def apply hash
      hash.each_key do |k|
        value = hash[k]
        if value.is_a?(Symbol)
          value = value.to_s
        end
        self[k.to_s] = value
      end
      return nil
    end
  
      # returns an Array of propety names of the object
	  def keys
		JsObj.get("Ruby.JsObj.properties").call(@object)
	  end
	  
	  # return property k of the object
	  def [] k
		get k
	  end
	  
	  # sets property k of the object to v
	  def []= k,v
	    set k,v
	  end
	  
	  # return property k of the object	  
	  def get k
		JS::Object.get("Ruby.JsObj.get_property").call(@object,k)
	  end  
	  
	  # sets property k of the object to v	  
	  def set k,v=nil,&b
	    if !v and b
	      v = b
	    end
	    JS::Object.get("Ruby.JsObj.set_property").call(@object,k,v)
	  end
	  
	  def each_pair
	    raise "No block given" unless block_given?
	    keys.each do |k|
	      yeild [k,self[k]]
	    end
	  end
	  
	  # gets the value of property, str
	  # will return functions as objects, not invoke them
	  # returns value or a JS::Object 
	  def self.get(str)
	    ret = JsObj.get(str)
	    if ret.is_a?(JsFunc) or ret.is_a?(JsObj)
	      return new(ret)
	    end
	    return ret
	  end
	  
	  # see if value needs to be wrapped
	  def self.cast value
	    if value.is_a?(JsFunc) or value.is_a?(JsObj)
	      return new(value)
	    end
	    return value
	  end
	  
	  def initialize obj
	    @object = obj
	  end
	  
	  # are we a function?
	  def is_function?
        @object.is_a?(JsFunc)
	  end
	end  
end


