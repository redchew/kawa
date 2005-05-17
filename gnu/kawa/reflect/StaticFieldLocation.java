package gnu.kawa.reflect;
import gnu.bytecode.ClassType;
import gnu.bytecode.Access;
import gnu.mapping.*;
import gnu.expr.*;

public class StaticFieldLocation extends FieldLocation
{
  public StaticFieldLocation(String cname, String fname)
  {
    super(null, ClassType.make(cname), fname);
  }

  public StaticFieldLocation(ClassType type, String mname)
  {
    super(null, type, mname);
  }

  public boolean isConstant ()
  {
    return true;
  }

  public Object get (Object defaultValue)
  {
    Object val = super.get(defaultValue);
    if (val instanceof kawa.lang.Macro)
      getDeclaration();
    return val;
  }

  public static StaticFieldLocation
  define(Environment environ, Symbol sym, Object property,
	 String cname, String fname)
  {
    StaticFieldLocation loc = new StaticFieldLocation(cname, fname);
    environ.addLocation(sym, property, loc);
    return loc;
  }

  public static StaticFieldLocation make (/*Object name,*/ String cname, String fldName)
  { 
    return new StaticFieldLocation(cname, fldName);
  }
}
