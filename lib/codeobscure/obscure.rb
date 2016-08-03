require_relative 'filtsymbols.rb'
require 'sqlite3'

class String 
  def upcase_first_letter
    self.slice(0,1).capitalize + self.slice(1..-1)
  end
end

module Obscure  

  @@STRING_SYMBOL_FILE="func.list"  
  @@IGNORE_NAME="ignoresymbols"
  
  def self.ramdomString  
    `openssl rand -base64 64 | tr -cd 'a-zA-Z' |head -c 16`
  end

  #有define重复的问题等待解决
  def self.run(root_dir)

    @@HEAD_FILE="#{root_dir}/codeObfuscation.h"  
    @@STRING_SYMBOL_FILE = "#{root_dir}/#{@@STRING_SYMBOL_FILE}"

    ignore_symbols = []
    ignore_path = "#{root_dir}/#{@@IGNORE_NAME}"
    if File.exist? ignore_path
      ignore_content = File.read ignore_path
      ignore_symbols = ignore_content.gsub(" " , "").split ","
    end
    
    if File.exists? @@HEAD_FILE 
      `rm -f #{@@HEAD_FILE}` 
    end 

    date = `date`
    file = File.new @@HEAD_FILE , 'w'
    file.puts "#ifndef co_codeObfuscation_h" 
    file.puts "#define co_codeObfuscation_h" 
    file.puts "//confuse string at #{date.to_s}"

    #beginTransition
    symbol_file = File.open(@@STRING_SYMBOL_FILE).read
    symbol_file.each_line do |line|
      line_type = line.rstrip.split(":").first
      line_content = line.rstrip.split(":").last
      result = FiltSymbols.query(line_content) 
      if result.nil? || result.empty? 
        ramdom = ramdomString
        if line_type == "p"
          result = FiltSymbols.query("set#{line_content.upcase_first_letter}") 
          if result.nil? || result.empty? 
            if !ignore_symbols.include?(line_content)
              file.puts "#define #{line_content} #{ramdom}"
              file.puts "#define _#{line_content} _#{ramdom}"
              file.puts "#define set#{line_content.upcase_first_letter} set#{ramdom.upcase_first_letter}"
            end
          end
        else 
            if !ignore_symbols.include?(line_content)
              file.puts "#define #{line_content} #{ramdom}"
            end
        end
      end 
    end

    file.puts "#endif" 
    file.close

    if File.exist? @@STRING_SYMBOL_FILE
      `rm -f #{@@STRING_SYMBOL_FILE}`
    end
    @@HEAD_FILE
  end
end 
