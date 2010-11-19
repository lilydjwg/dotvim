require 'rexml/rexml'
require 'rexml/document'
include REXML
module Vjde
	class Struts2ConfigLoader
		attr_reader :configs
		attr_reader :classdir
		attr_reader :packages
		def initialize(webapp)
			@classdir=webapp+"/WEB-INF/classes"
			@configs={}
			load_config(@classdir+"/struts.xml")
		end
		def load_config(file)
			return if ( @configs.has_key?(file)) 
			if File.exist?(file)
				doc =   Document.new(File.new(file),"r")
				configs[file] = doc
				XPath.each(doc.root,"/struts/include") { |t| 
					load_config("#{@classdir}/#{t.attributes['file']}")
					#load_config("#{@classdir}/#{t["
			       	}
			end
		end
		def each_package
			@configs.each { |file,doc|
				XPath.each(doc.root,"package") { |p|
					yield(p)
				}
			}
		end
		def each_action 
			each_package { |p|
				XPath.each(p,"action") { |a|
					yield(p,a)
				}
			}
		end
		def find_action_if(url2) 
			url = url2
			idx = url2.rindex(".")
			url = url2[0..idx-1] if idx
			each_action { |p,a|
				n = p.attributes["namespace"]
				n = '' unless n
				name = n+"/"+a.attributes["name"] 
				if name == url
					yield(p,a)
				end
			}
		end
		def find_actions(url)
			res=[]
			find_action_if(url) { |p,a|
				res << a
			}
			return res
		end
		def find_file(src,url) 
			res = []
			#find .java file and the method,then is result
			find_action_if(url) { |p,a|
				r1=[]
				cn = a.attributes["class"]
				m = "execute"
				r1 << src+"/" + cn.gsub!(".","/")+".java"
				m2 = a.attributes["method"]
				m = m2 if m2
				r1 << m
				res << r1

				XPath.each(a,"result") { |r|
					n = r.attributes["name"]
					n = 'success' unless n
					v = r.get_text()
					res << [n,v]
				}
				break
			}
			return res
		end
		def print_info(src,url)
			res = find_file(src,url)
			puts "file  :\t#{res[0][0]}" if res.length>0 
			puts "method:\t#{res[0][1]}" if res.length>0 
			(1..res.length-1).each { |r|
				puts "#{res[r][0]} ->\t#{res[r][1]}"
			}
		end
		def get_action_url(fp,websrc,str)
			return str
		end
	end

end

include Vjde
if $*.length==3
	#l = Struts2ConfigLoader.new('d:/workspace/b600-2/WebContent')
	#puts l.find_file("javasource","/chinaoil/ToOplogin")
	#l.print_info("javasource","/aillypay/AillyFill.action")
	l = Struts2ConfigLoader.new($*[0])
	l.print_info($*[1],$*[2])
end
	
