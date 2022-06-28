# LogLevel Attributes

By default the log-level is set to `LogLevel.Error` which means only `Log.E()` will be printed to the console at all.



You can override this by adding a log-attribute `[Log(LogLevel.X)]` to your class or method. The logger will output whichever level is lowest, between global, class or method.

```C#
// By adding this override, we say that this entire class should output warnings and above
[Log(LogLevel.Warning)]
public class MyClass : MonoBehaviour
{
    // Then we can also add this override to specify that this method should output info and above
    [Log(LogLevel.Info)]
    private void Awake()
    {
        Log.I("Log Method Attribute Awake"); // <- Will output because of the log-tag on this method
        Log.W("Log Method Attribute Awake"); // <- Will output because of the log-tag on this method
        Log.E("Log Method Attribute Awake"); // <- Will output because of the log-tag on this method
    }

    private void Start()
    {
        Log.I("Log Method Attribute Start"); // <- Will NOT be output
        Log.W("Log Method Attribute Start"); // <- Will output because of the log-tag on this class
        Log.E("Log Method Attribute Start"); // <- Will output because of the log-tag on this class
    }
}

public class MyOtherClass : MonoBehaviour
{
    private void Awake()
    {
        Log.I("Log Method Attribute Awake"); // <- Will NOT be output
        Log.W("Log Method Attribute Awake"); // <- Will NOT be output
        Log.E("Log Method Attribute Awake"); // <- Will output because of global-level
    }

    private void Start()
    {
        Log.I("Log Method Attribute Start"); // <- Will NOT be output
        Log.W("Log Method Attribute Start"); // <- Will NOT be output
        Log.E("Log Method Attribute Start"); // <- Will output because of global-level
    }
}

```

## Custom global log level

To set a custom GlobalLogLevel, you can do so through `Log.Initialize()` at the start of your app