
module Vjde #{{{1
	class TypeElement #{{{2 
		attr_reader:name
		attr_accessor:values
		def initialize(name,values=[])
			@name = name
			@values=[]
			@values.concat(values) if values!=nil
		end
	end
	class AttributeElement #{{{2
		attr_reader:name
		attr_accessor:values
                attr_accessor:type
		def initialize(name)
			@name=name
                        @type=""
			@values=[]
		end
		def add_value(v)
			@values << v
		end
	end
	class TagElement #{{{2
		attr_reader:name
		attr_reader:attrs
		attr_reader:pars
		attr_reader:children
		def initialize(name)
			@name=name
			@attrs=[]
			@pars=[]
			@children=[]
		end
		def add_attr(a)
			@attrs<< a
		end
		def add_pars(p)
			@pars << p
		end
	end
	class VjdeDefLoader #{{{2
		#require 'singleton'
		#include Singleton
		attr_reader:tags
		attr_reader:pars
		attr_reader:types
		@@comment = Regexp.new('^\s*[*/]')
		@@line_regexp = Regexp.new('\s*(private|public)*\s*(tag)\s+([^ \t]+)\s*([^<]*)(<\s[^\{]*)*\{((\s*attr\s+[^;\{]*\s*(;|\{[^\}]*\}))*)\s*\}') 
		@@line_regexp_enum = Regexp.new('\s*(private|public)*\s+enum\s*([^ \t]+)\s*\{([^\}]*)\}') 
		@@re_elem_child = Regexp.new('[?+* \t()\|,]')
		@@attr_split_regexp = Regexp.new('[\{,; \t]')
		@@attr_regexp = Regexp.new('[;|\}]')
		@@re_enum = /[,; \t]/
		@@re_parent = /[,; \t<]/
		@@loaded={}
		def VjdeDefLoader.[](name,fname=nil)
			if @@loaded[name]==nil
				ld = VjdeDefLoader.new
				ld.load(fname) if fname!=nil
				@@loaded[name]=ld
			end
			@@loaded[name]
		end
		def initialize() #{{{3
			@tags=[]
			@pars=[]
			@types=[]
			# name,children,parent,attrs
			#if ( name!=nil) 
				#if @@loaded[name]==nil
					#@@loaded[name]=self 
					#if ( fname!=nil)
						#load(fname)
					#end
				#end
			#end
		end
		def parse_tag ( name,children,parent,attris) #{{{3
			ele = TagElement.new(name)
			if ( children!=nil) 
				cs = children.split(@@re_elem_child)
				cs.delete_if { |c| c.length==0 }
				ele.children.concat(cs[0..-1]) if cs.length>0
			end
			if (parent!=nil) 
				ps = parent.split(@@re_parent).delete_if { |p| p.length==0 }
				ele.pars.concat(ps[0..-1]) if ps.length>0
			end
			attrs = attris.split(@@attr_regexp)
			attrs.each { |a|
				if a.index('{') != nil # attr test { ... }
					values = a.split(@@attr_split_regexp)
					values.delete_if { |p|p.length==0}
					att_ele = AttributeElement.new(values[1])
					att_ele.values.concat(values[2..-1]) if values.length>=3
					ele.add_attr(att_ele)
				else #attr [TYPE] ttt
					values = a.split(/[ \t]+/)
					values.delete_if { |p| p.length==0}
					next if values.length<2
					att_ele = AttributeElement.new(values[-1])
					att_ele.type = values[1]  if values.length>2
					ele.add_attr(att_ele)
				end
			}
			ele
		end
		def parse_attr( line)
		end
		def parse(input) #{{{3
			str = ""
			input.each_line { |line|
				next if line =~ @@comment	
				str << " " << line.strip!
				next if str[-1,1]!='}'
				str.sub!(@@line_regexp_enum) { |p|
					n = $2
					if $3!=nil
						attrs = $3.split(@@re_enum)
						attrs.delete_if { |p| p.length==0}
						define = TypeElement.new(n,attrs)
						@types<< define
					end
					" "
				}
				str.sub!(@@line_regexp) { |p|
					case $1 
					when "private"
						case $2
						when 'tag'
							@pars<<	parse_tag($3,$4,$5,$6) #name,parent,attrs
						end
                                        when "public"
						case $2
						when 'tag'
							@tags << parse_tag($3,$4,$5,$6) if $3!=nil #name,parent,attrs
						end
					when nil
						case $2
						when 'tag'
							@tags << parse_tag($3,$4,$5,$6) if $3!=nil #name,parent,attrs
						end
					else
					end
					" "
				}
			}

		end
                def load(fname) #{{{3
			f = File.new(fname)
			parse(f)
			f.close()
		end
		def each_child(tag_name,name=nil)
			tag = @tags.find { |t| t.name=~/^#{tag_name}$/i }
			if tag!=nil
				if name==nil || name.length==0
					tag.children.each { |t| yield(t); }
				else
					#r1 = Regexp.new(name,true)
					r1 = Regexp.new("^#{name}$",true)
					tag.children.each { |t| yield(t) if ( t[0,name.length]=~r1) }
				end
				
				#tag.pars.each { |pname|
					#p = @pars.find { |p| p.name == pname}
					#next if p == nil
					#each_attr_priv(p,name) { |a| yield(a) }
				#}
			end
		end
		def each_tag(name=nil) #{{{3
			if name==nil || name.length==0
				@tags.each { |t| yield(t) }
			else
				r1 = Regexp.new(name,true)
				@tags.each { |t| yield(t) if t.name[0,name.length]=~r1 }
			end
		end
                def each_child(tag,name=nil) 
                    each_tag(name) { |e| yield(e)}
                end
                def each_element(name=nil) #{{{3
			if name==nil || name.length==0
				@tags.each { |t| yield(t) }
			else
				r1 = Regexp.new(name,true)
				@tags.each { |t| yield(t) if t.name[0,name.length]=~r1 }
			end
                end
                def each_value(tag_name,att_name,v="") #{{{3
			each_attr(tag_name,att_name) { |t|
				next if att_name!=t.name
				if t.values.length >0
					if (v == nil || v.length==0)
						
						t.values.each { |s| yield(s)  }
					else
						#r1 = Regexp.new(v,true)
						r1 = Regexp.new("^#{v}$",true)
						t.values.each { |s| yield(s)  if s[0,v.length]=~r1}
					end
                                end
				if t.type!=nil && t.type.length!=0
					type = @types.find { |p| p.name==t.type }
					return if type==nil
					if (v == nil || v.length==0)
						type.values.each { |s| yield(s) }
					else
						r1 = Regexp.new("^#{v}$",true)
						type.values.each { |s| yield(s)  if s[0,v.length]=~r1}
					end
				end
				#each_attr_priv(tag,v) { |t| yield(t.name) if  t.name[0,v.length]==v}
			}
                end
		def each_attr(tag_name,name=nil) #{{{3
			tag = @tags.find { |t| t.name=~/^#{tag_name}$/i }
			if tag!=nil
				if name==nil || name.length==0
					tag.attrs.each { |t| yield(t); }
				else
					#r1 = Regexp.new(name,true)
					r1 = Regexp.new("^#{name}$",true)
					tag.attrs.each { |t| yield(t) if (t.name!=nil && t.name[0,name.length]=~r1) }
				end
				tag.pars.each { |pname|
					p = @pars.find { |p| p.name == pname}
					next if p == nil
					each_attr_priv(p,name) { |a| yield(a) }
				}
			end
		end
		def each_attr_priv(tag,name="") #{{{3
				if name==nil || name.length==0
					tag.attrs.each { |t| yield(t)  }
				else
					#r1 = Regexp.new(name,true)
					r1 = Regexp.new("^#{name}$",true)
					tag.attrs.each { |t| yield(t) if ( t.name[0,name.length]=~r1) }
				end
		end
	end
	#$vjde_html_loader=Vjde::VjdeDefLoader.[]("html")
	#$vjde_xsl_loader=Vjde::VjdeDefLoader.new("xsl")
	$vjde_def_loader=nil
end
#{{{1 test 1
#html_loader = Vjde::VjdeDefLoader.[]("xsd","/home/wangfc/workspace/vim/plugin/vjde/tlds/xsd.def")
#html_loader.parse(strTest)
#html_loader.load("xsd","/home/wangfc/workspace/vim/plugin/vjde/tlds/xsd.def")
#html_loader.parse(File.new("/home/wangfc/workspace/vim/plugin/vjde/tlds/html.def"))
#html_loader.load("/home/wangfc/workspace/vim/plugin/vjde/tlds/html.def")
#html_loader.each_value("xsd:element","substitutionGroup","") { |t| puts t }
#html_loader.each_value("body","fgcolor","a") { |t| puts t }
#html_loader.each_attr("xsd:all","") { |t| puts "\t"+t.name }
#html_loader.each_child("xsd:element","k") { |t| puts "\t"+t }
#html_loader.each_tag("") { |t| 
	#puts t.name  
#t.attrs.each() { |a|
#		puts "\t"+a.name
#        	a.values.each { |v| puts "\t\t"+v }
#	}
#}
#puts "-----------"
#html_loader.pars.each  { |t|
#	puts t.name
#}
#puts "-----------"

#html_loader.each_attr("html","v") { |t|
#    puts t.name
#}
# vim:fdm=marker
