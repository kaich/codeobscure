require_relative 'filtsymbols.rb'
require 'sqlite3'
require 'random_word'

class String 
  def upcase_first_letter
    self.slice(0,1).capitalize + self.slice(1..-1)
  end
end

module Obscure  

  @@STRING_SYMBOL_FILE="func.list"  
  @@IGNORE_NAME="ignoresymbols"
 
  #type 1 ：随机字符, 2 : 随机单词, 3 : 自定义单词替换
  def self.ramdomString(var_type , replace_type = 1)  
    result = ""
    case replace_type 
    when 1
      result = `openssl rand -base64 64 | tr -cd 'a-zA-Z' |head -c 16`
    when 2 
      words = RandomWord.phrases.next.split /[ _]/  
      join_words = ""
      words.each_with_index do |word,index| 
        if index == 0  

          join_words += word
          if var_type == "c"
            join_words.capitalize!
          end
        else
          join_words += word.capitalize
        end
      end
      result = join_words
    when 3
      raise "c选项功能暂未实现，下一版本中加入！"
    end
  

    result
  end

  def self.toTypeNumber(type)
    result = 1
    case type
    when "r"
      result = 1
    when "w" 
      result = 2
    when "c"
      result = 3
    else
      raise "该参数不符合！"
    end

    result
  end

  #有define重复的问题等待解决
  def self.run(root_dir,type = 'r')

    replace_type = toTypeNumber type

    @@HEAD_FILE="#{root_dir}/codeObfuscation.h"  
    @@STRING_SYMBOL_FILE = "#{root_dir}/#{@@STRING_SYMBOL_FILE}"

    ignore_symbols = []
    ignore_path = "#{root_dir}/#{@@IGNORE_NAME}"
    if File.exist? ignore_path
      ignore_content = File.read ignore_path
      ignore_symbols = ignore_content.gsub(/\s/ , "").split ","
    end
    
    if File.exists? @@HEAD_FILE 
      `rm -f #{@@HEAD_FILE}` 
    end 

    date = `date`
    file = File.new @@HEAD_FILE , 'w'
    file.puts "#ifndef co_codeObfuscation_h" 
    file.puts "#define co_codeObfuscation_h" 
    file.puts "//confuse string at #{date.to_s}"

    symbol_file = File.open(@@STRING_SYMBOL_FILE).read
    symbol_file.each_line do |line|
      line_type = line.rstrip.split(":").first
      line_content = line.rstrip.split(":").last
      result = FiltSymbols.query(line_content) 
      if result.nil? || result.empty? 
        ramdom = ramdomString line_type , replace_type
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
