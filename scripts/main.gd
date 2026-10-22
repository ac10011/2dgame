extends Node2D

const TILE := Vector2(48.0, 24.0)
const GRID_SIZE := Vector2i(24, 18)
const ORIGIN := Vector2(480, 250)

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	# Isometric diamond grid: each logical cell is rendered at 45 degrees.
	for y in range(GRID_SIZE.y):
		for x in range(GRID_SIZE.x):
			var p := ORIGIN + Vector2((x - y) * TILE.x * 0.5, (x + y) * TILE.y * 0.5)
			var points := PackedVector2Array([
				p + Vector2(0, -TILE.y * 0.5),
				p + Vector2(TILE.x * 0.5, 0),
				p + Vector2(0, TILE.y * 0.5),
				p - Vector2(TILE.x * 0.5, 0)
			])
			var color := Color("#6f9d57") if (x + y) % 2 == 0 else Color("#679150")
			draw_colored_polygon(points, color)
			draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]), Color("#4d7544"), 1.0)

func _process(_delta: float) -> void:
	queue_redraw()
