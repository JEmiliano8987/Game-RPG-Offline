extends CanvasLayer
class_name HUD

## Interfaz en pantalla: salud, nivel, XP, créditos y misión actual.

signal abrir_tienda_pulsado

@onready var barra_salud: ProgressBar = $PanelStats/VBox/BarraSalud
@onready var etiqueta_nivel: Label = $PanelStats/VBox/EtiquetaNivel
@onready var barra_xp: ProgressBar = $PanelStats/VBox/BarraXP
@onready var etiqueta_creditos: Label = $PanelStats/VBox/EtiquetaCreditos
@onready var etiqueta_titulo_mision: Label = $PanelMision/VBoxMision/EtiquetaTituloMision
@onready var etiqueta_historia_mision: Label = $PanelMision/VBoxMision/EtiquetaHistoriaMision
@onready var etiqueta_objetivo_mision: Label = $PanelMision/VBoxMision/EtiquetaObjetivoMision
@onready var etiqueta_progreso_mision: Label = $PanelMision/VBoxMision/EtiquetaProgresoMision
@onready var etiqueta_mensaje: Label = $EtiquetaMensaje
@onready var boton_tienda: Button = $BotonTienda

var _estadisticas: EstadisticasJugador = null
var _misiones: SistemaMisiones = null
var _temporizador_mensaje: float = 0.0

func _ready() -> void:
	boton_tienda.pressed.connect(func() -> void: abrir_tienda_pulsado.emit())
	etiqueta_mensaje.text = ""

func _process(delta: float) -> void:
	if _temporizador_mensaje > 0.0:
		_temporizador_mensaje -= delta
		if _temporizador_mensaje <= 0.0:
			etiqueta_mensaje.text = ""

## Conecta el HUD con las estadísticas y las misiones.
func conectar(estadisticas: EstadisticasJugador, misiones: SistemaMisiones) -> void:
	_estadisticas = estadisticas
	_misiones = misiones
	estadisticas.salud_cambiada.connect(_al_actualizar_salud)
	estadisticas.experiencia_cambiada.connect(_al_actualizar_experiencia)
	estadisticas.creditos_cambiados.connect(_al_actualizar_creditos)
	estadisticas.nivel_subido.connect(_al_subir_nivel)
	misiones.mision_actualizada.connect(actualizar_mision)
	misiones.mision_completada.connect(_al_completar_mision)
	misiones.historia_completada.connect(_al_completar_historia)
	estadisticas.emitir_todo()
	actualizar_mision()

func _al_actualizar_salud(salud: int, salud_maxima: int) -> void:
	barra_salud.max_value = salud_maxima
	barra_salud.value = salud

func _al_actualizar_experiencia(experiencia: int, necesaria: int, nivel: int) -> void:
	etiqueta_nivel.text = "Nivel %d" % nivel
	barra_xp.max_value = necesaria
	barra_xp.value = experiencia

func _al_actualizar_creditos(creditos: int) -> void:
	etiqueta_creditos.text = "Créditos: %d" % creditos

func _al_subir_nivel(nuevo_nivel: int) -> void:
	mostrar_mensaje("¡Subiste al nivel %d! Salud y daño aumentados." % nuevo_nivel, 4.0)

## Actualiza el panel con la misión actual y su progreso.
func actualizar_mision() -> void:
	if _misiones == null:
		return
	var mision := _misiones.obtener_actual()
	if mision.is_empty():
		etiqueta_titulo_mision.text = "Historia completada"
		etiqueta_historia_mision.text = "Neo-CDMX vuelve a respirar... de momento."
		etiqueta_objetivo_mision.text = ""
		etiqueta_progreso_mision.text = ""
		return
	etiqueta_titulo_mision.text = String(mision.get("titulo", ""))
	etiqueta_historia_mision.text = String(mision.get("historia", ""))
	etiqueta_objetivo_mision.text = String(mision.get("objetivo_texto", ""))
	etiqueta_progreso_mision.text = "%d / %d" % [_misiones.progreso, int(mision.get("objetivo_cantidad", 1))]

func _al_completar_mision(mision: Dictionary) -> void:
	mostrar_mensaje("¡Misión completada! +%d créditos, +%d XP. %s" % [int(mision.get("recompensa_creditos", 0)), int(mision.get("recompensa_xp", 0)), String(mision.get("texto_completada", ""))], 7.0)
	actualizar_mision()

func _al_completar_historia() -> void:
	mostrar_mensaje("¡Historia completada! Apagaste a NÚCLEO... pero el misterio de IAonic sigue abierto.", 8.0)

## Muestra un mensaje temporal en el centro de la pantalla.
func mostrar_mensaje(texto: String, duracion: float = 3.0) -> void:
	etiqueta_mensaje.text = texto
	_temporizador_mensaje = duracion
