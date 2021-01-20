void kernel_main() {
  char* video_mem = (char*) 0xb8000;
  video_mem[0] = 'X';
//  video_mem[1] = '+';
//  video_mem[2] = '@';
  while(1);
}

