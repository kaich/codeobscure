module FuncList

  regex = /\s*(\w+)\s*:\s*\(\s*\w+\s*\*?\s*\)\s*\w+\s*/

  def self.capture(str) 
    results = []
    str.scan regex do |curr_match|
      md = Regexp.last_match
      whole_match = md[0]
      captures = md.captures

      captures.each do |capture|
        results << capture
        p [whole_match, capture, whole_match.index(capture)]
      end
    end
  end

  def self.genFuncList(path)
    capture_methods = []
    file = File.open("/tmp/some_file", "w")
    file_pathes = `find . -name "*.m"`.split "\n"
    file_pathes.each do |file_path|
      full_file_path = path + file_path[1...-1]
      content = File.read full_file_path
      captures = capture content 
      capture_methods = capture_methods + captures
      if capture_methods.length % (1024 * 1024) == 0 
        file.write(captures.join "\n") 
        capture_methods = []
      end
    end
    if capture_methods.length > 0 
      file.write(captures.join "\n") 
    end
    file.close
  end
  
end

