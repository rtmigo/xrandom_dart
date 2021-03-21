# 0.6.2

- Updated documentation

- Minor improvements

# 0.6.0

- Tests have been removed from the pub.dev package to reduce the size 
  of the library

- Updated documentation

# 0.5.1

- Aliases changed to Xrandom, Qrandom, Drandom

- expected() methods changed to seeded()

- Added Mulberry32

- Added nextRaw53()

- Renamed nextIntNN() methods to nextRawNN() 

- nextInt() works faster 

- fixed: the case of generating zero by 64-bit generators

# 0.4.0

- nextFloat() method now uses more accurate type of conversion

- added RandomBase32.nextInt64()

- nextDoubleMemcast() renamed to nextDoubleBitcast()

- fixed: nextInt() results were not uniform  

- fixed: RandomBase64.nextInt32() can return 0 (reflected 
  in the documentation) 

# 0.3.2

- Alias names changed

- Alias constructors unified

- Example updated

# 0.2.2

- Added Splitmix64 algorithm

- Better time-based seeds for all generators  

# 0.1.1

- Added Xrandom and Xrandom64 aliases

- Added xoshiro128++ 

- deterministic() replaced to expected()

- Speed improvements

- Changed the order in which the results appear nextBool() results appear

- Improved the accuracy of nextDouble() in Xorshift64 and 
  Xorshift120p for exact matching of reference values
    
- Changed the order of nextInt32() results in Xorshift64 and 
  Xorshift120p
 
  

# 0.0.2

- Added example
- Fixes for the causes of dart.pub warnings

# 0.0.1

- Initial release