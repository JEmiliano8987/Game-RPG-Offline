extends Area3D
class_name Interactuable

## Punto con el que el jugador puede interactuar con la tecla E
## (antena, ingeniera...). La forma visual se crea según el id.

@export var id_interaccion: String = ""
@export var nombre: String = ""

@onready var etiqueta: Label3D = $Etiqueta

func _ready() -> void:
	add_to_group("interactuables")
	etiqueta.text = nombre
	_construir_visual()

## Crea una figura sencilla según el tipo de interactuable.
func _construir_visual() -> void:
	match id_interaccion:
		"antena":
			# Poste alto con una parábola y una luz.
			var poste := MeshInstance3D.new()
			var cilindro := CylinderMesh.new()
			cilindro.top_radius = 0.15
			cilindro.bottom_radius = 0.2
			cilindro.height = 5.0
			poste.mesh = cilindro
			poste.position.y = 2.5
			poste.material_override = _material(Color(0.4, 0.42, 0.5), 0.7, 0.3)
			add_child(poste)
			var parabola := MeshInstance3D.new()
			var esfera := SphereMesh.new()
			esfera.radius = 0.9
			esfera.height = 1.0
			parabola.mesh = esfera
			parabola.scale = Vector3(1.0, 0.4, 1.0)
			parabola.position = Vector3(0, 5.2, 0)
			parabola.rotation.x = -0.6
			parabola.material_override = _material(Color(0.1, 0.7, 0.9), 0.3, 0.8)
			add_child(parabola)
			var luz := MeshInstance3D.new()
			var esfera_luz := SphereMesh.new()
			esfera_luz.radius = 0.15
			esfera_luz.height = 0.3
			luz.mesh = esfera_luz
			luz.position = Vector3(0, 5.9, 0)
			luz.material_override = _material_emisivo(Color(1.0, 0.3, 0.2))
			add_child(luz)
		"ingeniera":
			# Personaje con traje técnico y casco.
			var cuerpo := MeshInstance3D.new()
			var capsula := CapsuleMesh.new()
			capsula.radius = 0.35
			capsula.height = 1.2
			cuerpo.mesh = capsula
			cuerpo.position.y = 0.85
			cuerpo.material_override = _material(Color(0.1, 0.6, 0.55), 0.8, 0.0)
			add_child(cuerpo)
			var casco := MeshInstance3D.new()
			var esfera_casco := SphereMesh.new()
			esfera_casco.radius = 0.3
			esfera_casco.height = 0.6
			casco.mesh = esfera_casco
			casco.position.y = 1.7
			casco.material_override = _material(Color(0.9, 0.85, 0.7), 0.5, 0.1)
			add_child(casco)
		_:
			# Consola genérica.
			var consola := MeshInstance3D.new()
			var caja := BoxMesh.new()
			caja.size = Vector3(1.2, 1.4, 0.6)
			consola.mesh = caja
			consola.position.y = 0.7
			consola.material_override = _material(Color(0.2, 0.25, 0.35), 0.5, 0.5)
			add_child(consola)

func _material(color: Color, rugosidad: float, metalico: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = rugosidad
	material.metallic = metalico
	return material

func _material_emisivo(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.5
	return material
