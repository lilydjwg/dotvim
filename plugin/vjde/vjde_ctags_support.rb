module Vjde
		class SourceReader #{{{2
				#{{{3
				RE_TYPEDEFINE = /\s*typedef\s*(struct|union)\s.*$/
				RE_COMMENTER = /^\s*\/\/.*/
				RE_COMMENTER2 = /\/\/.*$/
				RE_COMMENTER3=/\/\*.*\*\//
				RE_START=/\/\*/
				RE_END=/\*\//
				#RE_STRING=/"(\\\\|\\"|[^\\"])*"/
				RE_STRING=/"(\\|\"|[^\"])*"/
				RE_DEFINE=/(\w+(\s*<.*>\s*)*::)*\w+(<.*>)*(\s*\[.*\])*[	 *]+\w+\s*\W/
				KEY_WORDS=['int','char','long','struct','union','class','enum']
				def initialize
						@lines=[]
						@first = false
						@found = true
						@count = 0
				end
				def clear
						@lines=[]
						@first = false
						@found = true
						@count = 0
				end
				#}}}3
				def each_line(f) #{{{3
						incomment = false
						f.each { |l|
								l.chomp!
								if !incomment
										l.gsub!(RE_STRING,'')
										l.gsub!(RE_COMMENTER2,'')
										next if l.length==0
								end
								if l.index(RE_START)!=nil && !incomment
										incomment = true
										if incomment && l.index(RE_END)!=nil
												incomment = false
												l.gsub!(RE_COMMENTER3,'')
												#next if l.chomp!.length==0
												yield(l)
												next
										end
								end
								if incomment && l.index(RE_END)!=nil
										l.gsub!(/^.*\*\//,'')
										incomment = false
										#next if l.chomp!.length==0
										yield(l)
										next
								end
								next if incomment
								next if l.index(RE_COMMENTER)!=nil
								#next if l.chomp!.length==0
								yield(l)
						}
				end
				#}}}3
				def find_typedef(tags,file,cmd,beginning='') #{{{3
						source = File.dirname(tags)+'/'+file
						return unless File.exist?(source)
						f = File.open(source)
						clear()
						each_line(f) { |l|
							do_typedef(l,cmd) { |lines| 
								lines.each { |ls|
									tag = get_tag(ls)
									next if tag==nil
									tag.file=file 
									tag.cmd='/^'+ls+'$/'
									if beginning==nil|| beginning==''
										yield(tag) 
									else
										yield(tag) if tag.name.index(beginning)==0
									end
								}
							}
						}
						f.close
				end
				#}}}3
				def get_tag(ls) #{{{3
						l = ls.sub(/\(\s*[^*][^()]*\)/,'')
						ld = l[RE_DEFINE]
						if ld==nil
								l = ls.sub('(','')
								l = l.sub(')','')
								ld = l[RE_DEFINE]
						end
						return nil if ld==nil
						name = ld[/\w+\s*\W$/][0..-2]
						name.strip!
						return nil if KEY_WORDS.include?(name)
						tag = CtagsTag.new('','','','','','','','','','')
						tag.name=name
						#tag.cmd='/^'+l+'$/'
						tag.kind='m'
						return tag
				end
				#}}}3
				def do_typedef(l,cmd) #{{{3
						if @found
								if !@first && @count==0
										@found = false
										yield(@lines) if @lines[-1]==cmd
										return if @lines[-1]==cmd
										@lines=[]
										@first=false
										return
								end
								if l.index(RE_TYPEDEFINE)!=nil
										@lines=[]
										@first=false
										return
								end
								@lines << l
								@count += l.count('{')
								@first =( @count == 0)
								@count -= l.count('}')
								return
						end
						return if l.index(RE_TYPEDEFINE)==nil
						@found = true
						@lines << l
						@count += l.count('{')
						@first = ( @count == 0)
						@count -= l.count('}')
				end
				#}}}3
		end
		#}}}2
		def Vjde.getCtags(tagsVar,cmd='')
				if File.executable?(cmd)
						return ReadTags.new(tagsVar,cmd)
				end
				return CtagsTagList.new(tagsVar)
		end
		#{{{2
    def Vjde.getTagFiles(tagsVar)
        if ( (tagsVar == "") || (tagsVar == nil) )
            tagsVar = "./tags,/"
        end

        curDir = curVimDir()
        curDir.gsub!(/ /, '\\ ')

        tagsVar.gsub!(/^\./, curDir)

        result = tagsVar.scan(/(?:\\ |[^,; ])+/)

        result.each { |tr|
            tr.gsub!(/\\ / ," ")

            tr.gsub!(/\\/, "/")
        }

        if result.include?("/")
            result.delete("/")
            curDir = curVimDir() 
            while (!File.rootDir?(curDir))
                result.push(curDir + "/tags")
                curDir = File.dirUp(curDir)
            end
            # we didn't add rootdir/tags yet
            result.push("#{curDir}/tags")
        end
        # remove duplicate dirs
        result.uniq!

        return result
    end
	#}}}2

	#{{{2
    def Vjde.generateIndex(fileName,len=1)
	    return if !File.exist?(fileName)
        index = 0
        latter=" "*len
	#return if !File.stat(fileName+".vjde_idx").writable_real?
        f_idx = File.open(fileName+".vjde_idx","w")
	return if f_idx == nil
        f_tag = File.open(fileName)
        f_tag.each_line { |line|
            if ( line[0,len]!=latter)
                latter=line[0,len]
                f_idx.puts latter+"\t"+index.to_s
            end
            index = f_tag.pos
        }
        f_tag.close()
        f_idx.close()
    end
	#}}}2

    def Vjde.curVimDir()
        curDir = Dir.pwd
        return curDir
    end

	#{{{2
    class MyFile
        def File.dirUp(path)
            # remove final "/" if there is one
            cleanPath = path.chomp(File::SEPARATOR)
            return path if (File.rootDir?(path))
            File.split(cleanPath)[0]
        end

        def File.rootDir?(path)
            # remove final "/" if there is one
            cleanPath = path.chomp(File::SEPARATOR)
            # UNIX root dir:
            return true if path == "/"
            # windows network drives \\machine\drive\dir
            # we're at the root if it's something like
            # \\machine\drive
            return true if cleanPath =~ %r{^//\w+/\w+$}
            # now standard windows root directories
            # (a: c: d: ...)
            return true if cleanPath =~ /^[a-zA-Z]:$/
            return false
        end
    end
	#}}}2

    # manages one tag.
    class CtagsTag #{{{2
        attr_reader :scope
        attr_accessor:name
	attr_accessor:file
	attr_accessor:line
        attr_accessor :className
        attr_accessor :kind
        attr_accessor :inherits
        attr_accessor :access
	attr_accessor :ns
	attr_accessor :cmd
	attr_accessor :typename
	RE_CMD_SP=/\/\^.*\$\//

        def initialize(name, file, kind, line, scope, inherits, className, access,ns,cmd)
            @name = name
            @file = file
            @kind = kind
            @line = line
            @scope = scope
            @inherits = inherits
            @className = className
            @access = access
	    @ns = ns
	    @cmd = cmd
        end

        # for debug.
        def to_s()
            return "tag, name : " + @name + ", file : " + @file + ", kind : " + @kind + ", line : " + ((@line==nil)?(""):(@line)) + ", scope : " + ((@scope == nil)?(""):(@scope)) + ", inherits : " + ((@inherits == nil)?(""):(@inherits)) + ", className : " + ((@className == nil)?(""):(@className)) + ", access : \"" + ((@access == nil)?(""):(@access)) + "\""
        end

        # for now "==" is not defined for speed (i often do comparisons
        # will nil)

        # I need a hash method because Array.uniq uses it
        # to remove duplicate elements and I want that duplicate
        # elements are properly accounted for...
        def hash
            return @name.hash() + @kind.hash()
        end

        # http://165.193.123.250/book/ref_c_object.html#Object.hash
        # "must have the property that a.eql?(b) implies a.hash == b.hash."
        # without this, Array.uniq doesn't work properly.
        def eql?(other)
            return hash == other.hash
        end

        # here is a ctags line:
        # ENTRY_AUTH_KEYCHANGE	snmp/usm/SnmpUser.java	/^	public static final String ENTRY_AUTH_KEYCHANGE = ".6";$/;"	f	class:SnmpUser	access:default
        def CtagsTag.getTagFromCtag(ctag_line, knownTags)

            # ;\ separates the "extended" information
            # from the standard one.
	    #ctag_infos = ctag_line.split('$/;"')
            ctag_infos = ctag_line.split(';"')

            ctag_infos_base = ctag_infos[0].split("\t")
	    cmd = ctag_line[RE_CMD_SP]
	    cmd = '' if cmd==nil
		typename=''


            if ( ctag_infos[1] == nil) 
		    return
            end
            ctag_infos_ext = ctag_infos[1].split("\t")


            index = 2 # at 0 it's "", at 1 it's the tag type (c, m, f, ...)
            while (ctag_infos_ext[index] != nil)
                info = [] #ctag_infos_ext[index].split(":")
                infoindex = ctag_infos_ext[index].index(":")
                return if infoindex == -1

                info << ctag_infos_ext[index][0,infoindex]
                info << ctag_infos_ext[index][infoindex+1,ctag_infos_ext[index].length]

                #infoindex = info[1].index("::")
                #if (infoindex != nil)
			#info[1][0,infoindex+2]=""
                #end
                # possible optimisation: call chomp only
                # if it's REALLY the last identifier of the line,
                # not "just in case" like that.
		if (info[0] == "line")
			line = info[1].chomp
        elsif ( info[0] == 'signature')
            cmd = info[1]
		elsif (info[0] == "inherits")
			inherits = info[1].chomp.split(",")
		elsif ( (info[0] == "class") || (info[0] == "interface") || info[0]=="struct" )
			#infoindex = info[1].index("::")
			#if (infoindex != nil)
			#info[1][0,infoindex+2]=""
			#end
			className = info[1].chomp
		elsif (info[0] == "access")
			access = info[1].chomp
		elsif ( info[0]=='namespace')
			ns = info[1].chomp
		elsif ( info[0]=='typename')
			typename=info[1].chomp
		end
                index = index + 1
            end
            # since there is no ctag_infos_ext[index], there will
            # be a carriage return here.
            # 		ctag_infos_ext[index-1].chomp!

            scope = ctag_infos_ext[3]
            # 		if (scope != nil)
            # 			scope.chomp!
            # 		end

	    kind = ''
	    kind = ctag_infos_base[1].chomp if ctag_infos_base[1]!=nil
	    ext = ''
	    ext = ctag_infos_ext[1].chomp if ctag_infos_ext[1]!=nil
            result = CtagsTag.new(ctag_infos_base[0], kind, ext, line, scope, inherits, className, access,ns,cmd)
            # if the tag is already known..
            # 		if (knownTags.include?(result))
            # # 			puts "already known tag"
            # 			# don't parse it again
            # 			return nil
            # 		end
			result.typename=typename
            return result
        end

        # is this tag a method? (language dependant)
        # (do it in the constructor and cache it?)
        def tagMethod?()
            lang = language()
            return (@kind == "m" ||  @kind=="f") if (lang == "java")
            return (@kind == "f" || @kind=="t") if (lang == "cpp")
        end

        # is this tag defining a class? (language dependant)
        def tagClass?()
            return (@kind == "c") || (@kind== "i")
        end

        # language for this tag (do it in the constructor and cache it?)
        def language()
            return "java" if (@file =~ /java\Z/ )
            return "cpp" if ( (@file =~ /cpp\Z/) || (@file =~ /cc\Z/) || (@file =~ /h\Z/) || (@file =~ /hpp\Z/) )
	    return "cpp" 
        end

    end
	#}}}2
    class CtagsTagList #{{{2
	    attr_accessor :max
	    attr_accessor :count
	    attr_accessor :type_searched
	    attr_accessor :max_deep

	    RE_CMD_LINE=/((typedef|struct|union|enum|public|prviate|protected|class)*\s)*/
	def initialize(tagsVar)
            @tagFiles = Vjde::getTagFiles(tagsVar)
            @local_depth = 0
	    @max = -1
	    @count = 0
	    @type_searched = Array.new
	    @max_deep = 2
        end


        # parsing. TODO: parse only what I need..
	def get_skip2(tagFile,beginning,seek)
		    f_tag = File.open(tagFile)
		    f_tag.seek(seek)
		    index = seek
		    len = beginning.length
		    f_tag.each_line { |line|
			    if line[0,len]==beginning 
				    seek = index -1
				    break
			    end
			    index = f_tag.pos
		    }
		    f_tag.close()
		    return seek
	end
	#{{{3
	def get_skip(tagFile,beginning) 
	    seek = -1
            headLen = -1
            compareLen = -1
            if (beginning.length>0)
		    if(FileTest.exist?(tagFile+".vjde_idx"))
			    idx = File.open(tagFile+".vjde_idx")
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
				    return -1
			    end
			    seek = idx_line[headLen+1,idx_line.length].to_i
			    idx.close()
			    if compareLen < beginning.length && seek > 0
				    seek = get_skip2(tagFile,beginning,seek)
			    end

		    else
			    f_tag = File.open(tagFile)
			    index = 0
			    len = beginning.length
			    f_tag.each_line { |line|
				    if line[0,len]==beginning 
					    seek = index -1
					    break
				    end
				    index = f_tag.pos
			    }
			    f_tag.close()
		    end
	    else
		    seek = 0
            end
	    return seek
	end
	#}}}3
	#{{{3
	def each_tag(name='',firstfile=true)
		find = false
	    @tagFiles.each { |curFile|
		    next if (!FileTest.exist?(curFile))
		    if name.length == 0
			    each_tag4file(curFile,get_skip(curFile,name)) { |t|
				    yield(t,curFile)
			    }
		    else
			    len = name.length
			    each_tag4file(curFile,get_skip(curFile,name),name) { |t|
					next if firstfile && t.name!=name
				    tg = t.name[0,len]
				    yield(t,curFile) if tg==name
				    break if tg>name
			    }
		    end
	    }
	end
	#}}}3
	#{{{3
        def each_tag4file(tagFile,seek=0,must='')
		return if seek==-1
            file = File.open(tagFile)
	    file.seek(seek)
            ctags_line = file.gets
	    use = true if must!=''
            file.each_line { |ctags_line|
                if (ctags_line[0,2]== "!_")
                    next
                end
		next if (use&&!ctags_line.include?(must))
                tag = CtagsTag.getTagFromCtag(ctags_line, nil)
                next if tag==nil 
		yield(tag)
		break if @count == @max
            }
            file.close
	    return seek
    end
	#}}}3

	#{{{3
    def each_class(className='')
	    if className.length == 0
		    each_tag() { |t,f|
			    if t.kind=='c'  
				    yield(t,curFile)
			    end
		    }
	    else
		    each_tag(className) { |t,curFile|
			    next if t.kind!='c' 
			    nm = t.name[0,className.length]
			    #break if nm>className
			    yield(t,curFile) if nm==className
		    }
	    end
    end
	#}}}3
	#{{{3
    def CtagsTagList.get_type(line2,name) 
	    re=Regexp.new('(\w+(\s*<.*>\s*)*::)*\w+(<.*>)*(\s*\[.*\])*[	 *]+'+name+'\s*\W')
	    line = line2[re]
	    return nil if line==nil
	    find = true
	    while find
		    find = false
		    line.gsub!(/<[^<>]*>/) { |p|
			    find = true
			    ''
		    }
	    end
	    return nil if line==nil
	    idx = line.index(/[\[<( 	*]/)
		if idx != nil
			tp = line[0,idx]
			tp.strip!
			if $CPtr4Handle.index(tp) != nil
				p3 = nil
				line2.sub(Regexp.new('(\w+(\s*<.*>\s*)*::)*'+tp+'(<.*>)*(\s*\[.*\])*[	 *]+'+name+'\s*\W')) { |p|
					p3 =  $3
				}
				if p3!=nil && p3[0,1]=='<'
					tp = p3[1..-2].strip
				end
			end
			return tp
		end
	    nil
    end
	#}}}3
	#{{{3
    def find_class(className1)
		if className1[0,2]=="::"
			className1=className1[2..-1]
		end
	    if @type_searched.include?(className1) || @type_searched.length>=@max_deep
		    if block_given? 
			    return nil
		    else
			    return nil
		    end
	    end
	    @type_searched << className1
	    className = className1
	    idx = className1.rindex("::")
	    ns = nil
	    if idx != nil
		    ns = className1[0,idx]
		    className = className1[idx+2..-1]
	    end
	    each_tag(className) { |t,f|
		    next if className!=t.name
		    if t.kind=='c' ||  t.kind=='n' || t.kind=='s'
			   if ( t.ns!= nil && ns!=nil) 
				   next if t.ns.rindex(ns)!= t.ns.length-ns.length
			   end
			   if ( t.className !=nil)
				   next if t.className.rindex(className1)!= t.className.length - className1.length
			   end
			   #puts t.name
			   #puts t.ns
			   #puts t.kind
			   if block_given?
				   yield(t,f)
			   else
				   return t,f
			   end
		    elsif t.kind=='t'
			   if ( t.ns!= nil && ns!=nil) 
				   next if t.ns.rindex(ns)!= t.ns.length-ns.length
			   end
			   if ( t.className !=nil && ns!=nil)
				   next if t.className.rindex(ns)!= t.className.length-ns.length
			   end
			   if t.cmd.length>0
				   cmd = CtagsTagList.get_type(t.cmd,className)
				   if cmd!=nil
						   if block_given?
								   find_class(cmd) { |t,f| yield(t,f) }
						   else
								   return find_class(cmd) 
						   end
				   else
						   if block_given?
								   yield(t,f) 
						   else
								   return t,f
						   end
				   end
			   end
		   elsif t.kind=='v' || t.kind=='m'
			   cmd = CtagsTagList.get_type(t.cmd,className)
			   if cmd!=nil
				   if block_given?
					   find_class(cmd) { |t,f| yield(t,f) }
				   else
					   return find_class(cmd) 
				   end
			   end
		   end
	    }
	    return nil
    end
	#}}}3
	#{{{3
    def each_member(className1, beginning='',full=false)
	    className = className1
	    clsTag = nil
	    seachedFile = nil
	    cls = find_class(className)
	    return if cls==nil

	    clsTag = cls[0]
	    seachedFile = cls[1]

		if clsTag.kind=='t'
				src = SourceReader.new
				src.find_typedef(seachedFile,clsTag.file,clsTag.cmd[2..-3],beginning) { |tag|
						yield(tag,seachedFile)
				}
				return
		end

	    #namespace
	    if clsTag.kind=='n'
			if clsTag.ns == nil
				ns=clsTag.name
			else
				ns = clsTag.ns+"::" + clsTag.name
			end
		    if beginning.length==0
			    each_tag4file( seachedFile ,0,ns) { |t|
				    yield(t,seachedFile) if t.ns== ns
			    }
		    else
			    each_tag4file( seachedFile,get_skip(seachedFile,beginning),className1) {|t|
					next if full && t.name!=beginning
				    tg = t.name[0,beginning.length]
				    break if tg > beginning 
				    yield(t,seachedFile) if t.ns==ns && t.name[0,beginning.length]==beginning
			    }
		    end
		    return
	    end


	    cn = ""
	    cn = cn + clsTag.ns+"::" if clsTag.ns != nil
	    cn = cn + clsTag.name
	    pre = cn
	    pre = "class:"+cn if clsTag.kind == 'c'
	    pre = "struct:"+cn if clsTag.kind == 's'
	    if beginning.length==0
		    each_tag4file( seachedFile,0,pre) { |t|
			    yield(t,seachedFile) if t.className==cn
		    }
	    else
		    each_tag4file( seachedFile,get_skip(seachedFile,beginning),pre) {|t|
			    tg = t.name[0,beginning.length]
			    break if tg > beginning 
			    yield(t,seachedFile) if t.className==cn && t.name[0,beginning.length]==beginning
		    }
	    end
		if clsTag.inherits!=nil
			each_member(clsTag.inherits,beginning,full) { |t,f| 
				yield(t,f)
			}
		end
    end
		#}}}3
end
#}}}2
class ReadTags #{{{1
	attr_accessor :cmd
	attr_accessor :type_searched
	attr_accessor :max_deep
	attr_accessor :max_tags
	attr_accessor :exttp
	attr_accessor :count
	def initialize(tagsVar,cmd,exttp='')
            @tagFiles = Vjde::getTagFiles(tagsVar)
	    @cmd = cmd
		@exttp=exttp
	    @type_searched = Array.new
	    @max_deep = 2
		@max_tags = -1
    end
	def max=(m)
			@max_tags = m
	end
	#{{{2
    def ReadTags.get_type(line2,name) 
		return CtagsTagList.get_type(line2,name)
	    #re=Regexp.new('(\w+(\s*<.*>\s*)*::)*\w+(<.*>)*(\s*\[.*\])*[	 *]+'+name+'\s*\W')
	    #line = line2[re]
	    #return nil if line==nil
	    #find = true
	    #while find
		    #find = false
		    #line.gsub!(/<[^<>]*>/) { |p|
			    #find = true
			    #''
		    #}
	    #end
	    #return nil if line==nil
	    #idx = line.index(/[\[<( 	*]/)
	    #return line[0,idx] if idx!= nil
	    #nil
    end
	#}}}2
	#{{{2
    def find_class(className1) 
		if className1[0,2]=="::"
			className1=className1[2..-1]
		end
	    if @type_searched.include?(className1) || @type_searched.length>=@max_deep
		    if block_given? 
			    return nil
		    else
			    return nil
		    end
	    end
	    @type_searched << className1

	    className = className1
	    idx = className1.rindex("::")
	    ns = nil
	    if idx != nil
		    ns = className1[0,idx]
		    className = className1[idx+2..-1]
	    end


		#{{{3
	    @tagFiles.each { |f|
		    next if (!FileTest.exist?(f))
		    cmdline= @cmd + " -e -k ncstuv#{@exttp} -t #{f} #{className}"
		    res = `#{cmdline}`
		    next if res.length==0
			lastt = nil
		    res.each { |l|
			    t = CtagsTag.getTagFromCtag(l,nil)
			    if t.kind=='c' || t.kind=='n' || t.kind=='s'
				   if ( t.ns!= nil && ns!=nil) 
					   next if t.ns.rindex(ns)!= t.ns.length-ns.length
				   end
				   if ( t.className !=nil)
					   next if t.className.rindex(className1)!= t.className.length - className1.length
				   end
				   if block_given?
					   yield(t,f)
				   else
					   return t,f
				   end
			   elsif t.kind=='t'
				   if ( t.ns!= nil && ns!=nil) 
					   next if t.ns.rindex(ns)!= t.ns.length-ns.length
				   end
				   if ( t.className !=nil && ns!=nil)
					   next if t.className.rindex(ns)!= t.className.length-ns.length
				   end
				   if t.cmd.length>0
					   cmd = ReadTags.get_type(t.cmd,className)
					   if cmd!=nil
							   if block_given?
									   find_class(cmd) { |t,f| yield(t,f) }
							   else
									   return find_class(cmd) 
							   end
					   else
							   if block_given?
									   yield(t,f) 
							   else
									   return t,f
							   end
					   end
				   end
		   elsif t.kind=='v' || ( t.kind==@exttp)
			   lastt = t
			   #cmd = ReadTags.get_type(t.cmd,className)
			   #if cmd!=nil
			   # 	   if block_given?
			   # 			   find_class(cmd) { |t,f| yield(t,f) }
			   # 	   else
			   # 			   return find_class(cmd) 
			   # 	   end
			   #end
		   end
		    }
			if lastt!= nil && (lastt.kind=='v' || (lastt.kind=@exttp ))
				cmd = ReadTags.get_type(lastt.cmd,className)
				@exttp=''
				if cmd!=nil
					if block_given?
						find_class(cmd) { |t,f| yield(t,f) }
					else
						return find_class(cmd) 
					end
				end
			end
	    }
		nil
		#}}}3
    end
	#}}}2
	#{{{2
    def each_member(className1, beginning='',full=false)
	    className = className1
	    clsTag = nil
	    seachedFile = nil
		@exttp=''
	    cls = find_class(className)
		if cls==nil
			@exttp='m'
			@type_searched.clear
			cls = find_class(className)
		end
	    return if cls==nil

		para = ""
		para = " -p " if !full

	    clsTag = cls[0]
	    seachedFile = cls[1]
		#typedef 
		if clsTag.kind=='t'
			if clsTag.typename!=''
				idx = clsTag.typename.index(':')
				ty = clsTag.typename[0..idx-1]
				tv = clsTag.typename[idx+1..-1]
				case ty
				when "struct"
					clsTag.kind='s'
				when "union"
					clsTag.kind='u'
				end
				clsTag.name=tv
			else
				src = SourceReader.new
				src.find_typedef(seachedFile,clsTag.file,clsTag.cmd[2..-3],beginning) { |tag|
						yield(tag,seachedFile)
				}
				return
			end
		end

		cmdline = @cmd + " -e #{para} "
		cmdline = cmdline + " -m #{@max_tags} " if @max_tags!=-1
		ns =''
		ns = clsTag.ns+"::" if clsTag.ns!=nil && clsTag.ns.length!=0
		ns = ns + clsTag.name
		if clsTag.kind=='n'
				cmdline = cmdline + " -f namespace #{ns} "
		elsif clsTag.kind=='c'
				cmdline = cmdline + " -f class #{ns} "
		elsif clsTag.kind=='s'
				cmdline = cmdline + " -f struct #{ns} "
		elsif clsTag.kind=='u'
				cmdline = cmdline + " -f union #{ns} "
		end
		cmdline = cmdline + " -t #{seachedFile} #{beginning}"
		#puts cmdline
		res = `#{cmdline}`
		find = false
		res.each { |l|
			    t = CtagsTag.getTagFromCtag(l,nil)
				next if t == nil
				yield(t,seachedFile)
				find = true
		}
		if clsTag.inherits!=nil
			each_member(clsTag.inherits,beginning,full) { |t,f| 
				yield(t,f)
			}
		end
end
#}}}2
#{{{2
	def each_tag(beginning,full=false)

		count = 0
		para = ""
		para = " -p " if !full
		@tagFiles.each { |f|
				next if (!FileTest.exist?(f))
				cmdline = @cmd + " -e #{para} "
				cmdline = cmdline + " -m #{@max_tags-count} " if @max_tags!=-1
				if beginning!=nil && beginning.length>0
						cmdline = cmdline + " -t #{f} #{beginning}"
				else
						cmdline = cmdline + " -t #{f} -l"
				end
				res = `#{cmdline}`
				res.each { |l|
						t = CtagsTag.getTagFromCtag(l,nil)
						yield(t,f)
						count +=1
				}
				break if @max_tags==count
		}
	end
end
#}}}2
#}}}1

$CPtr4Handle =Array.new
fn = File.expand_path("~/.vim/vjde/ptr.lst")
Custom = Struct.new("Custom",:name,:namespace)
if File.exist?(fn)
	f = File.open(fn)
	f.each_line { |l|
		$CPtr4Handle << l.strip!
		#idx = l.index(' ')
		#if idx != nil
			#$CPtr4Handle <<  l[idx+1..-1] +"::"+l[0..idx-1]
		#end
	}
end
#$CPtr4Handle.each { |l|
#	puts l
#}
end
# {{{2
# this file separator API is badly broken
# or I missed something..

# puts "ruby invoked : " + Time.now.min.to_s + ":"+ Time.now.sec.to_s
#$keepAllInfo =false 
#Vjde.generateIndex('d:\workspace\vjde\plugin\vjde\tlds\jdk1.5.lst',6)
#Vjde.generateIndex("/usr/share/vim/vimfiles/plugin/vjde/tlds/jdk1.5.lst")
#Vjde::generateIndex("d:/mingw/include/c++/3.4.2/tags")
#Vjde::generateIndex("d:/mingw/include/tags")
#Vjde::generateIndex("d:/gtk/include/tags",1)
#taglist = Vjde::CtagsTagList.new("d:/temp/first/tags")
#arrs = taglist.find_class('NATION')
#puts arrs[0].name if arrs!=nil
#d1 = Time.now
#taglist.max_deep = 1
#taglist.find_class('boost::multi_index') do |t,f|
	#	puts t.name
	#puts t.ns
	#puts t.className
	#puts t.cmd
	#break
	#end
#puts taglist.type_searched

#puts taglist.type_searched

#puts cls[0].name if cls!=nil
#puts cls[0].ns if cls!=nil
#{ |t,f|
	#puts t.name 
	#puts t.ns
	#puts t.kind
#}
#}}}2
#taglist.max=100
# {{{2
#taglist.max=100 
#taglist.count=0
#taglist.each_member('__gnu_cxx::__normal_iterator','') {|t,f|
	#puts "#{t.name} , #{t.kind}  #{t.className} #{t.ns}"
	#taglist.count+=1
#}
#puts 'a'
#puts 'a'
#puts 'a'
#puts cls[0].className if cls!=nil
#puts 'a'
#taglist.each_class('iterator') { |t,f| 
	#puts t.name
	#if t.kind=='t'
	
	#end
#}
#taglist.each_tag('VjdeTem') { |t,f|
	#cmd = t.cmd
	#cmd.gsub!('\\','\\\\')
	#cmd.gsub!('"','\"')
	#puts "#{t.name} #{t.kind} " + cmd
#}
#puts Time.now - d1
#str='/^ typedef		  abc<def> a;$/'
#puts str[/\/\^.*\$\//]
#module Vjde
	#class CtagsTagList 
		#def CtagsTagList.get_type(t,s)
			#puts 'hello'+t + s
		#end
	#end
#end
#taglist = Vjde::CtagsTagList.new("d:/mingw/include/c++/3.4.2/tags")
#taglist.each_member('std::string','') {|t,f|
	#puts "#{t.name} , #{t.kind}  #{t.className} #{t.ns}"
	#taglist.count+=1
#}
#puts Vjde::CtagsTagList.get_type('/^}  NATION;  $/','NATION')
# }}}2
#taglist = Vjde::getCtags("d:/workspace/mmterminal/tags",'d:/vim/vimfiles/plugin/vjde/readtags.exe')
#taglist = Vjde::getCtags('d:/workspace/mmterminal/tags,./tags,d:\cbuilder6\include\tagsf,d:\cbuilder6\include\tagsm,d:\cbuilder6\include\tagsz,d:\cbuilder6\include\vcl\tagsd,d:\cbuilder6\include\vcl\tagsi,d:\cbuilder6\include\vcl\tagsp,d:\cbuilder6\include\vcl\tagsz','d:/vim/vimfiles/plugin/vjde/readtags.exe')

#taglist.find_class('AnsiString') { |t,f|
#		puts "#{t.name} #{t.ns} #{t.className} #{t.kind} #{t.cmd} #{t.inherits}"
#}
#puts '----------'
#taglist.max_deep=4
#taglist.find_class('transaction_base') { |t,f|
		#puts "#{t.name} #{t.ns} #{t.className} #{t.kind} #{t.cmd} #{t.inherits}"
#}
#taglist.each_member('MoviesListURL','') { |t,f|
#	puts "#{t.name} , #{t.kind}  #{t.className} #{t.ns}"
#}
#puts taglist.type_searched
#puts taglist.find_class('multi_index')
#taglist.find_class('multi_index')  { |t,f|
		#puts t
		#puts f
#}
#puts cls[0].name
#puts cls[0].ns
#taglist.max_tags = 30
#taglist.each_member('Ice','in') { |t,f|
	#puts "#{t.name} , #{t.kind}  #{t.className} #{t.ns}"
#}
#taglist.each_tag('gtk_widget',false) {|t,f|
	#puts "#{t.name} , #{t.kind}  #{t.className} #{t.ns}"
	#puts '---------------'
	#puts t.cmd
	#taglist.count+=1
	#}
#t1 = Time.now
#tr = Vjde::SourceReader.new
#tr.find_typedef('d:/temp/first/tags','./t.c','} QQ  ; ') { |tag|
		#puts tag.name
#}
#tr.find_typedef('d:/temp/first/tags','./t.c','} NATION;  ') { |tag|
		#puts tag.name
#}
#puts Time.now - t1
  
#re_string=/"(\\|\"|[^\"])*"/
#str=<<EOF
#"this is a test"
#"this is \\" a test"
#"this is \\\\"
#EOF
#str.each { |l|
		#puts l
		#puts l[re_string]
#}
# vim:ft=ruby:fdm=marker:ts=4:sw=4:


