require 'rexml/rexml'
require 'rexml/document'
include REXML
module Vjde #{{{1
    class Tld_document #{{{2
        attr_reader :doc
        attr_reader :shortname
        attr_reader :uri
        attr_reader :tags
        def initialize(d,u=nil)
            @doc = d;
            @shortname = doc.root.get_text("/taglib/shortname")
            if ( u == nil || u.length==0) 
                @uri = doc.root.get_text("/taglib/uri").value
            else 
                @uri = u
            end
            @tags=[]
            XPath.each(@doc.root,"/taglib/tag") { |t| @tags << t }
            #temp = []
            #@tags = temp.sort { |a,b| a.get_text("name").value<=>b.get_text("name").value }
        end
        def find_tag(name) 
            return find_tag_if { |t| t.get_text("name")==name }
        end
        def find_tag_if
            @tags.find { |el|
                return el if yield(el)
            }
            return nil
        end
        def each_tag
            @tags.each { |el|
                yield(el)
            }
        end
        def each_attr(tag)
            XPath.each(tag,"attribute") { |el|
                yield(el)
            }
        end
    end
    class Tld_Loader #{{{2

        attr_reader :tlds
	require 'singleton'
	include Singleton
        def initialize() 
            @tlds={}
        end
        def load2(doc,uri=nil)
            tld = Tld_document.new(doc,uri)
	    return if @tlds.key?(tld.uri)  
            @tlds[tld.uri] = tld
        end
        def load(f,uri=nil) 
            doc = Document.new(File.new(f),"r");
	    load2(doc,uri)
        end
        def each_tag(tld_doc,base=nil)
            if ( base == nil || base.length == 0 ) 
                tld_doc.each_tag { |tag| yield(tag) }
            else
                tld_doc.each_tag { |tag| 
                    v = tag.get_text("name").value[0,base.length]<=>base
                    if v==0
                        yield(tag)
                    end
                    if v>0
                        #return
                    end
                }
            end
        end
        def each_tag4uri(uri,tag=nil) 
            tld = @tlds[uri]
            if ( tld != nil) 
                each_tag(tld,tag) { |t| yield(t) }
            end
        end
        def each_attr4uri(uri,t,a=nil) 
            tld = @tlds[uri]
            if ( tld != nil) 
                tag = find_tag(tld,t)
                if ( tag != nil) 
                    each_attr(tld,tag,a) { |at| yield(at)}
                end
            end
        end
        def find_tag(tld,name)
            return tld.find_tag_if { |el| el.get_text("name")==name }
        end
        def each_attr(tld,tag,base=nil)
            if ( base == nil || base.length==0)
                tld.each_attr(tag) { |at| yield(at) }
            else
                tld.each_attr(tag) { |at|
                    if (at.get_text("name").value[0,base.length]==base)
                        yield(at)
                    end
                }
            end
        end
    end
    class JspDirective  #{{{2
	require 'singleton'
	include Singleton
        attr_reader:directives
        def initialize
            @directives = {"page"=>["language=\\\"java\\\"","extends","import","session","buffer","autoFlush",
            "isThreadSafe","info","errorPage","isErrorPage","contentType","pageEncoding","isELIgnored"],
            "include"=>["file"],
            "taglib"=>["uri","tagdir","prefix"]}
        end
        def each(n=nil) 
            if (n==nil || n.length==0)
                @directives.each_key { |k| yield(k) }
            else
                @directives.each_key { |k| yield(k) if k[0,n.length]==n }
            end
        end
        def each_attr(name,n=nil) 
            arr = @directives[name]
            return if arr == nil
            if ( n == nil || n.length==0) 
                arr.each { |v| yield(v) }
            else
                arr.each { |v| yield(v) if v[0,n.length]==n }
            end
        end
    end
    class VjdeProjectTlds #{{{2
	require 'singleton'
	include Singleton
        attr_accessor :tlds
        def initialize
            @tlds=[]
        end
        def add(file,uri=nil) 
            loader=Vjde::Tld_Loader.instance
            loader.load2(Document.new(File.new(file,"r")),uri);
            @tlds<<[file,uri]
        end
        def each   
            @tlds.each { |t| yield(t[0],t[1]) } 
        end
    end
    def Vjde::init_jstl(path=nil) #{{{2
	    #$vjde_tld_loader.load2(Document.new(File.new("#{path}jsp.tld","r")))
	    $vjde_tld_loader.load2(Document.new(File.new("#{path}c.tld","r")))
	    $vjde_tld_loader.load2(Document.new(File.new("#{path}sql.tld","r")))
	    $vjde_tld_loader.load2(Document.new(File.new("#{path}fn.tld","r")))
	    $vjde_tld_loader.load2(Document.new(File.new("#{path}x.tld","r")))
	    $vjde_tld_loader.load2(Document.new(File.new("#{path}fmt.tld","r")))
	    #$vjde_tld_loader.load2(Document.new(File.new("#{path}xsl.tld","r")),"http://www.w3c.org/1999/XSL/Transform")
    end
    $vjde_tld_loader = Vjde::Tld_Loader.instance
    $vjde_tlds = Vjde::VjdeProjectTlds.instance
    $vjde_jsp = Vjde::JspDirective.instance
end

#Vjde::init_jstl("/usr/share/vim/vimfiles/plugin/vjde/tlds/")
#$vjde_tlds.add("/usr/share/vim/vimfiles/plugin/vjde/tlds/fmt.tld","")
#$vjde_tlds.each { |f,u| puts f ; puts u }

#$Vjde_jsp.each("p") { |n| puts n}
#$Vjde_jsp.each("") { |n| puts n}
#$Vjde_jsp.each_attr("page") { |n| puts n}
#$Vjde_jsp.each_attr("page","i") { |n| puts n}



#st = Time.now()
#doc = Document.new(File.new("doc/map.tld","r"))
#puts Time.now()-st
#tld = Vjde::Tld_document.new(doc,"/test")
#el = tld.find_tag_if { |el| el.get_text("name")=="map"}
#tld.each_attr(el) { |e2| puts e2.get_text("name") }

#loader = Vjde::Tld_Loader.new
#loader.load2(doc,"/test")
#puts Time.now()-st
#loader.load("doc/map.tld","/test")
#test = loader.find_4_uri("/test")
#t = test.find_tag_if { |el| el.get_text("name")=="map" }
#t = loader.find_tag_if { |el| el.get_text("name")=="map" }
#puts t.get_text("name")
#loader.each_tag(loader.find_4_uri("/test"),"t") { |t| puts t.get_text("name") }
#loader.each_tag4uri("/test","t") {|t| puts t.get_text("name") }
#puts Time.now()-st
#loader.each_tag4uri("/test","the") {|t| puts t.get_text("name") }
#puts Time.now()-st
#loader.each_tag4uri("/test","") {|t| puts t.get_text("name") }
#puts Time.now()-st
#loader.each_attr4uri("/test","map") {|t| puts t.get_text("name") }
#puts Time.now()-st

# vim:fdm=marker:ft=ruby
