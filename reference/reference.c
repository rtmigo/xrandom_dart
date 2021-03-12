// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail.com>
// SPDX-License-Identifier: CC-BY-4.0

// this file runs reference implementations of random number generators
// to create lists of reference values and print them to the terminal.
// The values can be used for testing of alternate implementations of the same
// RNGs

// uh C, hello again

#include <stdio.h>
#include <stdint.h>

#define VALUES_PER_SAMPLE 1000

////////////////////////////////////////////////////////////////////////////////
// sample from https://en.wikipedia.org/wiki/Xorshift

// Refactored from
// George Marsaglia 2003 "Xorshift RNGs"
// https://www.jstatsoft.org/article/view/v008i14
//		page 3: "Here is a basic 32-bit xorshift C procedure that takes
//      a 32-bit seed value y:"
// 		unsigned long xor(){ 
//			static unsigned long y=2463534242; 
//			yˆ=(y<<13); y=(y>>17); return (yˆ=(y<<5)); 
//		}

struct xorshift32_state {
  uint32_t a;
};

/* The state word must be initialized to non-zero */
uint32_t xorshift32(struct xorshift32_state *state)
{
	/* Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs" */
	uint32_t x = state->a;
	x ^= x << 13;
	x ^= x >> 17;
	x ^= x << 5;
	return state->a = x;
}

void print32(uint32_t seed)
{
    printf("'xorshift32 (seed %d)': [\n", seed);

    struct xorshift32_state state;
    state.a = seed;

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
        printf("  \"%08x\",\n", xorshift32(&state));

    printf("],\n\n");
}

////////////////////////////////////////////////////////////////////////////////
// sample from https://en.wikipedia.org/wiki/Xorshift

//	Refactored from
//	George Marsaglia 2003 "Xorshift RNGs" 
// 	https://www.jstatsoft.org/article/view/v008i14
//
// 	page 4: For C compilers that have 64-bit integers, the following will 
//  provide an excellent period 264−1 RNG, given a 64-bitseed x:
//		unsigned long long xor64(){
//			static unsigned long long x=88172645463325252LL;
//			xˆ=(x<<13); xˆ=(x>>7); return (xˆ=(x<<17));
//		}

struct xorshift64_state {
  uint64_t a;
};

uint64_t xorshift64(struct xorshift64_state *state)
{
	uint64_t x = state->a;
	x ^= x << 13;
	x ^= x >> 7;
	x ^= x << 17;
	return state->a = x;
}

void print64(uint64_t seed)
{
    struct xorshift64_state state;
    state.a = seed;

    printf("'xorshift64 (seed %llu)': [\n", state.a);

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
		printf("  \"%016llx\",\n", xorshift64(&state)); // 08jx for long

    printf("],\n\n");
}

////////////////////////////////////////////////////////////////////////////////
// sample from https://en.wikipedia.org/wiki/Xorshift

//	Refactored from
//	George Marsaglia 2003 "Xorshift RNGs" 
// 	https://www.jstatsoft.org/article/view/v008i14
//
// 	page 5: 
//	Suppose we compare a xorshift RNG, period 2128−1, with a multiply-with-carry 
//	RNG of comparable period. First,the xorshift:
//		unsigned long xor128(){
//			static unsigned long x=123456789,y=362436069,z=521288629,w=88675123;
//			unsigned long t;t=(xˆ(x<<11));x=y;y=z;z=w;
//			return( w=(wˆ(w>>19))ˆ(tˆ(t>>8)) );}

struct xorshift128_state {
  uint32_t a, b, c, d;
};

/* The state array must be initialized to not be all zero */
uint32_t xorshift128(struct xorshift128_state *state)
{
	/* Algorithm "xor128" from p. 5 of Marsaglia, "Xorshift RNGs" */
	uint32_t t = state->d;

	uint32_t const s = state->a;
	state->d = state->c;
	state->c = state->b;
	state->b = s;

	t ^= t << 11;
	t ^= t >> 8;
	return state->a = t ^ s ^ (s >> 19);
}

