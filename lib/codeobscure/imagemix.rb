require "colorize"
module ImageMix

    def self.mix(root_path) 

        puts "处理图片资源中...".colorize(:yellow)

        file_pathes = `find #{root_path} -name "*.png" -d`.split "\n"
        file_pathes += `find #{root_path} -name "*.jpeg" -d`.split "\n"
        file_pathes += `find #{root_path} -name "*.jpg" -d`.split "\n"
        file_pathes += `find #{root_path} -name "*.pdf" -d`.split "\n"

        file_pathes.each do |file_path|
            puts "处理图片#{file_path}"

            identifier = "9751ccfb0743f75600dba0d69e482433"  
            date_str = Time.now.to_f.to_s
            content = File.read(file_path)
            addition_content = "#{identifier}#{date_str}#{identifier}"
            aindex = content.index identifier
            if aindex
                content[aindex..-1] = addition_content
            else
                content += addition_content
            end
            File.open(file_path, "w") {|file| file.puts content }
        end
    end

end