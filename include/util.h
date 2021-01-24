#include <stdint.h>

#define lo_nib(x) ((uint8_t)((x) & 0x0F))
#define hi_nib(x) ((uint8_t)((x) >> 4))

