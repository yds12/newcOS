#include "driver/keyboard.h"
#include "driver/ioport.h"
#include "driver/vga.h"
#include "util.h"

#define KB_PORT_IN 0x60

#define SCANCODE_ERROR 0x0
#define SCANCODE_ESC 0x1
#define SCANCODE_1 0x2
#define SCANCODE_2 0x3
#define SCANCODE_3 0x4
#define SCANCODE_4 0x5
#define SCANCODE_5 0x6
#define SCANCODE_6 0x7
#define SCANCODE_7 0x8
#define SCANCODE_8 0x9
#define SCANCODE_9 0xA
#define SCANCODE_0 0xB
#define SCANCODE_MINUS 0xC
#define SCANCODE_PLUS 0xD
#define SCANCODE_BSPACE 0xE
#define SCANCODE_TAB 0xF
#define SCANCODE_Q 0x10
#define SCANCODE_W 0x11
#define SCANCODE_E 0x12
#define SCANCODE_R 0x13
#define SCANCODE_T 0x14
#define SCANCODE_Y 0x15
#define SCANCODE_U 0x16
#define SCANCODE_I 0x17
#define SCANCODE_O 0x18
#define SCANCODE_P 0x19
#define SCANCODE_LSQB 0x1A
#define SCANCODE_RSQB 0x1B
#define SCANCODE_ENTER 0x1C
#define SCANCODE_LCTRL 0x1D
#define SCANCODE_A 0x1E
#define SCANCODE_S 0x1F
#define SCANCODE_D 0x20
#define SCANCODE_F 0x21
#define SCANCODE_G 0x22
#define SCANCODE_H 0x23
#define SCANCODE_J 0x24
#define SCANCODE_K 0x25
#define SCANCODE_L 0x26
#define SCANCODE_SEMI 0x27
#define SCANCODE_QUOT 0x28
#define SCANCODE_BTCK 0x29
#define SCANCODE_LSHIFT 0x2A
#define SCANCODE_BSLASH 0x2B
#define SCANCODE_Z 0x2C
#define SCANCODE_X 0x2D
#define SCANCODE_C 0x2E
#define SCANCODE_V 0x2F
#define SCANCODE_B 0x30
#define SCANCODE_N 0x31
#define SCANCODE_M 0x32
#define SCANCODE_COMMA 0x33
#define SCANCODE_DOT 0x34
#define SCANCODE_SLASH 0x35
#define SCANCODE_RSHIFT 0x36
#define SCANCODE_STAR 0x37
#define SCANCODE_LALT 0x38
#define SCANCODE_SPACE 0x39
#define SCANCODE_CLOCK 0x3A
#define SCANCODE_F1 0x3B
#define SCANCODE_F2 0x3C
#define SCANCODE_F3 0x3D
#define SCANCODE_F4 0x3E
#define SCANCODE_F5 0x3F
#define SCANCODE_F6 0x40
#define SCANCODE_F7 0x41
#define SCANCODE_F8 0x42
#define SCANCODE_F9 0x43
#define SCANCODE_F10 0x44
#define SCANCODE_F11 0x57
#define SCANCODE_F12 0x58
#define SCANCODE_LEFT 0x4B
#define SCANCODE_UP 0x48
#define SCANCODE_RIGHT 0x4D
#define SCANCODE_DOWN 0x50
#define SCANCODE_SUPER 0x5B

#define SCANCODE_SPECIAL 0xE0 // special keys, need to read next

#define MASK_SHIFT 0x01
#define MASK_CTRL 0x02
#define MASK_ALT 0x04
#define MASK_SPECIAL 0x08

uint8_t kb_state;

void init_kb() {
  kb_state = 0;
}

