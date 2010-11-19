require 'vjde_xml_cfu.rb'
#loader = Vjde::DTD_Parser.new()
#loader.parse(File.new("e:/wfc/ant.dtd"))

class Generator
    attr_accessor   :ns
    attr_accessor :file
    def initialize(ns,file)
        @ns = ns
        @file = file
    end
    def to_stdout
        loader = Vjde::DTD_Parser.new()
        loader.parse(File.new(@file))
        puts "let g:xmldata_#{@ns}= {"
        dchar=''
        line=''
        loader.each_element("") { |a|
            puts "#{line}\\ '#{a.name}': [ " 
            cs = [] 
            achar=''
            cchar=''
            print "\\ ["
            c = 0
            loader.each_child(a.name) { |b| 
                if (b.class== Array ) 
                    cs.concat( b)
                else
                    cs << b
                end
            }
            cs.each { |b| 
                print "#{cchar}'#{b}'"
                cchar = ' , '
                c=c+1
                print "\n\\ " if c%6==5
            }
            puts "],"
            print "\\ { "
            loader.each_attr(a.name) { |c|
                print "#{achar}'#{c.name}' : ["
                bchar=''
                loader.each_value(a.name,c.name) { |d| 
                    if ( d.class==Array)
                        print "#{bchar}'",d.join("' , '"),"'"
                        bchar=','
                    else
                        print "#{bchar}'#{d}'"
                        bchar=','
                    end
                }
                print "]"
                achar = ','
            }
            puts "}"
            line = "\\  ],"
        }
        puts "\\  ]}"
    end
end
if $*.length == 2 
gen = Generator.new($*[1],$*[0])
gen.to_stdout
end
