package gnu.kawa.functions;
import gnu.math.*;
import gnu.mapping.*;
import java.math.*;

/**
 * Implement the Scheme standard function "/".
 * @author Per Bothner
 */

public class DivideOp extends ArithOp
{
  /** Return one of FLOOR, CEILING, TRUNCATE, ROUND, or 0 if not applicable.
   * These are defined in gnu.math.Numeric.
   */
  public int getRoundingMode() { return rounding_mode; }
  int rounding_mode;

  public static final DivideOp SLASH = new DivideOp("/", DIVIDE_GENERIC);
  public static final DivideOp idiv = new DivideOp("idiv", QUOTIENT_EXACT);
  public static final DivideOp iceil = new DivideOp("iceil", QUOTIENT_EXACT);
  public static final DivideOp floorQuotient = new DivideOp("floor-quotient", QUOTIENT);
  public static final DivideOp quotient = new DivideOp("quotient", QUOTIENT);
  public static final DivideOp remainder = new DivideOp("remainder", MODULO);
  public static final DivideOp modulo = new DivideOp("modulo", MODULO);
  public static final DivideOp div = new DivideOp("div", QUOTIENT);
  public static final DivideOp mod = new DivideOp("mod", MODULO);
  public static final DivideOp div0 = new DivideOp("div0", QUOTIENT);
  public static final DivideOp mod0 = new DivideOp("mod0", MODULO);
  static {
    idiv.rounding_mode = Numeric.TRUNCATE;
    iceil.rounding_mode = Numeric.CEILING;
    quotient.rounding_mode = Numeric.TRUNCATE;
    floorQuotient.rounding_mode = Numeric.FLOOR;
    remainder.rounding_mode = Numeric.TRUNCATE;
    modulo.rounding_mode = Numeric.FLOOR;
    div.rounding_mode = Numeric.NONNEG_MOD;
    mod.rounding_mode = Numeric.NONNEG_MOD;
    div0.rounding_mode = Numeric.ROUND;
    mod0.rounding_mode = Numeric.ROUND;
  }

  public DivideOp(String name, int op)
  {
    super(name, op);
    setProperty(Procedure.validateApplyKey,
                "gnu.kawa.functions.CompileArith:validateApplyArithOp");
    Procedure.compilerKey.set(this, "*gnu.kawa.functions.CompileArith:forDiv");
  }

