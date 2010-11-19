require 'vjde_taglib_cfu.rb'
#puts loader.tlds
#loader.tlds.each { |key,val|
#        val.each_tag { |tg|
#            puts tg.get_text("name")
#        }
#}
class Generator
    attr_accessor   :ns
    attr_accessor :file
    def initialize(ns,file)
        @ns = ns
        @file = file
    end
    def to_stdout
        loader = Vjde::Tld_Loader.instance
        loader.load(@file)
        #loader = Vjde::DTD_Parser.new()
        #loader.parse(File.new(@file))
        puts "let g:xmldata_#{@ns}= {"
        dchar=''
        doc = nil
        loader.tlds.each { |k,v| doc = v } 
        line=''
        doc.each_tag { |a|
            puts "#{line}\\ '"+a.get_text("name").to_s+"': [ " 
            cs = [] 
            achar=''
            cchar=''
            print "\\ ["
            c = 0
            puts "],"
            print "\\ { "
            doc.each_attr(a) { |c|
                print "#{achar}'"+c.get_text("name").to_s+"' : ["
                bchar=''
                print "]"
                achar = ','
            }
            puts "}"
            line = "\\  ],\n"
        }
        puts "\\ ],"
	achar=' '
	print "\\ 'vimxmltaginfo': {"
        doc.each_tag { |a|
		puts achar
		print "\\ '" + a.get_text("name").to_s+"' : [ ' ', '" + xml_data(a.get_text("description").to_s)+"']"
		achar=',';
	}
	puts ""
	puts "\\ },"
	achar=' '
	print "\\ 'vimxmlattrinfo': {"
	attrs=[]
        doc.each_tag { |a|
		doc.each_attr(a) { |c|
			next if  attrs.index(c.get_text("name").to_s) 
			attrs.push( c.get_text("name").to_s)
			puts achar
			print "\\ '" + c.get_text("name").to_s+"' : [ ' ', '" + xml_data(c.get_text("description").to_s)+"']"
			achar=',';
		}
	}
	puts ""
	puts "\\ },"
	puts "\\}"
    end
    def xml_data(str)
	    return str.gsub("\n"," ").gsub("'","\"")
    end
end
if $*.length == 2
    gen = Generator.new($*[1],$*[0])
    gen.to_stdout
end

