;===================================================================================;
; MIT License                                                                       ;
;                                                                                   ;
; Copyright (c) 2025 imKokoT                                                        ;
;                                                                                   ;
; Permission is hereby granted, free of charge, to any person obtaining a copy      ;
; of this software and associated documentation files (the "Software"), to deal     ;
; in the Software without restriction, including without limitation the rights      ;
; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell         ;
; copies of the Software, and to permit persons to whom the Software is             ;
; furnished to do so, subject to the following conditions:                          ;
;                                                                                   ;
; The above copyright notice and this permission notice shall be included in all    ;
; copies or substantial portions of the Software.                                   ;
;                                                                                   ;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR        ;
; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,          ;
; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE       ;
; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER            ;
; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,     ;
; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE     ;
; SOFTWARE.                                                                         ;
;===================================================================================;

#Requires AutoHotkey v2.0
#SingleInstance Force
#Hotstring EndChars `n`r

; VERSION 1
; Example: typing  !!2+2*2 -> 6
; --- Settings -----------------
DEBUG := false
ENGINE := 'shell' ; Math Engine; supports: shell, msjs


shellEval(expr) {
    ; thanks to the guy from https://www.reddit.com/r/AutoHotkey/comments/150f5zv/need_help_with_a_script_to_do_simple_calculations/
    static shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_AhkPath " /ErrorStdOut=UTF-8 *")
    exec.StdIn.Write("#NoTrayIcon`n#Warn All, Off`ntry FileAppend(" expr ", '*')")
    exec.StdIn.Close()
    out := exec.StdOut.ReadAll()
    
    if out = "" 
        MsgBox("expr '" expr "' eval failed!`n`n" exec.StdErr.ReadAll(), "ERROR")
    return (out = "" ? "[ERROR]" : out)
}

msJsEval(expr) {
    static js := (
        sc := ComObject("ScriptControl"),
        sc.Language := "JScript",
        sc.ExecuteStatement("
            (
            var sin = Math.sin;
            var cos = Math.cos;
            var tan = Math.tan;
            var pow = Math.pow;
            var sqrt = Math.sqrt;
            var abs = Math.abs;
            var log = Math.log;
            var exp = Math.exp;
            var PI = Math.PI;
            var E = Math.E;
            )"
        ),
        sc
    )
    try 
        result := js.Eval(expr)
    catch Error as e{
        MsgBox("expr '" expr "' eval failed!`n`n" e.Message "`n" e.Extra, "ERROR")
        result := "[Error]"
    }
    return result
}

#HotIf true
:*?:!!::
{
    expr := ""
    SendText '='

    ; hook expression
    ih := InputHook("L1", "{Enter}{Left}{Right}{Backspace}{Delete}")
    ih.VisibleText := false
    caret := 0
    expr := ""

    outer:
    loop {
        ih.Start()
        ih.Wait()
        key := ih.EndKey
        ch := ih.Input
    
        switch key {
            case "Left":
                if caret - 1 < 0 {
                    Send('{Right}')
                }
                caret := Max(0, caret - 1)
            case "Right":
                if caret + 1 > StrLen(expr) {
                    Send('{Left}')
                }
                caret := Min(StrLen(expr), caret + 1)
            case "Backspace":
                if caret > 0 {
                    expr := SubStr(expr, 1, caret - 1) . SubStr(expr, caret + 1)
                    caret--
                }
            case "Delete":
                if caret < StrLen(expr) {
                    expr := SubStr(expr, 1, caret) . SubStr(expr, caret + 2)
                }
            case "Enter":
                break outer
            ; typed character
            default:
                expr := SubStr(expr, 1, caret) . ch . SubStr(expr, caret + 1)
                caret++
                SendText ch
                
                if ch = '('{
                    ch := ')'
                    expr := SubStr(expr, 1, caret) . ch . SubStr(expr, caret + 1)
                    SendText ch
                    Send '{Left}'
                }

        }
    }
    Send("{Right " StrLen(expr) - caret "}")
  
    if !expr {
        SendText "`b!!"
        return
    }

    ; math
    try {
        if (ENGINE == 'shell'){
            result := shellEval(expr)
        } 
        else if (ENGINE == 'msjs'){
            result := msJsEval(expr)
        } else {
            result := '[ERROR: unsupported engine "' ENGINE '"]'
        }
    } catch Error as e {
        if DEBUG {
            throw e
        } else {
            result := "[" e.Message " -> Line: " e.Line "]"
        }
    }

    ; send result
    Send("{Backspace " StrLen(expr)+1 "}")
    SendText result
}
#HotIf
