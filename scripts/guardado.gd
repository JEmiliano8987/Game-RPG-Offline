extends RefCounted
class_name Guardado

## Guardado local en JSON (el juego es offline: no necesita internet).
## Archivo: user://savegame.json

const RUTA_GUARDADO: String = "user://savegame.json"

## Guarda un diccionario de datos en JSON. Devuelve true si funcionó.
static func guardar(datos: Dictionary) -> bool:
	var archivo := FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if archivo == null:
		push_error("No se pudo abrir el archivo de guardado.")
		return false
	archivo.store_string(JSON.stringify(datos))
	archivo.close()
	return true

## Carga los datos guardados. Devuelve un diccionario vacío si no hay partida.
static func cargar() -> Dictionary:
	if not FileAccess.file_exists(RUTA_GUARDADO):
		return {}
	var archivo := FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
	if archivo == null:
		push_error("No se pudo leer el archivo de guardado.")
		return {}
	var texto: String = archivo.get_as_text()
	archivo.close()
	var datos: Variant = JSON.parse_string(texto)
	if datos is Dictionary:
		return datos
	return {}

## Borra la partida guardada (para empezar de cero).
static func borrar() -> bool:
	if FileAccess.file_exists(RUTA_GUARDADO):
		var resultado: Error = DirAccess.remove_absolute(RUTA_GUARDADO)
		return resultado == OK
	return true
