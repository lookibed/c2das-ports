# c2das-ports in the browser

The GitHub Pages site of [c2das-ports](https://github.com/lookibed/c2das-ports): its programs compiled
to WebAssembly. Generated, never hand-edited: c2das-re's `scripts/build_web.sh --ports <c2das-ports>
--pages <this checkout>` writes every file here (sources: c2das-re's `web/`).

- PureDOOM (`puredoom/`): c2das-ports 863eef7a32 `puredoom-readable/processed` (converted by c2das-re
  deee3209ce), with c2das-re 09c4e2662d's `crt` and browser host, compiled by daScript 2decba91d5's libc++ wasm
  host with emscripten 5.0.7.
- No game data is in this branch: the deploy workflow downloads Freedoom 0.13.0 from its official
  release and checks its sha256 before it publishes `puredoom/freedoom2.wad` into the Pages artifact.
