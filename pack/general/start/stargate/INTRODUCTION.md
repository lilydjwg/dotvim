## The story

The year is 3001. You are the only crew member of a fully automated science
spaceship. Your only companion is advanced AI system VIM9000. The mission is to
find a powerful obelisk, that can be anywhere in all known galaxies, so for
fast traveling you are using technology called... STARGATES.

## Explained terminology of the source code

**Ship** - current cursor position.

**Galaxy** - window of vim, so all reachable galaxies are windows of the current
tabpage.

**Orbit** - a line of the buffer/window, so reachable are currently visible buffer
lines.

**Orbital arc** - visible columns of a line.

**Degree** - a column of a line (I'm not an expert, so not sure if it is even
correct term for an orbit).

**Black matter** - vim folds.

**Display** - current vim window without sign columns.

**Labels** - hints for windows and cursor jump positions.

**Destinations** - all possible cursor jumps for the char or a pattern.

**Workstation** - collection of utility functions.

**Star** - character on a line.

**Stargate** - a hint with the desired position, act of using a stargate is just
cursor jump to that hint.
