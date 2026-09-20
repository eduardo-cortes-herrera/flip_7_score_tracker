# Flip 7 Score Tracker

A Flutter companion app for the card game **Flip 7** — tracks players and
scores across rounds, with a built-in calculator to work out each round's
score from the cards you drew.

## Features

- **Player management** — add, rename, remove and reorder players (manually
  or automatically by current score), right from the game screen or Settings.
- **Round tracking** — each player's card shows their running total, how
  many points they need to reach the target score, and every round's score
  as a scrollable strip of chips. Tapping a card walks you through entering
  a score for whichever player still needs one.
- **Built-in calculator** — a card-based calculator tailored to each game
  mode (Classic, Vengeance, Mixed), including the Flip 7 bonus, or a manual
  entry mode if you'd rather just type the total.
- **Game settings** — game mode, target score, player order, and a quick
  restart that clears rounds while keeping your players.
- **Theming** — several built-in color themes plus light/dark/system
  brightness, with a live preview before you commit.

## Getting started

Requirements: [Flutter](https://docs.flutter.dev/get-started/install) (see
`pubspec.yaml` for the exact SDK constraint).

```sh
flutter pub get
dart run build_runner build --delete-conflicting-outputs # generates Hive adapters
flutter run
```

## Architecture

The app follows a feature-first clean architecture (`domain` / `data` /
`presentation` per feature) across three features: `game`, `calculator`, and
`settings`. See [`AGENTS.md`](AGENTS.md) for a detailed guide to the codebase
— it's kept up to date as the project evolves and is the best starting point
for understanding how a change should be made.
