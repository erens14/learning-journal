# Decimal to Binary Conversion

## Overview

Although IP addresses are commonly written in **decimal notation**, computers process them in **binary**.

Understanding binary is essential because IPv4 addresses, subnet masks, and subnetting calculations are all based on binary values.

## Decimal vs Binary

Humans naturally count using the **decimal (base-10)** number system.

Decimal digits:

```text
0 1 2 3 4 5 6 7 8 9
```

Each column increases by a factor of **10**.

| 1000 | 100 | 10 |  1 |
| ---: | --: | -: | -: |

Computers, however, use the **binary (base-2)** number system.

Binary digits:

```text
0 1
```

Each column increases by a factor of **2**.

| 128 | 64 | 32 | 16 |  8 |  4 |  2 |  1 |
| --: | -: | -: | -: | -: | -: | -: | -: |

## Binary Conversion Process

The conversion follows a simple rule:

Starting from the largest value, ask:

> **Can this value fit into the remaining decimal number?**

* Yes → Write **1** and subtract the value.
* No → Write **0** and move to the next column.

Continue until reaching the last column (1).

### Example 1 — Convert 236 to Binary

```text
Decimal = 236

128 ✓   Remaining = 108
 64 ✓   Remaining = 44
 32 ✓   Remaining = 12
 16 ✗
  8 ✓   Remaining = 4
  4 ✓   Remaining = 0
  2 ✗
  1 ✗
```

Result:

```text
236 = 11101100₂
```

Verification:

```text
128 + 64 + 32 + 8 + 4

= 236 ✓
```

### Example 2 — Convert 179 to Binary

```text
Decimal = 179

128 ✓   Remaining = 51
 64 ✗
 32 ✓   Remaining = 19
 16 ✓   Remaining = 3
  8 ✗
  4 ✗
  2 ✓   Remaining = 1
  1 ✓   Remaining = 0
```

Result:

```text
179 = 10110011₂
```

Verification:

```text
128 + 32 + 16 + 2 + 1

= 179 ✓
```

## Quick Reference

[!TIP]

| Decimal | Binary   |
| ------: | :------- |
|       1 | 00000001 |
|       2 | 00000010 |
|       4 | 00000100 |
|       8 | 00001000 |
|      16 | 00010000 |
|      32 | 00100000 |
|      64 | 01000000 |
|     128 | 10000000 |

Memorizing these eight values makes subnetting much easier later.

## Tips

When converting decimal to binary:

1. Always start from the **largest binary value**.
2. Subtract the value whenever possible.
3. Continue until the remaining value becomes **0**.
4. Verify the answer by adding every column that contains **1**.

## Why This Matters

Binary conversion is one of the most important prerequisites for:

* IPv4 Addressing
* CIDR Notation
* Subnet Masks
* Subnetting
* Route Summarization

A solid understanding of binary makes subnetting much easier to understand.

## My Takeaways

* Computers interpret IP addresses in binary, even though humans write them in decimal.
* Binary uses only two digits (0 and 1), with each column representing a power of two.
* Converting decimal to binary follows a simple "fit or not fit" approach.
* Checking the result by adding all active bit values helps verify the conversion.
* Memorizing the values **128, 64, 32, 16, 8, 4, 2, 1** will significantly speed up subnetting calculations.
