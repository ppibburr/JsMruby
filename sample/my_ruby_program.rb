require "file_to_require.rb"

JS::DOM.on_ready do
  begin
    puts "$OK is: #{$OK}"
    div = document.createElement("div")
    div.id = "sample"
    document.getElementsByTagName("body")[0].appendChild(div)
    sample_ruby_lib()
  rescue => e
    puts e
    puts e.backtrace.join("\n")
  end 
end

def clear_sample
  document.getElementById("sample").innerHTML = ""
end

def sample_dom
  clear_sample()
  
  html = "<pre>Click me ...\n\n"+
  "Demonstration using core jsmruby\n"+
  "only relying on JS::Object\n"+
  "in leu of JsObj and JsFunc\n"+
  "to manipulate DOM and define events\n"+
  "JS::Object wraps both JsFunc and JsObj</pre>" 
  
  parent = document.getElementById("sample")
  div = document.createElement("div")

  div.innerHTML = html
  div.id = "sample_dom"
  div.style.apply :color=>:blue, :backgroundColor=>:gray, :width=>305.px,
                  :height=>200.px, :border=>"black solid 5px"
  
  parent.appendChild(div)
   
  a = Proc.new() do |this,args|
    log_event(this,args)
  end
  
  b = Proc.new() do |this,args|
    log_event(this,args)
  end
  
  div["onclick"] = a
  div.onmouseover = b
  
  div.set "onmouseup" do |this,args|
    log_event(this,args)
  end
  
rescue => e
  puts e
  puts e.backtrace.join("\n") 
end

def sample_dom_ext
  clear_sample()
  
  html = "<pre>Click me ...\n\n"+
  "Demonstration using Rubyfied\n"+
  "conventions to manipulate DOM and\n"+
  "define events</pre>" 
  
  parent = document.getElementById("sample")
  parent = JS::DOM::Element.wrap parent

  div = JS::DOM::Element.new("div",parent)

  div.innerHTML = html
  div.id = "sample_dom"
  
  div.style.apply :color=>:black, :backgroundColor=>:pink, :width=>305.px,
                  :height=>200.px, :border=>"blue solid 3px"
   
  div.on "click" do |this,args|
    log_event(this,args)
  end
 
  div.on "mouseover" do |this,args|
    log_event(this,args)
  end
  
  div.on "mouseup" do |this,args|
    log_event(this,args)
  end
  
rescue => e
  puts e
  puts e.backtrace.join("\n") 
end

def sample_dialog

end

def sample_dom_xui
  clear_sample()
  
  html = "<pre>Click me ...\n\n"+
  "Demonstration using XUI.js\n"+
  "as an external JS library to\n"+
  "manipulate DOM and define\n"+
  "events</pre>" 
  
  parent = XUI.collect("#sample")
  parent.html("inner","<div id=sample_library>#{html}</div>")
 
  div = XUI.collect("#sample_library")

  style = {
    :color=>"white", :backgroundColor=>"blue", :width=>305.px,
    :height=>200.px, :border=>"red solid 3px"
  }
  
  style.each_key do |k|
    div.setStyle(k.to_s,style[k])
  end
   
  div.click do |this,args|
    log_event(this,args)
  end
 
  div.on "mouseover" do |this,args|
    log_event(this,args)
  end
  
  div.on "mouseup" do |this,args|
    log_event(this,args)
  end
  
rescue => e
  puts e
  puts e.backtrace.join("\n") 
end

def sample_dom_ruby
  clear_sample()
  
  html = "<pre>Click me ...\n\n"+
  "Demonstration using XUI.js\n"+
  "as an external JS library to\n"+
  "manipulate DOM and define\n"+
  "events</pre>" 

  parent = JS.collect(:sample)
  parent.set("innerHTML","<div id=sample_ruby>#{html}</div>")
 
  div = JS.collect(:sample_ruby)
  
  div.style.apply :color=>"white", :backgroundColor=>"blue", :width=>305.px,
                  :height=>200.px, :border=>"red solid 3px"
   
  div.on "click" do |this,args|
    log_event(this,args)
  end
 
  div.on "mouseover" do |this,args|
    log_event(this,args)
  end
  
  div.on "mouseup" do |this,args|
    log_event(this,args)
  end
  
rescue => e
  puts e
  puts e.backtrace.join("\n") 
end

def log_event this,args
	event = args[0]
	puts "this: " + this.toString + " Event: " + event.toString + " type; " + event.type + " target, " + event.target.toString
end

def sample_ruby_lib
  clear_sample()
  
  parent = JS.collect(:sample)
  
  sample = JS::DOM::Element.new("div",parent.element())  
  sample.style.apply :width=>305.px,:border=>"solid black 2px"
  sample.id = "sample_ruby"
  
  optimize = nil
  
  cnt = 0
  
  for i in 0..2
    child = optimize ? JS::DOM::Element.wrap(optimize.cloneNode(true)) : (optimize = JS::DOM::Element.new("div",sample.element()))

    if cnt == 0
      child.set "className", "test even"
    else
      child.set 'className', "test odd"
    end
    
    cnt = cnt + 1
    
    if cnt == 2 then cnt = 0 end
    
    child.id = "test_div_#{i}"

    child.innerText = "test div #{i}"

    sample.appendChild(child)  
  end
  
  even = JS.collect("div").has_class?("even")
  odd = JS.collect("div").has_class?("odd")

  even.style.backgroundColor = "blue"
  odd.style.backgroundColor = "green"
    
  [:click, :mouseup, :mouseover].each do |e|  
    [even,odd].each_with_index do |col,i|
      col.on e.to_s do |this,args|
        if i == 0
          puts "\n\nEvent for even class:"
        else
          puts "\n\nEvent for odd class"
        end
        log_event(this,args)
      end
    end
  end
end
