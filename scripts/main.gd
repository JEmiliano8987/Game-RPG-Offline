extends Node3D

## Escena principal: coordina al jugador, los enemigos, las misiones,
## el guardado y la tienda. Neo-CDMX, 2087.

const ESCENA_ENEMIGO: PackedScene = preload("res://scenes/enemy.tscn")
const TIEMPO_REAPARICION_ENEMIGO: float = 8.0
const MAX_ENEMIGOS_VIVOS: int = 8

## Puntos donde aparecen los enemigos (posición y tipo).
const PUNTOS_ENEMIGOS: Array = [
	{"pos": Vector3(-8, 0, -6), "tipo": "dron"},
	{"pos": Vector3(8, 0, -4), "tipo": "robot"},
	{"pos": Vector3(-12, 0, 4), "tipo": "dron"},
	{"pos": Vector3(12, 0, 8), "tipo": "robot"},
	{"pos": Vector3(0, 0, -14), "tipo": "dron"},
]

@onready var jugador: Jugador = $Jugador
@onready var punto_aparicion: Marker3D = $PuntoAparicion
@onready var contenedor_enemigos: Node3D = $Enemigos
@onready var hud: HUD = $HUD
@onready var tienda: TiendaMejoras = $Tienda

var _estadisticas: EstadisticasJugador
var _misiones: SistemaMisiones

func _ready() -> void:
	_estadisticas = jugador.estadisticas
	_misiones = SistemaMisiones.new()
	_misiones.configurar(_estadisticas)
	add_child(_misiones)
	# Cargar la partida guardada, si existe.
	_cargar_partida()
	# Conectar señales.
	jugador.quiere_interactuar.connect(_al_interactuar)
	jugador.quiere_tienda.connect(_al_alternar_tienda)
	jugador.quiere_guardar.connect(_al_guardar_tecla)
	_estadisticas.jugador_muerto.connect(_al_morir_jugador)
	_estadisticas.creditos_ganados.connect(_misiones.registrar_creditos)
	_misiones.mision_completada.connect(_al_completar_mision)
	tienda.compra_realizada.connect(_al_comprar_mejora)
	tienda.tienda_cerrada.connect(_al_cerrar_tienda)
	hud.abrir_tienda_pulsado.connect(_al_alternar_tienda)
	hud.conectar(_estadisticas, _misiones)
	tienda.configurar(_estadisticas, _misiones)
	# Colocar al jugador en el punto de aparición.
	jugador.global_position = punto_aparicion.global_position
	# Generar los enemigos iniciales.
	for punto in PUNTOS_ENEMIGOS:
		var pos: Vector3 = punto["pos"]
		_generar_enemigo(pos, String(punto["tipo"]))
	hud.mostrar_mensaje("Neo-CDMX, 2087. Restaura la ciudad, técnico.", 5.0)

## Genera un enemigo en una posición (o lo reaparece tras morir).
func _generar_enemigo(posicion: Vector3, tipo: String) -> void:
	if contenedor_enemigos.get_child_count() >= MAX_ENEMIGOS_VIVOS:
		return
	var enemigo := ESCENA_ENEMIGO.instantiate() as Enemigo
	enemigo.tipo = tipo
	enemigo.position = posicion
	enemigo.derrotado.connect(_al_enemigo_derrotado)
	contenedor_enemigos.add_child(enemigo)

## Cuando un enemigo muere: recompensas, misión y reaparición.
func _al_enemigo_derrotado(enemigo: Enemigo) -> void:
	_estadisticas.ganar_creditos(enemigo.recompensa_creditos)
	_estadisticas.ganar_experiencia(enemigo.recompensa_xp)
	_misiones.registrar_derrota(enemigo.tipo)
	hud.mostrar_mensaje("+%d créditos, +%d XP" % [enemigo.recompensa_creditos, enemigo.recompensa_xp], 2.0)
	# Reaparece otro igual en su zona al cabo de unos segundos.
	var posicion := enemigo.position
	var tipo := enemigo.tipo
	get_tree().create_timer(TIEMPO_REAPARICION_ENEMIGO).timeout.connect(_generar_enemigo.bind(posicion, tipo))

## Interactuar con el punto más cercano (tecla E).
func _al_interactuar() -> void:
	if tienda.visible:
		return
	var cercano: Interactuable = null
	var distancia_minima := 3.5
	for nodo in get_tree().get_nodes_in_group("interactuables"):
		var punto := nodo as Interactuable
		if punto == null:
			continue
		var distancia := jugador.global_position.distance_to(punto.global_position)
		if distancia < distancia_minima:
			distancia_minima = distancia
			cercano = punto
	if cercano == null:
		return
	var mensaje := _misiones.registrar_interaccion(cercano.id_interaccion)
	hud.mostrar_mensaje(mensaje, 5.0)
	guardar_partida()

## Abrir o cerrar la tienda (tecla T o botón del HUD).
func _al_alternar_tienda() -> void:
	if tienda.visible:
		tienda.cerrar()
		return
	if not tienda.esta_desbloqueada():
		hud.mostrar_mensaje("La tienda se desbloquea al rescatar a la ingeniera Mara (Misión 3).", 4.0)
		return
	tienda.abrir()
	jugador.interfaz_abierta = true

func _al_cerrar_tienda() -> void:
	jugador.interfaz_abierta = false

## Al completar una misión se guarda la partida automáticamente.
func _al_completar_mision(_mision: Dictionary) -> void:
	guardar_partida()

## Comprar una mejora: mensaje y guardado automático.
func _al_comprar_mejora(tipo: String, costo: int) -> void:
	var datos: Dictionary = DatosJuego.MEJORAS.get(tipo, {})
	hud.mostrar_mensaje("¡Mejora comprada: %s! (-%d créditos)" % [String(datos.get("nombre", tipo)), costo], 3.0)
	guardar_partida()

## Guardar con la tecla G.
func _al_guardar_tecla() -> void:
	guardar_partida()
	hud.mostrar_mensaje("Partida guardada.", 2.0)

## Guardar nivel, XP, créditos, mejoras y progreso de misiones.
func guardar_partida() -> void:
	var datos: Dictionary = _estadisticas.obtener_datos_guardado()
	datos.merge(_misiones.obtener_datos_guardado())
	Guardado.guardar(datos)

## Cargar la partida guardada al arrancar (si existe).
func _cargar_partida() -> void:
	var datos := Guardado.cargar()
	if datos.is_empty():
		return
	_estadisticas.cargar_desde(datos)
	_misiones.cargar_desde(datos)

## Al morir, el jugador reaparece en el refugio con la salud completa.
func _al_morir_jugador() -> void:
	hud.mostrar_mensaje("Has caído... pero un técnico siempre vuelve. Reapareciendo en el refugio.", 4.0)
	jugador.reaparecer(punto_aparicion.global_position)
