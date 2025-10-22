
# Culc
Simple autocomplete inline c-styled calculator powered by AutoHotKey2.

# How to do *meth*?
Just start script (or make it autostart) and type `!!`, then you can type your expression after `=`, which indicates you enter calculation mode, and press `Enter`:
```
!!  →  =2 + Sin(2) * 2  →  6
```

## Engines
For first version implemented two math engines:

1. *PowerShell* (CSharp Math Runtime) — default
2. *Com Javascript* (Native Javascript for Windows)

So, when you type expression, you type it like if you type it directly for this engine. Also it means, that changing engine — changing expression style. 

**BUT** default `shell` engine improved by excluding `[math]::` to access CSharp math methods like `Abs()`

## Limitations

> [!IMPORTANT]
> Due AHK limitations (or my laziness), calculator can behave a bit buggy. 

You **CAN**:
- use `Left` and `Right` arrows to move cursor bounded by expression size
- use `Backspace` and `Delete` to remove symbols, **BUT be careful**

You **CAN NOT**:
- do any copy/paste actions
- use more keys to move cursor
- *and other text editing stuff*

**This project IS NOT intended to replace other calculators, only make your life a bit easier, when you lazy to open them and want to calculate small stuff** 
