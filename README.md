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

not yet: the perf method audit (ledger item C, p-perf-method) comes first; the tables are rendered from captures by this publisher once it lands
