---
title: Vim
type: docs
prev: docs/Tools/kafka
---

# Vim Cheat Sheet for CKA/CKAD 

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


# Vim Movement, Editing, and Sorting Cheat Sheet

## Moving Around

| Shortcut Key | Function |
|---|---|
| `]]` or `G` | Go to the last line |
| `[[` or `gg` | Go to the first line |
| `Ctrl + f` | Move cursor one page down |
| `Ctrl + b` | Move cursor one page up |
| `h` | Move cursor one character left |
| `j` or `Ctrl + j` | Move cursor down one line |
| `k` or `Ctrl + p` | Move cursor up one line |
| `l` | Move cursor one character right |
| `0` | Move to beginning of line |
| `$` | Move to end of line |
| `^` | Move to first non-empty character of line |
| `w` | Move forward one alphanumeric word |
| `W` | Move forward one whitespace-delimited word |
| `5w` | Move forward five words |
| `b` | Move backward one alphanumeric word |
| `B` | Move backward one whitespace-delimited word |
| `5b` | Move backward five words |

---

# Vim Search and Replace Examples

## Replace text from current line through next 5 lines

### Goal
Replace all occurrences of `This` with `That` from the current line through the next 5 lines.

```vim
:50
```

Move to line 50.

```vim
:.,+5s/this/That/i
```

### Explanation

| Part | Meaning |
|---|---|
| `.` | Current line |
| `+5` | Next 5 lines |
| `s` | Substitute |
| `i` | Ignore case |

---

# Commenting and Uncommenting Lines

## Comment lines 20–30

```vim
:20,30s/^/# /
```

### Explanation

| Part | Meaning |
|---|---|
| `20,30` | Lines 20 through 30 |
| `^` | Beginning of line |
| `# ` | Insert comment character |

---

## Uncomment lines 20–30

```vim
:20,30s/^# //
```

---

# Insert and Append Commands

| Command | Description |
|---|---|
| `o` | Insert new line below current line and enter Insert mode |
| `O` | Insert new line above current line and enter Insert mode |
| `a` | Append after cursor and enter Insert mode |
| `A` | Append at end of line and enter Insert mode |
| `s` | Delete current character and enter Insert mode |
| `C` | Delete from cursor to end of line and enter Insert mode |

---

# Delete Operations

| Command | Description |
|---|---|
| `d<left-arrow>` | Delete current and left character |
| `d<right-arrow>` | Delete current and right character |
| `d<up-arrow>` | Delete current and upper line |
| `d<down-arrow>` | Delete current and bottom line |
| `d$` | Delete from cursor to end of line |
| `d^` | Delete backward to first non-empty character |
| `d0` | Delete backward to beginning of line |
| `dw` | Delete from cursor to end of current word |
| `db` | Delete from cursor to beginning of current word |

---

# Copy (Yank) Operations

| Command | Description |
|---|---|
| `y$` | Copy from cursor to end of line |
| `y^` | Copy from cursor to beginning of line |
| `yw` | Copy to start of next word |
| `yiw` | Copy current word |

---

# Visual Mode Example

## Comment first 3 lines

### Steps

1. Go to top of file

```vim
gg
```

2. Enter Visual Line mode

```vim
Shift + V
```

3. Select first 3 lines

```vim
2j
```

4. Replace beginning of each selected line with `#`

```vim
:s/^/#/
```

---

# Sorting Text

## Reset all changes

```vim
:u0
```

---

## Sort entire file uniquely and ignore case

### Steps

1. Go to top of file

```vim
gg
```

2. Enter Visual Line mode

```vim
Shift + V
```

3. Select entire file

```vim
G
```

4. Sort uniquely and ignore case

```vim
:sort ui
```

### Explanation

| Option | Meaning |
|---|---|
| `u` | Unique lines only |
| `i` | Ignore case while sorting |

---