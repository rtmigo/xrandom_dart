- nextInt(max) now supports any positive [max] values 

- nextFloat() method now uses more accurate type of conversion

- added RandomBase32.nextInt64()

- nextDoubleMemcast renamed to nextDoubleBitcast

- fixed: RandomBase64.nextInt32() can return 0 (this should 
  be reflected in the documentation) 

# 0.3.2

- Alias names changed

- Alias constructors are unified

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