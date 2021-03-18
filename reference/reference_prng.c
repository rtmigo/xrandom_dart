// SPDX-FileCopyrightText: Copyright (c) 2021 Art Galkin <github.com/rtmigo>
// SPDX-License-Identifier: MIT

// runs reference implementations of random number generators.
// The generated numbers are written to multiple JSON files
// in the current directory

#include <stdio.h>
#include <stdint.h>

#define VALUES_PER_SAMPLE 1024

int opened_files = 0;
int closed_files = 0;

////////////////////////////////////////////////////////////////////////////////

FILE* open_ref_outfile(
	char* alg_name,
	char* description,
	char* seed_id,
	char* seed, 
	char* type_suffix)
	{

	char filename[256];	
	snprintf(filename, sizeof filename, "%s_%s_%s.json",
		alg_name, seed_id, type_suffix);
	printf("+ %s\n", filename);

	opened_files++;

	FILE *result = fopen(filename, "w");

	fprintf(result, "{\n");
	fprintf(result, "'algorithm': '%s',\n", alg_name);
	fprintf(result, "'description': '%s',\n", description);
	fprintf(result, "'seed': '%s',\n", seed);
	fprintf(result, "'seed id': '%s',\n", seed_id);
	fprintf(result, "'type': '%s',\n", type_suffix);
	fprintf(result, "'values': [\n");
	fprintf(result, "\n");

	return result;
}

FILE* open_ref_outfile_old(
	char* alg_name,
	char* seed_id,
	char* seed, 
	char* type_suffix) {
		return open_ref_outfile(alg_name, "", seed_id, seed, type_suffix);
}

