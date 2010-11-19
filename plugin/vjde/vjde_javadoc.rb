module Vjde
    class JavadocReader
        attr_reader :lines
        RETAG=/<([^>]*)>/
        RESPACE=/&nbsp;/
        def initialize
            @lines = []
        end
        def read(f,fun)
            return unless FileTest.exist?(f)
            @lines.clear
            doc = File.open(f)
            find = false
            doc.each_line { |l|
                next if !find && l.index("<A NAME=\"#{fun}\">")!=0
                break if l.index('<HR>')==0
                break if find && l.index('<A NAME="')==0
                find = true
                @lines<< l
            }
            doc.close
        end
        def to_text_arr
            arr = []
            arr2=[]
            to_text { |l| arr<< l }
            arr.each { |l|
                l.each_line { |l2|
                    arr2<< l2
                }
            }
            arr2.delete_if { |l| l.index("\n")==0}
            arr2.delete_at(0)
            arr2
        end
            private
        def to_text
            @lines.each { |l|
                find = true
                while find
                    find = false
                    l.sub!(RESPACE,' ')
                    l.sub!(RETAG) { |p|
                        find = true
                        if $1=="CODE"
                            "\n"
                        elsif $1=="DT"
                            "\n"
                        else
                            ''
                        end
                    }
                end
                yield(l)
            }
        end
    end

end
$vjde_doc_reader = Vjde::JavadocReader.new 

if $*.length==2
$vjde_doc_reader.read($*[0],$*[1])
$vjde_doc_reader.to_text_arr.each {|l|
    puts l
}
end
if $*.length==3
$vjde_doc_reader.read($*[0],$*[1])
$vjde_doc_reader.lines.each {|l|
    puts l
}
end
