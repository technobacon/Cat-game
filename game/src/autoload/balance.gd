extends Node
## Tunable-constants home (DEVELOPMENT_PLAN.md §3.7).
##
## SCAFFOLD SEAM: M0 keeps a few defaults in-code so other skeletons compile.
## Per plan §0.1, EVERY real gameplay number must move into data/config/*.tres
## before it ships. Do not grow this file — grow data/ instead.

## "Content but missing you" need floor — needs settle here, never to 0
## (DESIGN §8/§11). Placeholder until data/config.
const NEED_FLOOR := 0.25

## Baseline daily "mail" stipend in Coins (DESIGN §10). Placeholder.
const DAILY_STIPEND_COINS := 10
