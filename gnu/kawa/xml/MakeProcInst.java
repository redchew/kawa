// Copyright (c) 2004  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.kawa.xml;
import gnu.bytecode.*;
import gnu.mapping.*;
import gnu.expr.*;
import java.io.*;
import gnu.xml.*;
import gnu.lists.*;

public class MakeProcInst extends CpsProcedure // NodeConstructor
{
  public static final MakeProcInst makeProcInst
    = new MakeProcInst();

  public void apply (CallContext ctx)
  {
    Consumer saved = ctx.consumer;
    Object target = ctx.getNextArg();
    Object content = ctx.getNextArg();
    ctx.lastArg();
    XConsumer out = NodeConstructor.pushNodeContext(ctx);
    try
      {
	char[] chars = content.toString().toCharArray();
	
	out.writeProcessingInstruction(target.toString(),
					 chars, 0, chars.length);
      }
    finally
      {
	NodeConstructor.popNodeContext(saved, ctx);
      }
  }
}
