class_name RowThreatAnalyzer
extends RefCounted

## Data parallelism with WorkerThreadPool (fork/join). A wave worker splits the
## board in rows, scores every row at the same time on the engine's thread pool
## (fork) and waits for all of them (join) before building the plan. The
## result is one spawn weight per row: weak rows get more enemies.
##
## The analyzer keeps no state of its own, so both wave workers can share one
## instance safely.

## Ally health that holds back one enemy of pressure.
const DEFENSE_PER_ENEMY: float = 300.0
## Pressure of an empty row, so a row without enemies still gets some weight.
const BASE_PRESSURE: float = 1.0
## Holding power of a row without allies.
const BASE_HOLDING: float = 1.0
const USE_ALL_POOL_THREADS: int = -1
const LOW_PRIORITY: bool = false
const GROUP_TASK_DESCRIPTION: String = "Row threat analysis"
const ROW_LOG: String = "[RowThreat] row %d: weakness %.2f, weight %.2f (pool thread %d)"

## Wave worker thread: returns one spawn weight per snapshot row, summing 1.
func analyze(snapshot: BoardSnapshot) -> Array[float]:
	var rows: Array[RowThreat] = _split_rows(snapshot)
	if rows.is_empty():
		return []
	var task_id: int = WorkerThreadPool.add_group_task(
		_score_row.bind(rows), rows.size(), USE_ALL_POOL_THREADS, LOW_PRIORITY, GROUP_TASK_DESCRIPTION
	)
	WorkerThreadPool.wait_for_group_task_completion(task_id)
	var weights: Array[float] = _normalize(rows)
	_log_rows(rows, weights)
	return weights

## Pool thread: scores one row. It reads and writes only rows[index].
func _score_row(index: int, rows: Array[RowThreat]) -> void:
	var row_threat: RowThreat = rows[index]
	var pressure: float = BASE_PRESSURE + float(row_threat.enemy_count)
	var holding: float = BASE_HOLDING + row_threat.ally_health / DEFENSE_PER_ENEMY
	row_threat.weakness = pressure / holding
	row_threat.thread_id = OS.get_thread_caller_id()

func _split_rows(snapshot: BoardSnapshot) -> Array[RowThreat]:
	var rows: Array[RowThreat] = []
	for index: int in range(snapshot.row_indices.size()):
		var row_threat: RowThreat = RowThreat.new()
		row_threat.row = snapshot.row_indices[index]
		if index < snapshot.row_ally_health.size():
			row_threat.ally_health = snapshot.row_ally_health[index]
		if index < snapshot.row_enemy_count.size():
			row_threat.enemy_count = snapshot.row_enemy_count[index]
		rows.append(row_threat)
	return rows

func _normalize(rows: Array[RowThreat]) -> Array[float]:
	var total: float = 0.0
	for row_threat: RowThreat in rows:
		total += row_threat.weakness
	var weights: Array[float] = []
	for row_threat: RowThreat in rows:
		weights.append(row_threat.weakness / total if total > 0.0 else 1.0 / float(rows.size()))
	return weights

func _log_rows(rows: Array[RowThreat], weights: Array[float]) -> void:
	for index: int in range(rows.size()):
		var row_threat: RowThreat = rows[index]
		print(ROW_LOG % [row_threat.row, row_threat.weakness, weights[index], row_threat.thread_id])
