extends CanvasLayer
class_name TiendaMejoras

## Tienda de mejoras: gasta créditos en daño, salud máxima y velocidad.
## Se desbloquea al completar la Misión 3 (rescatar a la ingeniera).

signal tienda_cerrada
signal compra_realizada(tipo: String, costo: int)

@onready var etiqueta_creditos: Label = $Fondo/VBox/EtiquetaCreditos
@onready var etiqueta_nivel_dano: Label = $Fondo/VBox/FilaDano/EtiquetaNivelDano
@onready var etiqueta_costo_dano: Label = $Fondo/VBox/FilaDano/EtiquetaCostoDano
@onready var etiqueta_nivel_salud: Label = $Fondo/VBox/FilaSalud/EtiquetaNivelSalud
@onready var etiqueta_costo_salud: Label = $Fondo/VBox/FilaSalud/EtiquetaCostoSalud
@onready var etiqueta_nivel_velocidad: Label = $Fondo/VBox/FilaVelocidad/EtiquetaNivelVelocidad
@onready var etiqueta_costo_velocidad: Label = $Fondo/VBox/FilaVelocidad/EtiquetaCostoVelocidad
@onready var boton_comprar_dano: Button = $Fondo/VBox/FilaDano/BotonComprarDano
@onready var boton_comprar_salud: Button = $Fondo/VBox/FilaSalud/BotonComprarSalud
@onready var boton_comprar_velocidad: Button = $Fondo/VBox/FilaVelocidad/BotonComprarVelocidad
@onready var boton_cerrar: Button = $Fondo/VBox/BotonCerrar

var _estadisticas: EstadisticasJugador = null
var _misiones: SistemaMisiones = null

func _ready() -> void:
	visible = false
	boton_comprar_dano.pressed.connect(_al_comprar.bind("dano"))
	boton_comprar_salud.pressed.connect(_al_comprar.bind("salud"))
	boton_comprar_velocidad.pressed.connect(_al_comprar.bind("velocidad"))
	boton_cerrar.pressed.connect(cerrar)

func configurar(estadisticas: EstadisticasJugador, misiones: SistemaMisiones) -> void:
	_estadisticas = estadisticas
	_misiones = misiones
	estadisticas.creditos_cambiados.connect(func(_c: int) -> void: actualizar())

## ¿La tienda ya está desbloqueada? (Misión 3 completada).
func esta_desbloqueada() -> bool:
	if _misiones == null:
		return false
	return _misiones.misiones_completadas >= 3

func abrir() -> void:
	if not esta_desbloqueada():
		return
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	actualizar()

func cerrar() -> void:
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	tienda_cerrada.emit()

func actualizar() -> void:
	if _estadisticas == null or not visible:
		return
	etiqueta_creditos.text = "Créditos: %d" % _estadisticas.creditos
	_actualizar_fila("dano", etiqueta_nivel_dano, etiqueta_costo_dano, boton_comprar_dano)
	_actualizar_fila("salud", etiqueta_nivel_salud, etiqueta_costo_salud, boton_comprar_salud)
	_actualizar_fila("velocidad", etiqueta_nivel_velocidad, etiqueta_costo_velocidad, boton_comprar_velocidad)

func _actualizar_fila(tipo: String, etiqueta_nivel: Label, etiqueta_costo: Label, boton: Button) -> void:
	var datos: Dictionary = DatosJuego.MEJORAS.get(tipo, {})
	var nivel_actual := int(_estadisticas.mejoras.get(tipo, 0))
	var max_nivel := int(datos.get("max_nivel", 5))
	etiqueta_nivel.text = "Nv. %d / %d" % [nivel_actual, max_nivel]
	if nivel_actual >= max_nivel:
		etiqueta_costo.text = "Máximo"
		boton.disabled = true
	else:
		var costo := DatosJuego.costo_mejora(tipo, nivel_actual)
		etiqueta_costo.text = "Costo: %d créditos" % costo
		boton.disabled = _estadisticas.creditos < costo

func _al_comprar(tipo: String) -> void:
	if _estadisticas == null:
		return
	var datos: Dictionary = DatosJuego.MEJORAS.get(tipo, {})
	var nivel_actual := int(_estadisticas.mejoras.get(tipo, 0))
	if nivel_actual >= int(datos.get("max_nivel", 5)):
		return
	var costo := DatosJuego.costo_mejora(tipo, nivel_actual)
	if _estadisticas.gastar_creditos(costo):
		_estadisticas.aplicar_mejora(tipo)
		actualizar()
		compra_realizada.emit(tipo, costo)
	else:
		actualizar()
