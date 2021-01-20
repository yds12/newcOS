void kmain() {
  short offset = 80 * 5;
  char text[27] = "> Hello from NewcOS kernel!";
  char color = 0xE1;
  char* video_mem = (char*) 0xb8000;

  for(char i = 0; text[i] != 0; i++) {
    video_mem[offset * 2 + i * 2] = text[i];
    video_mem[offset * 2 + i * 2 + 1] = color;
  }

  while(1);
}

