#ifdef __APPLE__
#  include <sys/stat.h>
#  include <unistd.h>
#elif _WIN32
#  define _CRT_SECURE_NO_WARNINGS
#  define _CRT_NONSTDC_NO_WARNINGS
#  include <direct.h>
#  include <process.h>
#endif

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int run(char ** args) {
  assert(args && args[0]);

#ifdef __APPLE__
  pid_t pid = fork();
  if (pid == 0) {
    execvp(args[0], args);
    abort();
  } else if (pid > 0) {
    int sl = 0;
    assert(0 <= waitpid(pid, &sl, 0));
    if (WIFEXITED(sl)) return WEXITSTATUS(sl);
  }
#elif _WIN32
  if (0 == _spawnvp(_P_WAIT, args[0], (const char * const *)args)) {
    return 0;
  }
#endif

  fprintf(stderr, "failed to run child process: %s\n", args[0]);
  return 1;
}
#define RUN(...) do { char * args[] = { __VA_ARGS__, 0 }; if (run(args)) return 1; } while (0)

int main() {
#ifdef __APPLE__
  mkdir("deckie.app", 0777);
  mkdir("deckie.app/Contents", 0777);
  mkdir("deckie.app/Contents/MacOS", 0777);

  RUN("clang", "-fmodules", "-c", "-o", "app.o", "app.m");
  RUN("clang", "-o", "deckie.app/Contents/MacOS/deckie", "app.o");

  return 0;
#elif _WIN32
  RUN("clang", "-c", "-o", "app.o", "app.c");
  RUN("clang", "-o", "deckie.exe", "app.o");
  return 0;
#endif
}
