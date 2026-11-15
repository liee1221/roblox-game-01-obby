# Rainbow Obby — Setup Guide

A cute, simple 15-stage obby for Roblox. Free to play, no Robux, no paid features.

## Install in Roblox Studio

Open your place in Roblox Studio, then add each file as the script type shown.
Script names are case-sensitive — use the exact names below.

| File | Where | Script type |
|---|---|---|
| `ReplicatedStorage/ObbyConfig.lua` | ReplicatedStorage | **ModuleScript**, name `ObbyConfig` |
| `ServerScriptService/BuildObby.lua` | ServerScriptService | **ModuleScript**, name `BuildObby` |
| `ServerScriptService/ObbyServer.server.lua` | ServerScriptService | **Script**, name `ObbyServer` |
| `StarterGui/ObbyGui.client.lua` | StarterGui | **LocalScript**, name `ObbyGui` |

How to insert: hover over the service in the Explorer, click **+**, pick the
script type, rename it, then double-click it and paste the file's contents.

## Play

Press **Play** (F5). The course builds itself: 15 rainbow stages, clouds,
balloons and a rainbow arch, a spawn pad on stage 1, and lava below.
Walk forward to jump the gaps — touching a stage platform sets your
checkpoint. Red neon parts and the lava kill you and send you back to your
last checkpoint. Reach the gold WIN pad on stage 15 for +1 win.

## What each script does

- **ObbyConfig** — shared settings: 15 stages, colors, cute themes, the
  obstacle plan per stage, spinner/mover/blink tuning.
- **BuildObby** — builds the whole world: stage platforms with borders and
  theme decorations, gaps, beams, spinners, movers, disappearing pads,
  stairs, the lava floor, the WIN pad, clouds, balloons, rainbow and the
  spawn location.
- **ObbyServer** — checkpoints, kill bricks, the WIN pad, the Stage/Wins
  leaderboard, reset handling, and the animation loops for spinners,
  movers and disappearing platforms.
- **ObbyGui** — the client UI: top bar with `Stage N / 15` and wins, a
  Reset button, `Checkpoint! Stage N` and `You Win!` messages, and a
  Play Again panel. Fredoka One titles, Gotham Bold buttons, rounded
  pastel panels.

## Publish

File → Publish to Roblox, set the game to **Public**, then take screenshots
in Play mode for the bounty entry.
