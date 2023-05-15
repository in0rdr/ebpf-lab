#include <stdio.h>
#include <time.h>

int output(int hour, int min, int sec) {
  printf("Current time: %d:%d:%d \n", hour, min, sec);
}

int main(int argc, char** argv) {
  struct timespec timer = { 0, 700000000 };
  time_t datetime;
  // see /usr/include/bits/types/struct_tm.h
  struct tm i;

  for (;;) {
    datetime = time(NULL);
    localtime_r(&datetime, &i);
    output(i.tm_hour, i.tm_min, i.tm_sec);
    nanosleep(&timer, &timer);
  }
}
