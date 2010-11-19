namespace Wangfc {
	using System;
	using System.Reflection;
	public class CSParser {
            static string tn = null;
            static string[] libs ;
            static string[] nss  ;
            static string bas=null;
            // mono CSParaser typename libs namespace
            // mono CSParaser Assembly d:/mono-1.1.13.4/lib/mono/2.0/mscorlib.dll "System;System.Reflection"
		public static void Main(string[] argv) {
			if ( argv.Length < 2 ) {
				return;
			}
            if ( argv.Length >3 ) {
                bas = argv[3];
            }
            tn = argv[0];

            libs = argv[1].Split(';');
            if ( argv.Length < 3 ) {
                nss = new string[1];
                nss[0]="";
            }
            else {
                nss = argv[2].Split(';');
                for ( int i = 0 ; i < nss.Length ; i++ ) {
                    if (nss[i].Trim().Length==0)
                        nss[i] = "";
                    else
                        nss[i] = nss[i].Trim()+".";
                }
            }
            findType();
		}
        private static void findType() {
            foreach ( string lib in libs ) {
                
                Assembly assem = null;
                try {
                assem = Assembly.LoadFrom(lib);
                if ( assem == null ) {
                    continue;
                }
                }
                catch(Exception e) {
                    //Console.Write(lib);
                    //Console.WriteLine(lib);
                    continue;
                }
                Module[] module = assem.GetModules();
                if (module != null ) {
                    foreach (Module m in module) {
                        if (genModule(m)) {
                            return;
                        }
                    }
                }
				Type[] typeInfo = assem.GetTypes();
				int find = 0;
				string fchar = " " ;
				foreach ( string ns in nss) {
                    string tof = ns+tn;
                    int len = tof.Length;
                    if ( bas != null ) {
                        tof = tof+"."+bas ;
                    }
						foreach ( Type t in typeInfo) {
								if ( t.FullName.StartsWith(tof)  && 
                                    t.FullName.IndexOf('.',len+1,t.FullName.Length-len-1)<0) {
										if (find==0) {
												Console.WriteLine("[");
												Console.WriteLine("\""+ns+tn+"\",");
												Console.WriteLine("[");
												find = 2;
										}
										Console.WriteLine( fchar +"[\""+ t.FullName.Substring(len+1) + "\",\""+t.FullName+"\"]");
										fchar = ",";
										find += 1;
                                        /*if ( find>=50) {
                                            break;
                                        }*/
								}
						}
						if ( find > 0 ) {
								Console.WriteLine("],");
								//constructor
								Console.WriteLine("[");
								Console.WriteLine("],");
								//methods
								Console.WriteLine("[");
								Console.WriteLine("],");
								// inner class 
								Console.WriteLine("[");
								Console.WriteLine("],");
								Console.WriteLine("0");
								Console.WriteLine("]");
								return;
						}
				}
            }
        }
        private static Boolean genModule(Module m) {
            foreach ( string ns in nss) {
                Type t = m.GetType(ns+ tn);
                if ( t != null ) {
                    genType(t);
                    return true;
                }
            }
            /*
            Type[] infos = m.GetTypes();
            foreach ( Type t in infos) {
            }
            */
            return false;
        }
        private static void genType(Type t ) {
            Console.WriteLine("[");
            Console.WriteLine("\""+t.FullName+"\",");
            string fchar = " " ;
            // properties
            PropertyInfo[] infos = t.GetProperties();
            Console.WriteLine("[");
            foreach (PropertyInfo i in infos ) {
                Console.WriteLine( fchar +"[\""+ i.Name + "\",\""+i.PropertyType+"\"]");
                fchar = ",";
            }
            Console.WriteLine("],");
            
            //constructor
            Console.WriteLine("[");
            Console.WriteLine("],");
            // methods
            Console.WriteLine("[");
            fchar=" ";
            MethodInfo[] methods = t.GetMethods();
            foreach ( MethodInfo m in methods ) {
                Console.Write( fchar +"[\""+ m.Name + "\",\""+m.ReturnType+"\",");
                ParameterInfo[] paras = m.GetParameters();
                string mchar="";
                foreach ( ParameterInfo pi in paras ) {
                    Console.Write(mchar+"\""+pi.ParameterType+ " " + pi.Name + "\"");
                    mchar=",";
                }
                Console.WriteLine(mchar+"[ ],0]");
                fchar=",";
            }
            Console.WriteLine("],");
            // inner class 
            Console.WriteLine("[");
            Console.WriteLine("],");
            Console.WriteLine("0");
            Console.WriteLine("]");

            /*
            FieldInfo[] infos = t.GetFields();
            foreach ( FieldInfo i in infos ) {
                Console.WriteLine(fchar + i.Name);
                fchar = ",";
            }
            */
            /*
            MemberInfo[] infos = t.GetMembers();
            foreach ( MemberInfo i in infos ) {
                Console.WriteLine(fchar + i.Name);
                fchar = ",";
            }
            */
        }
	}
}

// vim: ts=4 sws=4
