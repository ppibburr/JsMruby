var a = [];
var Ruby = {
  jsmruby : undefined,
  
  // set the enviroment (plugin object) and load in some
  //   sugar.
  // returns true # TODO: check already init, false if so
  init : function(object) {
	Ruby.jsmruby = object; 
    x$.ready(function() {
		Ruby.send("__dom_ready__");
	});
    // Give me some sugar
    Ruby.require('ruby_js/out/ruby_js.rb' ); 
    console.log("ruby ...");
	return true;
  },	
	
  // calls a method by name of name
  // returns the result of the method	
  send : function(name) {
	return Ruby.jsmruby.send(name);  
  },	
	
  // Not much  really
  File : {
	// read a file into a string
	// returns a string of the files contents  
    read : function(path) {
	  var result;
	  foo = {
	    async: false,
	    callback: function() {
			result = (this.responseText);
	    }
	  };
	  x$().xhr(path,foo);
	  return result
    }
  },
  
  // require: load ruby source file *.rb
  require : function(path) {
	code = Ruby.File.read(path);
	Ruby.jsmruby.load(code);
  },
  
  // Provide Hash like features for JsObj instances in mruby
  JsObj : {
	// returns list of properties of object obj
    properties : function(obj) {
	  a = [];
	  cnt = -1;
	  for (i in obj) {
	    cnt = cnt + 1;
	    a[cnt] = i	
	  };
	  return a;  
    },
    
    // get property prop of object obj
    // this will return functions, not call them as in aJsObj.method_missing
    get_property : function(obj,prop) {
	  return obj[prop];
    },

    // set property prop on object obj to value value
    set_property : function(obj,prop,value) {
      obj[prop] = value;
      return value;	
    }
  },
  
  // foo
  Util : {
	  alert : function(message) {
		  alert(message);
	  },
	  
	  prompt : function(message,value) {
		  return prompt(message,value);
	  },
	  
	  confirm : function(message) {
		  return confirm(message);
	  },
	  
	  wrap_proc : function(proc) {
          f = function() {
			proc.call(this,arguments);  
		  };
		  return f;
	  },
	  
	  echo : function(str) {
		return str.toString();  
	  }
  }
} 
