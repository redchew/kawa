package gnu.kawa.brl;
import gnu.mapping.*;
import kawa.standard.Scheme;
import gnu.lists.*;
import gnu.xml.*;
import gnu.expr.*;

public class BRL extends Scheme
{
  static BRL instance;
  static final Object emptyForm = new FString();

  public BRL ()
  {
    instance = this;
    ModuleBody.setMainPrintValues(true);
    Environment.setCurrent(getEnvironment());
    try
      {
	loadClass("gnu.brl.stringfun");
	loadClass("gnu.kawa.brl.progfun");
	loadClass("gnu.kawa.slib.HTTP");
      }
    catch (java.lang.ClassNotFoundException ex)
      {
	System.err.println("caught "+ex);
      }
  }

  public static Language getInstance(boolean brlCompatible)
  {
    if (instance == null)
      new BRL ();
    instance.setBrlCompatible(brlCompatible);
    return instance;
  }

  public static BRL getKrlInstance()
  {
    getInstance(false);
    return instance;    
  }

  public static BRL getBrlInstance()
  {
    getInstance(true);
    return instance;    
  }

  boolean brlCompatible = false;

  public boolean isBrlCompatible() { return brlCompatible; }
  public void setBrlCompatible(boolean compat) {  brlCompatible = compat; }

  public gnu.text.Lexer getLexer(InPort inp, gnu.text.SourceMessages messages)
  {
    Compilation.defaultCallConvention = Compilation.CALL_WITH_CONSUMER;
    BRLRead lexer = new BRLRead(inp, messages);
    lexer.setBrlCompatible(isBrlCompatible());
    return lexer;
  }

  public Consumer getOutputConsumer(java.io.Writer out)
  {
    if (isBrlCompatible())
      return super.getOutputConsumer(out);
    return new XMLPrinter(out, false);
  }

  /** The compiler insert calls to this method for applications and applets. */
  public static void registerEnvironment()
  {
    Language.setDefaults(new BRL());
  }

  public Expression makeBody(Expression[] exps)
  {
    if (isBrlCompatible())
      return super.makeBody(exps);
    return new ApplyExp(gnu.kawa.functions.AppendValues.appendValues, exps);
  }

  public Procedure getPrompter()
  {
    return new Prompter();
  }
}

class Prompter extends Procedure1
{
  public Object apply1 (Object arg)
  {
    InPort port = (InPort) arg;
    int line = port.getLineNumber() + 1;
    char state = port.readState;
    if (state == ']')
      return "<!--BRL:"+line+"-->";
    else
      {
	if (state == '\n')
	  state = '-';
	return "#|--BRL:"+line+state+"|#";
      }
  }
}
