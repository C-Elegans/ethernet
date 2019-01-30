#include "Vmaster.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>
using namespace std;

Testbench<Vmaster> tb;
#define SIG(x) tb.core->x

int main(int argc, char** argv){
  Verilated::traceEverOn(true);
  tb.opentrace("master.vcd");
  tb.reset();
  tb.tick();
  SIG(rst) = 0;
  tb.cycles(100);
}
