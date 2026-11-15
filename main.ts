// Rainbow Obby — a cute, simple 15-stage obstacle course for Roblox, built for make.fun's
// "Make the best Roblox game" bounty (roblox-game-01). This program (Node 22, standard library
// only) hands the game in: it copies game.rbxl, PLAY.json, src/ and screenshots/ from beside
// this file to the output dir, then writes dossier.json — the summary the judge reads — with
// the vendored make.fun library (./vendor/makefun-roblox.ts).
//
// The place is a Rojo project: build it with `rojo build default.project.json --output game.rbxl`
// before running this. PLAY.json holds the published place. The first screenshot by name is the
// cover, so put the cutest one first.
//
// Outside the grader's container, MAKEFUN_OUTPUT_DIR stands in for /output:
//   mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts

import { copyFileSync, cpSync, existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { buildDossier } from './vendor/makefun-roblox.ts';

const here = fileURLToPath(new URL('.', import.meta.url));
const out = process.env.MAKEFUN_OUTPUT_DIR ?? '/output';

// Make sure the output dir exists before the first copy: the starter only creates the
// screenshots subdir, which runs after game.rbxl and PLAY.json are already copied.
mkdirSync(out, { recursive: true });

copyFileSync(join(here, 'game.rbxl'), join(out, 'game.rbxl'));
copyFileSync(join(here, 'PLAY.json'), join(out, 'PLAY.json'));
cpSync(join(here, 'src'), join(out, 'src'), { recursive: true });
mkdirSync(join(out, 'screenshots'), { recursive: true });
if (existsSync(join(here, 'screenshots'))) cpSync(join(here, 'screenshots'), join(out, 'screenshots'), { recursive: true });

// The scorer's own caps (reference/gate.json): only text_max_bytes shapes the bytes; the others
// refuse an entry the scorer would refuse — more than 4 screenshots or one over 256 KiB; a place
// of more than 500000 instances, whose scripts' sources come to over 8 MiB or whose scripts'
// paths come to over 1048576 characters, in all.
writeFileSync(
  join(out, 'dossier.json'),
  buildDossier(out, { text_max_bytes: 65536, screenshots: { max: 4, max_bytes: 262144 }, max_instances: 500000, scripts_max_source_bytes: 8388608, scripts_max_path_chars: 1048576 }),
);
