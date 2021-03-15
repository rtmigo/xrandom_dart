// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: CC-BY-4.0

// this file runs reference implementations of random number generators
// (RNG) to create lists of numbers. Those numbers are written into text files
//
// The data can be used for testing of alternate implementations
// of the same RNGs (to match the reference numbers to the newly generated)

#include <stdio.h>
//#include <math.h>
#include <stdint.h>

#define VALUES_PER_SAMPLE 4096

////////////////////////////////////////////////////////////////////////////////

FILE* open_ref_outfile(char* alg_name, char* sample_id, char* seed, char* type_suffix)
{
	char filename[256];	
	snprintf(filename, sizeof filename, "../test/data/%s_%s_%s.txt", alg_name, sample_id, type_suffix);
	FILE *result = fopen(filename, "w");

	fprintf(result, "# reference data for github.com/rtmigo/xrandom\n");
	fprintf(result, "# SPDX-FileCopyrightText: (c) 2021 Art Galkin <ortemeo@gmail.com>\n");
	fprintf(result, "# SPDX-License-Identifier: CC-BY-4.0\n");
	fprintf(result, "\n");

	fprintf(result, "# algo %s\n", alg_name);
	fprintf(result, "# seed %s\n", seed);
	fprintf(result, "\n");

	return result;
}

////////////////////////////////////////////////////////////////////////////////	

// "in C99 a 64-bit unsigned integer x should be converted to a 64-bit 
// double using the expression"
// by Sebastiano Vigna <https://prng.di.unimi.it/>

static double vigna_uint64_to_double_mult(uint64_t x) {
	return (x >> 11) * 0x1.0p-53;
}

// "An alternative, multiplication-free conversion" suggestion 
// by Sebastiano Vigna <https://prng.di.unimi.it/>
static inline double vigna_uint64_to_double_alt(uint64_t x) {
	const union { uint64_t i; double d; } u = { 
		.i = UINT64_C(0x3FF) << 52 | x >> 12 
	};
	return u.d - 1.0;
}

////////////////////////////////////////////////////////////////////////////////
// XORSHIFT32
//
// sample from https://en.wikipedia.org/wiki/Xorshift
//
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

void write32(char* name, uint64_t seed) {

    struct xorshift32_state state;
    state.a = seed;

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "%u", state.a);

	char* alg_name = "xorshift32";
	FILE *ints_file = open_ref_outfile(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile(alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile(alg_name, name, seed_str, "double_cast");

    for (int i=0; i<VALUES_PER_SAMPLE; ++i) {

		uint32_t x1 = xorshift32(&state);
		fprintf(ints_file, "%08x\n", x1);

		uint32_t x2 = xorshift32(&state);
		fprintf(ints_file, "%08x\n", x2);

		uint64_t combined = (((uint64_t)x1)<<32)|x2;

		fprintf(doubles_file, "%.20e\n", vigna_uint64_to_double_mult(combined));
		fprintf(doubles_cast_file, "%.20e\n", vigna_uint64_to_double_alt(combined));
	}	

	fclose(doubles_cast_file);
	fclose(doubles_file);
	fclose(ints_file);
}

////////////////////////////////////////////////////////////////////////////////
// XORSHIFT64
//
// sample from https://en.wikipedia.org/wiki/Xorshift
//
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

    for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = xorshift64(&state);
		printf("  \"%016llx\",\n", x); // 08jx for long

	}	

    printf("],\n\n");
}

void write64(uint64_t seed, char* name) {

    struct xorshift64_state state;
    state.a = seed;

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "%llu", state.a);

	char* alg_name = "xorshift64";
	FILE *ints_file = open_ref_outfile(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile(alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile(alg_name, name, seed_str, "double_cast");

    for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = xorshift64(&state);
		fprintf(ints_file, "%016llx\n", x);

		fprintf(doubles_file, "%.20e\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "%.20e\n", vigna_uint64_to_double_alt(x));
	}	

	fclose(doubles_cast_file);
	fclose(doubles_file);
	fclose(ints_file);
}

////////////////////////////////////////////////////////////////////////////////
// XORSHIFT128
//
// sample from https://en.wikipedia.org/wiki/Xorshift
//
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

    printf("'xorshift128 (seed %u %u %u %u)': [\n", state.a, state.b, state.c, state.d);

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
        printf("  \"%08x\",\n", xorshift128(&state)); // 08jx for long

    printf("],\n\n");
}

