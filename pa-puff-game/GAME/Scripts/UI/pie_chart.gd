extends Control

var values: Array[float] = [30.0, 45.0, 25.0]
var colors: Array[Color] = [Color.RED, Color.BLUE, Color.WHITE]

func _draw():
	
	var radius: float = min(size.x, size.y) / 4.0
	var total = values[0]+values[1]+values[2]
	var previous_angle = 0.0
	var center = size / 2
	for i in values.size():
		var percentage: float = values[i] / (total / 100.0)
		var current_angle: float = 360.0 * (percentage / 100.0)
		var angle: float = deg_to_rad(current_angle + previous_angle)
		var mid_angle: float = angle - deg_to_rad(current_angle / 2.0)
		var angle_point: Vector2 = Vector2(cos(mid_angle), sin(mid_angle)) * radius
		draw_slice(center, radius, previous_angle, previous_angle + current_angle, colors[i])
		previous_angle += current_angle
		
func draw_slice(center: Vector2, radius: float, angle_from: float, angle_to: float, color: Color) -> void:
	var nb_points: int = round((angle_to-angle_from)/5)
	var outer_arc: Array[Vector2] = []
	var inner_arc: Array[Vector2] = []
	
	inner_arc.push_back(center)
	
	for i in range(nb_points + 1):
		var angle_point: float = deg_to_rad(angle_from + i * (angle_to - angle_from) / nb_points)
		outer_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	if inner_arc.size()+outer_arc.size()>3:
		draw_colored_polygon(inner_arc + outer_arc,color)
		draw_polyline(outer_arc,Color.BLACK, 0.5, true)
