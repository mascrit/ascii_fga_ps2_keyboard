# ascii_fga_ps2_keyboard

## Asignación de Pines

| PIN | Funcion                     | Dirección          | Descripción    |
|-----|-----------------------------|--------------------|----------------|
| 1   | Datos                       | :left_right_arrow: | Llave de datos |
| 2   | N/C o Datos para ps/2 Dual  | -                  | No se conecta  |
| 3   | GND                         | :arrow_down_small: | GND            |
| 4   | Vcc 5V+                     | :arrow_right:      | Vcc            |
| 5   | Reloj                       | :arrow_left:       | Reloj          |
| 6   | N/C o Reloj2 para ps/2 dual | -                  | No se conecta  |

![Asignación de pines en GPIO](./assets/img/gpioAss.jpg "Asignación de Pines PS/2 a GPIO ")

## make/breake code

| Tecla     | Make code               | Break code        |
|:----------|:------------------------|:------------------|
| F8        | 0A                      | F0,0A             |
| F6        | 0B                      | F0,0B             |
| F4        | 0C                      | F0,0C             |
| TAB       | 0D                      | F0,0D             |
| `         | 0E                      | F0,0E             |
| F9        | 1                       | F0,01             |
| Z         | 1A                      | F0,1A             |
| S         | 1B                      | F0,1B             |
| A         | 1C                      | F0,1C             |
| W         | 1D                      | F0,1D             |
| 2         | 1E                      | F0,1E             |
| V         | 2A                      | F0,2A             |
| F         | 2B                      | F0,2B             |
| T         | 2C                      | F0,2C             |
| R         | 2D                      | F0,2D             |
| 5         | 2E                      | F0,2E             |
| F5        | 3                       | F0,03             |
| M         | 3A                      | F0,3A             |
| J         | 3B                      | F0,3B             |
| U         | 3C                      | F0,3C             |
| 7         | 3D                      | F0,3D             |
| 8         | 3E                      | F0,3E             |
| F3        | 4                       | F0,04             |
| /         | 4A                      | F0,4A             |
| L         | 4B                      | F0,4B             |
| ;         | 4C                      | F0,4C             |
| P         | 4D                      | F0,4D             |
| F1        | 5                       | F0,05             |
| ENTER     | 5A                      | F0,5A             |
| ]         | 5B                      | F0,5B             |
| \|5D      | F0,5D                   |                   |
| F2        | 6                       | F0,06             |
| KP 4      | 6B                      | F0,6B             |
| KP 7      | 6C                      | F0,6C             |
| F12       | 7                       | F0,07             |
| KP 3      | 7A                      | F0,7A             |
| KP -      | 7B                      | F0,7B             |
| KP *      | 7C                      | F0,7C             |
| KP 9      | 7D                      | F0,7D             |
| SCROLL    | 7E                      | F0,7E             |
| F10       | 9                       | F0,09             |
| L ALT     | 11                      | F0,11             |
| L SHFT    | 12                      | FO,12             |
| L CTRL    | 14                      | FO,14             |
| Q         | 15                      | F0,15             |
| 1         | 16                      | F0,16             |
| C         | 21                      | F0,21             |
| X         | 22                      | F0,22             |
| D         | 23                      | F0,23             |
| E         | 24                      | F0,24             |
| 4         | 25                      | F0,25             |
| 3         | 26                      | F0,26             |
| SPACE     | 29                      | F0,29             |
| N         | 31                      | F0,31             |
| B         | 32                      | F0,32             |
| H         | 33                      | F0,33             |
| G         | 34                      | F0,34             |
| Y         | 35                      | F0,35             |
| 6         | 36                      | F0,36             |
| ,         | 41                      | F0,41             |
| K         | 42                      | F0,42             |
| I         | 43                      | F0,43             |
| O         | 44                      | F0,44             |
| 0         | 45                      | F0,45             |
| 9         | 46                      | F0,46             |
| .         | 49                      | F0,49             |
| '         | 52                      | F0,52             |
| [         | 54                      | FO,54             |
| =         | 55                      | FO,55             |
| CAPS      | 58                      | F0,58             |
| R SHFT    | 59                      | F0,59             |
| BKSP      | 66                      | F0,66             |
| KP 1      | 69                      | F0,69             |
| KP 0      | 70                      | F0,70             |
| KP .      | 71                      | F0,71             |
| KP 2      | 72                      | F0,72             |
| KP 5      | 73                      | F0,73             |
| KP 6      | 74                      | F0,74             |
| KP 8      | 75                      | F0,75             |
| ESC       | 76                      | F0,76             |
| NUM       | 77                      | F0,77             |
| F11       | 78                      | F0,78             |
| KP +      | 79                      | F0,79             |
| F7        | 83                      | F0,83             |
| L GUI     | E0,1F                   | E0,F0,1F          |
| APPS      | E0,2F                   | E0,F0,2F          |
| KP /      | E0,4A                   | E0,F0,4A          |
| KP EN     | E0,5A                   | E0,F0,5A          |
| L ARROW   | E0,6B                   | E0,F0,6B          |
| HOME      | E0,6C                   | E0,F0,6C          |
| PG DN     | E0,7A                   | E0,F0,7A          |
| PG UP     | E0,7D                   | E0,F0,7D          |
| R ALT     | E0,11                   | E0,F0,11          |
| PRNT SCRN | E0,12,E0,7C             | E0,F0,7C,E0,F0,12 |
| R CTRL    | E0,14                   | E0,F0,14          |
| R GUI     | E0,27                   | E0,F0,27          |
| END       | E0,69                   | E0,F0,69          |
| INSERT    | E0,70                   | E0,F0,70          |
| DELETE    | E0,71                   | E0,F0,71          |
| D ARROW   | E0,72                   | E0,F0,72          |
| R ARROW   | E0,74                   | E0,F0,74          |
| U ARROW   | E0,75                   | E0,F0,75          |
| PAUSE     | E1,14,77,E1,F0,14,F0,77 | -NONE-            |