  public Object applyN (Object[] args)
    throws Throwable
  {
    int len = args.length;
    if (len != 2) {
        if (len == 1 && op == DIVIDE_GENERIC)
            return apply2(IntNum.one(), args[0]);
        if (len == 0 || op != DIVIDE_GENERIC)
            throw new WrongArguments(this, len);
    }
    Object result = args[0];
    for (int i = 1; i < len; i++)
        result = apply2(result, args[i]);
    return result;
  }
    public Object apply2 (Object arg1, Object arg2) throws Throwable {
        Number result;
        int code1 = Arithmetic.classifyValue(arg1);
	int code2 = Arithmetic.classifyValue(arg2);
	int code = Arithmetic.leastSpecificCode(code1, code2);
        int scode = code;
        if (code < Arithmetic.INTNUM_CODE && code != Arithmetic.UNKNOWN_CODE)
          {
            switch (op)
              {
              case DIVIDE_GENERIC:
              case DIVIDE_INEXACT:
                scode = code = Arithmetic.INTNUM_CODE;
                break;
              default:
                  if (rounding_mode == Numeric.TRUNCATE
                      && code >= Arithmetic.INT_CODE
                      /* #ifdef JAVA8 */
                      && code <= Arithmetic.ULONG_CODE
                      /* #else */
                      // && code <= Arithmetic.LONG_CODE
                      /* #endif */
                      )
                  ; // handled specifically
                else
                  scode = Arithmetic.INTNUM_CODE;
                break;
              }
          }
        if (op == DIVIDE_INEXACT && code <= Arithmetic.REALNUM_CODE
                 && code != Arithmetic.UNKNOWN_CODE)
          {
            scode = Arithmetic.REALNUM_CODE;
            if (code != Arithmetic.DOUBLE_CODE && code != Arithmetic.FLOAT_CODE)
              code = Arithmetic.FLONUM_CODE;
          }
        else if (scode == Arithmetic.DOUBLE_CODE || scode ==  Arithmetic.FLOAT_CODE)
          {
            scode = Arithmetic.FLONUM_CODE;
            if (op == QUOTIENT_EXACT)
              code = scode;
          }
	switch (scode)
	  {
	  case Arithmetic.INT_CODE:
	    int i1 = Arithmetic.asInt(arg1);
	    int i2 = Arithmetic.asInt(arg2);
            switch (op)
              {
              case MODULO:
                i1 = i1 % i2;
                break;
              default:
                i1 = i1 / i2;
                break;
              }
	    result = Integer.valueOf(i1);
	    break;
	  case Arithmetic.UINT_CODE:
	  case Arithmetic.LONG_CODE:
	    long l1 = Arithmetic.asLong(arg1);
	    long l2 = Arithmetic.asLong(arg2);
            if (scode == Arithmetic.UINT_CODE)
              {
                l1 &= 0xffffffffl;
                l2 &= 0xffffffffl;
              }
            switch (op)
              {
              case MODULO:
                l1 = l1 % l2;
                break;
              default:
                l1 = l1 / l2;
                break;
              }
            if (scode == Arithmetic.UINT_CODE)
                result = UInt.valueOf((int) l1);
            else
                result = Long.valueOf(l1);
	    break;
          /* #ifdef JAVA8 */
          case Arithmetic.ULONG_CODE:
            l1 = Arithmetic.asLong(arg1);
            l2 = Arithmetic.asLong(arg2);
            switch (op)
              { // FIXME Hacker's Delight has better algorithms than jdk8
              case MODULO:
                l1 = Long.divideUnsigned(l1, l2);
                break;
              default:
                l1 = Long.remainderUnsigned(l1, l2);
                break;
              }
            result = ULong.valueOf(l1);
            break;
          /* #endif */
	  case Arithmetic.INTNUM_CODE:
            switch (op)
              {
              default:
              case QUOTIENT:
              case QUOTIENT_EXACT:
                result = IntNum.quotient(Arithmetic.asIntNum(arg1),
                                         Arithmetic.asIntNum(arg2),
                                         getRoundingMode());
                break;
              case MODULO:
                result = IntNum.remainder(Arithmetic.asIntNum(arg1),
                                          Arithmetic.asIntNum(arg2),
                                          getRoundingMode());
                break;
              case DIVIDE_GENERIC:
                result = RatNum.make(Arithmetic.asIntNum(arg1),
                                     Arithmetic.asIntNum(arg2));
                code = result instanceof IntNum ? Arithmetic.INTNUM_CODE
                  : Arithmetic.RATNUM_CODE;
                scode = code;
                break;
              }
	    break;
          /* #ifdef JAVA5 */
	  case Arithmetic.BIGDECIMAL_CODE:
	    BigDecimal bd1 = Arithmetic.asBigDecimal(arg1);
	    BigDecimal bd2 = Arithmetic.asBigDecimal(arg2);
            int mprec = 0; // ???
            RoundingMode mround;
            switch (getRoundingMode())
              {
              case Numeric.FLOOR:
                mround = RoundingMode.FLOOR;
                break;
              case Numeric.CEILING:
                mround = RoundingMode.CEILING;
                break;
              case Numeric.TRUNCATE:
                mround = RoundingMode.DOWN;
                break;
              case Numeric.NONNEG_MOD:
                mround = bd2.signum() < 0 ? RoundingMode.CEILING : RoundingMode.FLOOR;
              default:  /* case ROUND: */
                mround = RoundingMode.HALF_EVEN;
                break;
              }
            MathContext mcontext = new MathContext(mprec, mround);
            switch (op)
              {
              default:
              case DIVIDE_GENERIC:
                result = bd1.divide(bd2);
                break;
              case QUOTIENT:
                result = bd1.divideToIntegralValue(bd2, mcontext);
                break;
              case QUOTIENT_EXACT:
                result = bd1.divideToIntegralValue(bd2, mcontext)
                  .toBigInteger();
                code = scode = Arithmetic.BIGINTEGER_CODE;
                break;
              case MODULO:
                result = bd1.remainder(bd2, mcontext);
                break;
              }
	    break;
          /* #endif */
	  case Arithmetic.FLONUM_CODE:
	    double d1 = Arithmetic.asDouble(arg1);
	    double d2 = Arithmetic.asDouble(arg2);
            switch (op)
              {
              default:
              case DIVIDE_GENERIC:
              case DIVIDE_INEXACT:
                result = DFloNum.valueOf(d1 / d2);
                break;
              case QUOTIENT:
                result = RealNum.toInt(d1 / d2, getRoundingMode());
                break;
              case QUOTIENT_EXACT:
                result = RealNum.toExactInt(d1 / d2, getRoundingMode());
                code = scode = Arithmetic.INTNUM_CODE;
                break;
              case MODULO:
                if (d2 != 0)
                  d1 = d1 - RealNum.toInt(d1 / d2, getRoundingMode()) * d2;
                result = DFloNum.valueOf(d1);
                break;
              }
	    break;
	  case Arithmetic.REALNUM_CODE:
	  default:
            Numeric num1 = Arithmetic.asNumeric(arg1);
            Numeric num2 = Arithmetic.asNumeric(arg2);
            if (op == MODULO && num2.isZero())
              return num2.isExact() ? num1 : num1.toInexact();
            Numeric numr = num1.div(num2);
            if (op == MODULO)
              numr = num1.sub(((RealNum) numr).toInt(getRoundingMode()).mul(num2));
            switch (op)
              {
              case QUOTIENT_EXACT:
                result = ((RealNum) numr).toExactInt(rounding_mode);
                scode = code = Arithmetic.INTNUM_CODE;
                break;
              case QUOTIENT:
                result = ((RealNum) numr).toInt(rounding_mode);
                break;
              case DIVIDE_INEXACT:
                result = numr.toInexact();
                break;
              default:
                result = numr;
              }
	  }
        if (code != scode)
          {
            switch (code)
              {
              case Arithmetic.INT_CODE:
                result = Integer.valueOf(result.intValue());
                break;
               case Arithmetic.UINT_CODE:
                result = UInt.valueOf(result.intValue());
                break;
              case Arithmetic.LONG_CODE:
                result = Long.valueOf(result.longValue());
                break;
              case Arithmetic.ULONG_CODE:
                result = ULong.valueOf(result.longValue());
                break;
              case Arithmetic.FLOAT_CODE:
                result = Float.valueOf(result.floatValue());
                break;
              case Arithmetic.DOUBLE_CODE:
                result = Double.valueOf(result.doubleValue());
                break;
              case Arithmetic.BIGINTEGER_CODE:
                result = Arithmetic.asBigInteger(result);
              }
          }
    return result;
   }

  public int numArgs()
  {
    return op == DIVIDE_GENERIC ? 0xfffff001 : 0x2002;
  }
}
