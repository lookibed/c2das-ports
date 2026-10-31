# c2das-ports

Real C programs converted to daslang by [c2das-re](https://github.com/lookibed/c2das-re), one
directory per program. Everything here is generated: `scripts/publish_ports.sh` in c2das-re
regenerates a directory from the pinned upstream release and commits it with the c2das-re commit
that produced it. Nothing is hand-edited; a fix belongs in c2das-re.

Each program directory holds the converted `.das` modules, the sidecar they were converted under,
the upstream release and its checksums, the generating c2das-re commit, the upstream license (the
conversion is a derived work) and a README with how to run it, which upstream tests pass and the
numbers of that generation.

<!-- generated below: c2das-re's scripts/publish_ports.sh renders everything under this line from each program's latest capture -->

## Programs

Each cell is the geometric mean, over the program's workloads (its startup row aside), of the lane's time over the native build's; a lane covering only some workloads names how many. A program's README holds its tables, its machine and its raw captures.

| Program              | Captured             | Machine                                    | Workloads | interpreter |           JIT |           exe |     AOT | interpreter, scc layout | JIT, scc layout | interpreter, single module | JIT, single module |
| :------------------- | :------------------- | :----------------------------------------- | --------: | ----------: | ------------: | ------------: | ------: | ----------------------: | --------------: | -------------------------: | -----------------: |
| [lua](lua/README.md) | 2026-10-31 23:48 UTC | x86_64, AMD FX(tm)-6300 Six-Core Processor |         5 |      222.93 | 7.37 (4 of 5) | 4.53 (4 of 5) | not yet |                  232.34 |  12.45 (4 of 5) |                     233.48 |     14.47 (4 of 5) |
