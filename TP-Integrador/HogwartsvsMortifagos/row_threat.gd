class_name RowThreat
extends RefCounted

## Data of one board row for the parallel threat analysis. Each pool task
## writes only the fields of its own RowThreat, so no two threads ever write
## the same memory and no lock is needed (data partitioning).

var row: int = 0
var ally_health: float = 0.0
var enemy_count: int = 0
var weakness: float = 0.0
## Id of the pool thread that scored this row, for logging.
var thread_id: int = 0
