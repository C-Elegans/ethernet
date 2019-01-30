#define CLK core->clk_100
#define NO_RESET
#include "Vtop.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>
using namespace std;

Testbench<Vtop> tb;
#define SIG(x) tb.core->x

int main(int argc, char** argv){
  Verilated::traceEverOn(true);
  tb.opentrace("top.vcd");
  tb.reset();
  SIG(rstn) = 0;
  tb.tick();
  SIG(rstn) = 1;
  tb.cycles(200);
}
