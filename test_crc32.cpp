#include "Vcrc32.h"
#include "verilated.h"
#include "testbench.h"
#include <iostream>
using namespace std;

Testbench<Vcrc32> tb;
#define SIG(x) tb.core->x

void clock_in_data(const uint8_t* data, size_t size){
  SIG(rst) = 1;
  tb.tick();
  SIG(rst) = 0;
  tb.tick();
  for(size_t i=0; i<size;i++){
    SIG(en) = 1;
    SIG(data_in) = data[i];
    tb.tick();
  }
  SIG(en) = 0;

}

uint32_t crc32(const uint8_t *ptr, size_t size){
  uint32_t crc = 0xffffffff;
  for(size_t i=0;i<size;i++){
    crc ^= ptr[i];
    for(size_t j=0;j<8;j++){
      if(crc & 1)
	crc = (crc >> 1) ^ 0xedb88320;
      else
	crc = crc >> 1;
    }
  }
  return crc ^ 0xffffffff;
}
/*
def crc32(frame):
    crc = 0xffffffff
    for byte in frame:
        crc ^= byte
        for i in range(0,8):
            if crc & 1:
                crc = (crc >> 1) ^ 0xedb88320
            else:
                crc = crc >> 1
    crc = crc ^ 0xffffffff
    return [crc & 0xff, (crc >> 8) & 0xff, (crc >> 16) & 0xff, (crc >> 24) & 0xff]
*/

void test_crc32(const uint8_t *data, size_t size){
  clock_in_data(data, size);
  tb.tick();
  uint32_t gold = crc32(data, size);
  if(SIG(crc) != crc32(data, size)){
    fprintf(stderr, "CRC failed: %08x should be %08x\n", SIG(crc), gold);
    exit(1);
  }
}

uint8_t buffer[256];
void test_random(int iterations){
  for(int i=0;i<iterations;i++){
    size_t bytes = rand() % 256;
    for(size_t j=0; j<bytes; j++){
      buffer[j] = rand() & 255;
    }
    test_crc32(buffer, bytes);
  }
}

int main(int argc, char** argv){
  Verilated::traceEverOn(true);
  tb.opentrace("dump.vcd");
  tb.reset();
  tb.tick();
  test_random(200);
  tb.cycles(5);

}
