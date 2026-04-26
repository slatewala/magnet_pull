---
title: "Magnet Pull - Physics Puzzles With Just Your Thumb"
date: 2026-04-26
categories:
  - Games
  - Mobile
tags:
  - flutter
  - puzzle
  - physics
  - hyper-casual
  - android
excerpt: "Drag a magnet around the screen and steer colored balls into matching goals. Simple input, surprisingly tactile physics."
featured_image: /assets/games/magnet-pull-feature.png
---

## Touch The Screen, Bend The Field

**Magnet Pull** is built on one input - your finger. Wherever you touch is a magnetic source. Balls drift toward it with realistic inverse-square attraction. Lift your finger and inertia takes over. The challenge is to land each ball into a same-colored goal ring without overshooting or colliding the wrong colors together.

The result is a game that feels less like clicking buttons and more like steering planets.

## Why Drag-Physics Hooks You

Most hyper-casual games are reflex-based - tap on cue. Magnet Pull is **planning-based**. You think two seconds ahead. Where will the red ball drift if I pull it left now? Will the yellow ball pass through the wall if I yank it too hard?

This shifts the game from finger-twitch to brain-twitch. Each level is short, but the satisfaction of clearing all goals in a single smooth gesture is genuinely Zen.

## Built With Flutter Canvas

A single `CustomPainter` renders balls, goals, and the magnetic glow. A `Ticker` integrates a basic Newtonian motion model at the device frame rate. No physics engine - inverse-square attraction plus 1.5% velocity damping per frame produces stable, predictable motion in under fifty lines of code.

The level generator is intentionally dumb - random ball placement above, random goal placement below, colors drawn from a small palette. Variety comes from physics, not authored content.

## Try It

Source, custom icon, sound, release APK on GitHub. Sideload, lose half an hour, blame me.
