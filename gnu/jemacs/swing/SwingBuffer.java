// Copyright (c) 2002  Per M.A. Bothner.
// This is free software;  for terms and warranty disclaimer see ./COPYING.

package gnu.jemacs.swing;
import java.io.*;
import gnu.jemacs.buffer.*;
import gnu.mapping.*;
import javax.swing.text.*;
import java.awt.Color;

/** An Emacs buffer implemented using the Swing toolkits. */

public class SwingBuffer extends Buffer
{
  public DefaultStyledDocument doc;

  public Caret curPosition = null;

  public BufferContent content;
  public StyledDocument modelineDocument;

  public static javax.swing.text.StyleContext styles
  = new javax.swing.text.StyleContext();
  static public Style defaultStyle = styles.addStyle("default",null);
  public Style inputStyle = defaultStyle;
  public static Style redStyle = styles.addStyle("red", null);
  static Style blueStyle = styles.addStyle("blue", null);
  static
  {
    String version = System.getProperty("java.version");
    if (version != null
	&& (version.startsWith("1.2") || version.startsWith("1.3")))
      {
	StyleConstants.setFontFamily(defaultStyle, "Lucida Sans TypeWriter");
	StyleConstants.setFontSize(defaultStyle, 14);
      }
    StyleConstants.setForeground(redStyle, Color.red);
    StyleConstants.setForeground(blueStyle, Color.blue);
  }

  public SwingBuffer(String name)
  {
    this(name, new BufferContent());
  }

  public SwingBuffer(String name, BufferContent content)
  {
    super(name);
    doc = new DefaultStyledDocument(content, styles);
    this.content = content;

    pointMarker = new Marker(this, 0, true);
    markMarker = new Marker();

    modelineDocument
      = new javax.swing.text.DefaultStyledDocument(new javax.swing.text.StringContent(), styles);
    // Needed for proper bidi (bi-directional text) handling.
    // Does cause extra overhead, so should perhaps not be default.
    // Instead only set it if we insert Hebrew/Arabic text?  FIXME.
    doc.putProperty("i18n", Boolean.TRUE);
    redrawModeline();
  }

  public void removeRegion (int start, int end)
    throws javax.swing.text.BadLocationException
  {
    doc.remove(start, end - start);
  }

  public void removeAll ()
  {
    try
      {
	doc.remove(0, maxDot());
      }
    catch (javax.swing.text.BadLocationException ex)
      {
	throw new gnu.mapping.WrappedException(ex);
      }
  }

  public void removeChar (int count)
  {
    remove(getDot(), count);
  }

  void remove (int point, int count)
  {
    try
      {
        if (count < 0)
          {
            count = - count;
	    if (point - count < minDot())
	      Signal.signal("Beginning of buffer");
            point -= count;
          }
	else
	  {
	    if (point + count > maxDot())
	      Signal.signal("End of buffer");
	  }
        doc.remove(point, count);

	// Should not be needed, but seems to be.  Otherwise, getDot()
	// returns its *old* value, which is `count' characters too high.
	// The problem seesm to be that Swing does not properly update
	// a Windows's caret position when the underlying Document has text
	// removed.  Unfortunately, this fix probably won't do the right
	// thing for *other windows* that reference the same buffer.  FIXME.
	// (Strangely, the correct thing seems to happen for insertions.)
	setDot(point);
      }
    catch (javax.swing.text.BadLocationException ex)
      {
        throw new Error("bad location: "+ex);
      }
    //doc.remove(index, count);
  }

  public void remove(int ipos, Object xpos, int count)
  {
    remove(nextIndex(ipos, xpos), count);
  }

  public void save(Writer out)
    throws Exception
  {
    int length = getLength();
    int todo = length;
    Segment segment = new Segment();
    int offset = 0;
    while (offset < length)
      {
        int count = length;
        if (count > 4096)
          count = 4096;
        doc.getText(offset, count, segment);
        out.write(segment.array, segment.offset, segment.count);
        offset += count;
      }
  }

  public void insert (char ch, int count)
  {
    pointMarker.insert(ch, count, inputStyle);
  }

