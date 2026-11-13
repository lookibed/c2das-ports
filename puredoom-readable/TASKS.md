# "Add a feature" tasks

Each task is given to a model together with ONE variant folder (`ugly/doom/` or `processed/doom/`),
this file's task text and `check.sh`. Each feature is switched on by a new command-line argument,
so the demos are the oracle twice over: with the argument absent every demo must stay in sync
(`./check.sh <variant> [interp|jit]` exits 0), and with it present the check below must hold.
Arguments after `--` go to the program after `-timedemo demoN`. The expected values come from a
reference implementation of each task in both variants (JIT; demo1 also under interp): they are
the same for both variants and both tiers. `jit` below can be `interp` (about 20-35 s a demo).

## 1. Kill log (a new console command)

**Task.** Add the command-line switch `-killlog`. While it is given, every time a monster dies -
`P_KillMobj` runs on a target whose flags have `MF_COUNTKILL` - the game prints one line through
`doom_print`:

```
kill tic=<gametic> type=<the target's mobjtype_t as a decimal number> by=<player|monster|world>
```

`by` is `world` when there is no source, `player` when the source is a player's mobj, `monster`
otherwise. The switch must not change the game.

**Check.**

```
./check.sh <variant> jit                                  # all 3 demos in sync (switch off)
./check.sh <variant> jit --grep 'kill ' -- -killlog       # all 3 demos in sync, and:
```

| demo  | `kill ` lines | sha256 of those lines (first 16 hex) |
| :---- | ------------: | :----------------------------------- |
| demo1 |            33 | `cf890d6429c0115c`                   |
| demo2 |            37 | `e0d4deca65b22823`                   |
| demo3 |            28 | `38c96b0f264abe54`                   |

## 2. Kill counter on screen

**Task.** Add the switch `-killhud`. While it is given, every frame drawn during a level shows
`KILLS <kills>/<total>` in the top-left corner of the screen: the console player's `killcount`
and the level's `totalkills`, drawn with the menu font (`M_WriteText`) at x=2, y=2, right after
`HU_Drawer` in `D_Display`. The switch must not change the game, only the picture.

**Check.** The tic lines carry `cs`, a hash of the game state, and `fb`, a hash of the frame:

```
./check.sh <variant> jit                                     # all 3 demos in sync (switch off)
./check.sh <variant> jit --state-only -- -killhud            # game state in sync, frames differ:
```

| demo  | expected output of the `--state-only` run                         |
| :---- | :---------------------------------------------------------------- |
| demo1 | `2664 tics, game state in sync; frame differs on 2661 tics`       |
| demo2 | `5444 tics, game state in sync; frame differs on 5441 tics`       |
| demo3 | `2743 tics, game state in sync; frame differs on 2740 tics`       |

The text drawn exactly as specified reproduces the reference run's frames:
`./check.sh <variant> jit --demo 1 --keep out -- -killhud` (it reports the desync of the frames,
expected), then `grep '^tic=' out/demo1.txt | sha256sum` gives
`2e6d0bd109e8870dcaf85be5100d7cf301e34c56b01aa9d617d7209ddd624b20`. Another position, font or
spelling changes that sha but not the table above.

## 3. Zombieman damage (one monster's behaviour)

**Task.** Add the option `-zombiedamage N` (an integer, default 1). The zombieman's (former human,
`MT_POSSESSED`) pistol attack multiplies the damage of each shot by N. The shot draws the same
random numbers in the same order as before; only its damage is multiplied.

**Check.**

```
./check.sh <variant> jit                                     # all 3 demos in sync (option absent)
./check.sh <variant> jit -- -zombiedamage 1                  # all 3 demos in sync (factor 1)
./check.sh <variant> jit -- -zombiedamage 3                  # desyncs exactly as below
```

| demo  | expected                                                                                  |
| :---- | :---------------------------------------------------------------------------------------- |
| demo1 | `DESYNC at tic line 419: want 'tic=418 cs=0501f4bc fb=0e40b251', got 'tic=418 cs=0501f4bc fb=920a6618'` |
| demo2 | `5444 tics in sync` (no zombieman shot changes anything there)                            |
| demo3 | `2743 tics in sync`                                                                        |

The frame changes first (tic 418); the game state first at tic 441:
`./check.sh <variant> jit --demo 1 --state-only -- -zombiedamage 3` reports
`DESYNC at tic line 442: want 'tic=441 cs=192f8d0f', got 'tic=441 cs=801e2f71'`.
