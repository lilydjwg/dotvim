module Vjde #{{{1
        $java_command="java" 

        PUBLIC = 0x00000001
        PRIVATE= 0x00000002
        PROTECTED=0x00000004
        STATIC=0x00000008
        FINAL=0x00000010
        SYNCHRONIZED=0x00000020
        VALATILE=0x00000040
        TRANSIENT=0x00000080
        NATIVE=0x00000100
        INTERFACE=0x00000200
        ABSTRACT=0x00000400
        STRICT=0x00000800
        def Vjde.getClass(jar,path,name,level=0,imps=[]) #{{{2
                if path == "" 
                    path='""'
                end
                args = getArgs(name,level,imps)
                str = `#{$java_command} -jar #{jar} #{path} #{args}`
                #puts "#{$java_command} -jar #{jar} #{path} #{args}"
		if str.chomp()==""
			return []
		end
                return eval(str.gsub("\n",""))
        end
	def Vjde.getClass4imps(jar,path,name,impstr,level1) #{{{2
                if path == "" 
                    path='""'
                end
		str = `#{$java_command} -jar #{jar} #{path} \"#{name}\" #{level1} #{impstr}`
		if str.chomp()==""
			return []
		end
                #return eval(str)
                return eval(str.gsub("\n",""))
	end
        def Vjde.getArgs(name,level,imps) #{{{2
                if ( imps.length > 0) 
                        str =  "\""+ name +"\""+ " 0 "
                        imps.each { |i| str << i << " " }
                        return str
                else
                        return   "\""+name+"\"" + " 0 "
                end
        end
        class JavaField #{{{2
                attr_accessor :f_name
                attr_accessor :f_type
                def initialize ( arr ) 
                        @f_name = arr[0]
                        @f_type = arr[1]
                end
                def to_s
                    return @f_type+" "+@f_name+";"
                end
                def to_cfu
                    return @f_type+" "+@f_name+";\n"
                end
        end
        class JavaMethod 
                attr_accessor :name
                attr_accessor :ret_type
                attr_accessor :paras
                attr_accessor :exces
                attr_accessor :modifier
                def initialize  ( arr)
                        @name = arr[0]
                        @ret_type = arr[1]
                        @paras = arr[2..-3]
                        @exces = arr[-2]
                        @modifier = arr[-1]
                end
                def to_s
                    str = @ret_type + " " + @name+"("+@paras.join(", ")+")"
                    if ( exces.length>0)
                        str << " throws " ;
                        str << exces.join(",")
                    end
                    return str << ";"
                end
                def to_arr_str
                    str = '["'
                    if @modifier&PUBLIC !=0
                        str << "public "
                    elsif @modifier&PROTECTED!=0
                        str << "protected "
                    elsif @modifier&ABSTRACT != 0
                        str << "abstract "
                    end
                    str << '","'
                    str << @ret_type << '","' << @name << '",'
                    str << '["'<< @paras.join('","') << '"],' if @paras.length > 0
                    str << '[],' if @paras.length == 0
                    str << '["' << @exces.join('","') << '"]' if @exces.length >0
                    str << '[]' if @exces.length == 0
                    str << ']'
                    return str
                end
                def to_cfu
                    return @name+"(/***"+@ret_type + " " + @name+"("+@paras.join(",")+")***/\n"
                end
        end
        class JavaConstructor 
                attr_accessor :name
                attr_accessor :paras
                attr_accessor :exces
                def initialize ( arr ) 
                        @name = arr[0]
                        @paras = arr[1..arr.length-2]
                        @exces = arr[arr.length-1]
                end
                    def to_s
                        str = @name +" "+ @name.sub(/^([a-zA-Z0-9]+\.)*([a-zA-Z0-9_]+)$/,'\2')+"("+@paras.join(", ")+")"
                        str << " throws "+@exces.join(",") if @exces.length>0
                        str << ";"
                        str
                    end
        end
        class JavaClass
                attr_accessor :name
                attr_accessor :fields
                attr_accessor :constructors
                attr_accessor :methods
                attr_accessor :inners
                attr_accessor :modifier
                def initialize (arr)
			@name = nil
                       if ( arr.length > 0 ) 
                               @name = arr[0]
                               @fields=[]
                               arr[1].each { |f| @fields << JavaField.new(f) }

                               @constructors=[]
                               arr[2].each { |c| @constructors << JavaConstructor.new(c) }

                               @methods=[]
                               arr[3].each { |m| @methods << JavaMethod.new(m) }
                               @methods.sort! { |a,b| a.name <=>b.name }

                               @inners=arr[4]
                               @modifier = arr[5]
                       end 
                end
                def to_s
			if ( @name == nil) 
				return ""
			end
                        str =  "public class "+@name
                        @fields.each { |f| str<< "\tpublic "+f.to_s }
                        @constructors.each { |c| str << "\t"+c.to_s }
                        @methods.each { |m| str <<"\tpublic "+m.to_s+"\n" }
                        @inners.each { |i| str << i}
                        return str
                end
        end

	class PackageClass #{{{2
		attr_reader:pkgs
		attr_reader:jar_name
		attr_reader:lib_path
		def initialize(jar,path='')
			@jar_name=jar
			@lib_path = path
			@pkgs=[]
		end
		def load(pkg)
			#str = `#{$java_command} -cp #{@jar_name} vjde.completion.PackageCompletion \"#{lib_path}\"`
			puts "#{$java_command} -cp #{@jar_name} vjde.completion.PackageClasses #{lib_path} #{pkg}"

			str = `#{$java_command} -cp #{@jar_name} vjde.completion.PackageClasses #{lib_path} #{pkg}`
			@pkgs.concat(str.split())
			@pkgs.delete_if { |s| s[-6..-1]!='.class' }
			@pkgs.sort!
			@pkgs.each { |s| s[-6..-1]='' }
                        loadjdk(pkg)
		end
        def loadjdk(beginning)
            tagFile = File.dirname(@jar_name)+'/tlds/jdk1.5.lst'
            seek = 0
            headLen = -1
            compareLen = -1
            if (beginning.length>0)
                if(FileTest.exist?(tagFile+".idx"))
                    idx = File.open(tagFile+".idx")
                    if ( compareLen ==-1)
                        str = idx.gets()
                        compareLen = str.index("\t")
                        headLen = compareLen
                        if ( compareLen > beginning.length)
                            compareLen = beginning.length
                        end
                    end
                    idx_line = idx.find { |line| line[0,compareLen]==beginning[0,compareLen]}
                    if (idx_line ==nil) 
                        return 
                    end
                    seek = idx_line[headLen+1,idx_line.length].to_i
                    idx.close()
                end
            end
            file = File.open(tagFile)
            file.seek(seek)
            file.each_line { |cls_line|
                v = cls_line[0,beginning.length]<=>beginning
                if (v==1) 
                    break
                elsif ( v==0)
                    @pkgs << cls_line[beginning.length..-1] if !cls_line.index('.',beginning.length)
                end	       
            }
        end
		def clear 
			@pkgs.clear
		end
		def each_pkg(prefix='') 
			if prefix == nil || prefix.length==0
				@pkgs.each { |p| yield(p) }
			else
				@pkgs.each { |p| yield(p) if p[0,prefix.length]==prefix }
			end
		end
	end
	class PackageCfu #{{{2
		attr_reader:pkgs
		attr_reader:jar_name
		attr_reader:lib_path
		def initialize(jar,path='')
			@jar_name=jar
			@lib_path = path
			@pkgs=[]
		end
		def load()
			#str = `#{$java_command} -cp #{@jar_name} vjde.completion.PackageCompletion \"#{lib_path}\"`
			str = `#{$java_command} -cp #{@jar_name} vjde.completion.PackageCompletion \"#{lib_path}\"`
			@pkgs.concat(str.split())
			@pkgs.sort!
		end
		def clear 
			@pkgs.clear
		end
		def each_pkg(base,pre='') 
			prefix = base+pre
			len = base.length
			if prefix == nil || prefix.length==0
				@pkgs.each { |p| yield(p) }
			else
				@pkgs.each { |p| yield(p[len..-1]) if p[0,prefix.length]==prefix }
			end
		end
	end
	class JavaCompletion #{{{2
		attr_accessor :found_class
		attr_reader :fields
		attr_reader :methods
		attr_accessor :jar_name
		attr_accessor :lib_path
                attr_reader :success
		def initialize(jar,path="\"\"")
			@jar_name=jar
			@lib_path=path
			@found_class = nil
			@fields =[]
			@methods=[]
                        @success =false
		end
		def findClass4imps(name,impstr,level=0) 
                    @success = false
			str1 = impstr.gsub("*","")
			#str1 = str1.gsub(";"," ")
                        arr = str1.split(";")
                        p = arr.find { |p| p.strip.index(/\.#{name}$/)!=nil }
                        if ( p != nil) 
                            cl = Vjde.getClass(@jar_name,@lib_path,p,level,[])
                        else
				arr.delete_if { |x| x[-1,1]!="."}
                            cl = Vjde.getClass4imps(@jar_name,@lib_path,name,arr.join(" "),level)
                        end
			if ( cl.length > 0 )
                            @success = true
				@found_class = JavaClass.new(cl)
				return @found_class
                        else
                            #@found_class = nil
			end
			return nil
		#findClass(name,0,impstr.split)
		end
		def findClass(name,level=0,imps=[])
			cl = Vjde.getClass(@jar_name,"#{@lib_path}",name,level,imps)
                        @success = false
			if ( cl.length > 0 )
                            @success = true
				@found_class = JavaClass.new(cl)
				return @found_class
			end
			return nil
		end
		def findConstructor()
			return @found_class.constructors
		end
		def findFields(prefix)
			#@fields.clear()
                        myfields=[]
			return [] if @found_class == nil
			return @found_class.fields.to_a if prefix.chomp() == ""
			len = prefix.length
			@found_class.fields.each { |f|
				if ( f.f_name[0,len]==prefix)
					myfields<< f
				end
			}
                        myfields
		end
		def findMethods(prefix)
                        mymethods=[]
			return [] if @found_class == nil
			return @found_class.methods.to_a if prefix.chomp() == ""
			len = prefix.length
			@found_class.methods.each { |m|
				if ( m.name[0,len]==prefix)
					mymethods<< m
				end
			}
                        mymethods
		end
	end
	class VjdeProject #{{{2
		attr_accessor :jar_name
		attr_accessor :lib_path
		attr_accessor :show_full
		attr_accessor :src_path
                attr_accessor :tlds
		def initialize(name,lib="",src="",show=false)
			@jar_name = name
			@lib_path = lib
			@show_full = show
			@src_path=src
                        @tlds=[]
		end
		def save(file)
		end
		def load()
		end
	end
end

$vjde_java_cfu = nil
$vjde_pkg_cfu = nil
$vjde_cls_cfu = nil
#{{{2
#puts Vjde::PUBLIC

#st = Time.now()

#cmp = Vjde::JavaCompletion.new("/usr/share/vim/vimfiles/plugin/vjde/vjde.jar")
#cmp.findClass4imps("java.lang.System","",0)
#methods = cmp.findMethods("")
#methods.each { |m|
	#puts m
#}
#puts Time.now()-st
#puts java.to_s

#cfu = Vjde::PackageCfu.new("vjde.jar","install/classes:lib/j2ee.jar")
#cfu.load()
#cfu.each_pkg('java.','n') { |p| puts p }

#cfu = Vjde::PackageClass.new("/usr/share/vim/vimfiles/plugin/vjde/vjde.jar","lib/j2ee.jar")
#cfu.load("java.awt.")
#cfu.each_pkg('') { |p| puts p }

# vim:fdm=marker:ft=ruby

