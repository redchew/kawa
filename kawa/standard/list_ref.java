package kawa.standard;
import kawa.lang.*;
import gnu.math.IntNum;
import gnu.mapping.*;

public class list_ref extends Procedure2
{
  public Object apply2 (Object arg1, Object arg2)
  {
    Object tail = list_tail.listTail (arg1,
				      IntNum.intValue (arg2));
    if (tail instanceof Pair)
      return ((Pair)tail).car;
    else
      throw new GenericError("List is too short.");
  }
}
