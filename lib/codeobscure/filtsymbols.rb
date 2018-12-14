require_relative "funclist.rb"
require 'sqlite3'
require "colorize"
module FiltSymbols
  @@db = nil
  @@filt_db_path = "#{File.expand_path '../../..', __FILE__}/filtSymbols"
  @@table_name = "symbols"
  @@key_words = ["interface","NSInteger","BOOL","Class","free","M_PI_2","abort","change","top","bottom","NSUIntegerMax","intoString","readonly"]

  def self.open_db 
    if @@db.nil? || @@db.closed? 
      @@db = SQLite3::Database.new(@@filt_db_path)
    end
  end

  def self.createTable  
    open_db
    if @@db 
      @@db.execute "create table if not exists #{@@table_name}(src text,PRIMARY KEY (src));" 
    end
  end

  def self.insertValue(line)  
    open_db
    @@db.execute "insert or ignore into #{@@table_name} values('#{line}');"
  end

  def self.query(line) 
    open_db
    results = []
    @@db.execute "select * from #{@@table_name} where src='#{line}';" do |row|
      results << row
    end
    results
  end

  def self.loadFiltSymbols(path) 

    @@db = SQLite3::Database.new(@@filt_db_path)
    createTable
    
    funclist_path = FuncList.genFuncList path , "all" , false

    puts "处理中,可能需要一段时间，耐心等候...".colorize(:yellow)
    symbol_file = File.open(funclist_path).read
    symbol_file.each_line do |line|
      line_content = line.rstrip.split(":").last
      insertValue line_content  
    end

    @@key_words.each do |word|
      insertValue word
    end

    if File.exist? funclist_path  
      `rm -f '#{funclist_path}'`
    end

  end


  def self.loadStrictMode(path) 
    file_pathes = []
    file_pathes += `find #{path} -name "*.h" -d`.split "\n"
    file_pathes += `find #{path} -name "*.m" -d`.split "\n"
    
    file_pathes.each do |file_path|
      content = File.read file_path
      FuncList.loadStrictSymbols content
    end
    
  end

end
