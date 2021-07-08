#include "random.hpp"

#include <stdint.h>

static uint64_t state;
static uint64_t where;

void random_seed(int seed)
{
	state = 0;
	where = (seed << 1) | 1;
	random_base();
	state += seed;
	random_base();
}

uint32_t random_base()
{
	uint64_t oldstate = state;
	state = oldstate * 6364136223846793005 + where;
	uint32_t xorshifted = ((oldstate >> 18) ^ oldstate) >> 27;
	uint32_t rot = oldstate >> 59;
	return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
}

int irandom(int min, int max)
{
	return random_base() % (max - min + 1) + min;
}

float frandom(float min, float max)
{
	return random_base() * (1.0f / static_cast<float>(0xFFFFFFFF)) * (max - min) + min;
}