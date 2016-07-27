require_relative 'filtsymbols.rb'
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
      line_content = line.rstrip
      result = FiltSymbols.query(line_content) 
      puts  "----------#{result}"
      if result.nil? || result.empty? 
        puts "+++++++++++++"
        ramdom = ramdomString
        insertValue line_content  , ramdom  
        file.puts "#define #{line_content} #{ramdom}"
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
