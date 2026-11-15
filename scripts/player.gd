extends CharacterBody3D
class_name Jugador

## Controlador en tercera persona: WASD para moverse, ratón para girar
## la cámara, Espacio para saltar y clic izquierdo para atacar con la
## espada de energía.

signal quiere_interactuar
signal quiere_tienda
signal quiere_guardar

const GRAVEDAD: float = 20.0
const FUERZA_SALTO: float = 7.0
const RANGO_ATAQUE: float = 2.6
const TIEMPO_ENTRE_ATAQUES: float = 0.45
const SENSIBILIDAD_RATON: float = 0.003

@onready var brazo_camara: SpringArm3D = $BrazoCamara
@onready var brazo_espada: Node3D = $Malla/BrazoEspada
@onready var estadisticas: EstadisticasJugador = $Estadisticas

## Cuando una interfaz (tienda) está abierta, el jugador no se mueve ni ataca.
var interfaz_abierta: bool = false

var _tiempo_desde_ataque: float = 99.0
var _atacando: bool = false

func _ready() -> void:
	# Captura el ratón para girar la cámara (clic para volver a capturar).
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(evento: InputEvent) -> void:
	if interfaz_abierta:
		return
	# Girar la cámara con el ratón mientras está capturado.
	if evento is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var movimiento := evento as InputEventMouseMotion
		rotation.y -= movimiento.relative.x * SENSIBILIDAD_RATON
		brazo_camara.rotation.x = clampf(brazo_camara.rotation.x - movimiento.relative.y * SENSIBILIDAD_RATON, -1.1, 0.4)
	# Si se soltó el ratón (por ejemplo, al abrir la tienda), un clic lo recaptura.
	if evento is InputEventMouseButton and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	_tiempo_desde_ataque += delta
	# Gravedad.
	if not is_on_floor():
		velocity.y -= GRAVEDAD * delta
	# Con una interfaz abierta, el jugador se queda quieto.
	if interfaz_abierta:
		velocity.x = move_toward(velocity.x, 0, 10.0)
		velocity.z = move_toward(velocity.z, 0, 10.0)
		move_and_slide()
		return
	# Movimiento WASD relativo a la dirección del jugador.
	var entrada := Input.get_vector("mover_izquierda", "mover_derecha", "mover_adelante", "mover_atras")
	var direccion: Vector3 = (transform.basis * Vector3(entrada.x, 0, entrada.y)).normalized()
	var velocidad := estadisticas.obtener_velocidad()
	if direccion != Vector3.ZERO:
		velocity.x = direccion.x * velocidad
		velocity.z = direccion.z * velocidad
	else:
		velocity.x = move_toward(velocity.x, 0, velocidad)
		velocity.z = move_toward(velocity.z, 0, velocidad)
	# Salto.
	if Input.is_action_just_pressed("saltar") and is_on_floor():
		velocity.y = FUERZA_SALTO
	move_and_slide()
	# Acciones con teclas.
	if Input.is_action_just_pressed("atacar"):
		_atacar()
	if Input.is_action_just_pressed("interactuar"):
		quiere_interactuar.emit()
	if Input.is_action_just_pressed("abrir_tienda"):
		quiere_tienda.emit()
	if Input.is_action_just_pressed("guardar"):
		quiere_guardar.emit()

## Ataque con la espada de energía: daña a los enemigos cercanos y delante.
func _atacar() -> void:
	if _tiempo_desde_ataque < TIEMPO_ENTRE_ATAQUES or _atacando:
		return
	_tiempo_desde_ataque = 0.0
	_atacando = true
	# Animación simple: giro rápido de la espada.
	var tween := create_tween()
	tween.tween_property(brazo_espada, "rotation:z", -1.2, 0.12)
	tween.tween_property(brazo_espada, "rotation:z", 0.3, 0.2)
	tween.tween_callback(_terminar_ataque)
	# Daño a los enemigos en rango y dentro del arco frontal.
	var dano := estadisticas.obtener_dano()
	for enemigo in get_tree().get_nodes_in_group("enemigos"):
		if enemigo is Enemigo:
			var distancia := global_position.distance_to(enemigo.global_position)
			if distancia > RANGO_ATAQUE:
				continue
			var hacia_enemigo: Vector3 = (enemigo.global_position - global_position).normalized()
			if -transform.basis.z.dot(hacia_enemigo) > 0.2:
				enemigo.recibir_danio(dano)

func _terminar_ataque() -> void:
	_atacando = false

## Reaparecer en el punto de aparición con la salud completa.
func reaparecer(punto: Vector3) -> void:
	global_position = punto
	velocity = Vector3.ZERO
	estadisticas.salud = estadisticas.salud_maxima
	estadisticas.emitir_todo()
