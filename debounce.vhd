library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity debounce is
  generic(
    counter_size  :  integer := 19); --tamaño del contador (19 bits dan 10,5[ms]
                                     --con un reloj de 50[mhz])
  port(
    clk     : in  std_logic;  --input clock
    button  : in  std_logic;  --input signal to be debounced
    result  : out std_logic); --debounced signal
end debounce;

architecture logic of debounce is
  signal flipflops   : std_logic_vector(1 downto 0); --input flip flops
  signal counter_set : std_logic;                    --sync reset to zero
  signal counter_out : std_logic_vector(counter_size downto 0) := (others => '0'); --counter output
begin

  counter_set <= flipflops(0) xor flipflops(1);   --determinar cuándo
                                                  --iniciar/restablecer el contador

  process(clk)
  begin
    if(clk'event and clk = '1') then
      flipflops(0) <= button;
      flipflops(1) <= flipflops(0);
      if(counter_set = '1') then                  --restablecer el contador
                                                  --porque la entrada está cambiando
        counter_out <= (others => '0');
      elsif(counter_out(counter_size) = '0') then --el tiempo de entrada
                                                  --estable aún no se ha cumplido
        counter_out <= counter_out + 1;
      else                                        --se cumple un tiempo de
                                                  --entrada estable
        result <= flipflops(1);
      end if;
    end if;
  end process;
end logic;
