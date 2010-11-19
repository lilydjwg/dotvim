package vjde.completion;

import java.util.Vector;
import java.util.Iterator;
//import java.io.BufferedReader;
import java.io.FileReader;
import java.io.BufferedReader;

public class ClassesByName {
	public static void main(String[] args) {
		if ( args.length < 2 ) {
			//  <class-name> <jdk1.5.lst> [libpath]
			return ;
		}
		Vector buffer =new Vector();


		// grep jdk1.5lst
        /*
		try {
			BufferedReader in = new BufferedReader(new FileReader(args[1]));	
			String str = null;
			String fullname="."+args[0];
			while ((str=in.readLine())!=null) {
				if ( str.endsWith(fullname) ) {
					buffer.add(str);
				}
			}
		}
		catch(Exception ex) {
			//TODO: Add Exception handler here
		}
		for ( Iterator it = buffer.iterator() ; it.hasNext(); ) {
			System.out.println(it.next());
		}
            */
		if ( args.length < 3)
			return ;
		String[] names = new DynamicClassLoader(args[2]).getClass4Name(args[0]);
		for ( int i=0 ; i< names.length ; i++ ) {
			System.out.println(names[i].substring(0,names[i].length()-6));
		}
	}
}
