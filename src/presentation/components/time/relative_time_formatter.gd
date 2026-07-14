@static_class
class_name RelativeTimeFormatter

const MINUTE_SECONDS := 60
const HOUR_SECONDS := 60 * MINUTE_SECONDS
const DAY_SECONDS := 24 * HOUR_SECONDS
const YEAR_SECONDS := 365 * DAY_SECONDS


static func format_since(unix_timestamp: int, current_unix_timestamp: int = -1) -> String:
	var now := current_unix_timestamp
	if now < 0:
		now = floori(Time.get_unix_time_from_system())
	var elapsed_seconds := maxi(0, now - unix_timestamp)
	if elapsed_seconds < MINUTE_SECONDS:
		return "%ds ago" % elapsed_seconds
	if elapsed_seconds < HOUR_SECONDS:
		return "%dm ago" % floori(float(elapsed_seconds) / MINUTE_SECONDS)
	if elapsed_seconds < DAY_SECONDS:
		return "%dh ago" % floori(float(elapsed_seconds) / HOUR_SECONDS)
	if elapsed_seconds < YEAR_SECONDS:
		return "%dd ago" % floori(float(elapsed_seconds) / DAY_SECONDS)
	return "%dy ago" % floori(float(elapsed_seconds) / YEAR_SECONDS)
