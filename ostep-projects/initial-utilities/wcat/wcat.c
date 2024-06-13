#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  if (argc < 2) {
    return 0;
  }
  for (int i = 1; i < argc; i++) {
    char *filename = argv[i];

    FILE* fp = fopen(filename, "r");

    if (fp == NULL) {
      printf("wcat: cannot open file\n");
      return 1;
    }

    char* string_buffer = malloc(30*sizeof(char));

    while (fgets(string_buffer, 20, fp) != NULL) {
      printf("%s", string_buffer);
    }

    fclose(fp);
  }
  return 0;
}
