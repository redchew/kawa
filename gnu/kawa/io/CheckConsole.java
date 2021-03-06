package gnu.kawa.io;

import gnu.lists.Consumer;
import gnu.mapping.ThreadLocation;
import gnu.text.Options;
import gnu.lists.PrintConsumer;

/** Helper class to decide if we have an interactive console.
 * This needs to be separate from InPort, since the latter uses haveConsole
 * in its static constructor, but we may need to call setHaveConsole first.
 */

public class CheckConsole {

    /** Have --console or --non-console been specified?
     * The value of haveConsole is initially 0;
     * it is 1 if {@code --console} was specified on the command line;
     * it is -1 if {@code --no-console} was specified on the command line.
     */
    private static int haveConsole;

    public static void setHaveConsole(boolean value) {
        haveConsole = value ? 1 : -1;
        setDomTermVersionInfo();
    }

    public static boolean haveConsole() {
        if (haveConsole > 0)
            return true;
        if (haveConsole < 0)
            return false;
        /* #ifdef JAVA6 */
        return System.console() != null;
        /* #else */
        // return true;
        /* #endif */
    }

    public static final ThreadLocation<String> prompt1
        = new ThreadLocation<String>("prompt1");

    public static final ThreadLocation<String> prompt2
        = new ThreadLocation<String>("prompt2");

    public static final ThreadLocation useJLine
        = new ThreadLocation("use-jline");

    public static final ThreadLocation useJLineMouse
        = new ThreadLocation("jline-mouse");

    public static String consoleTypeDefault = "google-chrome;browser;javafx;swing;console";
    public static final ThreadLocation consoleType
        = new ThreadLocation("type");

    public static int useJLine() { return getBoolean(useJLine); }
    public static int useJLineMouse() { return getBoolean(useJLineMouse); }

    public static String consoleType() {
         Object val = consoleType.get(null);
         return val == null ? consoleTypeDefault : val.toString();
    }

    private static int getBoolean(ThreadLocation loc) {
        Object val = loc.get(null);
        if (val == null)
            return 0;
        String sval = val.toString();
        Boolean bval = Options.booleanValue(val.toString());
        return bval == null ? 0 :
            bval.booleanValue() ? 1 : -1;
    }

    /** Check if parameter is a DomTerm console. */
    public static boolean forDomTerm(Consumer out) {
        return out instanceof PrintConsumer
            && ((PrintConsumer) out).isDomTerm();
    }

    /** Check if parameter is a DomTerm console. */
    public static boolean forDomTerm(Appendable out) {
        if (out instanceof OutPort)
            return ((OutPort) out).isDomTerm();
        if (out instanceof TermErrorStream)
            return ((TermErrorStream) out).isDomTerm();
        return false;
    }

    /** Return DomTerm version info, or null if not running under DomTerm.
     * The version info is found from either the "org.domterm" property,
     * or the DOMTERM environment variable, tried in that order.
     */
    public static String getDomTermVersionInfo() {
        return versionInfoDomTerm;
    }

    private static void setDomTermVersionInfo() {
        String version = domtermProperty;
        if (version == null && haveConsole())
            version = domtermEnv;
        if (version != null) {
            version = version.trim();
            if (version.length() > 0)
                versionInfoDomTerm = version;
        }
    }

    static String domtermProperty;
    static String domtermEnv;
    static String versionInfoDomTerm;
    static {
        try {
            domtermProperty = System.getProperty("org.domterm");
            domtermEnv = System.getenv("DOMTERM");
            setDomTermVersionInfo();
        } catch (Throwable ex) {
            // ignore
        }
    }
}
