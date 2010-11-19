
module Vjde #{{{1
	class DTD_Entity #{{{2
		attr_accessor:name
		attr_accessor:values
		def initialize (name,vs=[])
			@name=name
			@values=[]
			@values.concat(vs[0..-1]) if   vs.class=='Array' && vs.length>0
			@values << vs if vs.class!='Array'
		end
	end
	class DTD_Attribute #{{{2
		attr_accessor:name
		#ID CDATA IDREF (value) ...
		attr_accessor:values
		# #IMPLIED #REQUIRED...
		attr_accessor:type 
		def initialize(name,vt=nil,pt="#IMPLIED")
			@name = name
			@values=[]
            if vt.class == Array
                @values.concat(vt[0..-1]) if vt.length>0
            else
                @values<< vt if vt != nil
            end
			@type=pt
		end
	end
	class DTD_Element #{{{2
		attr_accessor:name
		attr_accessor:children
		attr_accessor:attrs
		def initialize(n,children=[])
			@name=n
			@children=children
			@attrs=[]
		end
	end
	class DTD_Parser #{{{2
		attr_accessor :elements
		attr_accessor :entities
		def initialize
			@elements=[]
			@entities=[]
		end
		def parse(input_i) #{{{3
			str=""
			#re_line = Regexp.new('<.([^ \t]*)\s+([^ \t]*)\s+(.*)>')
			re_line = Regexp.new('<.([^ \t]*)\s+([^ \t]*)\s+([^>]*)>')
			re_elem = Regexp.new('[?+* \t()\|,]')
			re_attr = Regexp.new('<!ATTLIST\s+[^ \t]+\s')
			re_attr_values = /\s*([^ \t]+)\s+(\([^)]+\))\s+([^ \t]+)\s*/
			re_values_split = /[ \t\|()]/
			re_entity = Regexp.new('[?+* \t()\|,"]')
			input_i.each_line { |line|
				line.strip!
				next if line.length==0
				str << " " << line
				find2 = true
                #next if line[-1,1]!='>'
				while ( str[-1,1]=='>' && find2)
					find2 = false
					str.sub!(re_line) { |p|
						#puts p
						find2 = true
						case $1
						when "ELEMENT"
							@elements << DTD_Element.new($2,$3.split(re_elem).delete_if { |i| i.length==0})
						when "ATTLIST"
							#puts $2+":"+p 
							element = @elements.find { |e| e.name == $2 }
							curr = ""
							if element != nil
								curr << $3
								curr.sub!(re_attr,"\t")
								find = true
								while find
									find = false
									curr.sub!(re_attr_values) { |p|
										find = true
										element.attrs << DTD_Attribute.new($1,$2.split(re_values_split).delete_if {|item| item.length==0 },$3)
										" "
									}
								end
								others = curr.split(/[ \t]/).delete_if { |item| item.length==0 }
								count = 1
								while others.length >= count *3
									element.attrs << DTD_Attribute.new(others[count*3-3],others[count*3-2],others[count*3-1])
									count +=1
								end
							end
						when "ENTITY"
							arr = $3.split(re_entity).delete_if { |i| i.length==0}
							@entities << DTD_Entity.new(arr[0],arr[1..-1])
						else
						end
						""
					}
				end
			}
		end

		def each_element(name=nil) #{{{3
			if ( name==nil || name.length==0) 
				@elements.each { |e| 
					yield(e)
				}
			else
				@elements.each { |e| 
					yield(e) if e.name[0,name.length]==name
				}
			end
		end
		def each_attr(ename,name=nil) #{{{3
			element = @elements.find { |el| el.name==ename }
			return if element == nil
			if name == nil || name.length==0
				element.attrs.each { |a| 
					if a.name[0,1]!='%'
						yield(a) 
					else
						e = @entities.find { |et| et.name == a[1..-2] }
						return if e == nil
						e.values.each { |v| yield(v) }
					end
				}
			else
				element.attrs.each { |a| 
					if a.name[0,1]!='%'
						yield(a) if a.name[0,name.length]==name 
					else
						e = @entities.find { |et| et.name == a[1..-2] }
						return if e == nil
						e.values.each { |v| yield(v) if v[0,name.length]==name}
					end
				}
			end
		end
		
        def each_value(tag_name,attr_name,v="") #{{{3
            each_attr(tag_name,attr_name) { |a|
                next if attr_name!=a.name
                if ( v == nil || v.length==0) 
                    a.values.each { |s| 
						if s[0,1]!='%' 
							yield(s) if s[0,5]!='CDATA'
						else
							e = @entities.find { |et| et.name == s[1..-2] }
							return if e == nil
							e.values.each { |v2| yield(v2) }
						end
					}
                else
                    a.values.each { |s| 
						if s[0,1]!='%'
							yield(s)  if s[0,v.length]==v
						else
							e = @entities.find { |et| et.name == s[1..-2] }
							return if e == nil
							e.values.each { |l| yield(l)  if l[0,name.length]==v}
						end
					}
                end
            }
        end
		def each_entity4_element(ename,name=nil) #{{{3
			e = @entities.find { |et| et.name == ename }
			return if e == nil
			if name == nil || name.length==0
				e.values.each { |v|
					element = @elements.find { |en| en.name==v }
					yield(element) if element != nil
				}
			else
				e.values.each { |v|
					next if v[0,name.length]!=name
					element = @elements.find { |en| en.name==v }
					yield(element) if element != nil
				}
			end
		end
		def each_child(pname,name=nil)  #{{{3
			par = @elements.find { |f| f.name==pname }
			return if par == nil
			if name==nil || name.length==0
				par.children.each { |c| 
					if c[0,1]!='%'
						yield(c)  
					else
						e = @entities.find { |et| et.name == c[1..-2] }
						return if e == nil
						e.values.each { |v| 
                            yield(v)
                        }
					end
				}
			else
				par.children.each { |c| 
					if c[0,1]!='%'
						yield(c) if c[0,name.length]==name 
					else
						e = @entities.find { |et| et.name == c[1..-2] }
						return if e == nil
						e.values.each { |v| yield(v)  if v[0,name.length]==name}
					end
				}
			end
		end
	end
    
    class DTD_Loader #{{{2
		#require 'singleton'
		#include Singleton
        DTD_Struct = Struct.new("DTD_Struct",:mname,:malias,:mparser)
        attr_reader :dtds
        def initialize
            @dtds=[]
        end
        def load(fname,m_a=nil)
            parser = DTD_Parser.new
            parser.parse(File.new(fname))
            @dtds<< DTD_Struct.new(fname,m_a,parser)
        end
        #def find 
            #@dtds.each { |s| return s if yield(s) }
            #nil
        #end
        def find(a)
            @dtds.each { |s| 
                return s.mparser if s.malias == a || s.mname==a
            }
            nil
        end
    end
    $vjde_dtd_loader = DTD_Loader.new
