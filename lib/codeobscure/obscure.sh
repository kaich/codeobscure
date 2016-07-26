Module Obscure  
  @@TABLENAME=symbols  
  @@SYMBOL_DB_FILE="symbols"  
  @@STRING_SYMBOL_FILE="func.list"  
  @@HEAD_FILE="$PROJECT_DIR/codeObfuscation.h"  
  
  #维护数据库方便日后作排重  
  def createTable  
    `echo "create table #{@@TABLENAME}(src text, des text);" | sqlite3 #{@@SYMBOL_DB_FILE}` 
  end
    
  def insertValue  
    `echo "insert into #{@@TABLENAME} values('$1' ,'$2');" | sqlite3 #{@@SYMBOL_DB_FILE}`
  end
    
  def query  
    `echo "select * from #{@@TABLENAME} where src='$1';" | sqlite3 #{@@SYMBOL_DB_FILE}`
  end
    
  def ramdomString  
    `openssl rand -base64 64 | tr -cd 'a-zA-Z' |head -c 16`
  end

  def run 
    
    `rm -f #{@@SYMBOL_DB_FILE}` 
    `rm -f #{@@HEAD_FILE}` 
    createTable  
      
    `touch #{HEAD_FILE}` 
    echo '#ifndef co_codeObfuscation_h  
    #define co_codeObfuscation_h' >> $HEAD_FILE  
    echo "//confuse string at `date`" >> $HEAD_FILE  
    cat "$STRING_SYMBOL_FILE" | while read -ra line; do  
        if [[ ! -z "$line" ]]; then  
            ramdom=`ramdomString`  
            echo $line $ramdom  
            insertValue $line $ramdom  
            echo "#define $line $ramdom" >> $HEAD_FILE  
        fi  
    done  
    echo "#endif" >> $HEAD_FILE  
      
      
    sqlite3 $SYMBOL_DB_FILE .dump  
  end
end 
