extends ColorRect

@onready var shaderMaterial : ShaderMaterial = material

func _ready():
	onResize()

func onResize() -> void:
	if shaderMaterial != null:
		setSize(size)

func setSize(val : Vector2) -> void:
	shaderMaterial.set_shader_parameter("size", val)

func setFilled(val : bool) -> void:
	shaderMaterial.set_shader_parameter("filled", val)

func setColor(val : Color) -> void:
	shaderMaterial.set_shader_parameter("color", val)

func setRadius(val : float) -> void:
	shaderMaterial.set_shader_parameter("radius", val)
