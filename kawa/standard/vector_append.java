package kawa.standard;
import kawa.lang.*;
import codegen.Field;
import codegen.Access;
import codegen.ClassType;

/**
 * Implement the Scheme extended function "vector-append".
 * @author Per Bothner
 */

public class vector_append extends ProcedureN implements Compilable
{
  public static vector_append vappendProcedure = new vector_append ();

  public Object applyN (Object[] args)
      throws WrongType
  {
    int length = 0;
    int args_length = args.length;
    for (int i = args_length;  --i >= 0; )
      {
	Object arg = args[i];
	if (arg instanceof Vector)
	  length += ((Vector)arg).length();
	else
	  {
	    int n = List.list_length (arg);
	    if (n < 0)
	      throw new WrongType (this.name (), i, "list or vector");
	    length += n;
	  }
      }
    Object[] result = new Object [length];
    int position = 0;
    for (int i = 0;  i < args_length;  i++)
      {
	Object arg = args[i];
	if (arg instanceof Vector)
	  {
	    Vector vec = (Vector) arg;
	    int vec_length = vec.length ();
	    for (int j = 0;  j < vec_length;  j++)
	      result[position++] = vec.elementAt (j);
	  }
	else if (arg instanceof Pair)
	  {
	    while (arg != List.Empty)
	      {
		Pair pair = (Pair) arg;
		result[position++] = pair.car;
		arg = pair.cdr;
	      }
	  }
      }
    return new Vector (result);
  }

  private static Field vappendConstant;

  public Literal makeLiteral (Compilation comp)
  {
    if (vappendConstant == null)
      {
	ClassType thisType = new ClassType ("kawa.standard.vector_append");
	vappendConstant = thisType.new_field ("vappendProcedure", thisType,
					      Access.PUBLIC|Access.STATIC);
      }
    return new Literal (this, vappendConstant, comp);
  }

  public void emit (Literal literal, Compilation comp)
  {
    throw new Error ("internal error - vector_append.emit called");
  }
}
