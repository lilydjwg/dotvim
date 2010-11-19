

/*
 * Document.java 1.00 Wed Aug 24 15:02:50 中国标准时间 2005
 *
 * 版权信息
 */

package vjde.completion;
import java.util.StringTokenizer;
import java.io.File;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.regex.Pattern;
import java.util.HashMap;
import java.util.regex.Matcher;

public class Document {
	String paths;
	String className;
	String member;
	String src;
	static HashMap tagMaps= new HashMap();
	static {
		tagMaps.put("A","<u>");
		tagMaps.put("/A","</u>");
		tagMaps.put("B","<b>");
		tagMaps.put("/B","</b>");
		tagMaps.put("H3","<big><big>");
		tagMaps.put("/H3","</big></big>");
		tagMaps.put("CODE","<span foreground=\"blue\">");
		tagMaps.put("/CODE","</span>");
		tagMaps.put("DD","\n");
	}
	public Document(String ps,String src,String cname,String m) {
		paths = ps;
		int index = cname.indexOf(":",0);
		if ( index > 0 ) {
			className = cname.substring(0,index);
		}
		else  {
			className = cname;
		}
		member = m;
		index = member.indexOf(";",0);
		if ( index > 0 ) {
			member = member.substring(0,index);
		}
		this.src = src;
	}
	public String read() throws Exception {
		String fn = className.replace('.','/');
		File srcFile = new File(src+"/"+fn+".java");
		if ( srcFile.exists()) {
			return readSource(srcFile);
		}
		StringTokenizer stks = new StringTokenizer(paths,File.pathSeparator);
		while ( stks.hasMoreTokens()) {
			String str = stks.nextToken();
            if (!str.endsWith("/") ) {
                str = str+"/";
            }
			File file = new File( str+fn+".html" );
			if ( file.exists()) {
				return readFile(file);
			}
		}
		return "";
	}
	private String readSource(File f ) throws Exception {
		String mem = member;
		int index = member.indexOf("(",0);
		if ( index > 0 ) {
			mem = member.substring(0,index);
		}
		else {
			index = member.indexOf(";",0);
			if (index > 0 ) 
				mem = member.substring(0,index);
		}
		index = className.lastIndexOf(".");
		String cn = className;
		if ( index > 0 ) {
			cn = className.substring(index+1);
		}
		SourceDocReader reader = new SourceDocReader(f.getAbsolutePath());
		return reader.getMemberDoc(cn,mem);
	}
	private String readFile(File f) throws IOException {
		StringBuffer buffer = new StringBuffer();
		boolean find = false;
		BufferedReader reader = new BufferedReader(new FileReader(f));
		String line ;
		//Pattern pattern = Pattern.compile("(<([^ ]+) ?[^>]*>)");
		Pattern pattern = Pattern.compile("<([^ >]+)[^>]*>");
		//Pattern pattern = Pattern.compile("<[^>]*>");
		Pattern pattern2 = Pattern.compile("&nbsp;");
		Pattern spacePattern = Pattern.compile("^\\s*$");
		while ( ( line = reader.readLine())!= null) {
			if ((!find) && line.indexOf("<A NAME=\"" + member +"\">",0)!=0) {
				continue;
			}
			if ( line.indexOf("<HR>",0)==0 ) {
				break;
			}
			if ( find &&  line.indexOf("<A NAME=\"",0)==0 ) {
				break;
			}
			String temp = line;//pattern.matcher(line).replaceAll("");
			Matcher mat = pattern.matcher(line);
			StringBuffer  buffer2 = new StringBuffer();
			//if ( mat.matches()) {
				while ( mat.find()) {
					String old = mat.group(1);
					mat.appendReplacement(buffer2, getTags(old));
				}
				mat.appendTail(buffer2);
				temp = buffer2.toString();
			//}
			

			//temp = temp.replace("&nbsp;"," ");
			temp = temp.replaceAll("&nbsp;"," ");
			//if ( temp.length()>1) {
			if (!spacePattern.matcher(temp).find()) {
				buffer.append(temp);
				if ( temp.compareTo("\n")!=0) {
					buffer.append("\n");
				}
			}
			//String temp = pattern.matcher(line).replaceAll("");
			//if ( temp.length()>1) 
			//	System.out.println();
			find = true;
		}
		reader.close();
		return buffer.toString();
	}
        public static void main(String[] args) {
            //<search path> <source path> <class name> <method name>
		if ( args.length < 4 ) {
			return;
		}
		String args4 = args[3];
		for ( int i = 4 ; i < args.length; i++) {
			args4 = args4+" " + args[i];
		}
		try {
			Document doc = new Document(args[0],args[1],args[2],args4);
            doc.useHTML = false;
			//System.out.println("<span background=\"yellow\">");
			System.out.println(doc.read().replaceFirst("\n",""));
			//System.out.println("</span>");
		}
		catch(Exception ex) {
			ex.printStackTrace();
			//TODO: Add Exception handler here
		}
        }
        boolean useHTML = true;
	private String getTags(String old) {
        if (!useHTML) {
			if (old.compareToIgnoreCase("DD")==0) {
				return "\n";
			}
            return " ";
        }
		if (tagMaps.containsKey(old)) 
			return (String) tagMaps.get(old);
		return "";
	}

}
// vim: ft=java
