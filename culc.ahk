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
#Hotstring EndChars `t `n`r

DEBUG := true

; VERSION 1
; Example: typing  !!2+2*2 -> 6
#HotIf true
:*?:!!::
{
    expr := ""
    ih := InputHook("L1", "{Space}{Enter}{Tab}")
    ih.Start()
    loop {
        ih.Wait()
        if (ih.EndReason = "EndKey" || ih.EndReason = "Stopped")
            break
        expr .= ih.Input
        SendText ih.Input
        ih.Start()
    }

    ; clean and check
    endKey := ih.EndKey
    expr := Trim(expr)
    if !expr {
        SendText "!!"
        return
    }

    ; math
    try {
        ; thanks to the guy from https://www.reddit.com/r/AutoHotkey/comments/150f5zv/need_help_with_a_script_to_do_simple_calculations/
        static shell := ComObject("WScript.Shell")
        exec := shell.Exec(A_AhkPath " /ErrorStdOut=UTF-8 *")
        exec.StdIn.Write("#NoTrayIcon`n#Warn All, Off`ntry FileAppend(" expr ", '*')")
        exec.StdIn.Close()
        out := exec.StdOut.ReadAll()
        result := (out = "" ? "[ERROR]" : out)
    } catch Error as e {
        if DEBUG {
            throw e
        } else {
            result := "[" e.Message " -> Line: " e.Line "]"
        }
    }

    ; send result
    Send("{Backspace " StrLen(expr) "}")
    SendText result
}
#HotIf
