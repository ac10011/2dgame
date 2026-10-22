extends CharacterBody2D

@export var speed := 180.0

func _physics_process(_delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	# Convert cardinal input to screen-space movement for the isometric prototype.
	velocity = input * speed
	move_and_slide()
	global_position.x = clamp(global_position.x, 80.0, 880.0)
	global_position.y = clamp(global_position.y, 80.0, 480.0)
	queue_redraw()

func _draw() -> void:
	# Temporary readable player marker; replace with processed farmer sprite later.
	draw_ellipse(Vector2(0, 13), Vector2(15, 7), Color(0, 0, 0, 0.25))
	draw_circle(Vector2(0, -5), 10.0, Color("#f3c49b"))
	draw_colored_polygon(PackedVector2Array([Vector2(-13, 2), Vector2(13, 2), Vector2(9, 22), Vector2(-9, 22)]), Color("#3d6193"))
	draw_arc(Vector2(0, -8), 14.0, PI, TAU, 16, Color("#d9913d"), 6.0)

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for i in range(25):
		var a := TAU * float(i) / 24.0
		points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
	draw_colored_polygon(points, color)
