// Copyright (c) 2001  Per M.A. Bothner and Brainfood Inc.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.xml;
import gnu.lists.*;
import java.io.*;

/** Print an event stream in XML format on a PrintWriter. */

public class XMLPrinter extends PrintConsumer implements PositionConsumer
{
  boolean inAttribute = false;
  boolean inStartTag = false;
  boolean canonicalize = true;
  boolean htmlCompat = true;
  public boolean escapeText = true;
  boolean isHtml = false;
  Object style;

  /* If prev==WORD, last output was a number or similar. */
  private static final int WORD = -2;
  int prev = ' ';

  public XMLPrinter (Writer out, boolean autoFlush)
  {
    super(out, autoFlush);
  }

  public XMLPrinter (Writer out)
  {
    super(out);
  }

  public XMLPrinter (Consumer out)
  {
    super(out, false);
  }

  public static XMLPrinter make(Consumer out, Object style)
  {
    XMLPrinter xout = new XMLPrinter(out);
    xout.style = style;
    if ("html".equals(style))
      {
	xout.isHtml = true;
	xout.htmlCompat = true;
      }
    if ("xhtml".equals(style))
      xout.htmlCompat = true;
    if ("plain".equals(style))
      xout.escapeText = false;
    return xout;
  }

  protected static final boolean isWordChar(char ch)
  {
    return Character.isJavaIdentifierPart(ch) || ch == '-' || ch == '+';
  }

  private final void writeRaw(String str)
    // Can probably just use write(str).  FIXME
  {
    try
      {
	out.write(str);
      }
    catch (java.io.IOException ex)
      {
	throw new RuntimeException(ex.toString());
      }
  }

  private final void writeRaw(int c)
  {
    try
      {
	out.write(c);
      }
    catch (java.io.IOException ex)
      {
	throw new RuntimeException(ex.toString());
      }
  }

  private final void writeRaw(char[] buf, int off, int len)
  {
    try
      {
	out.write(buf, off, len);
      }
    catch (java.io.IOException ex)
      {
	throw new RuntimeException(ex.toString());
      }
  }

  public void writeChar(int v)
  {
    closeTag();
    if (prev == WORD)
      {
	if (isWordChar((char) v))
	  writeRaw(' ');
      }
    // if (v >= 0x10000) emit surrogtes FIXME;
    if (! escapeText)
      writeRaw((char) v);
    else if (v == '<' && ! (isHtml && inAttribute))
      writeRaw("&lt;");
    else if (v == '>')
      writeRaw("&gt;");
    else if (v == '&')
      writeRaw("&amp;");
    else if (v == '\"' && inAttribute)
      writeRaw("&quot;");
    else if (v >= 127)
      writeRaw("&#"+v+";");
    else
      writeRaw((char) v);
    prev = v;
  }

  private void startWord()
  {
    closeTag();
    if (prev == WORD || isWordChar((char) prev))
      writeRaw(' ');
    prev = WORD;
  }

  public void writeBoolean(boolean v)
  {
    startWord();
    super.print(v);
  }

  private void closeTag()
  {
    if (inStartTag && ! inAttribute)
      {
	writeRaw('>');
	inStartTag = false;
	prev = '>';
      }
  }

  protected void startNumber()
  {
    startWord();
  }

  public void beginGroup(String typeName, Object type)
  {
    closeTag();
    writeRaw('<');
    writeRaw(typeName);
    inStartTag = true;
    if (isHtml
	&& ("script".equals(typeName) || "style".equals(typeName)))
      escapeText = false;
  }

  static final String HtmlEmptyTags
  = "/area/base/basefont/br/col/frame/hr/img/input/isindex/link/meta/para/";

  public static boolean isHtmlEmptyElementTag(String name)
  {
    int index = HtmlEmptyTags.indexOf(name);
    return index > 0 && HtmlEmptyTags.charAt(index-1) == '/'
      && HtmlEmptyTags.charAt(index+name.length()) == '/';
  }

  public void endGroup(String typeName)
  {
    if (canonicalize && ! htmlCompat)
      closeTag();
    if (inStartTag)
      {
	writeRaw(isHtml
		 ? (isHtmlEmptyElementTag(typeName) ? ">" : "></"+typeName+">")
		 : (htmlCompat ? " />" : "/>"));
	inStartTag = false;
      }
    else
      {
	writeRaw("</");
	writeRaw(typeName);
	writeRaw(">");
      }
    prev = '>';
    if (isHtml && ! escapeText
	&& ("script".equals(typeName) || "style".equals(typeName)))
      escapeText = true;
  }

  /** Write a attribute for the current group.
   * This is only allowed immediately after a beginGroup. */
  public void beginAttribute(String attrName, Object attrType)
  {
    if (inAttribute)
      writeRaw('"');
    inAttribute = true;
    writeRaw(' ');
    writeRaw(attrName);
    writeRaw("=\"");
    prev = ' ';
  }

  public void endAttribute()
  {
    writeRaw('"');
    inAttribute = false;
    prev = ' ';
  }

  public void writeObject(Object v)
  {
    closeTag();
    if (v instanceof UnescapedData)
      {
	writeRaw(((UnescapedData) v).getData());
      }
    else if (v instanceof Consumable)
      ((Consumable) v).consume(this);
    else if (v instanceof SeqPosition)
      {
	SeqPosition pos = (SeqPosition) v;
	pos.sequence.consumeNext(pos.ipos, pos.xpos, this);
      }
    else if (v instanceof String || v instanceof CharSeq)
      {
	writeChars(v.toString());
      }
    else
      {
	startWord();
	prev = ' ';
	writeChars(v == null ? "(null)" : v.toString());
	prev = WORD;
      }
  }

  /** Write each element of a sequence, which can be an array,
   * a Sequence or a Consumable. */
  //public void writeAll(Object sequence);

  /** True if consumer is ignoring rest of group.
   * The producer can use this information to skip ahead. */
  public boolean ignoring()
  {
    return false;
  }

  public void writeChars(String str)
  {
    closeTag();
    int len = str.length();
    for (int i = 0;  i < len;  i++)
      writeChar(str.charAt(i));
  }

  //public void writeChars(AbstractString str);

  public void write(char[] buf, int off, int len)
  {
    closeTag();
    if (len <= 0)
      return;
    int ch = prev;
    char c;
    if (prev == WORD)
      {
	c = buf[off++];
	writeChar(c);
	ch = c;
	len--;
      }
    int limit = off + len;
    int count = 0;
    while (off < limit)
      {
	c = buf[off++];
	ch = c;
	if (ch >= 127 || ch == '<' || ch == '>'
	    || ch == '&' || (ch == '"' && inAttribute))
	  {
	    if (count > 0)
	      writeRaw(buf, off - 1 - count, count);
	    writeChar(c);
	    count = 0;
	  }
	else
	  count++;
      }
    if (count > 0)
      writeRaw(buf, limit - count, count);
  }

  public boolean writePosition(AbstractSequence seq, int ipos, Object xpos)
  {
    seq.consumeNext(ipos, xpos, this);
    return true;
  }

  public boolean consume(TreePosition position)
  {
    throw new Error("not implemented consume(TreePosition)");
  }
}
