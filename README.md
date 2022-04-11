# This project is forked from [a gist post](https://gist.github.com/ascendbruce/677c3169259c975259045f905cd889d6) made by [ascendbruce](https://gist.github.com/ascendbruce)

and is modified for Chinese language use.

The following README comes from the original post:

---

# Use macOS-style shortcuts in Windows / keyboard mappings using a Mac keyboard on Windows

**Make Windows PC's shortcut act like macOS (Mac OS X)** (using AutoHotkey (ahk) script)

With this AutoHotKey script, you can use most macOS style shortcuts (eg, cmd+c, cmd+v, ...) on Windows with a standard PC keyboard.

## How does it work

Here's some examples of how this script work:

| you want to press | what you're actually pressing | AutoHotKey tells Windows |
|-------------------|-------------------------------|--------------------------|
| cmd + c           | alt + c                       | ctrl + c                 |
| cmd + v           | alt + v                       | ctrl + v                 |
| cmd + r           | alt + r                       | F5                       |
| cmd + ↑           | alt + ↑                       | Home                     |
| cmd + shift + \[  | alt + shift + \[              | ctrl + shift + Tab       |
| ...               | ...                           | ...                      |


Note that:

1. **you shouldn't change the modifier keys mapping with keyboard DIP**. This script assumes you (1) use a PC keyboard on Mac and have swapped [cmd] and [option] keys via Mac system preferences (2) you are familiar with mac shortcuts in macs (3) you want to use the PC keyboard and mac-style shortcuts on PC.
2. To use `cmd + shift + ↑ / ↓ / ← / →` (select text between cursor and top / bottom / beginning of line / end of line), You should disable the `Between input languages` shotcut from `Control Panel\Clock, Language, and Region\Language\Advanced settings > Change lanugage bar hot keys` due to conflicting.
3. Some Windows built-in keyboard shortcuts will be overridden. For example: `win + ↑ / ↓ / ← / →` (snap window to side). Change `mac.ahk` accordingly if you prefer to keep the default behavior.

## To Run Once (until reboot)

1. Install https://www.autohotkey.com/
2. Copy and save the content of `mac.ahk` in a text file, named as `mac.ahk`
3. Double click on `mac.ahk` file

## Auto start after Windows startup

Complete the step of "To Run Once" section first.

Place `mac.ahk` file (or make a shortcut) at `C:\Users\<USERNAME>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup`