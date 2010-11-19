using System;
using System.Collections.Generic;
using System.Text;
namespace Wangfc
{
    public class UsingFinder
    {
        static string tn = null;
        static string[] libs;
        static string[] nss;
        static string bas = null;
        // mono CSParaser typename libs namespace
        // mono CSParaser Assembly d:/mono-1.1.13.4/lib/mono/2.0/mscorlib.dll "System;System.Reflection"
        public static void Main(string[] argv)
        {
            if (argv.Length < 2)
            {
                return;
            }
            if (argv.Length > 3)
            {
                bas = argv[3];
            }
            tn = argv[0];

            libs = argv[1].Split(';');
            if (argv.Length < 3)
            {
                nss = new string[1];
                nss[0] = "";
            }
            else
            {
                nss = argv[2].Split(';');
                for (int i = 0; i < nss.Length; i++)
                {
                    if (nss[i].Trim().Length == 0)
                        nss[i] = "";
                    else
                        nss[i] = nss[i].Trim() + ".";
                }
            }
            List<string> modes = findType();
	    Console.Write("[");
	    int j = 0 ;
	    foreach ( string m in modes) {
		    if ( m!=null &&  m.StartsWith(tn)) {
			if ( j != 0 ) {
				Console.Write(",");
			}
			j = 1;
			Console.Write("'");
			Console.Write(m);
			Console.Write("'");
		    }
	    }
	    Console.Write("]");
        }
        public static List<String> findType()
        {
            List<String> mods = new List<string>();
            foreach (string lib in libs)
            {

                Assembly assem = null;
                try
                {
                    assem = Assembly.LoadFrom(lib);
                    if (assem == null)
                    {
                        continue;
                    }
                }
                catch (Exception e)
                {
                    //Console.Write(lib);
                    //Console.WriteLine(lib);
                    continue;
                }
                
                Module[] module = assem.GetModules();
                if (module != null)
                {
                    foreach (Module m in module)
                    {
                        Type[] ts = m.GetTypes();
                        foreach (Type t in ts)
                        {
                            if (mods.Contains(t.Namespace))
                            {
                                continue;
                            }
                            mods.Add(t.Namespace);
                            //Console.WriteLine(t.Namespace);
                        }
                    }
                }
            }
	    return mods;
        }
    }
}