  public void insert (int index, String string, Object style)
  {
    if (style == null)
      style = defaultStyle;
    try
      {
        doc.insertString(index, string, (Style) style);
      }
    catch (javax.swing.text.BadLocationException ex)
      {
        throw new Error("bad location: "+ex);
      }
  }

  public void insert (String string, Object style)
  {
    insert(getDot(), string ,style);
  }

  public void insert (String string, Object style, int ipos, Object xpos)
  {
    insert (nextIndex(ipos, xpos), string, style);
  }

  public void insertFile(Reader in)
    throws Exception
  {
    char[] buffer = new char[2048];
    int offset = getDot();
    for (;;)
      {
        int count = in.read(buffer, 0, buffer.length);
        if (count <= 0)
          break;
        doc.insertString(offset, new String(buffer, 0, count), null);
        offset += count;
      }
  }

  public void redrawModeline ()
  {
    try
      {
        modelineDocument.remove(0, modelineDocument.getLength());
        
        modelineDocument.insertString(0, "-----", redStyle);
        modelineDocument.insertString(modelineDocument.getLength(),
                                      "JEmacs: " + getName(),
                                      blueStyle);
        modelineDocument.insertString(modelineDocument.getLength(),
                                      " ---",
                                      redStyle);
      }
    catch (javax.swing.text.BadLocationException ex)
      {
        throw new Error("internal error in redraw-modeline- "+ex);
      }
  }

  public long scan(char target, int start, int end,
		   int count, boolean allowQuit)
  {
    if (end == 0)
      end = count > 0 ? content.length() - 1 : 0;
    return content.scan(target, start, end, count, allowQuit);
  }

  public int lineStartOffset(int offset)
  {
    return (int) content.scan('\n', offset, minDot(), -1, true);
  }

  public int getDot()
  {
    if (pointMarker.sequence == null)
      return curPosition.getDot();
    else
      return pointMarker.getOffset();
  }

  public void setDot(int i)
  {
    if (i > maxDot())
      throw new Error("set dot to "+i+ " max:"+maxDot());
    if (pointMarker.sequence == null)
      curPosition.setDot(i);
    else
      pointMarker.set(this, i);
  }

  public int maxDot()
  {
    // Subtract 1 for the content's final "\n".
    return content.length() - 1;
  }

  public int getLength()
  {
    return doc.getLength();
  }

  public char charAt(int index)
  {
    return content.charAt(index);
  }

  public void setCharAt(int index, char ch)
  {
    content.setCharAt(index, ch);
  }

  public void fill(char value)
  {
    content.fill(value);
  }

  public void fill(int fromIndex, int toIndex, char value)
  {
    content.fill(fromIndex, toIndex, value);
  }

  public void getChars (int srcBegin, int srcEnd, char[] dst, int dstBegin)
  {
    content.getChars(srcBegin, srcEnd, dst, dstBegin);
  }

  public void writeTo(int start, int count, java.io.Writer dest)
    throws java.io.IOException
  {
    content.writeTo(start, count, dest);
  }

  public void consume(int start, int count, gnu.lists.Consumer out)
  {
    content.consume(start, count, out);
  }

  public int createPosition(int index, boolean isAfter)
  {
    return content.createPosition(index, isAfter);
  }

  public Object get (int index)
  {
    return content.get(index);
  }

  public int size ()
  {
    return content.size();
  }

  public int nextIndex(int ipos, Object xpos)
  {
    return content.nextIndex(ipos, xpos);
  }

  public long savePointMark ()
  {
    int pointPosition = content.createPosition(getDot(), false);
    int markPosition = 0;  // FIXME
    return ((long) markPosition) << 32 | ((long) pointPosition & 0xffffffffl);
  }

  public void restorePointMark (long pointMark)
  {
    int pointPosition = (int) pointMark;
    int markPosition = (int) (pointMark >> 32);
    setDot(content.nextIndex(pointPosition, null));
    content.releasePosition(pointPosition, null);
    // Restore mark - FIXME
    // content.releasePosition(markPosition);
  }

  public InPort openReader (int start, int count)
  {
    return new BufferReader(this, start, count);
  }


}
