#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
  if (argc > 2) {
    printf("Too many arguments\n");
    return 1;
  }
  if (argc < 2) {
    printf("wcat: file [file ...]\n");
    return 1;
  }
  char *filename = argv[1];

  FILE* fp = fopen(filename, "r");
  printf("Opened the file\n");

  if (fp == NULL) {
    printf("Error opening file name %s\n", filename);
    return 1;
  }

  char* string_buffer = malloc(30*sizeof(char));

  while (fgets(string_buffer, 20, fp) != NULL) {
    printf("%s", string_buffer);
  }

  fclose(fp);
  printf("Closed the file\n");

}
