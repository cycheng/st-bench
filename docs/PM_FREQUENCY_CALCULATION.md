# PM Frequency Calculation

This document explains how `PM Post Deep Sleep Freq average (best benchmark run)`
is calculated.

## PM collection command

```bash
sudo -n /opt/amd-apps/agt_internal/agt_internal \
  -unilog=PM \
  -unilogallgroups \
  -unilogperiod=50 \
  -i=0 \
  -unilogoutput=<pm-output.csv>
```

- `-unilogperiod=50` samples the PM counters every 50 us.
- `-i=0` means monitor GPU0. To monitor GPUn, use `-i=5n`.

The benchmark script enables this collection with `--pm-log-maf`. Pass
`--gpu <n>` to run the workload with `HIP_VISIBLE_DEVICES=<n>` and to monitor
that GPU (`-i=0` for GPU 0, `-i=5` for GPU 1). Add `--keep-pm-log` if the raw
PM CSV files should be retained.

## Calculation

For every PM row:

1. Read `Post Deep Sleep Freq` for XCD0 through XCD7.
2. Average the eight XCD frequencies to get the row average.
3. Find the first row average below 2000. This is the begin row.
4. Find the first subsequent row average above 2000. This is the end row.
5. Drop the begin and end rows.
6. Select the minimum row average from the remaining rows.

That minimum is `all-xcd-average-min-row`.

## Example

```text
         XCD0  XCD1  XCD2  XCD3  XCD4  XCD5  XCD6  XCD7   Row average
Row 1:  2354  2363  2360  2357  2351  2353  2362  2363   2358  <- idle
Row 2:  1861  1850  1870  1838  1852  1835  1879  1840   1853  <- begin
Row 3:  1660  1640  1672  1630  1646  1621  1681  1625   1647
Row 4:  1659  1639  1669  1628  1645  1620  1678  1627   1646
Row 5:  1628  1611  1642  1601  1617  1592  1653  1598   1618
Row 6:  2287  2297  2296  2291  2290  2289  2304  2299   2294  <- end
```

Row 2 is the first row below 2000, and Row 6 is the first row back above
2000. Drop these two boundary rows and keep Rows 3 through 5:

```text
all-xcd-average-min-row = min(1647, 1646, 1618) = 1618
```

## Repeated benchmark runs

If the benchmark is repeated three times, the script uses the PM log from the
best-performing run—the run with the highest GFLOPS for MAF. Its
`all-xcd-average-min-row` is shown under:

```text
PM Post Deep Sleep Freq average (best benchmark run)
```

If multiple runs have the same best score, the first best run is used.

## Warning cases

The result is marked with `*` when the PM window may be unreliable:

- Fewer than three rows exist from the begin row through the end row.
- No row average drops below 2000, so no begin row is found.
- The row average never returns above 2000, so no end row is found.

The script still calculates a result when possible, but the `*` indicates that
it should be reviewed carefully.