end

# Test code {{{1
#loader = Vjde::DTD_Parser.new()
#loader.parse(File.new("e:/wfc/ant.dtd"))
#puts "let g:xmldata_ant= {"
#dchar=''
#loader.each_element("") { |a|
#    puts "\\ '#{a.name}': [ " 
#    cs = [] 
#    achar=''
#    cchar=''
#    print "\\ ["
#    c = 0
#    loader.each_child(a.name) { |b| 
#        if (b.class== Array ) 
#            cs.concat( b)
#        else
#            cs << b
#        end
#    }
#    cs.each { |b| 
#        print "#{cchar}'#{b}'"
#        cchar = ','
#        c=c+1
#        print "\n\\ " if c%6==5
#    }
#    puts "],"
#    print "\\ { "
#    loader.each_attr(a.name) { |c|
#        print "#{achar}'#{c.name}':["
#        bchar=''
#        loader.each_value(a.name,c.name) { |d| 
#            if ( d.class==Array)
#                print "#{bchar}'",d.join("','"),"'"
#                bchar=','
#            else
#                print "#{bchar}'#{d}'"
#                bchar=','
#            end
#        }
#        print "]"
#        achar = ','
#    }
#    puts "}"
#    puts "\\  ],"
#}
#loader.each_attr("project") { |a|
	#puts a.name
#}
#loader.parse(File.new("/tmp/hibernate/hibernate-mapping-3.0.dtd"))
#loader.each_attr("sql-query") { |a|
	#puts a.name
#}
#loader.each_value("version","unsaved-value",nil) { |a|
    #puts a
#}
#loader.parse(File.new("web-jsptaglibrary_1_2.dtd"))
#loader.each_child("target") { |e| 
	#puts e
#}
#loader.each_element("fileset") { |e| 
	#puts e.name
	#e.children.each { |c|
			#puts "\t"+c  
	#}
	#e.attrs.each { |a|
		#puts a.name+"="
		#puts a.values
	#}
#}
#loader.each_attr("fileset") { |a| puts a.name }
#loader.each_value("mapper","type") { |a| puts a }
#loader.each_value("fileset","defaultexcludes") { |a| puts a }
#e = loader.entities.each{ |et| puts et.name }
# vim:fdm=marker:shiftwidth=4:ts=4
