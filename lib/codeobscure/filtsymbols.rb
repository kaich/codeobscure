require_relative "funclist.rb"
require "colorize"
module FiltSymbols
  @@filt_db_path = "#{File.expand_path '../../..', __FILE__}/filtSymbols"
  @@table_name = "symbols"

  def self.createTable  
    if !File.exist? @@filt_db_path 
      `echo "create table #{@@table_name}(src text,PRIMARY KEY (src));" | sqlite3 #{@@filt_db_path}` 
    end
  end

  def self.insertValue(line)  
    `echo "insert or ignore into #{@@table_name} values('#{line}');" | sqlite3 #{@@filt_db_path}`
  end

  def self.query(line) 
    `echo "select * from #{@@table_name} where src='#{line}';" | sqlite3 #{@@filt_db_path}`
  end

  def self.loadFiltSymbols(path) 

    createTable
    
    funclist_path = FuncList.genFuncList path

    puts "处理中,可能需要一段时间，耐心等候...".colorize(:yellow)
    symbol_file = File.open(funclist_path).read
    symbol_file.each_line do |line|
      line_content = line.rstrip
      insertValue line_content  
    end

    if File.exist? funclist_path  
      `rm -f #{funclist_path}`
    end

    `sqlite3 #{@@filt_db_path} .dump`  

  end

end
