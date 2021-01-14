library ieee;
use ieee.std_logic_1164.all;

entity keyboard is
  generic(
    clk_freq                  : integer := 50_000_000; --clock frequency in hz
    ps2_debounce_counter_size : integer := 8);         --2 ^ size/clk_freq = 5us (tamaño = 8 para 50mhz)
  port(
    clk        : in  std_logic;                     --system clock input
    ps2_clk    : in  std_logic;                     --clock signal from ps2 keyboard
    ps2_data   : in  std_logic;                     --data signal from ps2 keyboard
    ascii_new  : out std_logic;                     --output flag indicating new ascii value
    ascii_code : out std_logic_vector(6 downto 0)); --ascii value
end keyboard;

architecture behavior of keyboard is
  type machine is(ready, new_code, traducir, output);              --estados necesarios
  signal state             : machine;                               --máquina
                                                                    --de estados
  signal ps2_code_new      : std_logic;                             --nueva
                                                                    --bandera de
                                                                    --código
                                                                    --ps2 del
                                                                    --componente ps2_keyboard
  signal ps2_code          : std_logic_vector(7 downto 0);          --ps2
                                                                    --formulario de
                                                                    --entrada de
                                                                    --código componente ps2_keyboard
  signal prev_ps2_code_new : std_logic := '1';                      --valor de
                                                                    --la
                                                                    --bandera
                                                                    --ps2_code_newenel reloj anterior
  signal break             : std_logic := '0';                      --'1' para código de interrupción, '0' para código de marca
  signal e0_code           : std_logic := '0';                      --'1' para comandos de código múltiple, '0' para comandos de código único
  signal caps_lock         : std_logic := '0';                      --'1' si el bloqueo de mayúsculas está activo, '0' si el bloqueo de mayúsculas está inactivo
  signal control_r         : std_logic := '0';                      --'1' si se mantiene presionada la tecla de control derecha, de lo contrario '0'
  signal control_l         : std_logic := '0';                      --'1' si se mantiene presionada la tecla de control izquierda, de lo contrario '0'
  signal shift_r           : std_logic := '0';                      --'1' si se mantiene presionada la tecla de desplazamiento a la derecha, en caso contrario '0'
  signal shift_l           : std_logic := '0';                      --'1' si se mantiene presionada la tecla de desplazamiento a la izquierda, en caso contrario '0'
  signal ascii             : std_logic_vector(7 downto 0) := x"ff"; --valor interno de la traducción ascii
  signal dis7					: std_logic_vector(6 to 0);
  
  --declarar componente de interfaz de teclado ps2
  component ps2_keyboard is
    generic(
      clk_freq              : integer;  --
      debounce_counter_size : integer); --set such that 2^size/clk_freq = 5us (size = 8 for 50mhz)
    port(
      clk          : in  std_logic;                     --system clock
      ps2_clk      : in  std_logic;                     --clock signal from ps2 keyboard
      ps2_data     : in  std_logic;                     --data signal from ps2 keyboard
      ps2_code_new : out std_logic;                     --flag that new ps/2 code is available on ps2_code bus
      ps2_code     : out std_logic_vector(7 downto 0)); --code received from ps/2
  end component;

