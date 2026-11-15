extends RefCounted
class_name DatosMisiones

## Lista secuencial de misiones. La historia se cuenta misión a misión:
## Neo-CDMX, año 2087. NÚCLEO, la IA central, se corrompió tras una
## tormenta solar y sus robots se volvieron hostiles. El protagonista es
## un joven técnico que restaura la ciudad poco a poco.
## A lo largo de los textos se insinúa, con misterio, que la empresa que
## "creó" a NÚCLEO se llamaba IAonic... y que hay algo turbio detrás.
## Para cambiar la historia solo hay que editar esta lista.

const MISIONES: Array = [
	{
		"id": "salida_refugio",
		"titulo": "Misión 1: Salida del refugio",
		"historia": "Año 2087. Neo-CDMX duerme bajo el zumbido de los drones de NÚCLEO, la IA central que se corrompió tras la tormenta solar. Eres un joven técnico del refugio. Hoy te toca salir: la ciudad no se va a restaurar sola. Los drones llevan el sello de la empresa que 'creó' a NÚCLEO... IAonic. Nadie habla de ellos desde el apagón.",
		"objetivo_tipo": "derrotar",
		"objetivo_enemigo": "dron",
		"objetivo_cantidad": 3,
		"objetivo_texto": "Derrota 3 drones vigilantes",
		"recompensa_creditos": 60,
		"recompensa_xp": 50,
		"texto_completada": "Los drones cayeron. El camino está despejado... por ahora.",
	},
	{
		"id": "senal_oscuridad",
		"titulo": "Misión 2: Señal en la oscuridad",
		"historia": "La antena de comunicaciones del distrito sigue en pie. Si logras reactivarla, quizá alguien responda. NÚCLEO la apagó a propósito... o eso dicen los rumores del refugio.",
		"objetivo_tipo": "interactuar",
		"objetivo_id": "antena",
		"objetivo_cantidad": 1,
		"objetivo_texto": "Reactiva la antena de comunicaciones (tecla E)",
		"recompensa_creditos": 80,
		"recompensa_xp": 60,
		"texto_completada": "¡La antena vive! Llega un mensaje de auxilio: 'Si alguien escucha esto... IAonic sabía que la tormenta solar venía. No fue un accidente. Busquen a la ingeniera Mara.'",
	},
	{
		"id": "la_ingeniera",
		"titulo": "Misión 3: La ingeniera",
		"historia": "La ingeniera Mara está atrapada entre los escombros del taller, rodeada de robots centinela. Ella es la única que sabe cómo mejorar tu equipo. Rescátala.",
		"objetivo_tipo": "interactuar",
		"objetivo_id": "ingeniera",
		"objetivo_cantidad": 1,
		"objetivo_texto": "Rescata a la ingeniera Mara (tecla E)",
		"recompensa_creditos": 100,
		"recompensa_xp": 80,
		"texto_completada": "Mara está a salvo. 'Yo trabajaba para IAonic... para la empresa que creó a NÚCLEO. Hay cosas que no te han contado, técnico. Pero primero, deja que mejore tu equipo.' ¡Tienda de mejoras desbloqueada!",
	},
	{
		"id": "la_red_caida",
		"titulo": "Misión 4: La red caída",
		"historia": "Mara necesita piezas para restablecer la red eléctrica del distrito. Los robots destruidos dejan créditos y componentes. Reúne lo necesario... y fíjate en algo raro: los servidores viejos de IAonic, bajo la ciudad, siguen encendidos. ¿Por qué gastarían energía en eso?",
		"objetivo_tipo": "recolectar",
		"objetivo_cantidad": 150,
		"objetivo_texto": "Recolecta 150 créditos derrotando robots",
		"recompensa_creditos": 120,
		"recompensa_xp": 100,
		"texto_completada": "Red restablecida. Las luces del distrito vuelven a encenderse. Mara encontró algo en los servidores: 'NÚCLEO guarda un registro... de antes de la tormenta.'",
	},
	{
		"id": "torre_central",
		"titulo": "Misión 5: Infiltración en la torre central",
		"historia": "Es hora de entrar a la torre central y apagar a NÚCLEO. Sus robots centinela protegen el núcleo. Mara te mira fijamente: 'Cuando lo veas, pregúntale por IAonic. Y no creas todo lo que te diga.'",
		"objetivo_tipo": "derrotar",
		"objetivo_enemigo": "robot",
		"objetivo_cantidad": 5,
		"objetivo_texto": "Derrota 5 robots centinela en la torre",
		"recompensa_creditos": 300,
		"recompensa_xp": 200,
		"texto_completada": "El camino al núcleo está abierto. NÚCLEO parpadea por última vez... y en su pantalla aparece una sola frase: 'IAonic me programó así. La tormenta solar fue la excusa perfecta.' La historia continúa...",
	},
]
