extends Node
## Real-time clock (DEVELOPMENT_PLAN.md §4.7; DESIGN §11). 1:1 with the wall
## clock — the pet shares your real day. Exposes day phase and offline-delta
## consumption. M0 = skeleton; later milestones use the delta to grow plants,
## accrue stipend/tips, and settle needs to floor (never to punish, DESIGN §11).

enum DayPhase { DAWN, DAY, DUSK, NIGHT }


func now_unix() -> int:
	return int(Time.get_unix_time_from_system())


func day_phase() -> DayPhase:
	var h: int = Time.get_datetime_dict_from_system()["hour"]
	if h >= 5 and h < 7:
		return DayPhase.DAWN
	if h >= 7 and h < 17:
		return DayPhase.DAY
	if h >= 17 and h < 20:
		return DayPhase.DUSK
	return DayPhase.NIGHT


## Seconds elapsed since the player was last seen. Never negative; 0 if unknown.
## Being away yields discovery, never loss (DESIGN §11).
func seconds_since(last_seen_unix: int) -> int:
	if last_seen_unix <= 0:
		return 0
	return max(0, now_unix() - last_seen_unix)
