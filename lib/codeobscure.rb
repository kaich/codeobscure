require "codeobscure/version"
require "codeobscure/funclist"
require "codeobscure/obscure"
require "colorize"
require 'xcodeproj'
require 'fileutils'
require 'optparse'

module Codeobscure

  def self.root
    File.dirname __dir__
  end

  def self.obscure 
    xpj_path = ARGV[0]
      
    if File.exist? xpj_path
      root_dir = xpj_path.split("/")[0...-1].join "/"
      shell_path = "#{root}/lib/codeobscure/obscure.sh" 
      funclist_path = FuncList.genFuncList root_dir
      header_file = Obscure.run root_dir 
      project = Xcodeproj::Project.open xpj_path
      project_name = project.name
      main_group = project.main_group
      main_group.new_reference header_file 
      project.targets.each do |target|
        if target.name = project_name  
          build_configs = target.build_configurations
          build_configs.each do |build_config| 
            build_settings = build_config.build_settings
            prefix_key = "GCC_PREFIX_HEADER"
            prefix_header = build_settings[prefix_key]
            if prefix_header.include? "codeObfuscation.h"
              break  
            elsif prefix_header.nil? 
              build_config.build_settings[prefix_key] = "#{main_group.name}/codeObfuscation.h"
            else 
              puts "请在#{prefix_header}中#import \"codeObfuscation.h\""  
            end
            break
          end
        end
      end
      project.save
    else 
      puts "指定的目录不存在:#{path}".colorize(:red)
    end 
  end

end
