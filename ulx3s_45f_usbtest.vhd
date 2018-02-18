-- (c)EMARD
-- License=BSD

-- module to bypass user input and usbserial to esp32 wifi

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library ecp5u;
use ecp5u.components.all;

-- test USB helper functions
use work.usb_req_gen_func_pack.all;

entity ulx3s_usbtest is
  generic
  (
    C_dummy_constant: integer := 0
  );
  port
  (
  clk_25MHz: in std_logic;  -- main clock input from 25MHz clock source

  -- UART0 (FTDI USB slave serial)
  ftdi_rxd: out   std_logic;
  ftdi_txd: in    std_logic;
  -- FTDI additional signaling
  ftdi_ndtr: inout  std_logic;
  ftdi_ndsr: inout  std_logic;
  ftdi_nrts: inout  std_logic;
  ftdi_txden: inout std_logic;

  -- UART1 (WiFi serial)
  wifi_rxd: out   std_logic;
  wifi_txd: in    std_logic;
  -- WiFi additional signaling
  wifi_en: inout  std_logic := 'Z'; -- '0' will disable wifi by default
  wifi_gpio0: inout std_logic;
  wifi_gpio2: inout std_logic;
  wifi_gpio15: inout std_logic;
  wifi_gpio16: inout std_logic;

  -- Onboard blinky
  led: out std_logic_vector(7 downto 0);
  btn: in std_logic_vector(6 downto 0);
  sw: in std_logic_vector(1 to 4);
  oled_csn, oled_clk, oled_mosi, oled_dc, oled_resn: out std_logic;

  -- GPIO (some are shared with wifi and adc)
  gp, gn: inout std_logic_vector(27 downto 0) := (others => 'Z');
  
  -- FPGA direct USB connector
  usb_fpga_dp, usb_fpga_dn: inout std_logic;

  -- SHUTDOWN: logic '1' here will shutdown power on PCB >= v1.7.5
  shutdown: out std_logic := '0';

  -- Digital Video (differential outputs)
  --gpdi_dp, gpdi_dn: out std_logic_vector(2 downto 0);
  --gpdi_clkp, gpdi_clkn: out std_logic;

  -- Flash ROM (SPI0)
  --flash_miso   : in      std_logic;
  --flash_mosi   : out     std_logic;
  --flash_clk    : out     std_logic;
  --flash_csn    : out     std_logic;

  -- SD card (SPI1)
  sd_dat3_csn, sd_cmd_di, sd_dat0_do, sd_dat1_irq, sd_dat2: inout std_logic := 'Z';
  sd_clk: inout std_logic := 'Z';
  sd_cdn, sd_wp: inout std_logic := 'Z'
  );
end;

architecture Behavioral of ulx3s_usbtest is
  signal clk_100MHz, clk_60MHz, clk_7M5Hz, clk_12MHz: std_logic;
  signal R_blinky: std_logic_vector(26 downto 0);
  
  constant usb_message: std_logic_vector(71 downto 0) := x"031122334455667788";
  
begin
  clk_pll: entity work.clk_25M_100M_7M5_12M_60M
  port map
  (
      CLKI        =>  clk_25MHz,
      CLKOP       =>  clk_100MHz,
      CLKOS       =>  clk_7M5Hz,
      CLKOS2      =>  clk_12MHz,
      CLKOS3      =>  clk_60MHz
  );

  -- TX/RX passthru
  --ftdi_rxd <= wifi_txd;
  --wifi_rxd <= ftdi_txd;

  wifi_en <= '1';
  wifi_gpio0 <= btn(0);

  -- clock alive blinky
  blink: if false generate
  process(clk_7M5Hz)
  begin
      if rising_edge(clk_7M5Hz) then
        R_blinky <= R_blinky+1;
      end if;
  end process;
  led(7 downto 0) <= R_blinky(R_blinky'high downto R_blinky'high-7);
  end generate;
  
  ps3: if false generate
  usb_ps3_inst: entity USB_ps3
  port map
  (
    clk60MHz => clk_60MHz,
    plage => "1000",
    usb_data(0) => usb_fpga_dp,
    usb_data(1) => usb_fpga_dn,
    leds => led
  );
  end generate;

  snifer: if false generate
  usb_snifer_inst: entity USB_snifer
  port map
  (
    clk => clk_7M5Hz,
    usb_data(0) => usb_fpga_dp,
    usb_data(1) => usb_fpga_dn,
    leds => led
  );
  end generate;

  logitech: if false generate
  usb_logitech_inst: entity USB_logitech
  port map
  (
    clk7_5MHz => clk_7M5Hz,
    plage => "100",
    usb_data(1) => usb_fpga_dp,
    usb_data(0) => usb_fpga_dn,
    leds => led
  );
  end generate;

  saitek: if true generate
  usb_saitek_inst: entity USB_saitek
  port map
  (
    clk7_5MHz => clk_7M5Hz,
    plage => "100",
    usb_data(1) => usb_fpga_dp,
    usb_data(0) => usb_fpga_dn,
    leds => open
  );
  end generate;
  
  --led <= reverse_any_vector(x"07");
  led <= usb_packet_gen(usb_message) (87 downto 87-7);
  
end Behavioral;
