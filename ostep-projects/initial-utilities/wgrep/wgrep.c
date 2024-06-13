#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void grep(FILE* fp, char* search_text) {
    char* line = NULL;
    size_t len = 0;

    while (getline(&line, &len, fp) != -1) {
      char * match = strstr(line, search_text);
      if (match != NULL) {
        printf("%s", line);
      }
    }
    free(line);
}

int main(int argc, char* argv[]) {
  if (argc == 1) {
    printf("wgrep: searchterm [file ...]\n");
    return 1;
  }
  char *search_text = argv[1];

  if (strlen(search_text) == 0) {
    return 0;
  }

  if (argc == 2) {
    grep(stdin, search_text);
    return 0;

  }

  for (int i = 2; i < argc; i++) {
    char* file_name = argv[i];

    FILE* fp = fopen(file_name, "r");
    if (fp == NULL) {
      printf("wgrep: cannot open file\n");
      return 1;
    }
    grep(fp, search_text);
    fclose(fp);
  }
}
