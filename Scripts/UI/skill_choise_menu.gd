extends Control

@onready var name_a = %NameA
@onready var desc_a = %DescA
@onready var name_b = %NameB
@onready var desc_b = %DescB

var current_skill_a_id: String = ""
var current_skill_b_id: String = ""
var player_skills_ref: Node = null 

var skill_database = {
	"forza": {
		5: [{"id": "braccio_di_ferro", "name": "Braccio di Ferro", "desc": "Aumenta i danni base della spada del 15%."}, {"id": "pelle_dura", "name": "Pelle Dura", "desc": "Riduci i danni subiti da tutti gli attacchi."}],
		10: [{"id": "forza_bruta", "name": "Forza Bruta", "desc": "Aumenta il Knockback dei colpi di spada."}, {"id": "sete_di_sangue", "name": "Sete di Sangue", "desc": "Uccidere un nemico ripristina un po' di Vita."}],
		15: [{"id": "raggio_esteso", "name": "Raggio Esteso", "desc": "La hitbox della tua spada è più grande (colpisci da più lontano)."}, {"id": "raffica", "name": "Raffica", "desc": "Velocità di attacco aumentata."}],
		20: [{"id": "esecutore", "name": "Esecutore", "desc": "Danni raddoppiati se il nemico ha meno del 30% di salute."}, {"id": "berserker", "name": "Berserker", "desc": "Se la tua salute scende sotto il 40%, danni raddoppiati e velocità aumentata."}]
	},
	"stealth": {
		5: [{"id": "passo_felpato", "name": "Passo Felpato", "desc": "Ti muovi più velocemente mentre sei accovacciato."}, {"id": "mimetizzazione", "name": "Mimetizzazione", "desc": "Da accovacciato, il raggio di visione dei nemici si riduce."}],
		10: [{"id": "punti_vitali", "name": "Punti Vitali", "desc": "Il Backstab infligge danni enormemente aumentati invece di uccidere all'istante."}, {"id": "via_di_fuga", "name": "Via di Fuga", "desc": "Se vieni scoperto, ottieni un bonus di velocità di scatto per 3 secondi."}],
		15: [{"id": "passo_silenzioso", "name": "Passo Silenzioso", "desc": "Il rumore dei tuoi passi (area di allerta) viene dimezzato."}, {"id": "lama_rigeneratrice", "name": "Lama Rigeneratrice", "desc": "Ogni Backstab andato a segno ti cura di 10 HP."}],
		20: [{"id": "fantasma", "name": "Fantasma", "desc": "Dopo un Backstab con successo, diventi invisibile ai nemici per 4 secondi."}, {"id": "impercettibile", "name": "Impercettibile", "desc": "Correre o camminare non aumenta più il rumore o la tua visibilità. Sei furtivo come in Crouch."}]
	}
}

func open_menu(tree_type: String, level: int, skills_component: Node) -> void:
	player_skills_ref = skills_component
	
	if skill_database.has(tree_type) and skill_database[tree_type].has(level):
		var choices = skill_database[tree_type][level]
		
		current_skill_a_id = choices[0]["id"]
		name_a.text = choices[0]["name"]
		desc_a.text = choices[0]["desc"]
		
		current_skill_b_id = choices[1]["id"]
		name_b.text = choices[1]["name"]
		desc_b.text = choices[1]["desc"]
		
		show()
	else:
		push_error("Nessuna abilità trovata per " + tree_type + " al livello " + str(level))

func _confirm_choice(chosen_id: String) -> void:
	if player_skills_ref:
		player_skills_ref.unlock_skill(chosen_id)
	
	# Si distrugge. L'HUD rileverà il tree_exited e agirà di conseguenza.
	queue_free()

func _on_texture_button_pressed() -> void:
	UIAudioManager.play_click()
	_confirm_choice(current_skill_a_id)

func _on_texture_button_2_pressed() -> void:
	UIAudioManager.play_click()
	_confirm_choice(current_skill_b_id)
