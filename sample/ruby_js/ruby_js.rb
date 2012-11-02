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

require 'ruby_js/lib/classes/file.rb'
require 'ruby_js/lib/classes/monkey.rb'
require 'ruby_js/lib/common.rb'
require 'ruby_js/lib/core.rb'

alert(File)
