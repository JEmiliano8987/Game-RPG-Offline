# Game-RPG-Offline

Videojuego RPG offline en tercera persona, hecho en **Godot 4**.

**Historia:** Neo-CDMX, año 2087. NÚCLEO, la IA central, se corrompió tras
una tormenta solar y sus robots se volvieron hostiles. Eres un joven técnico
del refugio que restaura la ciudad misión por misión... y en el camino irás
descubriendo qué papel jugó la empresa que "creó" a NÚCLEO: **IAonic**.

## Cómo abrir el proyecto

1. Instala **Godot 4.2 o superior** desde https://godotengine.org/download
   (la versión estándar, no hace falta nada más).
2. En Godot, pulsa **Importar** y elige la carpeta de este proyecto
   (o abre el archivo `project.godot`).
3. Pulsa **F5** (o el botón ▶) para jugar.

No se necesitan recursos externos: todos los modelos son figuras simples
(cápsulas, cajas y esferas) creadas dentro del propio Godot.

## Controles

| Tecla | Acción |
|---|---|
| W A S D / Flechas | Moverse |
| Ratón | Girar la cámara (clic para recapturar el ratón) |
| Espacio | Saltar |
| Clic izquierdo | Atacar con la espada de energía |
| E | Interactuar (antena, ingeniera...) |
| T | Abrir/cerrar la tienda de mejoras |
| G | Guardar la partida |

## Sistemas (dónde vive cada cosa)

- **Jugador** — `scenes/player.tscn` y `scripts/player.gd`: movimiento
  en tercera persona, cámara con órbita de ratón (SpringArm3D), salto y
  ataque con espada de energía.
- **Estadísticas** — `scripts/player_stats.gd`: salud, nivel, experiencia,
  XP para subir de nivel y créditos. Al subir de nivel aumentan la salud
  máxima y el daño, y te curas por completo.
- **Enemigos** — `scenes/enemy.tscn` y `scripts/enemy.gd`: drones y robots
  centinela con salud, IA de patrulla/persecución/ataque y barra de vida.
  Al morir sueltan créditos y XP, y reaparecen a los pocos segundos.
  Los datos de cada tipo están en `scripts/datos_juego.gd`.
- **Misiones** — `scripts/misiones.gd` y `scripts/datos_misiones.gd`: 5
  misiones secuenciales que cuentan la historia (salir del refugio,
  reactivar la antena, rescatar a la ingeniera, restablecer la red e
  infiltrarse en la torre central). Cada una tiene título, texto de
  historia, objetivo y recompensa en créditos y XP. Al completar una se
  desbloquea la siguiente. Para cambiar la historia, edita solo
  `datos_misiones.gd`.
- **Tienda de mejoras** — `scenes/tienda.tscn` y `scripts/tienda_mejoras.gd`:
  gasta créditos en Cañón de plasma (daño), Armadura de titanio (salud
  máxima) y Servomotores (velocidad), 5 niveles cada una. Se desbloquea al
  completar la Misión 3 (rescatar a la ingeniera Mara).
- **HUD** — `scenes/hud.tscn` y `scripts/hud.gd`: barra de salud, nivel,
  barra de XP, créditos, panel de la misión actual con su historia y
  progreso, y mensajes en pantalla.
- **Guardado** — `scripts/guardado.gd`: partida local en JSON
  (`user://savegame.json`, sin internet). Guarda nivel, XP, créditos,
  mejoras y progreso de misiones. Se carga sola al arrancar, se guarda con
  G, al completar una misión y al comprar una mejora.
- **Mundo** — `main.tscn` y `scripts/main.gd`: plaza de Neo-CDMX al
  atardecer (suelo, edificios en ruinas, contenedores, refugio, antena,
  torre central), aparición de enemigos y coordinación de todos los
  sistemas.

## Cambiar el tema o el equilibrio

- **Enemigos y mejoras:** edita los diccionarios de `scripts/datos_juego.gd`.
- **Historia y misiones:** edita la lista `MISIONES` de
  `scripts/datos_misiones.gd` (título, historia, objetivo y recompensa).
- **Puntos de aparición de enemigos:** lista `PUNTOS_ENEMIGOS` en
  `scripts/main.gd`.

## Estado

Proyecto inicial (starter): sistemas básicos funcionando con arte
provisional. No hay modelos ni sonidos externos todavía.
