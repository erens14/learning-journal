# IPv4 Address in Binary

## Overview

Although IPv4 addresses are written in **dotted decimal notation**, every octet is stored and processed internally in **binary**.

Since each octet contains **8 bits**, the possible decimal value of one octet ranges from **0 to 255**.

## Why Does an Octet Range from 0 to 255?

Each octet contains 8 bits.

```text
Bit Position

128   64   32   16    8    4    2    1
```

Possible values:

Lowest value

```text
00000000
= 0
```

Highest value

```text
11111111
```

```text
128 + 64 + 32 + 16 + 8 + 4 + 2 + 1
= 255
```

Therefore:

```text
Each IPv4 octet ranges from 0–255.
```

## Converting an IPv4 Address to Binary

Example IPv4 address:

```text
192.168.10.15
```

Convert **each octet independently**.

### Octet 1

Decimal:

```text
192
```

Calculation:

```text
128 ✓
 64 ✓
 32 ✗
 16 ✗
  8 ✗
  4 ✗
  2 ✗
  1 ✗
```

Binary:

```text
11000000
```

Verification:

```text
128 + 64 = 192
```

### Octet 2

Decimal:

```text
168
```

Calculation:

```text
128 ✓
 64 ✗
 32 ✓
 16 ✗
  8 ✓
  4 ✗
  2 ✗
  1 ✗
```

Binary:

```text
10101000
```

Verification:

```text
128 + 32 + 8 = 168
```

### Octet 3

Decimal:

```text
10
```

Calculation:

```text
128 ✗
 64 ✗
 32 ✗
 16 ✗
  8 ✓
  4 ✗
  2 ✓
  1 ✗
```

Binary:

```text
00001010
```

Verification:

```text
8 + 2 = 10
```

### Octet 4

Decimal:

```text
15
```

Calculation:

```text
128 ✗
 64 ✗
 32 ✗
 16 ✗
  8 ✓
  4 ✓
  2 ✓
  1 ✓
```

Binary:

```text
00001111
```

Verification:

```text
8 + 4 + 2 + 1 = 15
```

## Complete Conversion

```text
Decimal

192.168.10.15
```

↓

```text
Binary

11000000.10101000.00001010.00001111
```

Each decimal octet is converted independently into its 8-bit binary representation.

## Conversion Workflow

```text
Decimal Octet

↓

Write Binary Values

128 64 32 16 8 4 2 1

↓

Check from Left to Right

Can the value fit?

↓

Yes → Write 1

No → Write 0

↓

Subtract Remaining Value

↓

Repeat Until Remaining = 0

↓

Verify by Adding All Active Bits
```

## Tips

* Always evaluate values from **128 → 1**.
* Convert one octet at a time.
* Every octet must contain **exactly 8 bits**.
* Always verify the result by summing all active bit values.

## Why This Matters

Binary conversion is the foundation for:

* Subnet Masks
* CIDR Notation
* Network & Host Identification
* Subnetting
* Route Summarization

Without understanding binary, subnetting calculations become much more difficult.

## My Takeaways

* Every IPv4 octet consists of exactly **8 bits**.
* One octet can represent decimal values from **0 to 255**.
* Each octet is converted independently into binary.
* The binary representation of an IP address is essential for understanding subnet masks and subnetting.
* Verifying the conversion by adding all active bit values helps ensure the calculation is correct.
