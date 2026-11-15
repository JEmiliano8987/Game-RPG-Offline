extends RefCounted
class_name DatosJuego

## Datos base del juego (fáciles de modificar para cambiar el equilibrio
## o el tema: solo hay que tocar estos diccionarios).

## Tipos de enemigo: salud, daño, velocidad, rangos y recompensas.
const ENEMIGOS: Dictionary = {
	"dron": {
		"nombre": "Dron vigilante",
		"salud": 30,
		"dano": 8,
		"velocidad": 3.5,
		"rango_deteccion": 12.0,
		"rango_ataque": 1.8,
		"recompensa_creditos": 15,
		"recompensa_xp": 20,
		"color_cuerpo": Color(0.25, 0.45, 0.55),
		"color_ojo": Color(1.0, 0.2, 0.2),
	},
	"robot": {
		"nombre": "Robot centinela",
		"salud": 70,
		"dano": 15,
		"velocidad": 2.2,
		"rango_deteccion": 10.0,
		"rango_ataque": 2.0,
		"recompensa_creditos": 30,
		"recompensa_xp": 40,
		"color_cuerpo": Color(0.35, 0.35, 0.4),
		"color_ojo": Color(1.0, 0.15, 0.1),
	},
}

## Mejoras de la tienda: nombre, descripción, costo base, costo extra
## por nivel y nivel máximo.
const MEJORAS: Dictionary = {
	"dano": {
		"nombre": "Cañón de plasma",
		"descripcion": "+5 de daño por nivel",
		"costo_base": 50,
		"costo_por_nivel": 25,
		"max_nivel": 5,
	},
	"salud": {
		"nombre": "Armadura de titanio",
		"descripcion": "+20 de salud máxima por nivel",
		"costo_base": 50,
		"costo_por_nivel": 25,
		"max_nivel": 5,
	},
	"velocidad": {
		"nombre": "Servomotores",
		"descripcion": "+0.4 de velocidad por nivel",
		"costo_base": 40,
		"costo_por_nivel": 20,
		"max_nivel": 5,
	},
}

## Costo de una mejora según el nivel actual que ya tiene el jugador.
static func costo_mejora(tipo: String, nivel_actual: int) -> int:
	var datos: Dictionary = MEJORAS.get(tipo, {})
	if datos.is_empty():
		return 0
	return int(datos["costo_base"]) + int(datos["costo_por_nivel"]) * nivel_actual
