
module Vjde #{{{1
    class VjdeTemplate #{{{2
        ParaStruct = Struct.new("ParaStruct",:name,:desc,:value)
        attr_reader:paras
        attr_reader:name
        attr_accessor:desc
        attr_accessor:lines
        attr_reader:manager
        attr_reader:entities
        def initialize(n,m)
            @manager = m
            @paras={}
            @name=n
            @lines=[]
            @entities={}
            @desc=""
        end
        def add_para(n,d) 
            @paras[n]= ParaStruct.new(n,d)
        end
        def set_para(n,v)
            @paras[n].value = v if @paras.has_key?(n)
        end
        def each_line 
            @lines.each { |l|
                if l[/^\s*%.*%\s*$/]!=nil
                    name = l[/%.*%/][1..-2]
                    entity = nil
                    if @entities.has_key?(name)
                        entity = @entities[name]
                    else
                        entity = @manager.getTemplate(name)
                    end
                    entity.each_line { |l| yield(l) } if entity!=nil
                    next
                end
                l.gsub!(/%\{([^}]+)\}/) { |p|
                    if @paras.has_key?($1)
                        @paras[$1].value
                    else
                        eval($1)
                    end
                }
		l.each { |l1| yield(l1) }
            }
        end
        def each_para 
            @paras.each_value { |p| yield(p) }
            @lines.each { |l|
                if l[/^\s*%.*%\s*$/]!=nil
                    name = l[/%.*%/][1..-2]
                    entity = @manager.getTemplate(name)
                    entity.each_para { |p|
                        if @paras.has_key?(p.name)
                            entity.set_para(p.name,@paras[p.name].value)
                            next
                        else
                            yield(p)
                        end
                    }
                    @entities[name]=entity
                end
            }
        end
        def to_s
            @name + ":"+@desc
        end
    end
    class VjdeTemplateManager #{{{2
        attr_reader:current
        attr_reader:indexs
        TemplateIndex = Struct.new("TemplateIndex",:name,:desc,:pos,:file)
        RE_TEMPLATE=/^temp/
        RE_BODY=/^body/
        RE_END=/^endt/
        RE_PARA=/^para/
        RE_TEMP_SPLIT=/^temp[a-z]*\s+(\w+)(\s+.*)$/
        RE_PARA_SPLIT=/^para[a-z]*\s+(\w+)(\s+.*)$/
	@@loaded = {}
	@@iabs= {}
        def initialize(f=nil)
            @current=nil
            @indexs = []
            load_index(f) if f!= nil
        end
	def VjdeTemplateManager.loaded
		@@loaded
	end
	def VjdeTemplateManager.iabs
		@@iabs
	end
	def VjdeTemplateManager.GetIAB(name,path='')
		if @@iabs[name]==nil 
			tm = VjdeTemplateManager.new
			if path!=''
				tm.add_file(path+name+".iab")
			end
			#tm.add_file(File.expand_path("~/.vim/vjde/"+name+".iab"))
			@@iabs[name]=tm
		else
			tm = @@iabs[name]
			tm.add_file(path+name+".iab")
		end
		@@iabs[name]
	end
	def VjdeTemplateManager.[](name,path='')
		#puts path+name+".vjde"
		if @@loaded[name]==nil
			tm = VjdeTemplateManager.new
			if path!=''
				tm.add_file(path+name+".vjde")
			end
			#tm.add_file(File.expand_path("~/.vim/vjde/"+name+".vjde"))
			@@loaded[name]=tm
		else
			tm = @@loaded[name]
			tm.add_file(path+name+".vjde")
		end
		@@loaded[name]
	end
	def VjdeTemplateManager.load_all(path1)
		len1 = path1.length+11
		path1 = path1.gsub("\\","/")
		Dir[path1+'/vjde/tlds/*.vjde'].each { |fn|
			name = fn[len1..-6]
			VjdeTemplateManager.[](name,path1+'/vjde/tlds/')
		}
		Dir[path1+'/vjde/tlds/*.iab'].each { |fn|
			name = fn[len1..-5]
			VjdeTemplateManager.GetIAB(name,path1+'/vjde/tlds/')
		}
		
		path2 = File.expand_path('~/.vim/vjde/')
		len1 = path2.length+1
		Dir[path2+'/*.vjde'].each { |fn|
			name = fn[len1..-6]
			VjdeTemplateManager.[](name,path2+"/")
		}
		Dir[path2+'/*.iab'].each { |fn|
			name = fn[len1..-5]
			VjdeTemplateManager.GetIAB(name,path2+"/")
		}
	end
        def add_file(t)
            load_index(t)
        end
        def each
            @indexs.each { |i| yield(i.name,i.desc) }
        end
        def findIndex(name) 
            @indexs.find { |i| i.name==name } 
        end
        def getTemplate(index_name)
            #return current if current!=nil && current.name==index_name
            index = findIndex(index_name)
            return nil if index == nil
            return nil unless FileTest.exist?(index.file)
            temp = nil
            tpf = File.open(index.file)
	    #tpf.seek(index.pos)
            intemplate = false
            tpf.each_line { |l|
		    next if tpf.lineno<index.pos
		    next if l[0,1]=='/'
                case l
                when RE_TEMPLATE
                    arr = l.scan(RE_TEMP_SPLIT)
                    temp =  VjdeTemplate.new(arr[0][0],self)
                    temp.desc=arr[0][1].strip
                when RE_END
                    break
                when RE_BODY
                    intemplate = true
                when RE_PARA
                    arr = l.scan(RE_PARA_SPLIT)
                    temp.add_para(arr[0][0],arr[0][1])
                else
                    l[0,1]='' if l[0,1]=='\\'
                    temp.lines<<l if intemplate
                end
            }
            tpf.close()
            @current = temp
            @current
        end
        private
        def load_index(f)
            return unless FileTest.exist?(f)
            tpf = File.open(f,'r')
            tpf.each_line { |l|
                next if l[0,1]=='/'
                case l
                when RE_TEMPLATE
                    arr = l.scan(RE_TEMP_SPLIT)
		    @indexs.delete_if { |a| (a.name<=>arr[0][0])==0 }
                    @indexs << TemplateIndex.new(arr[0][0],arr[0][1],tpf.lineno,f)
                end
            }
            tpf.close
        end
    end
    $vjde_template_manager = nil
    $vjde_iab_manager= nil
