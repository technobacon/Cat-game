extends Node
## Coins balance + payouts (DEVELOPMENT_PLAN.md §4.8; DESIGN §10/§16).
##
## Coins only for the MVP. Trinkets are deferred (DESIGN §16) but the CurrencyType
## seam keeps them a drop-in for Phase 2. Money never buys power (DESIGN §10):
## rearranging decor is always free — no code path here charges for placement.

enum CurrencyType { COINS }  # TRINKETS added in Phase 2 (DESIGN §10)

var _coins: int = 0


func coins() -> int:
	return _coins


func add_coins(amount: int) -> void:
	if amount == 0:
		return
	_coins = maxi(0, _coins + amount)
	EventBus.coins_changed.emit(_coins)
