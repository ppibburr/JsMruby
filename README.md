
# mruby NPAPI plugin for Firefox and Chrome

## Sample
Usage of ruby.js in sample/ to load ruby files
paths resolved as an url would be normally

see sample/

```html
<!DOCTYPE html>
<html>
  <head>
    <title>JsMruby Sample</title>
    <script type="text/javascript" src="ruby_js/resource/xui.js"></script>
    <script type="text/javascript" src="ruby_js/resource/ruby.js"></script>
  </head>

  <body id="bodyId">
    <object id="jsmruby" type="application/x-jsmruby-plugin" width="1" height="1" style="position: absolute;">install JsMruby</object>
    <script type="text/javascript">
      // retrieve and initialize the mruby, and 'require' a ruby file 
      jsmruby = document.getElementById("jsmruby");
      Ruby.init(jsmruby);
      Ruby.require("my_ruby_program.rb"); // :D no more javascript!
    </script>
  </body>
</html>
```

