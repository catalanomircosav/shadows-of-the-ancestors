extends Control
# ==============================================================================
# SCRIPT: intro_cutscene.gd
# DESCRIZIONE: Gestisce le slide iniziali della storia con una transizione in dissolvenza.
# ==============================================================================

@onready var slide_image: TextureRect = $SlideImage
@onready var story_text: Label = $StoryText

# Indice della diapositiva attuale
var current_slide: int = 0
var is_transitioning: bool = false

# L'Array che contiene tutte le tue slide. 
# Ogni elemento è un dizionario con l'immagine e il testo.
var slides: Array[Dictionary] = [
	{
		"image": preload("res://Assets/intro1.png"),
		"text": "La superbia fu la rovina dell'antico Impero di Kaelen. Terrorizzato dalla mortalità, l'Imperatore strinse un empio patto con l'Oscurità delle profondità. Chiese la vita eterna per sé e per il suo regno. La ottenne... ma il prezzo fu la dannazione del suo stesso popolo."
	},
	{
		"image": preload("res://Assets/intro2.png"),
		"text": "Solo l'Ordine dei Custodi, fieri guerrieri dal mantello azzurro, rifiuto' l'orribile patto. Incapaci di salvare il loro Re e i loro fratelli ormai mutati, compirono un ultimo, disperato sacrificio: sigillarono le porte di Kaelen dall'esterno, seppellendo il proprio popolo nell'oscurità per proteggere il mondo di superficie."
	},
	{
		"image": preload("res://Assets/intro3.png"),
		"text": "Per secoli, il sigillo ha retto. Ma l'oscurità è paziente. Ora, il 'Morbo dell'Ombra' sta filtrando dalle viscere della terra, appestando il mondo dei vivi. I raccolti muoiono, l'aria si fa tossica e antiche rovine sputano fumo nerastro. La corruzione è giunta in superficie, e il tempo per la guardia passiva è finito."
	},
	{
		"image": preload("res://Assets/intro4.png"),
		"text": "Il sangue dell'antico Ordine scorre ormai nelle vene di un solo guerriero. Consapevole che vegliare sui sigilli non è piu' sufficiente, l'ultimo Custode stringe la sua lama nell'oscurità. Accetta il suo fardello e si prepara a compiere l'unico gesto possibile: una discesa suicida verso il cuore di Kaelen."
	},
	{
		"image": preload("res://Assets/intro5.png"),
		"text": "L'antico sigillo è infranto. Le fauci di Kaelen si aprono di nuovo, affamate. Con la spada sguainata e il peso del mondo sulle spalle, l'ultimo Custode varca la soglia. Non c'è piu' spazio per le esitazioni: il regno delle ombre lo attende."
	}
]

func _ready() -> void:
	# Mostra la prima slide appena la scena viene caricata
	_show_slide(current_slide)

func _input(event: InputEvent) -> void:
	# Ignora gli input se stiamo facendo l'animazione di dissolvenza
	if is_transitioning:
		return
		
	# Avanza se il giocatore preme Spazio/Invio, o se clicca con il mouse
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		_next_slide()

func _next_slide() -> void:
	current_slide += 1
	
	if current_slide < slides.size():
		_show_slide(current_slide)
	else:
		MenuIntroMusic.stop()
		get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _show_slide(index: int) -> void:
	is_transitioning = true
	
	# Prepara la nuova immagine e il nuovo testo
	slide_image.texture = slides[index]["image"]
	story_text.text = slides[index]["text"]
	
	# Trucco pro: Creiamo un Tween (animazione via codice) per una dissolvenza pulita
	# Imposta l'opacità a 0
	slide_image.modulate.a = 0.0
	story_text.modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	# Fai apparire l'immagine e il testo gradualmente in 1 secondo
	tween.tween_property(slide_image, "modulate:a", 1.0, 1.0)
	tween.tween_property(story_text, "modulate:a", 1.0, 1.0)
	
	# Quando l'animazione finisce, sblocca gli input
	tween.chain().tween_callback(func(): is_transitioning = false)


func _on_btn_options_pressed() -> void:
	MenuIntroMusic.stop()
	get_tree().change_scene_to_file("res://Scenes/World.tscn")