void print128(uint64_t a, uint64_t b, uint64_t c, uint64_t d)
{
    struct xorshift128_state state;
    state.a = a;
    state.b = b;
    state.c = c;
    state.d = d;

    char* name = "xorshift128_seed";

    printf( "const %s_%d_%d_%d_%d = [\n",
            name, state.a, state.b, state.c, state.d );

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
        printf("  \"%08x\",\n", xorshift128(&state)); // 08jx for long

    printf("];\n\n");
}

////////////////////////////////////////////////////////////////////////////////
// Code found on from Wikipedia page.
//
// It's from:
//	Sebastiano Vigna
//	Further scramblings of Marsaglia’s xorshift generators
//	https://arxiv.org/abs/1404.0390 [v1] Tue, 1 Apr 2014 - page 8

struct xorshift128p_state {
  uint64_t a, b;
};

/* The state must be seeded so that it is not all zero */
uint64_t xorshift128p(struct xorshift128p_state *state)
{
	uint64_t t = state->a;
	uint64_t const s = state->b;
	state->a = s;
	t ^= t << 23;		// a
	t ^= t >> 17;		// b
	t ^= s ^ (s >> 26);	// c
	state->b = t;
	return t + s;
}

////////////////////////////////////////////////////////////////////////////////
//	Sebastiano Vigna
//	Further scramblings of Marsaglia’s xorshift generators
//	https://arxiv.org/abs/1404.0390 [v2] Mon, 14 Dec 2015 - page 6
//	https://arxiv.org/abs/1404.0390 [v3] Mon, 23 May 2016 - page 6

/* code from https://github.com/AndreasMadsen/xorshift/blob/master/reference.c

	uint64_t s[ 2 ];

	uint64_t xorshift128plus_int(void) {
		uint64_t s1 = s[0];
		const uint64_t s0 = s[1];
		const uint64_t result = s0 + s1;
		s[0] = s0;
		s1 ^= s1 << 23; // a
		s[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5); // b, c
		return result;
}
*/

// the same refactored to avoid global variables:

uint64_t xorshift128plus_int(uint64_t *s) {
	uint64_t s1 = s[0];
	const uint64_t s0 = s[1];
	const uint64_t result = s0 + s1;
	s[0] = s0;
	s1 ^= s1 << 23; // a
	s[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5); // b, c
	return result;
}

/* code from https://github.com/AndreasMadsen/xorshift/blob/master/reference.c
	this if not from the article
	double xorshift128plus_double(void) {
		const uint64_t x = xorshift128plus_int();
		const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;

		return *((double *) &x_doublefied) - 1.0;
	}
*/	

// refactored to avoid global variables:
double xorshift128plus_double(uint64_t *s) {
	const uint64_t x = xorshift128plus_int(s);
	const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;
	return *((double *) &x_doublefied) - 1.0;
}

void print128plus(uint64_t a, uint64_t b)
{
    printf("const xorshift128plus_%d_%d = [\n",  a, b);

	uint64_t s[2];

    s[0] = a;
    s[1] = b;

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
        printf("  \"%016llx\",\n", xorshift128plus_int(&s)); 

    printf("];\n\n");
}

void print128plus_double(uint64_t a, uint64_t b)
{
    printf("const xorshift128plus_double_%d_%d = [\n",  a, b);

	uint64_t s[2];

    s[0] = a;
    s[1] = b;

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
        printf("  \"%.20e\",\n", xorshift128plus_double(&s)); 

    printf("];\n\n");
}

////////////////////////////////////////////////////////////////////////////////

int main()
{
    #define PI32 314159265
    #define PI64 3141592653589793238ll

	printf("// generated by reference.c\n\n");
	printf("// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <ortemeo@gmail.com>\n");
	printf("// SPDX-License-Identifier: CC-BY-4.0\n");
	printf("\n");
	printf("// This file contains reference results created with\n");
	printf("// different random number generators\n\n");

	printf("const referenceData = {\n\n");

	print32(1);
	print32(42);
	print32(PI32);

	print64(1);
	print64(42);
	print64(PI64);


	printf("};");

//    print64(3);
//    print128(1,2,3,3);
//	print128plus(1,2);
//	print128plus_double(1,2);
}

// TODO:
// https://prng.di.unimi.it/xoshiro256plus.c
// https://prng.di.unimi.it/
// https://prng.di.unimi.it/xoshiro256plusplus.c