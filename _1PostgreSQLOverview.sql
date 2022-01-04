-- Using additional information in pg_stat_activity
SELECT pid,
	wait_event_type,
	wait_event,
	backend_type
FROM pg_stat_activity;
