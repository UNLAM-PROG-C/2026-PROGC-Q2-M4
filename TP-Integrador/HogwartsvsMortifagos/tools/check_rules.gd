extends SceneTree

## Course coding rules checker (FR-016).
## Reports functions longer than MAX_FUNCTION_LINES and identifiers listed in
## the rename map. Usage:
## godot --headless --path . --script res://tools/check_rules.gd

const RENAME_MAP_PATH: String = "res://specs/004-refactor-catedra/rename-map.md"
const ROOT_PATH: String = "res://"
const EXCLUDED_DIRS: PackedStringArray = ["addons", "godot-mcp-main", ".godot", "specs"]
const CHECKED_EXTENSIONS: PackedStringArray = ["gd", "tscn", "gdshader"]
const SCRIPT_EXTENSION: String = "gd"
const SCENE_EXTENSION: String = "tscn"
const MAX_FUNCTION_LINES: int = 15

const REMOVED_MARKER: String = "—"
const CELL_SEPARATOR: String = "|"
const LINE_SEPARATOR: String = "\n"
const OLD_CELL_INDEX: int = 1
const NEW_CELL_INDEX: int = 2
const MIN_ROW_CELLS: int = 4
const IDENTIFIER_GROUP: int = 1

const EXIT_OK: int = 0
const EXIT_FINDINGS: int = 1
const EXIT_MAP_ERROR: int = 2

const LONG_FUNCTION: String = "LONG_FUNCTION"
const OLD_IDENTIFIER: String = "OLD_IDENTIFIER"
const REMOVED_IDENTIFIER: String = "REMOVED_IDENTIFIER"

const SCENE_TEXT_PREFIX: String = "text = "
const SINGLE_ID_PATTERN: String = "^`(\\w+)`$"
const FUNC_PATTERN: String = "^(?:static\\s+)?func\\s+(\\w+)"
const TEXT_CONST_PATTERN: String = "^\\s*const\\s+\\w+_TEXT\\b"
const ASSET_PATH_PATTERN: String = "res://Images/[^\"]*"
const IDENTIFIER_PATTERN_FORMAT: String = "\\b(%s)\\b"
const ALTERNATION_SEPARATOR: String = "|"

const LONG_FUNCTION_FORMAT: String = "%s %s:%d %s (%d lines)"
const IDENTIFIER_FORMAT: String = "%s %s:%d %s"
const MAP_ERROR_FORMAT: String = "check_rules: invalid rename map at %s:%d"
const MAP_MISSING_FORMAT: String = "check_rules: cannot read rename map %s"
const SUMMARY_FORMAT: String = "check_rules: %d findings (%d %s, %d %s, %d %s)"
const SUMMARY_EMPTY: String = "check_rules: 0 findings"


## One reported rule violation.
class Finding:
	var kind: String
	var path: String
	var line: int
	var text: String

	func _init(finding_kind: String, file_path: String, line_number: int, report: String) -> void:
		kind = finding_kind
		path = file_path
		line = line_number
		text = report


## Identifier from the rename map -> finding kind it produces.
var _categories: Dictionary[String, String] = {}
var _findings: Array[Finding] = []
var _single_id_regex: RegEx = _compile(SINGLE_ID_PATTERN)
var _func_regex: RegEx = _compile(FUNC_PATTERN)
var _text_const_regex: RegEx = _compile(TEXT_CONST_PATTERN)
var _asset_path_regex: RegEx = _compile(ASSET_PATH_PATTERN)
var _identifier_regex: RegEx


func _initialize() -> void:
	if not _load_rename_map():
		quit(EXIT_MAP_ERROR)
		return
	_identifier_regex = _compile(IDENTIFIER_PATTERN_FORMAT % ALTERNATION_SEPARATOR.join(PackedStringArray(_categories.keys())))
	for path: String in _collect_files(ROOT_PATH):
		_check_file(path)
	_print_report()
	quit(EXIT_OK if _findings.is_empty() else EXIT_FINDINGS)


func _compile(pattern: String) -> RegEx:
	var regex: RegEx = RegEx.new()
	regex.compile(pattern)
	return regex


# ==============================================================================
# RENAME MAP
# ==============================================================================

func _load_rename_map() -> bool:
	if not FileAccess.file_exists(RENAME_MAP_PATH):
		printerr(MAP_MISSING_FORMAT % RENAME_MAP_PATH)
		return false
	var lines: PackedStringArray = FileAccess.get_file_as_string(RENAME_MAP_PATH).split(LINE_SEPARATOR)
	for index: int in lines.size():
		if not _parse_map_row(lines[index]):
			printerr(MAP_ERROR_FORMAT % [RENAME_MAP_PATH, index + 1])
			return false
	return true


