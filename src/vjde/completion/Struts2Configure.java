package vjde.completion;
import java.lang.annotation.Annotation;
import java.lang.reflect.Method;
import org.apache.struts2.convention.annotation.Actions;
import org.apache.struts2.convention.annotation.Action;
import org.apache.struts2.convention.annotation.Result;
import org.apache.struts2.convention.annotation.InterceptorRef;
import org.apache.struts2.convention.annotation.ExceptionMapping;
import java.util.ArrayList;
import org.w3c.dom.Document;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.ParserConfigurationException;
import org.xml.sax.SAXException;
import java.io.IOException;
import org.w3c.dom.NodeList;
import org.w3c.dom.Element;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathFactory;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import java.io.FileInputStream;
class ResultImpl implements Result {
	String name;
	String location;
	public ResultImpl(String n,String l) {
		name = n;
		location = l;
	}
				public String name() {
					return name==null || name.length()==0 ? "success": name;
				}
				public String location() {
					if ( location.indexOf('\n')>=0) {
						return "";
					}
					return location.trim();
				}
				public String[] params() {
					return new String[0];
				}
				public String type() {
					return null;
				}
				public Class annotationType() {
					return null;
				}
}
class ActionImpl implements Action {
	String name ;
	Result[] res;
	public ActionImpl(String n,Result[] r) {
		name = n;
		res = r;
	}
				public String value() {
					return name;
				}
				public Result[] results() {
					return res;
				}
				public InterceptorRef[] interceptorRefs() {
					return null;
				}
				public ExceptionMapping[] exceptionMappings() {
					return null;
				}
				public String[] params() {
					return new String[0];
				}
				public Class annotationType() {
					return null;
				}
}
public class Struts2Configure {
	XPathExpression exprpackage = null ;
	XPathExpression expriclude= null ;
	XPathExpression expkg= null ;
	static XPathFactory factory = XPathFactory.newInstance();
	static XPath xpath = factory.newXPath();
	DocumentBuilder db = null ;
	private static class MyAction {
		public MyAction(Action a, String sp,String m,String k) {
			action = a;
			space = sp;
			klass = k;
			method  = m==null?"execute":m;
			url = space + action.value();
		}
		public String url;
		public Action action;
		public String space;
		public String method;
		public String klass;
	}
	DynamicClassLoader dcl = null ;
	String webapp;
	String classpath;
	String actionpkg;
	String classname;
	String currentPkg=null;
	ArrayList<MyAction> actions = new ArrayList<MyAction>();
	public Struts2Configure(String webapp,String path,String pkg)
	{
		classpath = path;
		this.webapp=webapp;
		actionpkg=pkg;
		dcl = new DynamicClassLoader(classpath);
	}
	public void findAnnotation()
	{
		findAnnotation(actionpkg);
		String[] names = dcl.getPackageNames();
		for ( int i = 0 ; i < names.length ; i++) {
			if ( names[i].startsWith(actionpkg))
			{
				findAnnotation(names[i]);
			}
		}
	}	
	public void findAnnotation(String pkg)
	{
		currentPkg = pkg;
		String[] names = dcl.getClassNames(pkg);
		for ( int i = 0 ; i < names.length ; i++) {
			handlerClass(pkg,names[i]);
		}
	}
	public void handlerClass(String p, String name) {
		String fname = p+"." + name.substring(0,name.length()-6) ;
		try {
			//Class c = dcl.loadClass(fname);
			Class c = Class.forName(fname);
			if ( c != null ) {
				Annotation[] anns = c.getDeclaredAnnotations();
				handleAnnotations(anns,c);
				Method[] ms = c.getMethods();
				for ( int i = 0 ; i < ms.length; i++) {
					//ms[i].getAnnotations()
					//System.out.println(ms[i].getDeclaredAnnotations().length);
					//System.out.println( ms[i].isAnnotationPresent(Deprecated.class));
					/*
					org.apache.struts2.convention.annotation.Action t = ms[i].getAnnotation(org.apache.struts2.convention.annotation.Action.class);
					System.out.println(t);
					if ( t != null) 
					{
						handleAction((Action)t,c,ms[i].getName());
					}
					*/
					handleAnnotations(ms[i].getDeclaredAnnotations(),c,ms[i]);
				}
			}
		}
		catch ( ClassNotFoundException ex) {
			//ex.printStackTrace();
		}
	}
	public void handleAction(Action action,Class c)
	{
		handleAction(action,c,"");
		//System.out.println(action.method());
	}
	public void handleAction(Action action,Class c,String m)
	{
		String space  = "/";
		if ( currentPkg.length() > actionpkg.length()) {
			space = space + currentPkg.substring(actionpkg.length()+1) +"/";
		}
		actions.add( new MyAction(action,space,m,c.getName()));
		/*
		System.out.println(m);
		//System.out.println(c.getName());
		System.out.println(action.value());
		if ( currentPkg.length() > actionpkg.length()) {
			System.out.println(currentPkg.substring(actionpkg.length()+1));
		}
		Result[] results = action.results();
		for ( int i = 0 ; i < results.length; i++ ) {
			System.out.println(results[i].name());
			System.out.println(results[i].location());
		}
		*/
		//System.out.println(action.method());
	}
	public void handleAnnotations(Annotation[] anns,Class c,Method m) {
			for ( int i = 0 ; i < anns.length ; i++ ) {
				Annotation an = anns[i];
				//System.out.println( an.annotationType());
				if ( an  instanceof  Actions) {
					Action[] actions = ((Actions)an).value();
					for ( int j = 0 ; j < actions.length; j++) {
						handleAction(actions[j],c,m.getName());
					}
					//System.out.println(an.annotationType().getName());
				}
				else if ( an instanceof Action) {
						handleAction((Action)an,c,m.getName());
				}
				else if ( an instanceof Deprecated){
					//System.out.println(an);
				}
				//System.out.println(an.annotationType().getName());

			}
	}
	public void handleAnnotations(Annotation[] anns,Class c) {
			for ( int i = 0 ; i < anns.length ; i++ ) {
				//System.out.println(anns[i]);
				Annotation an = anns[i];
				if ( an instanceof Actions) {
					Action[] actions = ((Actions)an).value();
					for ( int j = 0 ; i < actions.length; j++) {
						handleAction(actions[j],c);
					}
					//System.out.println(an.annotationType().getName());
				}
				else if (an instanceof Action)  {
						handleAction((Action)an,c);
				}
				//System.out.println(an.annotationType().getName());

			}
	}
	public void toOut() {
		for ( MyAction act : actions) {
			System.out.println(act.klass);
			System.out.println(act.space);
			System.out.println(act.method);
			System.out.println(act.action.value());
		}
	}
	public StringBuffer result2Dict(MyAction action) {
		StringBuffer b = new StringBuffer();
		b.append('{') ;
		char sp=' ';
		for (Result res : action.action.results()) {
			b.append(String.format(" %3$c '%1$s' : '%2$s'",res.name(),res.location().replaceAll("'","''"),sp));
			sp = ',';
		}
		b.append('}');
		return b;
	}
	public StringBuffer action2List(MyAction a) {
		StringBuffer b = new StringBuffer();
		b.append(String.format("['%1$s' , '%2$s' , '%3$s' , %4$s ]",a.klass, a.method,a.url,result2Dict(a).toString()));
		return b;
	}
	public String actions2vim() {
		StringBuffer b = new StringBuffer();
		b.append("[\n");
		for ( MyAction action : actions) {
			b.append("\\");
			b.append(action2List(action).toString());
			b.append(',');
			b.append("\n");
		}
		b.append("\\]");
		return b.toString();
	}
	public Document findStruts2(String webapp)
	{
			return findXml(webapp+"/WEB-INF/classes/struts.xml");
	}
	public Document findWeb(String webapp)
	{
			return findXml(webapp+"/WEB-INF/web.xml");
	}
	public NodeList findInclues(Document doc) {
		if ( expriclude== null ) {
			try {
				expriclude= xpath.compile("//struts/include");
			}
			catch(XPathExpressionException e1) {
			}
		}
		try {
			return (NodeList ) expriclude.evaluate(doc, XPathConstants.NODESET);
		}
		catch(XPathExpressionException e1) {
		}
		return null;
		//return doc.getElementsByTagName("include");
	}
	public NodeList findPackages(Document doc) {
		if ( expkg== null ) {
			try {
				expkg= xpath.compile("//struts/package");
			}
			catch(XPathExpressionException e1) {
			}
		}
		try {
			return (NodeList) expkg.evaluate(doc, XPathConstants.NODESET);
		}
		catch(XPathExpressionException e1) {
		}
		return null;
		//return doc.getElementsByTagName("package");
	}
	public void findInxml() {
		handleXml( findStruts2(webapp));
	}
	public void onPackage(Element pkg) {
		Object result = null ;
		if ( exprpackage == null ) {
			try {
				exprpackage = xpath.compile("action");
			}
			catch(XPathExpressionException e1) {
			}
		}
		try {
			result = exprpackage.evaluate(pkg, XPathConstants.NODESET);
		}
		catch(XPathExpressionException e1) {
		}
		if ( result == null ) {
			return ;
		}

		NodeList paction = (NodeList) result;
		//NodeList paction = pkg.getElementsByTagName("action");
		String space = pkg.getAttribute("namespace");
		if ( space == null ) {
			space = "/";
		}
		for ( int i = 0 ; i <  paction.getLength() ; i++ ) {
			final Element e = (Element) paction.item(i);
			final String name = e.getAttribute("name");
			//System.out.println(name);
			final String klass = e.getAttribute("class");
			String me = e.getAttribute("method");
			if  ( me == null || me.length() ==0 ) {
				me = "execute";
			}
			Result[] res = onResult(e);
			Action action = new ActionImpl(name,res);
			/*
			final Action action = new Action() {
				public String value() {
					return name;
				}
				public Result[] results() {
					return onResult(e);
				}
				public InterceptorRef[] interceptorRefs() {
					return null;
				}
				public ExceptionMapping[] exceptionMappings() {
					return null;
				}
				public String[] params() {
					return new String[0];
				}
				public Class annotationType() {
					return null;
				}
			};
			*/

			actions.add( new MyAction(action,space,me,klass));
		}
	}
	public Result[] onResult(Element act) {
		NodeList paction = act.getElementsByTagName("result");
		Result[] res = new Result[paction.getLength()];
		for ( int i = 0 ; i <  paction.getLength() ; i++ ) {
			Element e = (Element) paction.item(i);
			final String name = e.getAttribute("name");
			final String location = e.getTextContent();
			res[i] = new ResultImpl(name,location);
			/*
			res[i] = new Result() {
				public String name() {
					return name==null || name.length()==0 ? "success": name;
				}
				public String location() {
					if ( location.indexOf('\n')>=0) {
						return "";
					}
					return location.trim();
				}
				public String[] params() {
					return new String[0];
				}
				public String type() {
					return null;
				}
				public Class annotationType() {
					return null;
				}
			};
			*/

			//System.out.println(location);
		}
		return res;
	}
	public void handleXml(Document doc) {
		long s = System.currentTimeMillis();
		if ( doc != null ) {
			NodeList incs = findInclues(doc);
			for ( int i = 0 ; i < incs.getLength(); i++ ) {
				Element e = (Element) incs.item(i);
				String file=e.getAttribute("file");
				Document dd2 = findXml(webapp+"/WEB-INF/classes/" + file);
				if ( dd2 != null ) {
					handleXml(dd2);
				}
				//System.out.println(file);
			}
			NodeList pkgs = findPackages(doc);
			for ( int i = 0 ; i < pkgs.getLength() ; i++) {
				Element e = (Element) pkgs.item(i);
				onPackage(e);
			}
		}
		System.out.println(System.currentTimeMillis()-s);
	}
	public Document findXml(String xml) {
		System.out.println(xml);
		if ( db == null ) {
			DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
			dbf.setIgnoringComments(true);
			dbf.setValidating(false);
			try {
				db = dbf.newDocumentBuilder();
			}
			catch(ParserConfigurationException e1) {
				e1.printStackTrace(System.err);
				return null;
			}
		}
			long s = System.currentTimeMillis();
		try {
			return db.parse(new FileInputStream(xml));
		}
		catch(IOException e2) {
			e2.printStackTrace(System.err);
		}
		catch(SAXException e1) {
			e1.printStackTrace(System.err);
		}
		finally {
			System.out.println("parser "  + (System.currentTimeMillis()-s));
		}
		return null;
	}
	public static void main(String[] args) {
		if ( args.length < 2) {
			System.err.println("<webapp-dir> <actionpackage> ");
			return;
		}
		Struts2Configure s2c = new Struts2Configure(args[0],"",args[1]);
		s2c.findAnnotation();
		s2c.findInxml();
		//System.out.println(s2c.actions2vim());
	}
}
