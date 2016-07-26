require "codeobscure/version"
require "codeobscure/funclist"
require "colorize"
require 'xcodeproj'
require 'fileutils'

module Codeobscure

  def self.root
    File.dirname __dir__
  end

  def self.obscure 
    xpj_path = ARGV[0]
    if File.exist? xpj_path
      root_dir = xpj_path.split("/")[0...-1].join "/"
      shell_path = "#{root}/lib/codeobscure/obscure.sh" 
      FuncList.genFuncList root_dir
      project = Xcodeproj::Project.open xpj_path
      first_target = project.targets.first
      is_shell_phase_exist = false
      shell_script = "$PROJECT_DIR/obscure.sh"
      first_target.shell_script_build_phases.each do |shell_phase|
        if shell_phase.shell_script ==  shell_script
          is_shell_phase_exist = true
        end
      end
      if !is_shell_phase_exist 
        shell_phase = first_target.new_shell_script_build_phase 
        shell_phase.shell_script = shell_script
      end
      FileUtils.cp shell_path , "#{root_dir}/obscure.sh"
      project.save
    else 
      puts "指定的目录不存在:#{path}".colorize(:red)
    end 
  end

end
