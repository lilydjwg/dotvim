package vjde.completion;

import java.util.Arrays;
import java.util.Vector;
import java.util.Iterator;
import java.io.BufferedReader;
import java.io.FileReader;
public class PackageClasses {
	public static void main(String[] args) {
		if ( args.length < 3 ) {
			// <libpath>  <pkg-name> <jdk1.5.lst> <class-name>
			return ;
		}
		String[] names = new DynamicClassLoader(args[0]).getClassNames(args[1]);

		Vector buffer =new Vector();

		String prefix = args[1];
		int prelen = args[1].length();
		boolean check = true;
		if ( args.length>=4 && args[3].length()>0) {
			prefix += args[3];
			check = false;
		}

        /*
		// grep jdk1.5lst
		try {
			BufferedReader in = new BufferedReader(new FileReader(args[2]));	
			String str = null;
			while ((str=in.readLine())!=null) {
				if ( str.startsWith(prefix) ) {
					if ( check) {
						if ( str.charAt(prelen)<='Z' && str.charAt(prelen)>='A') {
							//buffer.add(str.substring(prelen));
							buffer.add(str);
						}
					}
					else {
						//buffer.add(str.substring(prelen));
						buffer.add(str);
					}
				}
			}
		}
		catch(Exception ex) {
			//TODO: Add Exception handler here
		}
        */

		Arrays.sort(names);

        /*
		for ( Iterator it = buffer.iterator() ; it.hasNext(); ) {
			System.out.println(it.next());
		}
        */

		if (args.length >= 4 && args[3].length()>0) {
			for ( int i = 0 ; i < names.length ; i++) {
				if ( names[i].startsWith(args[3]) && names[i].indexOf('$')<0 && names[i].endsWith(".class")) {
					System.out.println(names[i].substring(0,names[i].length()-6));
				}
			}
		}
		else {
			for ( int i = 0 ; i < names.length ; i++) {
                if ( names[i].indexOf('$') < 0 && names[i].endsWith(".class")) 
				System.out.println(names[i].substring(0,names[i].length()-6));
			}
		}
	}
}
