package kawa.lang;
import gnu.bytecode.*;
import gnu.mapping.*;
import gnu.expr.*;

public class PrimArraySet extends Procedure3 implements Inlineable
{
  Type element_type;

  public PrimArraySet (Type element_type)
  {
    this.element_type = element_type;
  }

  public Object apply3 (Object array, Object index, Object value)
  {
    java.lang.reflect.Array.set(array,
				((Number) index).intValue(),
				element_type.coerceFromObject(value));
    return Interpreter.voidObject;
  }
  public void compile (ApplyExp exp, Compilation comp, Target target)
  {
    Expression[] args = exp.getArgs();
    args[0].compile(comp, new ArrayType(element_type));
    args[1].compile(comp, Type.int_type);
    args[2].compile(comp, element_type);
    comp.getCode().emitArrayStore(element_type);
    comp.compileConstant(Interpreter.voidObject, target);
  }
}
