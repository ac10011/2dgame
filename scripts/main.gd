extends Node2D

const TILE := Vector2(48.0, 24.0)
const GRID_SIZE := Vector2i(24, 18)
const ORIGIN := Vector2(480, 250)
var plots: Dictionary = {}
var buildings: Dictionary = {}
var inventory: Dictionary = {"turnip_seed": 10, "turnip": 0, "wood": 20}
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
		KEY_B: place_building()
		KEY_X: remove_building()
		KEY_N: advance_day()
		KEY_F5: save_game()
		KEY_F9: load_game()

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
			if value == 1 and inventory.turnip_seed > 0:
				inventory.turnip_seed -= 1; plots[cell] = 2; status = "已播种"
			elif value != 1: status = "需要先锄地"
			else: status = "没有种子了"
		"water":
			if value >= 2: plots[cell] = 3; status = "已浇水"
			else: status = "需要先播种"
		"harvest":
			if value == 4:
				inventory.turnip += 1; plots[cell] = 1; status = "收获完成，获得萝卜"
			else: status = "作物还没有成熟"

func save_game() -> void:
	var data := {"day": day, "plots": {}, "buildings": {}, "inventory": inventory}
	for cell in plots:
		data.plots["%d,%d" % [cell.x, cell.y]] = plots[cell]
	for cell in buildings:
		data.buildings["%d,%d" % [cell.x, cell.y]] = buildings[cell]
	var file := FileAccess.open("user://farm_save.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		status = "已保存农场进度"
	else:
		status = "保存失败"

func load_game() -> void:
	if not FileAccess.file_exists("user://farm_save.json"):
		status = "没有找到存档"
		return
	var file := FileAccess.open("user://farm_save.json", FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) != TYPE_DICTIONARY:
		status = "存档格式错误"
		return
	day = int(data.get("day", 1)); plots.clear(); buildings.clear(); inventory = data.get("inventory", {"turnip_seed": 10, "turnip": 0, "wood": 20})
	for key in data.get("plots", {}):
		var parts := key.split(","); plots[Vector2i(int(parts[0]), int(parts[1]))] = int(data.plots[key])
	for key in data.get("buildings", {}):
		var parts := key.split(","); buildings[Vector2i(int(parts[0]), int(parts[1]))] = str(data.buildings[key])
	status = "已读取农场进度"

func place_building() -> void:
	var player := get_node_or_null("Player")
	if player == null: return
	var cell := world_to_cell(player.position)
	if _valid_cell(cell) and not buildings.has(cell) and inventory.wood >= 5:
		inventory.wood -= 5
		buildings[cell] = "house" if buildings.size() % 2 == 0 else "chest"
		status = "已放置建筑"
	elif inventory.wood < 5:
		status = "木材不足（需要 5）"
	else:
		status = "这里已有建筑或不在农场内"

func remove_building() -> void:
	var player := get_node_or_null("Player")
	if player == null: return
	var cell := world_to_cell(player.position)
	if buildings.erase(cell): status = "已拆除建筑"
	else: status = "当前格没有建筑"

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
	for cell in buildings:
		var bp := cell_to_world(cell)
		var kind: String = buildings[cell]
		if kind == "house":
			draw_colored_polygon(PackedVector2Array([bp + Vector2(-20, 0), bp + Vector2(0, -14), bp + Vector2(20, 0), bp + Vector2(0, 14)]), Color("#b56b4d"))
			draw_colored_polygon(PackedVector2Array([bp + Vector2(-15, -1), bp + Vector2(0, -22), bp + Vector2(15, -1)]), Color("#c8553d"))
			draw_rect(Rect2(bp + Vector2(-8, -1), Vector2(16, 14)), Color("#e8bd79"))
		else:
			draw_colored_polygon(PackedVector2Array([bp + Vector2(-13, -5), bp + Vector2(0, -13), bp + Vector2(13, -5), bp + Vector2(0, 3)]), Color("#85512f"))
			draw_rect(Rect2(bp + Vector2(-10, -5), Vector2(20, 12)), Color("#9e663d"))

	var player := get_node_or_null("Player")
	if player:
		var selected := world_to_cell(player.position)
		if _valid_cell(selected):
			var p := cell_to_world(selected)
			var highlight := PackedVector2Array([p + Vector2(0, -TILE.y * 0.5), p + Vector2(TILE.x * 0.5, 0), p + Vector2(0, TILE.y * 0.5), p - Vector2(TILE.x * 0.5, 0), p + Vector2(0, -TILE.y * 0.5)])
			draw_polyline(highlight, Color("#f6df75"), 2.0)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(20, 28), "四季边境 · 农场原型", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.WHITE)
	draw_string(font, Vector2(20, 52), "1 锄地  2 播种  3 浇水  4 收获  |  空格操作  B 建造  X 拆除  N 过一天  F5保存 F9读取", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#d7e7d1"))
	draw_string(font, Vector2(20, 76), "第 %d 天 · %s" % [day, status], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f6df75"))
	draw_string(font, Vector2(20, 98), "种子 %d  萝卜 %d  木材 %d" % [inventory.turnip_seed, inventory.turnip, inventory.wood], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#f2d49b"))
