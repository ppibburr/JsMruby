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
