require "codeobscure/version"
require "codeobscure/funclist"
require "colorize"
require 'xcodeproj'

module Codeobscure

  def self.obscure 
    xpj_path = ARGV[0]
    if File.exist? xpj_path
      root_dir = xpj_path.split("/")[0...-1].join "/"
      FuncList.genFuncList root_dir
      project = Xcodeproj::Project.open xpj_path
      first_target = project.targets.first
      shell_phase = first_target.new_shell_script_build_phase 
      shell_phase.shell_script = "$PROJECT_DIR/obscure.sh"
      project.save
    else 
      puts "指定的目录不存在:#{path}".colorize(:red)
    end 
  end

end
