
package vjde.completion;
public class Struts2ConfigureMain {
	public static void main(String[] args) {
		if ( args.length < 3) {
			System.err.println("<webapp-dir> <actionpackage> ");
			return;
		}
		Struts2Configure s2c = new Struts2Configure(args[0],"",args[1]);
		s2c.findAnnotation();
	}
}
