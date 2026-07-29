@tool
extends Node

@onready var terrain: Terrain3D = find_child("Terrain3D")
var objective_beacon: MeshInstance3D

func _ready():
	if not Engine.is_editor_hint() and has_node("UI"):
		$UI.player = $Player
		$UI.objective_position = Vector3(220, 5, -1825)
		$UI.objective_radius = 20.0

	objective_beacon = MeshInstance3D.new()
	objective_beacon.mesh = SphereMesh.new()
	objective_beacon.material_override = StandardMaterial3D.new()
	objective_beacon.material_override.albedo_color = Color(0.9, 0.6, 0.1)
	objective_beacon.scale = Vector3.ONE * 1.8
	objective_beacon.translation = Vector3(220, 8, -1825)
	add_child(objective_beacon)

	if not Engine.is_editor_hint():
		objective_beacon.visible = true
			$Environment.queue_free()
			var sky3d = load("res://addons/sky_3d/src/Sky3D.gd").new()
			sky3d.name = "Sky3D"
			add_child(sky3d, true)
			move_child(sky3d, 1)
			sky3d.owner = self
			sky3d.current_time = 10
			sky3d.enable_editor_time = false
			
		