void close_ref_outfile(FILE* f) {
	closed_files++;
	fprintf(f, "]},\n\n");
	fclose(f);
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
// Jurgen A. Doornik. 2007. Conversion of high-period random numbers to 
// floating point. ACM Trans. Model. Comput. Simul. 17, 1, Article 3 
// (January 2007). DOI=10.1145/1189756.1189759 
// http://doi.acm.org/10.1145/1189756.118975

#define M_RAN_INVM32 2.32830643653869628906e-010
#define M_RAN_INVM52 2.22044604925031308085e-016

#define RANDBL_32(iRan1) \
	((int)(iRan1)*M_RAN_INVM32 + 0.5)

#define RANDBL_32_NO_ZERO(iRan1) \
	((int)(iRan1)*M_RAN_INVM32 + (0.5 + M_RAN_INVM32 / 2))

//float number with 52bits
#define RANDBL_52_NO_ZERO(iRan1, iRan2) \
	((int)(iRan1)*M_RAN_INVM32 + (0.5 + M_RAN_INVM52 / 2) + \
	 (int)((iRan2)&0x000FFFFF) * M_RAN_INVM52)


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

// The state word must be initialized to non-zero 
uint32_t xorshift32(struct xorshift32_state *state)
{
	// Algorithm "xor" from p. 4 of Marsaglia, "Xorshift RNGs"
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
	FILE *ints_file = open_ref_outfile_old(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(alg_name, name, seed_str, 
		"double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(alg_name, name, seed_str, 
		"double_cast");
	FILE *doornik_file = open_ref_outfile_old(alg_name, name, seed_str, 
		"doornik_randbl_32");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {

		uint32_t x1 = xorshift32(&state);
		fprintf(ints_file, "'%08x',\n", x1);
		fprintf(doornik_file, "'%.20e',\n", RANDBL_32(x1));

		uint32_t x2 = xorshift32(&state);
		fprintf(ints_file, "'%08x',\n", x2);
		fprintf(doornik_file, "'%.20e',\n", RANDBL_32(x2));

		uint64_t combined = (((uint64_t)x1)<<32)|x2;

		fprintf(doubles_file, "'%.20e',\n", 
			vigna_uint64_to_double_mult(combined));
		fprintf(doubles_cast_file, "'%.20e',\n", 
			vigna_uint64_to_double_alt(combined));
		
	}	

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
	close_ref_outfile(doornik_file);
}

////////////////////////////////////////////////////////////////////////////////
// AMX

uint32_t xorshift32amx(struct xorshift32_state* state) {
	// https://stackoverflow.com/a/52056161
	// https://gist.github.com/Marc-B-Reynolds/82bcd9bd016246787c95
	int s = __builtin_bswap32(state->a * 1597334677);
	state->a ^= state->a << 13;
	state->a ^= state->a >> 17;
	state->a ^= state->a << 5;
	return state->a + s;
}

void write_xorshift32amx(char* name, uint64_t seed) {

	struct xorshift32_state state;
	state.a = seed;

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "0x%x", state.a);

	char* alg_name = "xorshift32amx";
	FILE *ints_file = open_ref_outfile_old(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(alg_name, name, seed_str, 
		"double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(alg_name, name, seed_str, 
		"double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {

		uint32_t x1 = xorshift32amx(&state);
		fprintf(ints_file, "'%08x',\n", x1);

		uint32_t x2 = xorshift32amx(&state);
		fprintf(ints_file, "'%08x',\n", x2);

		uint64_t combined = (((uint64_t)x1)<<32)|x2;

		fprintf(doubles_file, "'%.20e',\n", 
				vigna_uint64_to_double_mult(combined));
		fprintf(doubles_cast_file, "'%.20e',\n", 
				vigna_uint64_to_double_alt(combined));
	}	

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
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
	FILE *ints_file = open_ref_outfile_old(
			alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = xorshift64(&state);
		fprintf(ints_file, "'%016llx',\n", x);

		fprintf(doubles_file, "'%.20e',\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "'%.20e',\n", vigna_uint64_to_double_alt(x));
	}	

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
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

	printf("'xorshift128 (seed %u %u %u %u)': [\n", 
		state.a, state.b, state.c, state.d);

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
	snprintf(seed_str, sizeof seed_str, "%u %u %u %u", 
		state.a, state.b, state.c, state.d);

	char* alg_name = "xorshift128";
	FILE *ints_file = open_ref_outfile_old(
			alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {

		uint32_t x1 = xorshift128(&state);
		fprintf(ints_file, "'%08x',\n", x1);

		uint32_t x2 = xorshift128(&state);
		fprintf(ints_file, "'%08x',\n", x2);

		uint64_t combined = (((uint64_t)x1)<<32)|x2;

		fprintf(doubles_file, "'%.20e',\n", 
				vigna_uint64_to_double_mult(combined));
		fprintf(doubles_cast_file, "'%.20e',\n", 
				vigna_uint64_to_double_alt(combined));
	}	

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
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
	FILE *ints_file = open_ref_outfile_old(
			alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = xorshift128plus_int(s);
		fprintf(ints_file, "'%016llx',\n", x);

		fprintf(doubles_file, "'%.20e',\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "'%.20e',\n", vigna_uint64_to_double_alt(x));
	}

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
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

void write_xoshiro128pp(
	char* name, 
	uint32_t a, uint32_t b, uint32_t c, uint32_t d) {

	uint32_t s[4];
	s[0]=a;
	s[1]=b;
	s[2]=c;
	s[3]=d;

 	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "%u %u %u %u", a, b, c, d);

	char* alg_name = "xoshiro128pp";
	FILE *ints_file = open_ref_outfile_old(
			alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {

		uint32_t x1 = xoshiro128pp(s);
		fprintf(ints_file, "'%08x',\n", x1);

		uint32_t x2 = xoshiro128pp(s);
		fprintf(ints_file, "'%08x',\n", x2);

		uint64_t combined = (((uint64_t)x1)<<32)|x2;

		fprintf(doubles_file, "'%.20e',\n", 
				vigna_uint64_to_double_mult(combined));
		fprintf(doubles_cast_file, "'%.20e',\n", 
				vigna_uint64_to_double_alt(combined));

		// uint64_t x = xorshift128plus_int(s);
		// fprintf(ints_file, "%016llx\n", x);

		// fprintf(doubles_file, "%.20e\n", vigna_uint64_to_double_mult(x));
		// fprintf(doubles_cast_file, "%.20e\n", vigna_uint64_to_double_alt(x));
	}

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
}

////////////////////////////////////////////////////////////////////////////////
// XOSHIRO256++ 1.0
//
// https://prng.di.unimi.it/xoshiro256plusplus.c
// Written in 2019 by David Blackman and Sebastiano Vigna (vigna@acm.org) CC-0
//
// "This is xoshiro256++ 1.0, one of our all-purpose, rock-solid generators.
//  It has excellent (sub-ns) speed, a state (256 bits) that is large
//  enough for any parallel application, and it passes all tests we are
//  aware of.
//
//  For generating just floating-point numbers, xoshiro256+ is even faster.
//
//  The state must be seeded so that it is not everywhere zero. If you have
//  a 64-bit seed, we suggest to seed a splitmix64 generator and use its
//  output to fill s.

static inline uint64_t xoshiro256pp_rotl(const uint64_t x, int k) {
	return (x << k) | (x >> (64 - k));
}


//static uint64_t s[4];

uint64_t xoshiro256pp_next(uint64_t* s) {
	const uint64_t result = xoshiro256pp_rotl(s[0] + s[3], 23) + s[0];

	const uint64_t t = s[1] << 17;

	s[2] ^= s[0];
	s[3] ^= s[1];
	s[1] ^= s[2];
	s[0] ^= s[3];

	s[2] ^= t;

	s[3] = xoshiro256pp_rotl(s[3], 45);

	return result;
}

void write_xoshiro256pp(
	char* name, 
	uint64_t a, uint64_t b, uint64_t c, uint64_t d) {

	uint64_t s[4];

	s[0] = a;
	s[1] = b;
	s[2] = c;
	s[3] = d;

 	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, 
			 "0x%llx 0x%llx 0x%llx 0x%llx", a, b, c, d);

	char* alg_name = "xoshiro256pp";
	FILE *ints_file = open_ref_outfile_old(
			alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = xoshiro256pp_next(s);
		fprintf(ints_file, "'%016llx',\n", x);

		fprintf(doubles_file, "'%.20e',\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "'%.20e',\n", vigna_uint64_to_double_alt(x));
	}

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
}

////////////////////////////////////////////////////////////////////////////////
// SPLITMIX64
//
// https://prng.di.unimi.it/splitmix64.c
// Written in 2015 by Sebastiano Vigna (vigna@acm.org) CC-0
//
// "It is a very fast generator passing BigCrush, and it can be useful if
//  for some reason you absolutely want 64 bits of state."

// static uint64_t x; /* The state can be seeded with any value. */

struct splitmix64_state {
  uint64_t x;
};

uint64_t next_splitmix64(struct splitmix64_state *state) {
	uint64_t z = (state->x += 0x9e3779b97f4a7c15);
	z = (z ^ (z >> 30)) * 0xbf58476d1ce4e5b9;
	z = (z ^ (z >> 27)) * 0x94d049bb133111eb;
	return z ^ (z >> 31);
}

void write_splitmix64(char* name, uint64_t a) {

	struct splitmix64_state state;
	state.x = a;

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "0x%llx", a);

	char* alg_name = "splitmix64";
	FILE *ints_file = open_ref_outfile_old(alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(alg_name, name, 
		seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(alg_name, name, 
		seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint64_t x = next_splitmix64(&state);
		fprintf(ints_file, "'%016llx',\n", x);

		fprintf(doubles_file, "'%.20e',\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "'%.20e',\n", vigna_uint64_to_double_alt(x));
	}

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
}

////////////////////////////////////////////////////////////////////////////////
// SPLITMIX32
// Written in 2016 by Kaito Udagawa
// Released under CC0 <http://creativecommons.org/publicdomain/zero/1.0/>
// https://github.com/umireon/my-random-stuff/blob/master/xorshift/splitmix32.c

uint32_t next_splitmix32(uint32_t *x) {
  uint32_t z = (*x += 0x9e3779b9);
  z = (z ^ (z >> 16)) * 0x85ebca6b;
  z = (z ^ (z >> 13)) * 0xc2b2ae35;
  return z ^ (z >> 16);
}

void write_splitmix32(char* name, uint32_t a) {


 	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "0x%x", a);

	char* alg_name = "splitmix32";
	FILE *ints_file = open_ref_outfile_old(
			alg_name, name, seed_str, "int");
	FILE *doubles_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_mult");
	FILE *doubles_cast_file = open_ref_outfile_old(
			alg_name, name, seed_str, "double_cast");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint32_t x = next_splitmix32(&a);
		fprintf(ints_file, "'%08x',\n", x);

		fprintf(doubles_file, "'%.20e',\n", vigna_uint64_to_double_mult(x));
		fprintf(doubles_cast_file, "'%.20e',\n", vigna_uint64_to_double_alt(x));
	}

	close_ref_outfile(doubles_cast_file);
	close_ref_outfile(doubles_file);
	close_ref_outfile(ints_file);
}

////////////////////////////////////////////////////////////////////////////////

struct xorwow_state {
	uint32_t a, b, c, d, e;
	uint32_t counter;
};

/* The state array must be initialized to not be all zero in the first four words */
uint32_t xorwow(struct xorwow_state *state)
{
	/* Algorithm "xorwow" from p. 5 of Marsaglia, "Xorshift RNGs" */
	uint32_t t = state->e;
	uint32_t s = state->a;
	state->e = state->d;
	state->d = state->c;
	state->c = state->b;
	state->b = s;
	t ^= t >> 2;
	t ^= t << 1;
	t ^= s ^ (s << 4);
	state->a = t;
	state->counter += 362437;
	return t + state->counter;
}

////////////////////////////////////////////////////////////////////////////////
// The "Lemire Method" <https://arxiv.org/abs/1805.10941> implemented 
// by D. Lemire for Python (License: Apache):
// <https://github.com/lemire/fastrand/blob/master/fastrandmodule.c>

struct xorshift64_state lemire_feeder_state;
uint64_t lemire_feeder_x = 0;


uint32_t lemire_feed() {
	if (lemire_feeder_x==0) {
		lemire_feeder_x = xorshift64(&lemire_feeder_state);
		return lemire_feeder_x>>32;
	}
	uint32_t result = lemire_feeder_x & 0xFFFFFFFF;
	lemire_feeder_x = 0;
	return result;
}

uint32_t lemire_feeder_reset(uint32_t seed) {
	lemire_feeder_state.a = seed;
}

static inline uint32_t lemire_bounded(uint32_t range) {
	// renamed from "pcg32_random_bounded_divisionless"
	uint64_t random32bit, multiresult;
	uint32_t leftover;
	uint32_t threshold;
	random32bit =  lemire_feed();
	multiresult = random32bit * range;
	leftover = (uint32_t) multiresult;
	if(leftover < range ) {
		threshold = -range % range ;
		while (leftover < threshold) {
			random32bit =  lemire_feed();
			multiresult = random32bit * range;
			leftover = (uint32_t) multiresult;
		}
	}
	return multiresult >> 32; // [0, range)
}

void write_lemire(char* name, uint32_t range) {

	lemire_feeder_reset(777);

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "0x%x", range);

	char* alg_name = "lemire";
	FILE *ints_file = open_ref_outfile(
			alg_name, 
			"Generating uint32s in range. "
			"Source uint32s are from xorshift64 (seed 777) "
			"with 64-bit output splitted as upper 32, then lower 32. "
			"The arg is the range (upper bound).",
			name, seed_str, "int");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint32_t x = lemire_bounded(range);
		fprintf(ints_file, "'%08x',\n", x);
	}

	close_ref_outfile(ints_file);
}

static inline uint32_t lemire_bounded_debug(uint32_t range) {
	// renamed from "pcg32_random_bounded_divisionless"
	printf("range %d\n", range);
	uint64_t random32bit, multiresult;
	uint32_t leftover;
	uint32_t threshold;
	random32bit =  lemire_feed();
	multiresult = random32bit * range;
	leftover = (uint32_t) multiresult;
	printf("leftover %u\n", leftover);
	if(leftover < range ) {
		threshold = -range % range;
		printf("threshold %u\n", threshold);
		while (leftover < threshold) {
			random32bit =  lemire_feed();
			multiresult = random32bit * range;
			leftover = (uint32_t) multiresult;
		}
	}
	printf("final multiresult %llu\n", multiresult);
	return multiresult >> 32; // [0, range)
}

void debug_lemire() {

	lemire_feeder_reset(777);
	int t = lemire_bounded_debug(0x7FFFFFFF);
	printf("t %d\n", t);
}

////////////////////////////////////////////////////////////////////////////////
// http://www.pcg-random.org/posts/bounded-rands.html
// (c) 2018 Melissa E. O'Neill (License: MIT)
// "The fastest (unbiased) method is Lemire's (with an extra tweak)"

uint32_t lemire_neill_bounded(uint32_t range) {

	uint32_t x = lemire_feed();
	uint64_t m = (uint64_t)x * (uint64_t)range;
	uint32_t l = (uint32_t)m;
	if (l < range) {
		uint32_t t = -range;
		if (t >= range) {
			t -= range;
			if (t >= range) 
				t %= range;
		}
		while (l < t) {
			x = lemire_feed();
			m = (uint64_t)x * (uint64_t)range;
			l = (uint32_t)m;
		}
	}
	return m >> 32;
}

void write_lemire_neill(char* name, uint32_t range) {

	lemire_feeder_reset(777);

	char seed_str[256];
	snprintf(seed_str, sizeof seed_str, "0x%x", range);

	char* alg_name = "lemire-neill";
	FILE *ints_file = open_ref_outfile(
			alg_name, 
			"Generating uint32s in range. "
			"Source uint32s are from xorshift64 (seed 777) "
			"with 64-bit output splitted as upper 32, then lower 32. "
			"The arg is the range (upper bound).",
			name, seed_str, "int");

	for (int i=0; i<VALUES_PER_SAMPLE; ++i) {
		uint32_t x = lemire_neill_bounded(range);
		fprintf(ints_file, "'%08x',\n", x);
	}

	close_ref_outfile(ints_file);
}

////////////////////////////////////////////////////////////////////////////////

int main()
{
	// printf("-----\n");
	// debug_lemire();
	// printf("-----\n");
	// return 1;

	#define PI32 314159265
	#define PI64 3141592653589793238ll

	write32("a", 1);
	write32("b", 42);
	write32("c", PI32);

	write_xorshift32amx("a", 1);
	write_xorshift32amx("b", 42);
	write_xorshift32amx("c", PI32);

	write64(1, "a");
	write64(42, "b");
	write64(PI64, "c");

	write128p("a", 1, 2);
	write128p("b", 42, 777);
	write128p("c", 8378522730901710845llu, 1653112583875186020llu);

	write128("a", 1, 2, 3, 4);
	write128("b", 5, 23, 42, 777);
	write128("c", 1081037251u, 1975530394u, 2959134556u, 1579461830u);	

	write_xoshiro128pp("a", 1, 2, 3, 4);
	write_xoshiro128pp("b", 5, 23, 42, 777);
	write_xoshiro128pp("c", 1081037251u, 1975530394u, 
							2959134556u, 1579461830u);

	write_xoshiro256pp("a", 1, 2, 3, 4);
	write_xoshiro256pp("b", 5, 23, 42, 777);
	write_xoshiro256pp("c", 0x621b97ff9b08ce44ull, 0x92974ae633d5ee97ull, 
							0x9c7e491e8f081368ull, 0xf7d3b43bed078fa3ull);

	write_splitmix64("a", 1);
	write_splitmix64("b", 0);
	write_splitmix64("c", 777);
	write_splitmix64("d", 0xf7d3b43bed078fa3ull);

	write_splitmix32("a", 1);
	write_splitmix32("b", 0);
	write_splitmix32("c", 777);
	write_splitmix32("d", 1081037251u);

	write_lemire("1000", 1000);
	write_lemire("1", 1);
	
	write_lemire("FFx", 0xFFFFFFFFu);
	write_lemire("7Fx", 0x7FFFFFFFu);
	write_lemire("80x", 0x80000000u);
	write_lemire("R1", 0x0f419dc8u);
	write_lemire("R2", 0x32e7aeecu);

	write_lemire_neill("1000", 1000);
	write_lemire_neill("1", 1);
	write_lemire_neill("FFx", 0xFFFFFFFFu);
	write_lemire_neill("7Fx", 0x7FFFFFFFu);
	write_lemire_neill("80x", 0x80000000u);
	write_lemire_neill("R1", 0x0f419dc8u);
	write_lemire_neill("R2", 0x32e7aeecu);

	
	


	printf("Created %d files.\n", opened_files);
}
