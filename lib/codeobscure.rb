require "codeobscure/version"
require "codeobscure/funclist"
require "codeobscure/obscure"
require "codeobscure/filtsymbols"
require "codeobscure/imagemix"
require "colorize"
require 'xcodeproj'
require 'fileutils'
require 'optparse'
require 'shellwords'

module Codeobscure

  @@ignore_symbols_path = "ignoresymbols"

  def self.root
    File.dirname __dir__
  end

  #waiting for add optionparse and add class obscure
  def self.obscure 

    options = {}
    #默认是随机替换的方式
    options[:type] = "r"
    OptionParser.new do |opts|
      opts.banner = "Usage: obscure code for object-c project"

      opts.on("-o", "--obscure XcodeprojPath", "obscure code") do |v|
        options[:obscure] = v
      end

      opts.on("-l", "--load path1,path2,path3",Array,"load filt symbols from path") do |v|
        options[:load] = v 
      end

      opts.on("-r", "--reset", "reset loaded symbols") do |v|
        options[:reset] = true
      end

      opts.on("-f", "--fetch type1,type2,type3", "fetch and replace type,default type is [c,p,f,i]. c for class, p for property, f for function") do |v|
        options[:fetch] = v
      end

      opts.on("-i", "--ignore XcodeprojPath", "create a ignore file, you can write your filt symbols in it.eg:name,age ...") do |v|
        options[:ignore] = v 
      end

      opts.on("-t", "--type replaceType", "obscure type = [r,w,c] ,r: random w: random words c: custom replace rule") do |v|
        options[:type] = v 
      end

      opts.on("-s", "--strict", "strict mode. It will filter all string. If there are many kvo in code, please add -s.") do |v|
        options[:strict] = true
      end

    end.parse!

    if options[:reset] 
      `rm -f '#{root}/filtSymbols'`
      `cp '#{root}/filtSymbols_standard' '#{root}/filtSymbols'`
      puts "重置完毕!".colorize(:green)
    end

    if options[:ignore] 
      xpj_path = options[:ignore]
      if File.exist? xpj_path
        root_dir = xpj_path.split("/")[0...-1].join "/"
        ignore_path = "#{root_dir}/#{@@ignore_symbols_path}"
        if !File.exist? ignore_path
          `touch #{ignore_path}`
        end
      end
    end

    #only load, execute load only
    #only obscure, execute obscure only
    #load and obscure at same time,load firt,then obscure.That's mean you can get rid of some directoies.
    load_pathes = options[:load]
    if load_pathes 
      load_pathes.each do |load_path|
        if File.exist? load_path 
          FiltSymbols.loadFiltSymbols load_path 
          puts "加载完毕!".colorize(:green)
        else 
          puts "指定的目录不存在:#{load_path}".colorize(:red)
        end
      end
    end

    fetch_types = ["p","c","f"]
    if !options[:fetch].nil? && options[:fetch].length > 0
      fetch_types = options[:fetch] 
    end


    if options[:obscure]  

      xpj_path = options[:obscure]
      if File.exist? xpj_path
        root_dir = xpj_path.split("/")[0...-1].join "/"
        ImageMix.mix root_dir
        if options[:strict] 
          FiltSymbols.loadStrictMode root_dir
          puts "准备严格模式完成!".colorize(:green)
        end
        FuncList.genFuncList root_dir , "h", true, fetch_types
        header_file = Obscure.run root_dir , options[:type]
        project = Xcodeproj::Project.open xpj_path
        project_name = xpj_path.split("/").last
        main_group = project.main_group
        if !main_group.find_file_by_path("codeObfuscation.h")
          main_group.new_reference header_file 
        end
        project.targets.each do |target|
          if "#{target.name}.xcodeproj" == project_name  
            build_configs = target.build_configurations
            build_configs.each do |build_config| 
              build_settings = build_config.build_settings
              prefix_key = "GCC_PREFIX_HEADER"
              prefix_header = build_settings[prefix_key]
              if prefix_header.nil? || prefix_header.empty? 
                build_config.build_settings[prefix_key] = "./codeObfuscation.h"
              elsif prefix_header.include? "codeObfuscation.h"
                puts "#{target.name}:#{build_config}配置文件已配置完成".colorize(:green)
              else 
                puts "请在#{prefix_header}中#import \"codeObfuscation.h\"".colorize(:green)
              end
            end
          end
        end
        project.save
        #Fix bug for SIP
        system "chmod 755 '#{xpj_path}/project.pbxproj'"
        puts "配置完成!".colorize(:green)
        puts "请直接运行项目，如果项目中出现类似: `+[LoremIpsum PyTJvHwWNmeaaVzp:]: unrecognized selector sent to class`。在codeObfuscation.h中查询PyTJvHwWNmeaaVzp并删除它!".colorize(:yellow)
      else 
        puts "指定的目录不存在:#{path}".colorize(:red)
      end 

    end

  end

end