void print_keyname(uint8_t scancode) {
  char done = 1;
  switch(scancode) {
    case SCANCODE_0: print("0"); break;
    case SCANCODE_1: print("1"); break;
    case SCANCODE_2: print("2"); break;
    case SCANCODE_3: print("3"); break;
    case SCANCODE_4: print("4"); break;
    case SCANCODE_5: print("5"); break;
    case SCANCODE_6: print("6"); break;
    case SCANCODE_7: print("7"); break;
    case SCANCODE_8: print("8"); break;
    case SCANCODE_9: print("9"); break;
    case SCANCODE_A:
      if(kb_state & MASK_SHIFT) print("A");
      else print("a");
      break;
    case SCANCODE_B: print("B"); break;
    case SCANCODE_C: print("C"); break;
    case SCANCODE_D: print("D"); break;
    case SCANCODE_E: print("E"); break;
    case SCANCODE_F: print("F"); break;
    case SCANCODE_G: print("G"); break;
    case SCANCODE_H: print("H"); break;
    case SCANCODE_I: print("I"); break;
    case SCANCODE_J: print("J"); break;
    case SCANCODE_K: print("K"); break;
    case SCANCODE_L: print("L"); break;
    case SCANCODE_M: print("M"); break;
    case SCANCODE_N: print("N"); break;
    case SCANCODE_O: print("O"); break;
    case SCANCODE_P: print("P"); break;
    case SCANCODE_Q: print("Q"); break;
    case SCANCODE_R: print("R"); break;
    case SCANCODE_S: print("S"); break;
    case SCANCODE_T: print("T"); break;
    case SCANCODE_U: print("U"); break;
    case SCANCODE_V: print("V"); break;
    case SCANCODE_W: print("W"); break;
    case SCANCODE_X: print("X"); break;
    case SCANCODE_Y: print("Y"); break;
    case SCANCODE_Z: print("Z"); break;
    case SCANCODE_PLUS: print("+"); break;
    case SCANCODE_MINUS: print("-"); break;
    case SCANCODE_SEMI: print(";"); break;
    case SCANCODE_LSQB: print("["); break;
    case SCANCODE_RSQB: print("]"); break;
    case SCANCODE_COMMA: print(","); break;
    case SCANCODE_DOT: print("."); break;
    case SCANCODE_SLASH: print("/"); break;
    case SCANCODE_STAR: print("*"); break;
    case SCANCODE_QUOT: print("'"); break;
    case SCANCODE_BTCK: print("`"); break;
    case SCANCODE_BSLASH: print("\\"); break;
    case SCANCODE_SPACE: print("SPACE"); break;
    case SCANCODE_TAB: print("TAB"); break;
    case SCANCODE_ENTER: print("ENTER"); break;
    case SCANCODE_BSPACE: print("BACKSPACE"); break;
    case SCANCODE_CLOCK: print("CAPS LOCK"); break;
    case SCANCODE_ESC: print("ESC"); break;
    case SCANCODE_LSHIFT: print("LSHIFT"); break;
    case SCANCODE_RSHIFT: print("RSHIFT"); break;
    case SCANCODE_LCTRL: print("LCTRL"); break;
    case SCANCODE_LALT: print("LALT"); break;
    case SCANCODE_F1: print("F1"); break;
    case SCANCODE_F2: print("F2"); break;
    case SCANCODE_F3: print("F3"); break;
    case SCANCODE_F4: print("F4"); break;
    case SCANCODE_F5: print("F5"); break;
    case SCANCODE_F6: print("F6"); break;
    case SCANCODE_F7: print("F7"); break;
    case SCANCODE_F8: print("F8"); break;
    case SCANCODE_F9: print("F9"); break;
    case SCANCODE_F10: print("F10"); break;
    case SCANCODE_F11: print("F11"); break;
    case SCANCODE_F12: print("F12"); break;
    default: done = 0; break;
  }

  if(done) return;

  if(kb_state & MASK_SPECIAL) {
    done = 1;
    switch(scancode) {
      case SCANCODE_SUPER: print("SUPER"); break;
      case SCANCODE_UP: print("UP"); break;
      case SCANCODE_LEFT: print("LEFT"); break;
      case SCANCODE_RIGHT: print("RIGHT"); break;
      case SCANCODE_DOWN: print("DOWN"); break;
      default: done = 0; break;
    }
  }
}

void handle_kb() {
  uint8_t scancode = port_byte_in(KB_PORT_IN);
  char done = 1;

  switch(scancode) {
    case SCANCODE_LSHIFT:
    case SCANCODE_RSHIFT:
      if(!(kb_state & MASK_SHIFT)) kb_state += MASK_SHIFT;
      break;
    case SCANCODE_LSHIFT + 0x80:
    case SCANCODE_RSHIFT + 0x80:
      if(kb_state & MASK_SHIFT) kb_state -= MASK_SHIFT;
      break;
    case SCANCODE_LCTRL:
      if(!(kb_state & MASK_CTRL)) kb_state += MASK_CTRL;
      break;
    case SCANCODE_LCTRL + 0x80:
      if(kb_state & MASK_CTRL) kb_state -= MASK_CTRL;
      break;
    case SCANCODE_SPECIAL:
      if(!(kb_state & MASK_SPECIAL)) kb_state += MASK_SPECIAL;
      break;
    case SCANCODE_SPECIAL + 0x80:
      if(kb_state & MASK_SPECIAL) kb_state -= MASK_SPECIAL;
      break;
    default: done = 0;
      break;
  }
  // print_byte(scancode);

  if(done) return;

  if(scancode < 0x80) {
    print_keyname(scancode);
  } else {
    print("^");
    print_keyname(scancode - 0x80); // key up is key down + 0x80
  }
}

