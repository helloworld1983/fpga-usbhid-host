-- (c) EMARD
-- License=BSD

library ieee;
use ieee.std_logic_1164.all;

package report_decoded_pack is
type T_report_decoded is
record
  lstick_x, lstick_y, rstick_x, rstick_y: std_logic_vector(7 downto 0); -- up/left=0 idle=128 down/right=255
  analog_trigger: std_logic_vector(5 downto 0);
  mouseq_x, mouseq_y: std_logic_vector(1 downto 0); -- quadrature encoder output
  hat_up, hat_down, hat_left, hat_right: std_logic;
  lstick_up, lstick_down, lstick_left, lstick_right: std_logic;
  rstick_up, rstick_down, rstick_left, rstick_right: std_logic;
  btn_a, btn_b, btn_x, btn_y: std_logic;
  btn_left_bumper, btn_right_bumper: std_logic;
  btn_left_trigger, btn_right_trigger: std_logic;
  btn_back, btn_start: std_logic;
  btn_lstick, btn_rstick: std_logic;
  btn_fps, btn_fps_toggle: std_logic;
end record;
end;
