class_name StandeePrimitive
extends Node3D

const COLLISION_SHAPE_NAME = "CollisionShape3D"
const HEX_FILE: String = "res://assets/hexes/hexa_h-5.json"
var standee: StandeePrimitiveMesh = StandeePrimitiveMesh.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	standee = StandeePrimitiveMesh.new()
	
func init_standee(texture_img: String, color: Color)->void:
	standee.create_standee(HEX_FILE,texture_img,color)
	var center = standee.center
	var rigid_body = RigidBody3D.new()
	var physics_material: PhysicsMaterial = PhysicsMaterial.new()
	physics_material.rough=true
	physics_material.friction=1
	physics_material.bounce=0
	
	rigid_body.physics_material_override = physics_material
	rigid_body.set_mass(1.0)
	rigid_body.set_lock_rotation_enabled(true)
	
	var col_shape = CollisionShape3D.new()
	col_shape.shape = CylinderShape3D.new()
	col_shape.shape.height = 0.2
	col_shape.shape.radius = 0.5
	col_shape.shape.margin = 0.04
	
	center[2] = center[2] + 0.4
	center[1] = center[1] + 0.0
	center[0] = center[0] - 0.5
	standee.translate(center)
	col_shape.add_child(standee)
	rigid_body.add_child(col_shape)
	add_child(rigid_body)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