void write128(char* name, uint64_t a, uint64_t b, uint64_t c, uint64_t d) {

    struct xorshift128_state state;
    state.a = a;
    state.b = b;
    state.c = c;
    state.d = d;

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "%u %u %u %u", state.a, state.b, state.c, state.d);

	char* alg_name = "xorshift128";
	FILE *ints_file = open_ref_outfile(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile(alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile(alg_name, name, seed_str, "double_cast");

    for (int i=0; i<VALUES_PER_SAMPLE; ++i) {

		uint32_t x1 = xorshift128(&state);
		fprintf(ints_file, "%08x\n", x1);

		uint32_t x2 = xorshift128(&state);
		fprintf(ints_file, "%08x\n", x2);

		uint64_t combined = (((uint64_t)x1)<<32)|x2;

		fprintf(doubles_file, "%.20e\n", vigna_uint64_to_double_mult(combined));
		fprintf(doubles_cast_file, "%.20e\n", vigna_uint64_to_double_alt(combined));
	}	

	fclose(doubles_cast_file);
	fclose(doubles_file);
	fclose(ints_file);
}

////////////////////////////////////////////////////////////////////////////////
// XORSHIFT128+ (V1 ?)
// Not implemented in xrandom.
//
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
//	XORSHIFT128+ (V2 ?)
//  Implemented in xrandom as Xorshift128p.
//
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
} */

// the same code without using global variables:

uint64_t xorshift128plus_int(uint64_t *s) {
	uint64_t s1 = s[0];
	const uint64_t s0 = s[1];
	const uint64_t result = s0 + s1;
	s[0] = s0;
	s1 ^= s1 << 23; // a
	s[1] = s1 ^ s0 ^ (s1 >> 18) ^ (s0 >> 5); // b, c
	return result;
}

// code from https://github.com/AndreasMadsen/xorshift/blob/master/reference.c
// this is not from the article
// double xorshift128plus_double(void) {
// 	const uint64_t x = xorshift128plus_int();
// 	const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;
// 	return *((double *) &x_doublefied) - 1.0;
// } 


// refactored to avoid global variables:
double xorshift128plus_double(uint64_t *s) {

	const uint64_t x = xorshift128plus_int(s);
	const uint64_t x_doublefied = UINT64_C(0x3FF) << 52 | x >> 12;
	return *((double *) &x_doublefied) - 1.0;
}

void print128plus(uint64_t a, uint64_t b)
{
    printf("'xorshift128plus (seed %llu %llu)': [\n",  a, b);

	uint64_t s[2];

    s[0] = a;
    s[1] = b;

    for (int i=0; i<VALUES_PER_SAMPLE; ++i)
        printf("  \"%016llx\",\n", xorshift128plus_int(s));

    printf("],\n\n");
}

