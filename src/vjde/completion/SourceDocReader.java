
/*
 * SourceDocReader.java 1.00 Wed Aug 24 09:38:45 中国标准时间 2005
 *
 * 版权信息
 */

package vjde.completion;
import java.io.FileReader;
import java.io.StreamTokenizer;

/**
 * Java Plugin for Vim Intellisense.
 * Author  : Madan Ganesh (mganesh@baan.com)
 * Dated   : 25th September 2003
 * Version : javaft 0.92
 * 
 * You can modify the source, provided you leave this header information.
 */
public class SourceDocReader {
	private String m_fileName;
	public SourceDocReader(String f) {
		this.m_fileName = f;
	}
	/**
	 * This method reads the documentation for the given class. 
	 *
	 * @param	className		The class name for which the documentation has
	 * 							to be read.
	 *
	 * @return	The documentation for the given class.
	 */
	public String getClassDoc(String className) throws Exception
	{
		FileReader fd = new FileReader(m_fileName);

		StreamTokenizer st = new StreamTokenizer(fd);
		st.slashSlashComments(true);
		st.wordChars((char)' ',(char)' ');
		st.wordChars((char)'\t',(char)'\t');
		st.wordChars((int)'_',(int)'_');
		st.wordChars((int)'[',(int)']');
		st.wordChars((int)'{',(int)'}');
		st.wordChars((int)';',(int)';');
		st.wordChars((int)'(',(int)')');
		st.wordChars((int)',',(int)',');
		st.wordChars((int)'=',(int)'=');
		st.wordChars((int)'/',(int)'/');
		st.wordChars((int)'*',(int)'*');

		String doc = "";
		while (st.nextToken() != StreamTokenizer.TT_EOF)
		{
			if (st.ttype == StreamTokenizer.TT_WORD)
			{
				doc = "";
				if (st.sval.startsWith("/**"))
				{
					doc = readDoc(st);
					if (st.nextToken() == StreamTokenizer.TT_EOF)
					{
						doc = "";
						break;
					}
				}
				if (indexOfOnly(st.sval,"class "+className) || (indexOfOnly(st.sval,"interface "+className)))
				{
					doc = st.sval + "<BR><BR>" + doc;
					break;
				}
			}
		}
		return doc;
	}	

	/**
	 * This method returns the documentation of the given member belonging to
	 * the class specified by the class name.
	 *
	 * @param	className		The name of the type whose member's
	 * 							documentation has to be read.
	 *
	 * @param	member			The member whose documentation has to be read.
	 *
	 * @return	The documentation of the member.
	 */
	public String getMemberDoc(String className,String member) throws Exception
	{
		FileReader fd = new FileReader(m_fileName);

		StreamTokenizer st = new StreamTokenizer(fd);
		st.slashSlashComments(true);
		st.wordChars((char)' ',(char)' ');
		st.wordChars((char)'\t',(char)'\t');
		st.wordChars((int)'_',(int)'_');
		st.wordChars((int)'[',(int)']');
		st.wordChars((int)'{',(int)'}');
		st.wordChars((int)';',(int)';');
		st.wordChars((int)'(',(int)')');
		st.wordChars((int)',',(int)',');
		st.wordChars((int)'=',(int)'=');
		st.wordChars((int)'/',(int)'/');
		st.wordChars((int)'*',(int)'*');

		String doc = "";
		boolean classFound = false;
		while (st.nextToken() != StreamTokenizer.TT_EOF)
		{
			if (st.ttype == StreamTokenizer.TT_WORD)
			{
				if (indexOfOnly(st.sval,"class "+className) || (indexOfOnly(st.sval,"interface "+className)))
				{
					classFound = true;
					break;
				}
			}
			
		}

		if (classFound)
		{
			while (st.nextToken() != StreamTokenizer.TT_EOF)
			{
				if (st.ttype == StreamTokenizer.TT_WORD)
				{
					doc = "";
					if (st.sval.startsWith("/**"))
					{
						doc = readDoc(st);
					}
					
					// First Collect the member signature completly.
					if (!doc.equals(""))
					{
						String buffer = "";
						while (st.nextToken() != StreamTokenizer.TT_EOF)
						{
							if (st.ttype == StreamTokenizer.TT_WORD)
							{	
								buffer += st.sval;
								if (st.sval.endsWith("{") || st.sval.endsWith(";"))
								{
									break;
								}
							}
						}
						if (buffer.indexOf(member) != -1)
						{
							buffer = buffer.substring(0,buffer.length() - 1);
							doc = buffer + "\n" + doc;
							break;
						}
					}
				}
			}
		}
		else
		{
			throw new Exception(className + " not found in " + m_fileName);
		}
		
		fd.close();
		return doc;
	}

    public String getMemberTipDoc(String className,String member,int paramPos) throws Exception
    {
        return "";
    }

	// Helper Methods.
	 
	/**
	 * This method consumes the documentation part of the tokenizer. 
	 *
	 * @param	st		StreamTokenizer from which the immediate documentation
	 * 					portion is to be read.
	 *
	 * @return	The documentation consumed from the stream.
	 */
	private String readDoc(StreamTokenizer st) throws Exception
	{
		String doc = "";
		while (st.nextToken() != StreamTokenizer.TT_EOF)
		{
			if (st.ttype == StreamTokenizer.TT_WORD)
			{
				if (st.sval.endsWith("*/"))
				{
					break;
				}
				String test = st.sval;
				int pos = test.indexOf('*');
				if (pos != -1)
				{
					test = "\n"+test.substring(pos+1);
				}
				doc += test;
			}
		}
		return doc;
	}
	/**
	 * Checks if the 'test' is part of 'whole' string and the 'test' ends in
	 * the 'whole' string. Eg
	 * 			whole - "class XPath implements Parser"
	 * 			test - "class XPath"
	 * 				returns true
	 * 
	 * 			whole - "class XPathAPI implements Parser"
	 * 			test - "class XPath"
	 * 				return false 
	 * 				
	 * 			whole - "class XPath{"
	 * 			test - "class XPath"
	 * 				returns true
	 */	
	static boolean indexOfOnly(String whole,String test)
	{
		boolean ret = false;
		int pos = whole.indexOf(test);
		if (pos != -1)
		{
			String testSeparated = whole.substring(pos).trim();
			int l1 = test.length();
			int l2 = testSeparated.length();
			if (l1 == l2)
			{
				if (testSeparated.equals(test))
				{
					ret = true;
				}
			}
			else if (l2 > l1)
			{
				char c = testSeparated.charAt(l1);
				if (c==' ' || c=='\t' ||  c=='{')
				{
					ret = true;
				}
			}
		}
		return ret;
	}
	
	public static void main(String[] args) {
		try {
			SourceDocReader reader = new SourceDocReader("src/vjde/completion/SourceDocReader.java");
			String clsDoc = reader.getClassDoc("SourceDocReader");
			System.out.println(clsDoc);
			System.out.println();
			String memberDoc = reader.getMemberDoc("SourceDocReader","getMemberDoc");
			System.out.println(memberDoc);
		}
		catch(Exception ex) {
			//TODO: Add Exception handler here
		}
        }
}
// vim: ft=java
