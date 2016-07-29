# Codeobscure

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/codeobscure`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation

Add this line to your application's Gemfile:

install it yourself as:

    $ gem install codeobscure

## Usage

`codeobscure -h` for command help. 


	Usage: obscure code for object-c project
	    -o, --obscure XcodeprojPath      obscure code
	    -l, --load path1,path2,path3     load filt symbols from path
	    -r, --reset                      reset loaded symbols


-o [project file path], obscure for the project.    
-l [path],load filt symbol path. if you don't want obscure code for some direcotry. you can use this option.    
-r reset loaded filt symbols.

Example :

	codeobscure -o /Users/mac/Downloads/Examples/Messenger.xcodeproj  -l /Users/mac/Downloads/Examples/Pods >> /Users/mac/Desktop/9.3/1.txt



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/codeobscure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

