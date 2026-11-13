# puredoom-readable

The same [PureDOOM](https://github.com/Daivuk/PureDOOM) (`355cfbd`, with `patches/`) converted to daslang twice by [c2das-re](https://github.com/lookibed/c2das-re), source layout, sync build (`doom.c2das`), for "add a feature" tests of a model on each:
- `ugly/` - the default output before the readability phase, c2das-re `c25fca7`; `processed/` - all readability forms, `c_switch`/`c_do_while` and folded C macros (`[c_macro]`), c2das-re `deee320` (full shas in each folder's `c2das-re.commit`). Both play demo1-3 in sync under interp and JIT.
- Needs: a c2das-re checkout at `processed/`'s commit (it runs both variants) with `scripts/build_crt.sh` and `doom/fetch.sh` run (the latter downloads `freedoom2.wad`; no game data is in this repo), and the daslang its `VERSIONS.md` pins (daScript `abf1d40e35`).
- Run: `mkdir run && ln -s $C2DAS/doom/fetch/wads/freedoom2.wad run/doom2.wad`, then `DOOMWADDIR=run daslang -load_module $C2DAS/dasCRuntime -load_module $C2DAS/c_runtime [-jit] processed/doom/doom_main.das -- -timedemo demo1` (without `-jit`: interp).
- Check: `C2DAS=<checkout> ./check.sh ugly|processed [interp|jit]` plays demo1-3 and holds every tic's game-state and frame hash to `ref/` (native build logs); exit 0 = nothing broke. `./check.sh` with no arguments lists its options.
- Tasks: `TASKS.md`, three features behind new switches, each with its check and expected output.
- License: PureDOOM and so both conversions are GPL-2 (`LICENSE`, PureDOOM's own); never edit `ugly/` or `processed/` here except as a test, regenerate them in c2das-re.
