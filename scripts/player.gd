extends CharacterBody2D

@export var speed := 180.0
var farmer_texture := preload("res://assets/processed/sprites/characters_crops_tools_sheet/characters_crops_tools_sheet_001.png")

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input * speed
	move_and_slide()
	global_position.x = clamp(global_position.x, 80.0, 880.0)
	global_position.y = clamp(global_position.y, 80.0, 480.0)
	queue_redraw()

func _draw() -> void:
	draw_ellipse(Vector2(0, 13), Vector2(15, 7), Color(0, 0, 0, 0.25))
	draw_texture_rect(farmer_texture, Rect2(-20, -48, 40, 56), false)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var a := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
