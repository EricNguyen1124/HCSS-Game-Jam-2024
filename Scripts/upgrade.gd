extends Resource

class_name Upgrade

@export var display_name: String
@export var description: String
#@export var action: Callable
@export var texture: Texture2D

# Make sure that every parameter has a default value.
# Otherwise, there will be problems with creating and editing
# your resource via the inspector.

#func _init(p_name = "", p_description = "", p_function = func(): print("uh oh"), p_texture = Texture2D):
func _init(p_name = "", p_description = "", p_texture = Texture2D.new()):
	display_name = p_name
	description = p_description
	#action = p_function
	texture = p_texture
	
