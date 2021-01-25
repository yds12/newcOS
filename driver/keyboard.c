#include "driver/keyboard.h"
#include "driver/ioport.h"
#include "driver/vga.h"
#include "util.h"

#define KB_PORT_IN 0x60

void handle_kb() {
  uint8_t scancode = port_byte_in(KB_PORT_IN);

  switch(scancode) {
    case 0x0: println("ERROR");
      break;
    case 0x1: println("ESC");
      break;
    case 0x2: println("1");
      break;
    case 0x3: println("2");
      break;
    case 0x4: println("3");
      break;
    case 0x5: println("4");
      break;
    case 0x6: println("5");
      break;
    case 0x7: println("6");
      break;
    case 0x8: println("7");
      break;
    case 0x9: println("8");
      break;
    case 0xA: println("9");
      break;
    case 0xB: println("0");
      break;
    case 0x1E: println("A");
      break;
    case 0x30: println("B");
      break;
    case 0x39: println("SPACE");
      break;
    default:
      if(scancode < 0x80) {
        println("Unknown key down");
        print_byte(scancode);
      } else if(scancode <= 0x39 + 0x80) {
        println("Some key up");
        print_byte(scancode - 0x80); // key up is key down + 0x80
      } else println("Unknown key up");
      break;
  }
  newline();
}

