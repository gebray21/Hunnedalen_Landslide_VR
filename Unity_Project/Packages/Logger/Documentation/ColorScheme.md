# Color Scheme Tutorial
A color scheme can enhance your logger by miles. Do you want all your log messages to be pink by default? Or maybe you want all Warnings to be blue for some reason? Or do you wanna log a specifig log message in a custom color?

This is the place to learn how.

## Unity Console Logger Prefab
This is a prefab that ships with the package. If you drag it into your scene it will work out of the box. Just try using all log level in some other script:
```csharp
Log.I("heyoooo message");
Log.W("heyoooo warning");
Log.E("heyoooo error");
```

You will most likely see somehting like this:

![Console Output](Images/prefabOutput.PNG?raw=true "Console log output from Unity Console Logger Prefab.")

If we take a look at the prefab we can see that the colors set up in the Color Scheme matches the colors we observe in the console.

![Color Scheme Inspector](Images/prefabColorScheme.png?raw=true "Unity Console Logger color scheme.")

Now, if we want to log somehting with a specific color we can try logging these lines instead, and our provided color will override the color scheme:
```csharp
Log.I("heyoooo message", Color.white);
Log.W("heyoooo warning", Color.yellow);
Log.E("heyoooo error", Color.red);
```
![Specific Coloring](Images/specificColor.PNG?raw=true "Unity Console Logger color scheme.")

Isn't that great? But how can you make your own custom logger to do this, I hear you ask..


## Custom Logger with Color Scheme
To make your own Custom Logger you need to create a class that inherits from `LoggerBase`. The crucial thing here is that we need this CustomLogger's constructor to call `LoggerBase`'s constructor with a provided `ColorScheme` like this:

```csharp
public class OurCustomLogger : LoggerBase
{
    public OurCustomLogger(ColorScheme colorScheme) : base(colorScheme)
    {
        
    }
}
```

The `ColorScheme` is a `readonly struct` that has two constructors we can set our colors from.

Specify each induvidual color,
```csharp
public ColorScheme(Color classColor, Color methodColor, Color infoColor, Color warningColor, Color errorColor)
{
    ClassColor = classColor;
    MethodColor = methodColor;
    InfoColor = infoColor;
    WarningColor = warningColor;
    ErrorColor = errorColor;
}
```

or by a Template

```csharp
public ColorScheme(ColorSchemeTemplate template)
{
    ClassColor = template.classColor;
    MethodColor = template.methodColor;
    InfoColor = template.infoColor;
    WarningColor = template.warningColor;
    ErrorColor = template.errorColor;
}
```

In the case of the Unity Console Logger prefab, it is the `ColorSchemeTemplate` that is exposed in the editor, and it uses that to make a proper `ColorScheme` by constructing with the template. We can do the same to our custom Logger.

```csharp
ColorScheme colorScheme = new ColorScheme(serializedColorSchemTemplate);
OurCustomLogger ourCustomLogger = new OurCustomLogger(colorScheme);
```

Now, the last thing to do is to register our custom logger with the `Log` class
```csharp
Log.Initialize(ourCustomLogger);
```

To expand on your custom logger and learn how to combine it with other loggers, take a look at [Creating a Custom Logger](CustomLogger.md).