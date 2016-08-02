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
    -f, --fetch type1,type2,type3    fetch and replace type,default type is [c,p,f].c for class,p for property,f for function


-o [project file path], obscure for the project.    
-l [path],load filt symbol path. if you don't want obscure code for some direcotry. you can use this option.    
-r reset loaded filt symbols.
-f, --fetch type1,type2,type3    fetch and replace type,default type is [c,p,f].c for class,p for property,f for function

codeobscure主要用于oc（目前来说由于swift的特性摆在那里，这种方式不适用于swift）的项目，利用[iOS安全攻防（二十三）：Objective-C代码混淆](http://blog.csdn.net/yiyaaixuexi/article/details/29201699)的方式去进行代码混淆,纯粹的娱乐自己恶心他人。此工具会默认遍历项目属性，方法和类名进行混淆。当然如果简单的进行遍历的话，会产生无穷无尽的错误，因为你不可能混淆苹果提供给你的官方API，也不能混淆framework和.a的静态编译的库。所以在混淆代码的时候必须排除掉它们。我已经帮你过滤了系统的方法。如果你的项目中使用Pod或者使用了静态库，或者其他比较特别的第三方库，请使用`codeobscure -l [路径1,路径2..]`的方式去过滤这些库文件。运行`codeobscure -o [项目名.xcodepro]`去调用混淆你的代码，然后耐心等待一会就可以了。当然并不意味这你运行了就一定没错误，该工具最大的简化了混淆代码的工作，由于不同的人编写的代码可能各不相同。假设你调用了`NSClassFromString("classNameA")`而这个类正好被混淆了，它不识别classNameA到底是什么。那么怎么解决这个错误呢。最简单的方式就是在`codeObfuscation.h`中查询classNameA并删除它的#define即可。我测试的项目是有打几年历史的一个项目，代码也挺多的。合理的过滤掉某些不应该混淆的方法。提示错误的仅仅只有一个地方,然后就是运行的时候有几处崩溃，都是因为方法被混淆了，不识别方法导致的，仅仅删除它就可以了。运行完成后，除了解决错误，你不需要进行额外的文件添加删除操作，我已帮你添加好了。你觉得代码混淆不好用，那么直接删除codeObfuscation.h就行了。此致，敬礼！

Example :

	codeobscure -o /Users/mac/Downloads/Examples/Messenger.xcodeproj  -l /Users/mac/Downloads/Examples/Pods >> /Users/mac/Desktop/9.3/1.txt



## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/codeobscure. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

