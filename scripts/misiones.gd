extends Node
class_name SistemaMisiones

## Sistema de misiones secuenciales: la historia de Neo-CDMX 2087 se
## cuenta misión a misión. Al completar una se desbloquea la siguiente.

signal mision_actualizada
signal mision_completada(mision: Dictionary)
signal historia_completada

var indice_actual: int = 0
var progreso: int = 0
var creditos_en_mision: int = 0
var misiones_completadas: int = 0
var historia_terminada: bool = false

var _estadisticas: EstadisticasJugador = null
var _completando: bool = false

func configurar(estadisticas: EstadisticasJugador) -> void:
	_estadisticas = estadisticas

## Misión actual o diccionario vacío si ya se terminó la historia.
func obtener_actual() -> Dictionary:
	if indice_actual >= DatosMisiones.MISIONES.size():
		return {}
	return DatosMisiones.MISIONES[indice_actual]

func historia_esta_completada() -> bool:
	return historia_terminada

## Registrar que el jugador derrotó un enemigo de cierto tipo.
func registrar_derrota(tipo_enemigo: String) -> void:
	if _completando:
		return
	var mision := obtener_actual()
	if mision.is_empty():
		return
	if String(mision.get("objetivo_tipo", "")) == "derrotar" and String(mision.get("objetivo_enemigo", "")) == tipo_enemigo:
		progreso += 1
		_verificar_objetivo()

## Registrar créditos ganados (solo cuenta si la misión pide recolectar).
func registrar_creditos(cantidad: int) -> void:
	if _completando:
		return
	var mision := obtener_actual()
	if mision.is_empty():
		return
	if String(mision.get("objetivo_tipo", "")) == "recolectar":
		creditos_en_mision += cantidad
		progreso = creditos_en_mision
		_verificar_objetivo()

## Registrar una interacción (antena, ingeniera...). Devuelve un mensaje
## para mostrar en pantalla según lo que haya pasado.
func registrar_interaccion(id_interaccion: String) -> String:
	var mision := obtener_actual()
	if mision.is_empty():
		return "La historia ya está completa. Neo-CDMX respira... de momento."
	if String(mision.get("objetivo_tipo", "")) == "interactuar" and String(mision.get("objetivo_id", "")) == id_interaccion:
		progreso = int(mision.get("objetivo_cantidad", 1))
		_verificar_objetivo()
		return "¡Objetivo completado!"
	# Interacción fuera de la misión actual: pista contextual.
	match id_interaccion:
		"antena":
			return "La antena ya está reparada o aún no es el momento de tocarla."
		"ingeniera":
			return "La ingeniera Mara está atrapada... tendrás que rescatarla en su momento."
	return "Nada que hacer aquí por ahora."

## Comprueba si el objetivo actual ya se cumplió.
func _verificar_objetivo() -> void:
	if _completando:
		return
	var mision := obtener_actual()
	if mision.is_empty():
		return
	if progreso >= int(mision.get("objetivo_cantidad", 1)):
		_completar_mision(mision)
	else:
		mision_actualizada.emit()

## Recompensa, avance a la siguiente misión y aviso al HUD.
func _completar_mision(mision: Dictionary) -> void:
	_completando = true
	misiones_completadas += 1
	if _estadisticas != null:
		_estadisticas.ganar_creditos(int(mision.get("recompensa_creditos", 0)))
		_estadisticas.ganar_experiencia(int(mision.get("recompensa_xp", 0)))
	mision_completada.emit(mision)
	indice_actual += 1
	progreso = 0
	creditos_en_mision = 0
	_completando = false
	if indice_actual >= DatosMisiones.MISIONES.size():
		historia_terminada = true
		historia_completada.emit()
	else:
		mision_actualizada.emit()

func obtener_datos_guardado() -> Dictionary:
	return {
		"mision_actual": indice_actual,
		"misiones_completadas": misiones_completadas,
	}

func cargar_desde(datos: Dictionary) -> void:
	indice_actual = int(datos.get("mision_actual", 0))
	misiones_completadas = int(datos.get("misiones_completadas", 0))
	progreso = 0
	creditos_en_mision = 0
	historia_terminada = indice_actual >= DatosMisiones.MISIONES.size()
	mision_actualizada.emit()
