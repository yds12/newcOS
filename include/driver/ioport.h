#ifndef NEWCOS_DRIVER_IOPORT_H
#define NEWCOS_DRIVER_IOPORT_H

unsigned char port_byte_in(unsigned short port);
void port_byte_out(unsigned short port, unsigned char data);

#endif
