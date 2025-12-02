---
title: Vim
type: docs
prev: docs/Tools/
---

# Vim Cheat Sheet for CKA/CKAD (1-Page Printable)

## Navigation
- gg – Top of file
- G – Bottom of file
- 0 – Start of line
- $ – End of line
- w / b – Next/previous word
- :10 – Go to line 10

## Edit
- i / I – Insert at cursor / start of line
- a / A – Append at cursor / end of line
- o / O – New line below / above
- x – Delete character
- dw – Delete word
- d$ – Delete to end of line

## Copy, Cut, Paste
- yy – Copy line
- dd – Cut/delete line
- p / P – Paste below / above
- 3yy – Copy 3 lines
- 3dd – Cut 3 lines

## Undo/Redo
- u – Undo
- Ctrl+r – Redo

## Search
- /pattern – Search forward
- ?pattern – Search backward
- n / N – Next / previous match

## Indentation (Important for YAML)
- gg=G – Auto-indent entire file
- >> / << – Indent / unindent
- 3>> – Indent 3 lines
- Ctrl+v – Visual block mode
- = – Auto-align selected block

## Visual Modes
- v – Visual select
- V – Visual line select
- Ctrl+v – Visual block (best for YAML)

## Save & Exit
- :w – Save
- :q – Quit
- :wq – Save & quit
- :q! – Quit without saving

## Useful Exam Settings
:set nu
:set ai
:set ts=2
:set sw=2
:set expandtab

