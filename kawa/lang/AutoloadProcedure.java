package kawa.lang;
import gnu.mapping.*;
import gnu.expr.*;

/**
 * Implement autoloading of Procedures.
 * A named class is loaded, and apply requests are forwarded to it.
 * @author	Per Bothner
 */

public class AutoloadProcedure extends Procedure
{
  /** The name of the class that defines the procedure.
   * It must be the name of a class in the CLASSPATH (for example:
   * "kawa.standard.list"), and the class must extend Procedure,
   * and have a default constructor.
   * If the Procedure is a ModuleMody, apply0() is applied,
   * and that is expected to define the Procedure in the global environment. */
  String className;

  /** The loaded procedure, or null if it has not yet been loaded. */
  Procedure loaded;

  public AutoloadProcedure (String name, String className)
  {
    super(name);
    this.className = className;
  }

  public void print(java.io.PrintWriter ps)
  {
    ps.print ("#<procedure ");
    if (name () != null)
      {
	ps.print (name ());
	// ps.print (' ');
      }
    /*
    if (loaded != null)
      ps.print ("autoloaded");
    else
      {
	ps.print ("autoload ");
	ps.print (className);
      }
    */
    ps.print ('>');
  }

  private void throw_error (String prefix)
  {
    throw new GenericError (prefix + className
				+ " while autoloading "
				+ (name () == null ? "" : name().toString ()));
  }

  /** Load the class named in className. */
  void load ()
  {
    String name = this.name();
    try
      {
	loaded = (Procedure) Class.forName (className).newInstance ();
	if (loaded == this)
	  throw new GenericError("circularity in autoload of "+name);
	if (loaded instanceof ModuleBody)
	  {
	    Environment env = Environment.getCurrent();
	    ((ModuleBody)loaded).run (env);
	    Object value = env.get (name);
	    if (value == null
		|| !(value instanceof Procedure))
	      throw_error
		("invalid ModuleBody class - does not define " + name);
	    loaded = (Procedure) value;
	  }
	else if (name != null)
	  {
	    if (Environment.lookup_global (name) == this)
	      Environment.define_global (name, loaded);
	    if (loaded.name () == null)
	      loaded.setName (name);
	  }
      }
    catch (ClassNotFoundException ex)
      {	throw_error ("failed to find class "); }
    catch (InstantiationException ex)
      { throw_error ("failed to instantiate class "); }
    catch (IllegalAccessException ex)
      { throw_error ("illegal access in class "); }
  }

  public Object apply0 ()
  {
    if (loaded == null)
      load ();
    return loaded.apply0 ();
  }

  public Object apply1 (Object arg1)
  {
    if (loaded == null)
      load ();
    return loaded.apply1 (arg1);
  }

   public Object apply2 (Object arg1,Object arg2)
  {
    if (loaded == null)
      load ();
    return loaded.apply2 (arg1, arg2);
  }

  public Object apply3 (Object arg1, Object arg2, Object arg3)
  {
    if (loaded == null)
      load ();
    return loaded.apply3 (arg1, arg2, arg3);
  }

  public Object apply4 (Object arg1, Object arg2,
			Object arg3, Object arg4) 
  {
    if (loaded == null)
      load ();
    return loaded.apply4 (arg1, arg2, arg3, arg4);
  }

  public Object applyN (Object[] args)
  {
    if (loaded == null)
      load ();
    if (loaded instanceof AutoloadProcedure)
	  throw new InternalError("circularity in autoload of "+name());
    return loaded.applyN (args);
  }

  public Procedure getSetter()
  {
    if (loaded == null)
      load ();
    if (loaded instanceof HasSetter)
      return loaded.getSetter();
    return super.getSetter();
  }
}
