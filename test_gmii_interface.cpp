#include "Vgmii_interface.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>
using namespace std;

Testbench<Vgmii_interface> tb;
#define SIG(x) tb.core->x

char data[] = {0x01, 0x02, 0x03, 0x04};
int pointer = 0;

void print_packet(void){
  pointer = 0;
  while(!SIG(gmii_tx_en))
    tb.tick();
  while(SIG(gmii_tx_en)){
    if(SIG(fifo_rd))
      SIG(fifo_data) = data[pointer++];
    printf("%02x\n", SIG(gmii_tx_data));
    tb.tick();
  }

}

int main(int argc, char** argv){
  Verilated::traceEverOn(true);
  tb.opentrace("dump.vcd");
  tb.reset();
  tb.tick();
  SIG(rst) = 0;
  SIG(word_count) = 3;
  SIG(word_count_ready) = 1;
  while(!SIG(word_count_ack))
    tb.tick();
  SIG(word_count_ready) = 0;
  print_packet();
  tb.cycles(10);

}


