#ifndef SIMPLEX_HPP
#define SIMPLEX_HPP

#define HI(x) *(1+(int*)&x)
#define LO(x) *(int*)&x

static inline double fast_abs(double x)
{
	HI(x) &= 0x7fffffff;
	return x;
}

static inline int fast_floor(float x)
{
	return (x > 0) ? (static_cast<int>(x)) : ((static_cast<int>(x)) - 1);
}

extern void  simplex_seed(int seed);
extern float simplex_noise(float x, float y);
extern float simplex_fbm(float x, float y, float f, float a, float l, float p, int o);

#endif