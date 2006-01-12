package gnu.kawa.models;

/** Abstract class for Viewable objects, with notification/listener support. */

public abstract class Model implements Viewable
{
  transient WeakListener listeners;

  /*
  public abstract Object getProperty (Object key);

  public abstract void setProperty (Object key, Object value);
  */

  public void addListener (ModelListener listener)
  {
    listeners = new WeakListener(listener, listeners);
  }

  public void addListener (WeakListener listener)
  {
    listener.next = listeners;
    listeners = listener;
  }

  public void notifyListeners (String key)
  {
    WeakListener prev = null;
    WeakListener wlistener = listeners;
    while (wlistener != null)
      {
        Object listener = wlistener.get();
        WeakListener next = wlistener.next;
        if (listener == null)
          {
            if (prev != null)
              prev.next = next;
          }
        else
          {
            prev = wlistener;
            wlistener.update(listener, this, key);
          }
        wlistener = next;
      }
  }
}

class WeakListener extends java.lang.ref.WeakReference
{
  public WeakListener (Object referent)
  {
    super(referent);
  }

  public WeakListener (Object referent, WeakListener next)
  {
    super(referent);
    this.next = next;
  }
  WeakListener next;

  public void update (Object view, Model model, Object key)
  {
    ((ModelListener) view).modelUpdated(model, key);
  }
}
