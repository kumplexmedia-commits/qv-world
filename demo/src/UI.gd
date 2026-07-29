extends Control


var player: Node
var visible_mode: int = 1
var show_settings: bool = false
var objective_position: Vector3 = Vector3.ZERO
var objective_radius: float = 20.0

func _init() -> void:
	RenderingServer.set_debug_generate_wireframes(true)


func _process(p_delta) -> void:
	$Label.text = "FPS: %d\n" % Engine.get_frames_per_second()
	if player:
		$Label.text += "Move Speed: %.1f\n" % player.MOVE_SPEED
		$Label.text += "Position: %.1v\n" % player.global_position
		var objective_distance = player.global_position.distance_to(objective_position)
		if objective_distance <= objective_radius:
			$Label.text += "Objective: Reached the beacon!\n"
		else:
			$Label.text += "Objective: Reach the beacon (%.1f meters)\n" % objective_distance
		$Label.text += "Objective radius: %.1f\n" % objective_radius
	$Label.text += "Press F3 to toggle the settings panel.\n"
	if visible_mode == 1:
		$Label.text += """
			Player
			Move: WASDEQ,Space,Mouse
			Move speed: Wheel,+/-,Shift
			Camera View: V
			Gravity toggle: G
			Collision toggle: C
			Toggle settings: F3

			Window
			Quit: F8
			UI toggle: F9
			Render mode: F10
			Full screen: F11
			Mouse toggle: Escape / F12
		"""
	if show_settings:
		$Label.text += "\n=== Settings Panel ===\n"
		$Label.text += "  - Panel state: %s\n" % (show_settings ? "ON" : "OFF")
		$Label.text += "  - Objective radius: %.1f\n" % objective_radius
		$Label.text += "  - Settings visible: %s\n" % (str(show_settings))
		$Label.text += "  - Toggle settings: F3\n"

func _unhandled_key_input(p_event: InputEvent) -> void:
	if p_event is InputEventKey and p_event.pressed:
		match p_event.keycode:
			KEY_F8:
				get_tree().quit()
			KEY_F9:
				visible_mode = (visible_mode + 1 ) % 3
				$Label/Panel.visible = (visible_mode == 1)
				visible = visible_mode > 0
			KEY_F10:
				var vp = get_viewport()
				vp.debug_draw = (vp.debug_draw + 1 ) % 6
				get_viewport().set_input_as_handled()
			KEY_F11:
				toggle_fullscreen()
				get_viewport().set_input_as_handled()
			KEY_F3:
				show_settings = !show_settings
				get_viewport().set_input_as_handled()
			KEY_ESCAPE, KEY_F12:
				if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
					Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				else:
					Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				get_viewport().set_input_as_handled()
		
		
func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN or \
		DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2(1280, 720))
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
