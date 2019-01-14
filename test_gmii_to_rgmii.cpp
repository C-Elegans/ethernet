#include "Vgmii_to_rgmii.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>
using namespace std;

Testbench<Vgmii_to_rgmii> tb;
#define SIG(x) tb.core->x

unsigned char ddr_data_in;

void handler(void){
  static uint8_t data;
  static uint8_t en;
  static uint8_t past_clk = 0;
  if(SIG(rgmii_tx_clk) == 1 && past_clk == 0){
    data = SIG(rgmii_txd);
    en = SIG(rgmii_tx_ctrl);
  }
  if(SIG(rgmii_tx_clk) == 0 && past_clk == 1){
    data = data | (SIG(rgmii_txd) << 4);
    if(SIG(rgmii_tx_ctrl))
      printf("data: %02x\n", data);
  }
  past_clk = SIG(rgmii_tx_clk);
}

int main(int argc, char** argv){
  Verilated::traceEverOn(true);
  tb.register_tick_handler(handler);
  tb.opentrace("dump.vcd");
  tb.cycles(300);

}
