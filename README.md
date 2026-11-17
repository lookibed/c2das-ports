# c2das-ports in the browser

The GitHub Pages site of [c2das-ports](https://github.com/lookibed/c2das-ports): its programs compiled
to WebAssembly. Generated, never hand-edited: c2das-re's `scripts/build_web.sh --ports <c2das-ports>
--pages <this checkout>` writes every file here (sources: c2das-re's `web/`).

- PureDOOM (`puredoom/`): c2das-ports 863eef7a32 `puredoom-readable/processed` (converted by c2das-re
  deee3209ce), with c2das-re 3054da3c3d's `crt` and browser host, compiled by daScript b7d8f6f52f's libc++ wasm
  host with emscripten 5.0.7.
- Its C baseline (`puredoom/doom_c.html`): PureDOOM 355cfbd16f's own C with c2das-re 3054da3c3d's patches and
  the C twin of the browser host, by emscripten 5.0.7 at -O3 with the daslang build's wasm flags.
- quakegeneric (`quake/`): c2das-ports 863eef7a32 `quakegeneric/readable` (converted by c2das-re ef5b135351), with
  c2das-re 3054da3c3d's runtime and browser host, by the same wasm host.
- No game data is in this branch: the deploy workflow downloads Freedoom 0.13.0 from its official
  release and Quake 1.06's shareware zip from id Software's release, checks them, and publishes
  `puredoom/freedoom2.wad` and `quake/id1/pak0.pak` into the Pages artifact only.
