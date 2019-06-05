module FuncList

  require_relative "filtSymbols.rb"
  require 'pathname'

  # @@func_regex = /\s*(\w+)\s*:\s*\(\s*\w*\s*\s*\w+\s*\*?\s*\)\s*\w+\s*/
  @@func_regex = /\s*[-\+]\s*\(.*?\)\s*(\w+)\s*:\s*\(\s*\w*\s*\s*\w+\s*\*?\s*\)\s*\w+\s*/
  @@func_simple_regex = /\s*[-\+]\s*\(.*?\)\s*(\w+)\s*;*/
  @@hcls_regex = /@interface\s+(\w+)\s*:\s*(\w+)/
  @@mcls_regex = /@implementation\s+(\w+)\s*/
  @@property_regex = /\s*@property\s*\(.*?getter=(\w+).*?\)\s*\w+\s*\*?\s*\w+\s*.*;/
  @@property_regex2 = /\s*@property\s*\(.*?\)\s*\w+\s*\*?\s*(\w+)\s*.*;/
  @@property_regex3 = /\s*@property\s*\(.*?\)\s*\w+\s*<.*>\s*\*?\s*(\w+)\s*.*;/
  #---------------filter regex----------------
  @@strict_filt_regex = /@"(\w+?)"/
  @@storyboard_filt_regex = /customClass="(\w+)"/
  @@value_for_key_filte_regex = /\[\w*\s+setValue\s*:\s*.*\s* forKey\s*:\s*@\"(.*)\"\]/
  @@class_from_str_regex = /NSClassFromString\(\s*@"(\w+)"\s*\)/
  @@func_filt_keys = ["IBAction"]
  @@cls_filt_keys = ["NSManagedObject"]

  def self.validate?(str, type) 
    for filt_key  in @@func_filt_keys
       return false if str.include? filt_key 
    end
    return true
  end

  def self.to_utf8(str)
    str = str.force_encoding('UTF-8')
    return str if str.valid_encoding?
    str.encode("UTF-8", 'binary', invalid: :replace, undef: :replace, replace: '')
  end

  def self.capture(content_str,type = "m",fetch_types=["p","f","c"],file_path=nil,is_need_filt=false) 
    str = to_utf8 content_str

    #filter file  
    if file_path.include?(".storyboard") || file_path.include?(".xib")  
      str.scan @@storyboard_filt_regex do |curr_match|
        md = Regexp.last_match
        whole_match = md[0]
        captures = md.captures

        captures.each do |capture|
          FiltSymbols.insertValue capture
          p "过滤的#{File.basename(file_path)}数据：#{capture}"
        end
      end
      return []
    end

    # begin capture 
    results = []
    if fetch_types.include? "f"
      str.scan @@func_regex do |curr_match|
        md = Regexp.last_match
        whole_match = md[0]
        captures = md.captures

        if validate? whole_match , 'f' 
          captures.each do |capture|
            results << "f:#{capture}"
            #p [whole_match, capture]
            p "f:[#{capture}]"
          end
        end
      end
      #no arguments function
      str.scan @@func_simple_regex do |curr_match|
        md = Regexp.last_match
        whole_match = md[0]
        captures = md.captures

        if validate? whole_match , 'f' 
          captures.each do |capture|
            results << "f:#{capture}"
            #p [whole_match, capture]
            p "f:[#{capture}]"
          end
        end
      end
    end
    cls_regexs = ""
    if type == "all"
      cls_regexs = [@@hcls_regex,@@mcls_regex]
    elsif type == "h" 
      cls_regexs = [@@hcls_regex]
    else
      cls_regexs = [@@mcls_regex]
    end
    cls_regexs.each do |cls_regex|
      if fetch_types.include? "c"
        str.scan cls_regex do |curr_match|
          md = Regexp.last_match
          whole_match = md[0]
          captures = md.captures

          captures.each do |capture|
            if is_need_filt 
              if @@cls_filt_keys.include? capture 
                puts "过滤类#{capture}..."
                if file_path 
                  FiltSymbols.loadFiltSymbols file_path
                end
              end 
            end
            results << "c:#{capture}"
            #p [whole_match, capture]
            p "c:[#{capture}]"
          end
        end
      end
    end
    if fetch_types.include? "p"
      str.scan @@property_regex do |curr_match|
        md = Regexp.last_match
        whole_match = md[0]
        captures = md.captures

        captures.each do |capture|
          results << "p:#{capture}"
          #p [whole_match, capture]
          p "p:[#{capture}]"
        end
      end
      str.scan @@property_regex2 do |curr_match|
        md = Regexp.last_match
        whole_match = md[0]
        captures = md.captures

        captures.each do |capture|
          results << "p:#{capture}"
          #p [whole_match, capture]
          p "p:[#{capture}]"
        end
      end
      str.scan @@property_regex3 do |curr_match|
        md = Regexp.last_match
        whole_match = md[0]
        captures = md.captures

        captures.each do |capture|
          results << "p:#{capture}"
          #p [whole_match, capture]
          p "p:[#{capture}]"
        end
      end
    end
    #---------------记录可能引起崩溃的字段----------------
    str.scan @@value_for_key_filte_regex do |curr_match|
      md = Regexp.last_match
      whole_match = md[0]
      captures = md.captures

      captures.each do |capture|
        FiltSymbols.insertValue capture
        p "过滤的[setValue forkey]数据：#{capture}"
      end
    end

    str.scan @@class_from_str_regex do |curr_match|
      md = Regexp.last_match
      whole_match = md[0]
      captures = md.captures

      captures.each do |capture|
        FiltSymbols.insertValue capture
        p "过滤的[NSClassFromString]数据：#{capture}"
      end
    end
    results
  end

  def self.genFuncList(path,type = "m",need_filt=true,fetch_types=["p","f","c"])
    capture_methods = []
    p_methods = []
    funclist_path = "#{path}/func.list"  
    if File.file?(path) 
      funclist_path = "#{File.dirname(path)}/func.list"
    end
    file = File.open(funclist_path, "w")
    file_pathes = []
    if type == "h" || type == "m"
      file_pathes = `find '#{path}' -name "*.#{type}" -d`.split "\n"
    elsif type == "all"
      file_pathes += `find '#{path}' -name "*.h" -d`.split "\n"
      file_pathes += `find '#{path}' -name "*.m" -d`.split "\n"
    end
    file_pathes += `find '#{path}' -name "*.storyboard" -d`.split "\n"
    file_pathes += `find '#{path}' -name "*.xib" -d`.split "\n"

    file_pathes.each do |file_path|
      content = File.read file_path
      captures = capture content , type , fetch_types, file_path, need_filt
      captures.each do |capture_method| 
        method_type = capture_method.split(":").first
        method_content = capture_method.split(":").last
        if !(method_content.start_with?("init") || method_content.start_with?("set") || method_content.start_with?("_") || method_content.length < 4) || !need_filt
          if method_type == "c" || method_type == "f"
            if !capture_methods.include? capture_method 
              capture_methods << capture_method 
            end
          elsif method_type == "p"
            if !p_methods.include? capture_method 
              p_methods << capture_method 
            end
          end
        end
      end
    end
    
    p_methods.each do |capture_method|
      method_type = capture_method.split(":").first
      method_content = capture_method.split(":").last
      c_method = "c:#{method_content}"
      f_method = "f:#{method_content}"
      if capture_methods.include? c_method
        capture_methods.delete c_method
      end
      if capture_methods.include? f_method
        capture_methods.delete f_method
      end
    end

    capture_methods += p_methods

    if capture_methods.length > 0 
      file.write(capture_methods.join "\n") 
    end
    file.close
    funclist_path
  end


  def self.loadStrictSymbols(content_str) 
    str = to_utf8 content_str
    str.scan @@strict_filt_regex do |curr_match|
      md = Regexp.last_match
      whole_match = md[0]
      captures = md.captures

      captures.each do |capture|
        FiltSymbols.insertValue capture
        p "执行严格模式过滤：#{capture}"
      end
    end
  end
  
end