begin

  --instanciar la lógica de la interfaz del teclado ps2
  ps2_keyboard_0:  ps2_keyboard
    generic map(clk_freq => clk_freq, debounce_counter_size => ps2_debounce_counter_size)
    port map(clk => clk, ps2_clk => ps2_clk, ps2_data => ps2_data, ps2_code_new => ps2_code_new, ps2_code => ps2_code);

  process(clk)
  begin
    if(clk'event and clk = '1') then
      prev_ps2_code_new <= ps2_code_new; --realizar un seguimiento de los valores ps2_code_new anteriores para determinar las transiciones de menor a mayor
      case state is

        --estado listo: espere a que se reciba un nuevo código ps2
        when ready =>
          if(prev_ps2_code_new = '0' and ps2_code_new = '1') then --nuevo código ps2 recibido
            ascii_new <= '0';                                     --restablecer nuevo indicador de código ascii
            state <= new_code;                                    --pasar al estado new_code
          else                                                    --aún no se ha recibido un nuevo código ps2
            state <= ready;                                       --permanecer en estado ready
          end if;

        --estado de new_code: determina qué hacer con el nuevo código de ps2
        when new_code =>
          if(ps2_code = x"f0") then    --el código indica que el siguiente comando es break
            break <= '1';
            state <= ready;              --Regrese al estado ready para esperar el próximo código ps2
          elsif(ps2_code = x"e0") then --el código indica un comando de varias teclas
            e0_code <= '1';              --establecer bandera de comando de código múltiple
            state <= ready;              --Regrese al estado ready para esperar el próximo código ps2
          else                         --código es el último código de ps2 en el código de creación / interrupción
            ascii(7) <= '1';             --establecer el valor ascii interno en un código no admitido (para verificación)
            state <= traducir;          --proceder a traducir el estado
          end if;

        --estado traducir: traducir código ps2 a valor ascii
        when traducir =>
          break <= '0';    --reset break flag
          e0_code <= '0';  --reset multi-code command flag

          --manejar códigos para control, cambio y bloqueo de mayúsculas
          case ps2_code is
            when x"58" =>                   --CAPS LOCK
              if(break = '0') then            --Si se hace el comando
                caps_lock <= not caps_lock;     --cambia a mayus
              end if;
            when x"14" =>                   --código para las teclas de control
              if(e0_code = '1') then          --código para el control correcto
                control_r <= not break;         --actualizar la bandera de control derecho
              else                            --código para control izquierdo
                control_l <= not break;         --actualizar la bandera de control izquierdo
              end if;
            when x"12" =>                   --SHIFT izq
              shift_l <= not break;
            when x"59" =>                   --SHIFT der
              shift_r <= not break;
            when others => null;
          end case;

          --traducir códigos de control (estos no dependen del cambio o bloqueo de mayúsculas)
          if(control_l = '1' or control_r = '1') then
            case ps2_code is
              when x"1e" => ascii <= x"00"; --^@  nul
              when x"1c" => ascii <= x"01"; --^a  soh
              when x"32" => ascii <= x"02"; --^b  stx
              when x"21" => ascii <= x"03"; --^c  etx
              when x"23" => ascii <= x"04"; --^d  eot
              when x"24" => ascii <= x"05"; --^e  enq
              when x"2b" => ascii <= x"06"; --^f  ack
              when x"34" => ascii <= x"07"; --^g  bel
              when x"33" => ascii <= x"08"; --^h  bs
              when x"43" => ascii <= x"09"; --^i  ht
              when x"3b" => ascii <= x"0a"; --^j  lf
              when x"42" => ascii <= x"0b"; --^k  vt
              when x"4b" => ascii <= x"0c"; --^l  ff
              when x"3a" => ascii <= x"0d"; --^m  cr
              when x"31" => ascii <= x"0e"; --^n  so
              when x"44" => ascii <= x"0f"; --^o  si
              when x"4d" => ascii <= x"10"; --^p  dle
              when x"15" => ascii <= x"11"; --^q  dc1
              when x"2d" => ascii <= x"12"; --^r  dc2
              when x"1b" => ascii <= x"13"; --^s  dc3
              when x"2c" => ascii <= x"14"; --^t  dc4
              when x"3c" => ascii <= x"15"; --^u  nak
              when x"2a" => ascii <= x"16"; --^v  syn
              when x"1d" => ascii <= x"17"; --^w  etb
              when x"22" => ascii <= x"18"; --^x  can
              when x"35" => ascii <= x"19"; --^y  em
              when x"1a" => ascii <= x"1a"; --^z  sub
              when x"54" => ascii <= x"1b"; --^[  esc
              when x"5d" => ascii <= x"1c"; --^\  fs
              when x"5b" => ascii <= x"1d"; --^]  gs
              when x"36" => ascii <= x"1e"; --^^  rs
              when x"4e" => ascii <= x"1f"; --^_  us
              when x"4a" => ascii <= x"7f"; --^?  del
              when others => null;
            end case;
          else --if control keys are not pressed

            --traducir caracteres que no dependen de mayúsculas o mayúsculas
            case ps2_code is
              when x"29" => ascii <= x"20"; --space
              when x"66" => ascii <= x"08"; --backspace (bs control code)
              when x"0d" => ascii <= x"09"; --tab (ht control code)
              when x"5a" => ascii <= x"0d"; --enter (cr control code)
              when x"76" => ascii <= x"1b"; --escape (esc control code)
              when x"71" =>
                if(e0_code = '1') then      --ps2 code for delete is a multi-key code
                  ascii <= x"7f";             --delete
                end if;
              when others => null;
            end case;

            --traducir letras (dependen de mayúsculas y mayúsculas)
            if((shift_r = '0' and shift_l = '0' and caps_lock = '0') or
               ((shift_r = '1' or shift_l = '1') and caps_lock = '1')) then  --la letra es minúscula
              case ps2_code is
                when x"1c" => ascii <= x"61"; --a
                when x"32" => ascii <= x"62"; --b
                when x"21" => ascii <= x"63"; --c
                when x"23" => ascii <= x"64"; --d
                when x"24" => ascii <= x"65"; --e
                when x"2b" => ascii <= x"66"; --f
                when x"34" => ascii <= x"67"; --g
                when x"33" => ascii <= x"68"; --h
                when x"43" => ascii <= x"69"; --i
                when x"3b" => ascii <= x"6a"; --j
                when x"42" => ascii <= x"6b"; --k
                when x"4b" => ascii <= x"6c"; --l
                when x"3a" => ascii <= x"6d"; --m
                when x"31" => ascii <= x"6e"; --n
                when x"44" => ascii <= x"6f"; --o
                when x"4d" => ascii <= x"70"; --p
                when x"15" => ascii <= x"71"; --q
                when x"2d" => ascii <= x"72"; --r
                when x"1b" => ascii <= x"73"; --s
                when x"2c" => ascii <= x"74"; --t
                when x"3c" => ascii <= x"75"; --u
                when x"2a" => ascii <= x"76"; --v
                when x"1d" => ascii <= x"77"; --w
                when x"22" => ascii <= x"78"; --x
                when x"35" => ascii <= x"79"; --y
                when x"1a" => ascii <= x"7a"; --z
                when others => null;
              end case;
            else                                     --la letra es mayúscula
              case ps2_code is
                when x"1c" => ascii <= x"41"; --A
                when x"32" => ascii <= x"42"; --B
                when x"21" => ascii <= x"43"; --C
                when x"23" => ascii <= x"44"; --D
                when x"24" => ascii <= x"45"; --E
                when x"2b" => ascii <= x"46"; --F
                when x"34" => ascii <= x"47"; --G
                when x"33" => ascii <= x"48"; --H
                when x"43" => ascii <= x"49"; --I
                when x"3b" => ascii <= x"4a"; --J
                when x"42" => ascii <= x"4b"; --K
                when x"4b" => ascii <= x"4c"; --L
                when x"3a" => ascii <= x"4d"; --M
                when x"31" => ascii <= x"4e"; --N
                when x"44" => ascii <= x"4f"; --O
                when x"4d" => ascii <= x"50"; --P
                when x"15" => ascii <= x"51"; --Q
                when x"2d" => ascii <= x"52"; --R
                when x"1b" => ascii <= x"53"; --S
                when x"2c" => ascii <= x"54"; --T
                when x"3c" => ascii <= x"55"; --U
                when x"2a" => ascii <= x"56"; --V
                when x"1d" => ascii <= x"57"; --W
                when x"22" => ascii <= x"58"; --X
                when x"35" => ascii <= x"59"; --Y
                when x"1a" => ascii <= x"5a"; --Z
                when others => null;
              end case;
            end if;

            --traducir números y símbolos (estos dependen del turno pero no del bloqueo de mayúsculas)
            if(shift_l = '1' or shift_r = '1') then  --se desea el carácter secundario de la clave
              case ps2_code is
                when x"16" => ascii <= x"21"; --!
                when x"52" => ascii <= x"22"; --"
                when x"26" => ascii <= x"23"; --#
                when x"25" => ascii <= x"24"; --$
                when x"2e" => ascii <= x"25"; --%
                when x"3d" => ascii <= x"26"; --&
                when x"46" => ascii <= x"28"; --(
                when x"45" => ascii <= x"29"; --)
                when x"3e" => ascii <= x"2a"; --*
                when x"55" => ascii <= x"2b"; --+
                when x"4c" => ascii <= x"3a"; --:
                when x"41" => ascii <= x"3c"; --<
                when x"49" => ascii <= x"3e"; -->
                when x"4a" => ascii <= x"3f"; --?
                when x"1e" => ascii <= x"40"; --@
                when x"36" => ascii <= x"5e"; --^
                when x"4e" => ascii <= x"5f"; --_
                when x"54" => ascii <= x"7b"; --{
                when x"5d" => ascii <= x"7c"; --|
                when x"5b" => ascii <= x"7d"; --}
                when x"0e" => ascii <= x"7e"; --~
                when others => null;
              end case;
            else                                     --se desea el carácter principal de la clave
              case ps2_code is
                when x"45" => ascii <= x"30"; --0
                when x"16" => ascii <= x"31"; --1
                when x"1e" => ascii <= x"32"; --2
                when x"26" => ascii <= x"33"; --3
                when x"25" => ascii <= x"34"; --4
                when x"2e" => ascii <= x"35"; --5
                when x"36" => ascii <= x"36"; --6
                when x"3d" => ascii <= x"37"; --7
                when x"3e" => ascii <= x"38"; --8
                when x"46" => ascii <= x"39"; --9
                when x"52" => ascii <= x"27"; --'
                when x"41" => ascii <= x"2c"; --,
                when x"4e" => ascii <= x"2d"; ---
                when x"49" => ascii <= x"2e"; --.
                when x"4a" => ascii <= x"2f"; --/
                when x"4c" => ascii <= x"3b"; --;
                when x"55" => ascii <= x"3d"; --=
                when x"54" => ascii <= x"5b"; --[
                when x"5d" => ascii <= x"5c"; --\
                when x"5b" => ascii <= x"5d"; --]
                when x"0e" => ascii <= x"60"; --`
                when others => null;
              end case;
            end if;

          end if;

          if(break = '0') then  --el código es brak
            state <= output;      --pasar al estado de salida
          else                  --código es break
            state <= ready;       --Regrese al estado listo para esperar el próximo código ps2
          end if;

        --estado output: verificar que el código sea válido y generar el valor ascii
        when output =>
          if(ascii(7) = '0') then            --el código ps2 tiene una salida ascii
            ascii_new <= '1';                  --establecer bandera que
                                               --indica(si se esta pusando una
                                               --tecla)
                                               --nueva salida ascii
            ascii_code <= ascii(6 downto 0);   --generar el valor ascii(binario)
          end if;
          state <= ready;                    --Regresa al estado listo para
                                             --esperar el próximo código ps2

      end case;
    end if;
  end process;

end behavior;
