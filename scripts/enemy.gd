extends CharacterBody3D
class_name Enemigo

## Enemigo cuerpo a cuerpo: patrulla su zona, persigue al jugador si se
## acerca y ataca cuando está a su alcance. Al morir suelta créditos y XP.

signal derrotado(enemigo: Enemigo)

const GRAVEDAD: float = 20.0

@export var tipo: String = "dron"

@onready var malla: Node3D = $Malla
@onready var cuerpo: MeshInstance3D = $Malla/Cuerpo
@onready var ojo: MeshInstance3D = $Malla/Ojo
@onready var barra_vida: MeshInstance3D = $BarraVida

var salud_maxima: int = 30
var salud: int = 30
var dano: int = 8
var velocidad: float = 3.5
var rango_deteccion: float = 12.0
var rango_ataque: float = 1.8
var recompensa_creditos: int = 15
var recompensa_xp: int = 20

var _jugador: Jugador = null
var _tiempo_desde_ataque: float = 0.0
var _punto_origen: Vector3 = Vector3.ZERO
var _destino_patrulla: Vector3 = Vector3.ZERO
var _tiempo_patrulla: float = 0.0
var _tiempo_bob: float = 0.0
var _muerto: bool = false

func _ready() -> void:
	_punto_origen = global_position
	_destino_patrulla = _punto_origen
	_aplicar_datos_tipo()

## Configura las estadísticas y el color según el tipo (dron o robot).
func _aplicar_datos_tipo() -> void:
	var datos: Dictionary = DatosJuego.ENEMIGOS.get(tipo, DatosJuego.ENEMIGOS["dron"])
	salud_maxima = int(datos["salud"])
	salud = salud_maxima
	dano = int(datos["dano"])
	velocidad = float(datos["velocidad"])
	rango_deteccion = float(datos["rango_deteccion"])
	rango_ataque = float(datos["rango_ataque"])
	recompensa_creditos = int(datos["recompensa_creditos"])
	recompensa_xp = int(datos["recompensa_xp"])
	# Color del cuerpo según el tipo.
	var color_cuerpo: Color = datos.get("color_cuerpo", Color.GRAY)
	var material := StandardMaterial3D.new()
	material.albedo_color = color_cuerpo
	material.roughness = 0.4
	material.metallic = 0.6
	cuerpo.material_override = material
	var color_ojo: Color = datos.get("color_ojo", Color.RED)
	var material_ojo := StandardMaterial3D.new()
	material_ojo.albedo_color = color_ojo
	material_ojo.emission_enabled = true
	material_ojo.emission = color_ojo
	material_ojo.emission_energy_multiplier = 2.0
	ojo.material_override = material_ojo
	# El robot es más grande y pesado; el dron, más pequeño y flotante.
	if tipo == "robot":
		malla.scale = Vector3(1.15, 1.15, 1.15)
	else:
		malla.scale = Vector3(0.75, 0.75, 0.75)

func _physics_process(delta: float) -> void:
	if _muerto:
		return
	_tiempo_desde_ataque += delta
	_tiempo_bob += delta
	if _jugador == null:
		_jugador = get_tree().get_first_node_in_group("jugador") as Jugador
	# El dron flota: sube y baja suavemente.
	if tipo == "dron":
		malla.position.y = 0.35 + sin(_tiempo_bob * 2.0) * 0.12
		velocity.y = 0.0
	elif not is_on_floor():
		velocity.y -= GRAVEDAD * delta
	var distancia_jugador := 999.0
	if _jugador != null:
		distancia_jugador = global_position.distance_to(_jugador.global_position)
	if _jugador != null and distancia_jugador <= rango_deteccion:
		# Perseguir al jugador.
		var direccion := _jugador.global_position - global_position
		if tipo != "dron":
			direccion.y = 0
		direccion = direccion.normalized()
		velocity.x = direccion.x * velocidad
		velocity.z = direccion.z * velocidad
		# Mirar hacia el jugador.
		if distancia_jugador > 0.5:
			look_at(_jugador.global_position, Vector3.UP)
			rotation.x = 0
		# Atacar si está a su alcance.
		if distancia_jugador <= rango_ataque and _tiempo_desde_ataque >= 1.0:
			_tiempo_desde_ataque = 0.0
			_jugador.estadisticas.recibir_danio(dano)
	else:
		# Patrullar: caminar despacio hacia un punto cercano y cambiarlo cada poco.
		_tiempo_patrulla += delta
		if _tiempo_patrulla > 3.0 or global_position.distance_to(_destino_patrulla) < 0.5:
			_tiempo_patrulla = 0.0
			_destino_patrulla = _punto_origen + Vector3(randf_range(-3.0, 3.0), 0, randf_range(-3.0, 3.0))
		var direccion_p := _destino_patrulla - global_position
		direccion_p.y = 0
		direccion_p = direccion_p.normalized()
		velocity.x = direccion_p.x * velocidad * 0.3
		velocity.z = direccion_p.z * velocidad * 0.3
		if direccion_p != Vector3.ZERO and global_position.distance_to(_destino_patrulla) > 0.5:
			look_at(global_position + direccion_p, Vector3.UP)
			rotation.x = 0
	move_and_slide()

## Recibir daño del jugador.
func recibir_danio(cantidad: int) -> void:
	if _muerto:
		return
	salud = maxi(0, salud - cantidad)
	_actualizar_barra_vida()
	if salud <= 0:
		_morir()

## La barra de vida se encoge según la salud restante.
func _actualizar_barra_vida() -> void:
	var fraccion := float(salud) / float(maxi(1, salud_maxima))
	barra_vida.scale.x = maxf(0.02, fraccion)
	# Cambia de verde a rojo según la salud.
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0 - fraccion, fraccion, 0.1)
	material.emission_enabled = true
	material.emission = Color(1.0 - fraccion, fraccion, 0.1)
	barra_vida.material_override = material

## Morir: avisar al mundo (recompensas y misiones) y desaparecer.
func _morir() -> void:
	_muerto = true
	derrotado.emit(self)
	# Pequeña animación de destrucción antes de desaparecer.
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3(0.01, 0.01, 0.01), 0.25)
	tween.tween_callback(queue_free)
