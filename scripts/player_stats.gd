extends Node
class_name EstadisticasJugador

## Estadísticas del jugador: salud, nivel, experiencia y créditos.
## También guarda los niveles de mejora comprados en la tienda.

signal salud_cambiada(salud: int, salud_maxima: int)
signal experiencia_cambiada(experiencia: int, necesaria: int, nivel: int)
signal creditos_cambiados(creditos: int)
signal creditos_ganados(cantidad: int)
signal nivel_subido(nuevo_nivel: int)
signal jugador_muerto

const SALUD_BASE: int = 100
const DANO_BASE: int = 10
const VELOCIDAD_BASE: float = 5.0
const XP_BASE: int = 100

var salud_maxima: int = SALUD_BASE
var salud: int = SALUD_BASE
var nivel: int = 1
var experiencia: int = 0
var experiencia_necesaria: int = XP_BASE
var creditos: int = 0
var dano_base: int = DANO_BASE
var mejoras: Dictionary = {"dano": 0, "salud": 0, "velocidad": 0}

func _ready() -> void:
	emitir_todo()

## Emite todas las señales para que el HUD se actualice.
func emitir_todo() -> void:
	salud_cambiada.emit(salud, salud_maxima)
	experiencia_cambiada.emit(experiencia, experiencia_necesaria, nivel)
	creditos_cambiados.emit(creditos)

## Daño total del ataque (base + mejoras de daño).
func obtener_dano() -> int:
	return dano_base + int(mejoras.get("dano", 0)) * 5

## Velocidad de movimiento (base + mejoras de velocidad).
func obtener_velocidad() -> float:
	return VELOCIDAD_BASE + float(mejoras.get("velocidad", 0)) * 0.4

## Recibir daño de un enemigo.
func recibir_danio(cantidad: int) -> void:
	if salud <= 0:
		return
	salud = maxi(0, salud - cantidad)
	salud_cambiada.emit(salud, salud_maxima)
	if salud <= 0:
		jugador_muerto.emit()

## Curarse (por ejemplo, al subir de nivel te curas por completo).
func curar(cantidad: int) -> void:
	salud = mini(salud_maxima, salud + cantidad)
	salud_cambiada.emit(salud, salud_maxima)

## Ganar experiencia; puede provocar varias subidas de nivel seguidas.
func ganar_experiencia(cantidad: int) -> void:
	experiencia += cantidad
	while experiencia >= experiencia_necesaria:
		experiencia -= experiencia_necesaria
		_subir_nivel()
	experiencia_cambiada.emit(experiencia, experiencia_necesaria, nivel)

## Subir de nivel: más salud máxima, más daño y curación completa.
func _subir_nivel() -> void:
	nivel += 1
	experiencia_necesaria = int(experiencia_necesaria * 1.5)
	salud_maxima += 15
	dano_base += 3
	salud = salud_maxima
	nivel_subido.emit(nivel)
	salud_cambiada.emit(salud, salud_maxima)

## Ganar créditos (recompensas, botín de robots).
func ganar_creditos(cantidad: int) -> void:
	creditos += cantidad
	creditos_cambiados.emit(creditos)
	creditos_ganados.emit(cantidad)

## Gastar créditos en la tienda. Devuelve false si no alcanza.
func gastar_creditos(cantidad: int) -> bool:
	if creditos < cantidad:
		return false
	creditos -= cantidad
	creditos_cambiados.emit(creditos)
	return true

## Aplicar una mejora comprada en la tienda.
func aplicar_mejora(tipo: String) -> void:
	mejoras[tipo] = int(mejoras.get(tipo, 0)) + 1
	if tipo == "salud":
		salud_maxima += 20
		salud = mini(salud_maxima, salud + 20)
		salud_cambiada.emit(salud, salud_maxima)

## Datos para guardar la partida.
func obtener_datos_guardado() -> Dictionary:
	return {
		"nivel": nivel,
		"experiencia": experiencia,
		"creditos": creditos,
		"salud": salud,
		"mejoras": mejoras.duplicate(),
	}

## Cargar datos de una partida guardada (con valores por defecto seguros).
func cargar_desde(datos: Dictionary) -> void:
	nivel = int(datos.get("nivel", 1))
	experiencia = int(datos.get("experiencia", 0))
	creditos = int(datos.get("creditos", 0))
	# La salud máxima se recalcula desde el nivel y las mejoras.
	mejoras = {"dano": 0, "salud": 0, "velocidad": 0}
	var guardadas: Dictionary = datos.get("mejoras", {})
	for clave in mejoras.keys():
		mejoras[clave] = int(guardadas.get(clave, 0))
	experiencia_necesaria = XP_BASE
	for _i in range(1, nivel):
		experiencia_necesaria = int(experiencia_necesaria * 1.5)
	dano_base = DANO_BASE + (nivel - 1) * 3
	salud_maxima = SALUD_BASE + (nivel - 1) * 15 + int(mejoras.get("salud", 0)) * 20
	salud = mini(int(datos.get("salud", salud_maxima)), salud_maxima)
	emitir_todo()
