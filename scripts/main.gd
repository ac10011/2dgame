extends Node2D

const TILE := Vector2(48.0, 24.0)
const GRID_SIZE := Vector2i(24, 18)
const ORIGIN := Vector2(480, 250)
var plots: Dictionary = {}
var selected_tool := "hoe"
var status := "工具 1 锄地"
var day := 1

func _ready() -> void:
	queue_redraw()

func _process(_delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1: selected_tool = "hoe"; status = "工具 1 锄地"
		KEY_2: selected_tool = "seed"; status = "工具 2 播种"
		KEY_3: selected_tool = "water"; status = "工具 3 浇水"
		KEY_4: selected_tool = "harvest"; status = "工具 4 收获"
		KEY_SPACE: interact_with_plot()
		KEY_N: advance_day()

func interact_with_plot() -> void:
	var player := get_node_or_null("Player")
	if player == null: return
	var cell := world_to_cell(player.position)
	if not _valid_cell(cell):
		status = "走到农田网格内再操作"
		return
	var value: int = plots.get(cell, 0)
	match selected_tool:
		"hoe":
			if value == 0: plots[cell] = 1; status = "已锄地"
			else: status = "这里已经准备好了"
		"seed":
			if value == 1: plots[cell] = 2; status = "已播种"
			else: status = "需要先锄地"
		"water":
			if value >= 2: plots[cell] = 3; status = "已浇水"
			else: status = "需要先播种"
		"harvest":
			if value == 4: plots[cell] = 1; status = "收获完成"
			else: status = "作物还没有成熟"

func advance_day() -> void:
	day += 1
	for cell in plots:
		if plots[cell] == 3: plots[cell] = 4
	status = "第 %d 天：浇过水的作物成长了" % day

func world_to_cell(pos: Vector2) -> Vector2i:
	var dx := (pos.x - ORIGIN.x) / (TILE.x * 0.5)
	var dy := (pos.y - ORIGIN.y) / (TILE.y * 0.5)
	return Vector2i(round((dx + dy) * 0.5), round((dy - dx) * 0.5))

func cell_to_world(cell: Vector2i) -> Vector2:
	return ORIGIN + Vector2((cell.x - cell.y) * TILE.x * 0.5, (cell.x + cell.y) * TILE.y * 0.5)

func _valid_cell(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < GRID_SIZE.x and cell.y < GRID_SIZE.y

func _draw() -> void:
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var cell := Vector2i(x, y)
			var p := cell_to_world(cell)
			var points := PackedVector2Array([p + Vector2(0, -TILE.y * 0.5), p + Vector2(TILE.x * 0.5, 0), p + Vector2(0, TILE.y * 0.5), p - Vector2(TILE.x * 0.5, 0)])
			var state: int = plots.get(cell, 0)
			var color := Color("#7a9e5c") if (x + y) % 2 == 0 else Color("#709552")
			if state == 1: color = Color("#8b5a3b")
			elif state == 2: color = Color("#6c492f")
			elif state == 3: color = Color("#365e78")
			elif state == 4: color = Color("#527b3f")
			draw_colored_polygon(points, color)
			draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("#4d7544"), 1.0)
			if state >= 2:
				draw_circle(p + Vector2(0, -8), 4.0 if state < 4 else 8.0, Color("#86bd4a") if state < 4 else Color("#e5be55"))
	var player := get_node_or_null("Player")
	if player:
		var selected := world_to_cell(player.position)
		if _valid_cell(selected):
			var p := cell_to_world(selected)
			var highlight := PackedVector2Array([p + Vector2(0, -TILE.y * 0.5), p + Vector2(TILE.x * 0.5, 0), p + Vector2(0, TILE.y * 0.5), p - Vector2(TILE.x * 0.5, 0), p + Vector2(0, -TILE.y * 0.5)])
			draw_polyline(highlight, Color("#f6df75"), 2.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(20, 28), "四季边境 · 农场原型", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, Vector2(20, 52), "1 锄地  2 播种  3 浇水  4 收获  |  空格操作  N 过一天", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d7e7d1"))
	draw_string(font, Vector2(20, 76), "第 %d 天 · %s" % [day, status], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f6df75"))
