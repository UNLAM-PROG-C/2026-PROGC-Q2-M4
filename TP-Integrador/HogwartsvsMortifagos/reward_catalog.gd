class_name RewardCatalog
extends RefCounted

## Catalog mapping each level to its unlocked ally seed, tool or endgame trophy.

const LEVEL_1_DESC_TEXT: String = "¿Olvidaste algo? Su humo rojo se vuelve tan inestable que estalla mágicamente, fulminando al instante a los enemigos en un radio cercano."
const LEVEL_2_DESC_TEXT: String = "¿Necesitas tiempo? Este poderoso encantamiento crea una sólida barrera mágica que detiene a los mortífagos en seco, absorbiendo daño para proteger tus defensas."
const LEVEL_3_DESC_TEXT: String = "¿Necesitas espacio? Usa el hechizo convocador Accio para retirar instantáneamente a cualquier aliado del campo de batalla y reorganizar tu estrategia mágica."
const LEVEL_4_DESC_TEXT: String = "¡Pura potencia! Aunque le toma un momento extra preparar su ataque, los hechizos de Ron golpean con una fuerza aplastante que destroza al enemigo."
const LEVEL_5_DESC_TEXT: String = "¡A despejar el camino! Esta veloz escoba cruza el campo volando, barriendo una línea entera y fulminando a todos los mortífagos a su paso."
const LEVEL_6_DESC_TEXT: String = "¿Demasiado rápidos? Hermione conjura precisos hechizos gélidos que ralentizan el avance de los mortífagos, devolviéndote el control absoluto de la batalla."
const LEVEL_7_DESC_TEXT: String = "¿Peligro inminente? La profesora McGonagall desata una ráfaga implacable de cuatro hechizos consecutivos, destrozando velozmente hasta las defensas más resistentes de los mortífagos."
const LEVEL_8_DESC_TEXT: String = "¿Magia suprema? Dumbledore lanza un poderoso encantamiento frontal que detona al impactar, dañando simultáneamente a múltiples mortífagos en su zona de explosión."
const LEVEL_10_DESC_TEXT: String = "¡Has protegido la legendaria Piedra Filosofal! Gracias a tu brillante estrategia mágica, lograste derrotar a Quirrell y frustrar los oscuros planes de Voldemort. Este invaluable tesoro es el trofeo definitivo que consagra tu gran victoria. ¡Muchísimas gracias por jugar y defender los terrenos de Hogwarts hasta el final!"

const TEXTURE_REMEMBRALL: Texture2D = preload("res://Images/seed_remembrall.png")
const TEXTURE_PROTEGO: Texture2D = preload("res://Images/seed_protego.png")
const TEXTURE_ACCIO: Texture2D = preload("res://Images/elder_wand.png")
const TEXTURE_RON: Texture2D = preload("res://Images/seed_ron.png")
const TEXTURE_BROOMSTICK: Texture2D = preload("res://Images/seed_broomstick.png")
const TEXTURE_HERMIONE: Texture2D = preload("res://Images/seed_hermione.png")
const TEXTURE_MCGONAGALL: Texture2D = preload("res://Images/seed_mcgonagall.png")
const TEXTURE_DUMBLEDORE: Texture2D = preload("res://Images/seed_dumbledore.png")
const TEXTURE_PHILOSOPHERS_STONE: Texture2D = preload("res://Images/trophy_philosophers_stone.png")


class RewardData:
	var level_number: int
	var item_name: String
	var texture: Texture2D
	var description_text: String

	func _init(p_level: int, p_name: String, p_tex: Texture2D, p_desc: String) -> void:
		level_number = p_level
		item_name = p_name
		texture = p_tex
		description_text = p_desc


static func get_reward_for_level(level_num: int) -> RewardData:
	match level_num:
		1, 2, 3, 4:
			return _get_early_reward(level_num)
		5, 6, 7, 8:
			return _get_mid_reward(level_num)
		10:
			return RewardData.new(10, "PhilosophersStone", TEXTURE_PHILOSOPHERS_STONE, LEVEL_10_DESC_TEXT)
		_:
			return null


static func _get_early_reward(level_num: int) -> RewardData:
	match level_num:
		1:
			return RewardData.new(1, "Remembrall", TEXTURE_REMEMBRALL, LEVEL_1_DESC_TEXT)
		2:
			return RewardData.new(2, "Protego", TEXTURE_PROTEGO, LEVEL_2_DESC_TEXT)
		3:
			return RewardData.new(3, "Accio", TEXTURE_ACCIO, LEVEL_3_DESC_TEXT)
		4:
			return RewardData.new(4, "Ron", TEXTURE_RON, LEVEL_4_DESC_TEXT)
		_:
			return null


static func _get_mid_reward(level_num: int) -> RewardData:
	match level_num:
		5:
			return RewardData.new(5, "Broomstick", TEXTURE_BROOMSTICK, LEVEL_5_DESC_TEXT)
		6:
			return RewardData.new(6, "Hermione", TEXTURE_HERMIONE, LEVEL_6_DESC_TEXT)
		7:
			return RewardData.new(7, "McGonagall", TEXTURE_MCGONAGALL, LEVEL_7_DESC_TEXT)
		8:
			return RewardData.new(8, "Dumbledore", TEXTURE_DUMBLEDORE, LEVEL_8_DESC_TEXT)
		_:
			return null
