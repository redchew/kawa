package kawa.standard;
import kawa.lang.*;

/** Implement the standard Scheme procedure "equal?". */

public class equal_p extends gnu.mapping.Procedure2
{
  public Object apply2 (Object arg1, Object arg2)
  {
    if (arg1 == arg2 || (arg1 != null && arg1.equals (arg2)))
      return Boolean.TRUE;
    else
      return Boolean.FALSE;
   }

}
