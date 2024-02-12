# Mario Bros

Analogue Pocket port of Mario Bros. 

## Features

* Dip switches for difficulty, starting lives, and bonuses.

## Known Issues

* High Score saving doesn't work.
* Tate mode isn't supported.
* Video occasionally loses sync for a couple of frames.

## Attribution

```
Arcade: Mario Bros port to MiSTer by [gaz68](https://github.com/gaz68) - June 2020  
Original Donkey Kong port to MiSTer by [Sorgelig](https://github.com/sorgelig) - 18 April 2018
```

### Sources

[dkong](https://web.archive.org/web/20190330043320/http://www.geocities.jp/kwhr0/hard/fz80.html)  Copyright (c) 2003 - 2004 by Katsumi Degawa  
[T80](https://opencores.org/projects/t80)   Copyright (c) 2001-2002 Daniel Wallner (jesus@opencores.org) All rights reserved  
[T48](https://opencores.org/projects/t48)   Copyright (c) 2004, Arnim Laeuger (arniml@opencores.org) All rights reserved  

-  Quartus template and core integration based on the Analogue Pocket port of [Donkey Kong by ericlewis](https://github.com/ericlewis/openFPGA-DonkeyKong)

## ROM Instructions

ROM files are not included, you must use [mra-tools-c](https://github.com/sebdel/mra-tools-c/) to convert to a singular `mario.rom` file, then place the ROM file in `/Assets/mario/common`.