## Registers a table row whose first cell is a single identifier.
## Returns false when the row's second cell is neither an identifier nor REMOVED_MARKER.
func _parse_map_row(line: String) -> bool:
	var cells: PackedStringArray = line.split(CELL_SEPARATOR)
	if not line.begins_with(CELL_SEPARATOR) or cells.size() < MIN_ROW_CELLS:
		return true
	var old_match: RegExMatch = _single_id_regex.search(cells[OLD_CELL_INDEX].strip_edges())
	if old_match == null:
		return true
	var new_cell: String = cells[NEW_CELL_INDEX].strip_edges()
	if new_cell == REMOVED_MARKER:
		_categories[old_match.get_string(IDENTIFIER_GROUP)] = REMOVED_IDENTIFIER
	elif _single_id_regex.search(new_cell) != null:
		_categories[old_match.get_string(IDENTIFIER_GROUP)] = OLD_IDENTIFIER
	else:
		return false
	return true


# ==============================================================================
# FILE SCAN
# ==============================================================================

func _collect_files(dir_path: String) -> PackedStringArray:
	var files: PackedStringArray = []
	for file_name: String in DirAccess.get_files_at(dir_path):
		if file_name.get_extension() in CHECKED_EXTENSIONS:
			files.append(dir_path.path_join(file_name))
	for dir_name: String in DirAccess.get_directories_at(dir_path):
		if not dir_name in EXCLUDED_DIRS:
			files.append_array(_collect_files(dir_path.path_join(dir_name)))
	return files


func _check_file(path: String) -> void:
	var lines: PackedStringArray = FileAccess.get_file_as_string(path).split(LINE_SEPARATOR)
	var extension: String = path.get_extension()
	for index: int in lines.size():
		if not _is_ignored_line(lines[index], extension):
			_check_identifiers(path, index + 1, lines[index])
	if extension == SCRIPT_EXTENSION:
		_check_function_lengths(path, lines)


## Player-visible Spanish text is allowed: scene `text = ` lines and `*_TEXT` constants.
func _is_ignored_line(line: String, extension: String) -> bool:
	if extension == SCENE_EXTENSION:
		return line.begins_with(SCENE_TEXT_PREFIX)
	return extension == SCRIPT_EXTENSION and _text_const_regex.search(line) != null


func _check_identifiers(path: String, line_number: int, line: String) -> void:
	var code: String = _asset_path_regex.sub(line, "", true)
	for found: RegExMatch in _identifier_regex.search_all(code):
		var identifier: String = found.get_string(IDENTIFIER_GROUP)
		var kind: String = _categories[identifier]
		_add_finding(kind, path, line_number, IDENTIFIER_FORMAT % [kind, path, line_number, identifier])


func _check_function_lengths(path: String, lines: PackedStringArray) -> void:
	for index: int in lines.size():
		var found: RegExMatch = _func_regex.search(lines[index])
		if found == null:
			continue
		var body_length: int = _body_length(lines, index)
		if body_length > MAX_FUNCTION_LINES:
			var report: String = LONG_FUNCTION_FORMAT % [LONG_FUNCTION, path, index + 1, found.get_string(IDENTIFIER_GROUP), body_length]
			_add_finding(LONG_FUNCTION, path, index + 1, report)


## Body runs from the line after `func` to the last non-blank line before the
## next unindented line. Inner blank lines and comments count; trailing blanks do not.
func _body_length(lines: PackedStringArray, func_index: int) -> int:
	var last_body_index: int = func_index
	for index: int in range(func_index + 1, lines.size()):
		var line: String = lines[index]
		if line.strip_edges().is_empty():
			continue
		if line.strip_edges(true, false) == line:
			break
		last_body_index = index
	return last_body_index - func_index


# ==============================================================================
# REPORT
# ==============================================================================

func _add_finding(kind: String, path: String, line_number: int, report: String) -> void:
	_findings.append(Finding.new(kind, path, line_number, report))


func _print_report() -> void:
	_findings.sort_custom(_is_finding_before)
	var counts: Dictionary[String, int] = {LONG_FUNCTION: 0, OLD_IDENTIFIER: 0, REMOVED_IDENTIFIER: 0}
	for finding: Finding in _findings:
		print(finding.text)
		counts[finding.kind] += 1
	if _findings.is_empty():
		print(SUMMARY_EMPTY)
		return
	print(SUMMARY_FORMAT % [_findings.size(), counts[LONG_FUNCTION], LONG_FUNCTION, counts[OLD_IDENTIFIER], OLD_IDENTIFIER, counts[REMOVED_IDENTIFIER], REMOVED_IDENTIFIER])


static func _is_finding_before(a: Finding, b: Finding) -> bool:
	if a.path != b.path:
		return a.path < b.path
	if a.line != b.line:
		return a.line < b.line
	return a.text < b.text
