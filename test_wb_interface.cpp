
#include "Vwb_interface.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>
using namespace std;

Testbench<Vwb_interface> tb;
#define SIG(x) tb.core->x

unsigned char ddr_data_in;

void wishbone_write(uint32_t addr, uint8_t data){
  while(SIG(o_wb_stall) == 1) tb.tick();
  SIG(i_wb_cyc) = 1;
  SIG(i_wb_stb) = 1;
  SIG(i_wb_we) = 1;
  SIG(i_wb_addr) = addr;
  SIG(i_wb_data) = data;
  tb.tick();
  SIG(i_wb_stb) = 0;
  SIG(i_wb_we) = 0;
  int i=0;
  while(!SIG(o_wb_ack) && i<10){
    tb.tick();
    i++;
  }
  SIG(i_wb_cyc) = 0;
}

uint32_t wishbone_read(uint32_t addr){
  uint32_t data = 0;
  SIG(i_wb_cyc) = 1;
  SIG(i_wb_stb) = 1;
  SIG(i_wb_we) = 0;
  SIG(i_wb_addr) = addr;
  tb.tick();
  SIG(i_wb_stb) = 0;
  int i=0;
  while(!SIG(o_wb_ack) && i<10){
    tb.tick();
    i++;
  }
  data = SIG(o_wb_data);
  SIG(i_wb_cyc) = 0;
  return data;
}

int main(int argc, char** argv){
  Verilated::traceEverOn(true);
  tb.opentrace("dump.vcd");
  tb.reset();
  tb.tick();
  SIG(rst) = 0;
  wishbone_write(0, 0xaa);
  wishbone_write(0, 0xbb);
  wishbone_write(0, 0xcc);
  wishbone_write(0, 0xdd);
  wishbone_write(1, 0x40);
  wishbone_write(2, 0x01);
  tb.cycles(2);
  printf("%x\n", wishbone_read(1));
  printf("%x\n", wishbone_read(2));
  tb.cycles(3);
}
