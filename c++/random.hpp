#ifndef RANDOM_HPP
#define RANDOM_HPP

#include <stdint.h>

extern void     random_seed(int seed);
extern uint32_t random_base();

extern int   irandom(int   min, int   max);
extern float frandom(float min, float max);

#endif