end #}}}1
#str = "template NewClass "
#str = "template NewClass this is a new class template"
#puts str.scan(/^temp[a-z]+\s+(\w+)\s+(.*)$/)

#tmps = Vjde::VjdeTemplateManager.new
#tmps.load('plugin\vjde\tlds\java.template')
#tmps.each { |p|
    #puts p.name
    #p.lines.each { |l| puts l }
#}

#tmps = Vjde::VjdeTemplateManager.new('d:\vim\vimfiles\plugin\vjde\tlds\java.vjde')
#Vjde::VjdeTemplateManager.load_all('d:/vim/vimfiles/plugin')
#tmps = Vjde::VjdeTemplateManager['java']
#template = tmps.getTemplate('NewClass')
#template.set_para('classname','Wfc1')
#template.set_para('package','com.wfc.pkg')
#template.each_line { |l| puts l }
#tmps.indexs.each { |p|
#	puts p
#}
#template.set_para('classname','Wfc1')
#template.set_para('package','com.wfc.pkg')
#template.each_line { |l| puts l }

#tmps = Vjde::VjdeTemplateManager.new('plugin/vjde/tlds/java.vjde')
#template = tmps.getTemplate('NewClass')
#template.each_para { |p| 
    #puts " Inpute the value of #{p.name}\t#{p.desc}:"
    #template.set_para(p.name,gets().strip!)
#}
#template.each_line { |l| puts l }

#paras={'type'=>'interface','name'=>'Wfc'}
#str='public #{type} #{name} {'
#str.gsub!(/#\{([^}]+)\}/) { |p|
   #eval("paras[\""+$1+"\"]") 
#}
#puts str
#path1 = 'd:\vim\vimfiles\plugin'
#Dir[path1+'/vjde/tlds/*.vjde'].each { |fn|
	#puts fn[(path1.length+11)..-6]
#}
#Dir[File.expand_path('~/.vim/vjde/*.vjde')].each { |n|
	#puts n
#}
# vim: fdm=marker
