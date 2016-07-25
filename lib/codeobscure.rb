require "codeobscure/version"
require "codeobscure/funclist"
require "colorize"

module Codeobscure

  def self.obscure 
    path = ARGV[0]
    if File.exist? path
      FuncList.genFuncList path
    else 
      puts "指定的目录不存在:#{path}".colorize(:red)
    end 
  end

end
