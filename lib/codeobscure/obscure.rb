require_relative 'filtsymbols.rb'

class String 
  def upcase_first_letter
    self.slice(0,1).capitalize + self.slice(1..-1)
  end
end

module Obscure  


  @@TABLENAME="symbols"  
  @@SYMBOL_DB_FILE="symbols"  
  @@STRING_SYMBOL_FILE="func.list"  
  
  #维护数据库方便日后作排重  
  def self.createTable  
    if !File.exist? @@SYMBOL_DB_FILE
      `echo "create table #{@@TABLENAME}(src text, des text,PRIMARY KEY (src));" | sqlite3 #{@@SYMBOL_DB_FILE}` 
    end 
  end
    
  def self.insertValue(line,ramdom)  
    `echo "insert or ignore into #{@@TABLENAME} values('#{line}' ,'#{ramdom}');" | sqlite3 #{@@SYMBOL_DB_FILE}`
  end
    
  def self.query(line) 
    `echo "select * from #{@@TABLENAME} where src='#{line}';" | sqlite3 #{@@SYMBOL_DB_FILE}`
  end
    
  def self.ramdomString  
    `openssl rand -base64 64 | tr -cd 'a-zA-Z' |head -c 16`
  end

  #有define重复的问题等待解决
  def self.run(root_dir)

    @@HEAD_FILE="#{root_dir}/codeObfuscation.h"  
    @@SYMBOL_DB_FILE = "#{root_dir}/#{@@SYMBOL_DB_FILE}" 
    @@STRING_SYMBOL_FILE = "#{root_dir}/#{@@STRING_SYMBOL_FILE}"
    
    if File.exist? @@SYMBOL_DB_FILE
      `rm -f #{@@SYMBOL_DB_FILE}`
    end 
    if File.exists? @@HEAD_FILE 
      `rm -f #{@@HEAD_FILE}` 
    end 
    createTable  
      
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
        ramdom = ramdomString
        insertValue line_content  , ramdom  
        if line_type == "p"
          result = FiltSymbols.query("set#{line_content.upcase_first_letter}") 
          if result.nil? || result.empty? 
            file.puts "#define #{line_content} #{ramdom}"
            file.puts "#define _#{line_content} _#{ramdom}"
            file.puts "#define set#{line_content.upcase_first_letter} set#{ramdom.upcase_first_letter}"
          end
        else 
          file.puts "#define #{line_content} #{ramdom}"
        end
      end 
    end

    file.puts "#endif" 
    file.close

    `sqlite3 #{@@SYMBOL_DB_FILE} .dump`  
    if File.exist? @@SYMBOL_DB_FILE
      `rm -f #{@@SYMBOL_DB_FILE}`
    end
    if File.exist? @@STRING_SYMBOL_FILE
      `rm -f #{@@STRING_SYMBOL_FILE}`
    end
    @@HEAD_FILE
  end
end 