void write128p(char* name, uint64_t a, uint64_t b) {

	uint64_t s[2];

    s[0] = a;
    s[1] = b;

 	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "%llu %llu", a, b);

	char* alg_name = "xorshift128p";
	FILE *ints_file = open_ref_outfile(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile(alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile(alg_name, name, seed_str, "double_cast");

    for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = xorshift128plus_int(s);
		fprintf(ints_file, "%016llx\n", x);

		fprintf(doubles_file, "%.20e\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "%.20e\n", vigna_uint64_to_double_alt(x));
	}

	fclose(doubles_cast_file);
	fclose(doubles_file);
	fclose(ints_file);
}

// It it commented out because it was not needed for testing
// the dart xorshift.
// void print128plus_double(uint64_t a, uint64_t b)
// {
//     printf("const xorshift128plus_double_%d_%d = [\n",  a, b);
// 	uint64_t s[2];
//     s[0] = a;
//     s[1] = b;
//     for (int i=0; i<VALUES_PER_SAMPLE; ++i)
//         printf("  \"%.20e\",\n", xorshift128plus_double(&s)); 
//     printf("];\n\n");
// }

////////////////////////////////////////////////////////////////////////////////
// XOSHIRO128++ 1.0
//
// https://prng.di.unimi.it/xoshiro128plusplus.c
// Written in 2019 by David Blackman and Sebastiano Vigna (vigna@acm.org) CC-0
//
// "This is xoshiro128++ 1.0, one of our 32-bit all-purpose, rock-solid
//  generators. It has excellent speed, a state size (128 bits) that is
//  large enough for mild parallelism, and it passes all tests we are aware
//  of."

static inline uint32_t xoshiro128pp_rotl(const uint32_t x, int k) {
	return (x << k) | (x >> (32 - k));
}


//static uint32_t s[4];

uint32_t xoshiro128pp(uint32_t* s) {
	const uint32_t result = xoshiro128pp_rotl(s[0] + s[3], 7) + s[0];

	const uint32_t t = s[1] << 9;

	s[2] ^= s[0];
	s[3] ^= s[1];
	s[1] ^= s[2];
	s[0] ^= s[3];

	s[2] ^= t;

	s[3] = xoshiro128pp_rotl(s[3], 11);

	return result;
}

void printXoshiro128pp(uint32_t a, uint32_t b, uint32_t c, uint32_t d)
{
    printf("'xoshiro128++ (seed %08x %08x %08x %08x)': [\n", a, b, c, d);

	uint32_t s[4];
	s[0]=a;
	s[1]=b;
	s[2]=c;
	s[3]=d;

    for (int i=0; i<VALUES_PER_SAMPLE; ++i) 
        printf("  \"%08x\",\n", xoshiro128pp(s));

    printf("],\n\n");
}


////////////////////////////////////////////////////////////////////////////////



int main()
{
    #define PI32 314159265
    #define PI64 3141592653589793238ll

    // printf("\n\n%.*e\n\n", 0x1.0p-53);
	// printf("\n\n%.20e\n\n", 0x1.0p-53);
	// printf("\n\n%.60e\n\n", 0x1.0p-53);
    // return 0;

	printf("// generated by reference.c\n\n");
	printf("// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <github.com/rtmigo>\n");
	printf("// SPDX-License-Identifier: CC-BY-4.0\n");
	printf("\n");
	printf("// This file contains reference results created with\n");
	printf("// different random number generators\n\n");

	printf("const referenceData = {\n\n");

	write32("a", 1);
	write32("b", 42);
	write32("c", PI32);


	// print32(1);
	// print32(42);
	// print32(PI32);

	write64(1, "a");
	write64(42, "b");
	write64(PI64, "c");

	write128p("a", 1, 2);
	write128p("b", 42, 777);
	write128p("c", 8378522730901710845llu, 1653112583875186020llu);

	write128("a", 1, 2, 3, 4);
	write128("b", 5, 23, 42, 777);
	write128("c", 1081037251u, 1975530394u, 2959134556u, 1579461830u);	

	// print64(1);
	// print64(42);
	// print64(PI64);

	// print128(1, 2, 3, 4);
	// print128(5, 23, 42, 777);
	// print128(1081037251u, 1975530394u, 2959134556u, 1579461830u);

	// print128plus(1, 2);
	// print128plus(42, 777);
	// print128plus(8378522730901710845llu, 1653112583875186020llu);

	// printXoshiro128pp(1, 2, 3, 4);
	// printXoshiro128pp(5, 23, 42, 777);
	// printXoshiro128pp(1081037251u, 1975530394u, 2959134556u, 1579461830u);


	printf("};");
}