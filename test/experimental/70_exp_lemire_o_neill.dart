/*

2021-03-19
==========

I tried to make nextInt() faster than "the Java" method
and failed.

Was inspired by O'Neil <https://git.io/Jm0D7>.
In her experiments in C ++ with Xeon processors,
Lemire's algorithm was clearly ahead of the rest.

I was generating nextInt(max) where max is random
from [1, 1<<32] on A9 netbook with Ubuntu.

=======================================================

RandomBase64 does not override RandomBase32.nextInt32()
(which uses JDK algorithm)

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     755 |
| ✓  | *Random (dart:math)*   |     903 |
|    | Xoshiro256pp           |    1137 |

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     756 |
| ✓  | *Random (dart:math)*   |     902 |
|    | Xoshiro256pp           |    1152 |


RandomBase64 overrides RandomBase32.nextInt32()
with copy-pasted RandomBase32.nextInt32()
(i.e. the same JDK algorithm)

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     758 |
| ✓  | *Random (dart:math)*   |     893 |
|    | Xoshiro256pp           |    1141 |

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     756 |
| ✓  | *Random (dart:math)*   |     902 |
|    | Xoshiro256pp           |    1141 |


RandomBase64 overrides RandomBase32.nextInt32()
with hacked JDK algorithm: it's % hack by O'Neill:
(i.e. the same JDK algorithm)


| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     755 |
| ✓  | *Random (dart:math)*   |     878 |
|    | Xoshiro256pp           |    1266 |

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     769 |
| ✓  | *Random (dart:math)*   |     892 |
|    | Xoshiro256pp           |    1277 |


RandomBase64 overrides RandomBase32.nextInt32()
with divisionless algorithm (Lemire)

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
| ✓  | *Random (dart:math)*   |     883 |
|    | Xorshift64             |     911 | SLOWER THAN JDK
|    | Xoshiro256pp           |    1531 |

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
| ✓  | *Random (dart:math)*   |     888 |
|    | Xorshift64             |     900 |
|    | Xoshiro256pp           |    1534 |


RandomBase64 overrides RandomBase32.nextInt32()
with divisionless algorithm (Lemire) + O'Neill hacks

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     871 | HACK HELPS
| ✓  | *Random (dart:math)*   |     892 | BUT STILL SLOWER
|    | Xoshiro256pp           |    1566 | THAN JDK

| JS | Time (lower is better) | nextInt |
|----|------------------------|--------:|
|    | Xorshift64             |     891 |
| ✓  | *Random (dart:math)*   |     895 |
|    | Xoshiro256pp           |    1582 |

*/

import 'package:meta/meta.dart';
import 'package:xrandom/src/60_xorshift64.dart';

@internal
class Divisionless extends Xorshift64 {

  Divisionless(seed): super(seed);

  @override
  int nextInt(int range) {
    // D. Lemire's "nearly divisionless" algorithm <https://arxiv.org/pdf/1805.10941.pdf>
    // In Java: <https://git.io/Jm8en> <https://git.io/JmBI0>

    if (range < 1 || range > 0xFFFFFFFF) {
      throw RangeError.range(range, 1, 0xFFFFFFFF);
    }

    int multiresult = nextRaw32() * range;

    int leftover = multiresult & 0xffffffff;
    if (leftover < range) {
      final int threshold = (1 << 32) % range; // 2^32 % n
      while (leftover < threshold) {
        multiresult = nextRaw32() * range;
        leftover = multiresult & 0xffffffff;
      }
    }

    const urs = 32;
    final result = (multiresult >> urs) & ~(-1 << (64 - urs)); // (m >>> 32)

    assert(0 <= result);
    assert(result < range);

    return result;
  }
}

@internal
class DivisionlessHacked extends Xorshift64 {

  DivisionlessHacked(seed): super(seed);

  @override
  int nextInt(int range) {
    // D. Lemire's "nearly divisionless" algorithm <https://arxiv.org/pdf/1805.10941.pdf>
    // with modulo hack by O'Neil <https://git.io/Jm0D7>

    if (range < 1 || range > 0xFFFFFFFF) {
      throw RangeError.range(range, 1, 0xFFFFFFFF);
    }

    int m = nextRaw32() * range;
    int l = m & 0xffffffff;

    if (l < range) {
      // hack

      int t = (1 << 32);

      if (t >= range) {
        t -= range;
        if (t >= range) {
          t %= range;
        }
      }

      while (l < t) {
        m = nextRaw32() * range;
        l = m & 0xffffffff;
      }
    }

    const urs = 32;
    final result = (m >> urs) & ~(-1 << (64 - urs)); // (m >>> 32)

    assert(0 <= result);
    assert(result < range);

    return result;
  }
}

@internal
class JavaHacked extends Xorshift64 {

  JavaHacked(seed): super(seed);

  @override
  int nextInt(int max) {
    // the default "Java method" used in RandomBase32
    // rewritten to add O'Neill's modulo hack

    if (max < 1 || max > 0xFFFFFFFF) {
      throw RangeError.range(max, 1, 0xFFFFFFFF);
    }

    int r = nextRaw32();
    int m = max - 1;

    int u = r;

    for (;;) {
      int upm = u;

      // hacking upm%=max:
      if (upm >= max) {
        upm -= max;
        if (upm >= max) {
          upm %= max;
        }
      }

      if (u - (r = upm) + m >= 0) {
        break;
      }

      u = nextRaw32();
    }

    return r;
  }
}
