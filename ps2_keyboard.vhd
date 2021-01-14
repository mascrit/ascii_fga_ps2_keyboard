library ieee;
use ieee.std_logic_1164.all;

entity ps2_keyboard is
  generic(
    clk_freq              : integer := 50_000_000; --system clock frequency in hz
    debounce_counter_size : integer := 8);         --set such that (2^size)/clk_freq = 5us (size = 8 for 50mhz)
  port(
    clk          : in  std_logic;                     --system clock
    ps2_clk      : in  std_logic;                     --clock signal from ps/2 keyboard
    ps2_data     : in  std_logic;                     --data signal from ps/2 keyboard
    ps2_code_new : out std_logic;                     --flag that new ps/2 code is available on ps2_code bus
    ps2_code     : out std_logic_vector(7 downto 0)); --code received from ps/2
end ps2_keyboard;

architecture logic of ps2_keyboard is
  signal sync_ffs     : std_logic_vector(1 downto 0);       --synchronizer flip-flops for ps/2 signals
  signal ps2_clk_int  : std_logic;                          --debounced clock signal from ps/2 keyboard
  signal ps2_data_int : std_logic;                          --debounced data signal from ps/2 keyboard
  signal ps2_word     : std_logic_vector(10 downto 0);      --stores the ps2 data word
  signal error        : std_logic;                          --validate parity, start, and stop bits
  signal count_idle   : integer range 0 to clk_freq/18_000; --counter to determine ps/2 is idle

  --declare debounce component for debouncing ps2 input signals
  component debounce is
    generic(
      counter_size : integer); --debounce period (in seconds) = 2^counter_size/(clk freq in hz)
    port(
      clk    : in  std_logic;  --input clock
      button : in  std_logic;  --input signal to be debounced
      result : out std_logic); --debounced signal
  end component;
begin

  --synchronizer flip-flops
  process(clk)
  begin
    if(clk'event and clk = '1') then  --rising edge of system clock
      sync_ffs(0) <= ps2_clk;           --synchronize ps/2 clock signal
      sync_ffs(1) <= ps2_data;          --synchronize ps/2 data signal
    end if;
  end process;

  --debounce ps2 Señales de Entrada
  debounce_ps2_clk: debounce
    generic map(counter_size => debounce_counter_size)
    port map(clk => clk, button => sync_ffs(0), result => ps2_clk_int);
  debounce_ps2_data: debounce
    generic map(counter_size => debounce_counter_size)
    port map(clk => clk, button => sync_ffs(1), result => ps2_data_int);

  --Entrada ps2 datos
  process(ps2_clk_int)
  begin
    if(ps2_clk_int'event and ps2_clk_int = '0') then    --falling edge de reloj
                                                        --ps2
      ps2_word <= ps2_data_int & ps2_word(10 downto 1);   --cambio en el bit de
                                                          --datos de ps2
    end if;
  end process;

  --verifica que que los bits de paridad, inicio y parada sean correctos.
  error <= not (not ps2_word(0) and ps2_word(10) and (ps2_word(9) xor ps2_word(8) xor
                                                      ps2_word(7) xor ps2_word(6) xor ps2_word(5) xor ps2_word(4) xor ps2_word(3) xor
                                                      ps2_word(2) xor ps2_word(1)));

  --determinar si el puerto ps2 está inactivo (es decir, la última transacción
  --finalizó) y generar el resultado
  process(clk)
  begin
    if(clk'event and clk = '1') then           --rising edge of system clock

      if(ps2_clk_int = '0') then
        count_idle <= 0;                           --reset idle counter
      elsif(count_idle /= clk_freq/18_000) then  --El l reloj de ps2 ha estado
                                                 --alto en menos de medio
                                                 --período de reloj (<55us)
        count_idle <= count_idle + 1;            --sigue contando
      end if;

      if(count_idle = clk_freq/18_000 and error = '0') then  --umbral de
                                                             --inactividad
                                                             --alcanzado y no
                                                             --se han detectado
                                                             --errores
        ps2_code_new <= '1';                    --establecer la bandera de que
                                                --el nuevo código ps/2 está disponible
        ps2_code <= ps2_word(8 downto 1);       --salida de nuevo código ps/2
      else                                      --ps/2 puerto activo o error detectado
        ps2_code_new <= '0';                    --bandera de que la transacción
                                                --ps/2 está en curso
      end if;

    end if;
  end process;

end logic;
