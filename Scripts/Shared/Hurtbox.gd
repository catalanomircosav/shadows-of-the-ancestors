extends Area2D
class_name Hurtbox
# ==============================================================================
# SCRIPT: hurtbox.gd
# DESCRIZIONE: Componente universale che gestisce la ricezione dei colpi fisici.
# Rileva l'ingresso di Hitbox offensive (nemici o player), verifica la validità
# del colpo e inoltra i danni all'HealthComponent.
# ==============================================================================

# ------------------------------------------------------------------------------
# NODI (ONREADY)
# ------------------------------------------------------------------------------
# Cerca il componente della salute partendo dal presupposto che sia un nodo "fratello"
@onready var health_component: HealthComponent = get_parent().get_node("HealthComponent")


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	# Connette il segnale nativo di Area2D per rilevare l'ingresso di altre aree
	area_entered.connect(_on_area_entered)


# ==============================================================================
# CALLBACKS DEI SEGNALI
# ==============================================================================

## Invocato automaticamente dal motore fisico quando un'altra Area2D 
## entra nello spazio di collisione di questa Hurtbox.
func _on_area_entered(hitbox: Area2D) -> void:
	
	# 1. Ignora qualsiasi area che non sia la nostra classe universale Hitbox
	if not hitbox is Hitbox:
		return

	# 2. Identifica chi sta subendo il colpo (il genitore di questa Hurtbox)
	var owner_node: Node = get_parent()
	
	# 3. Verifica se questo colpo è già stato processato per questa entità
	if hitbox.already_hit(owner_node):
		return
		
	# 4. Registra l'entità per evitare colpi multipli durante la stessa animazione
	hitbox.register_hit(owner_node)
	
	# 5. Inizializza le variabili per il calcolo dei danni
	var final_damage: int = hitbox.damage
	var is_backstab: bool = false
	var attacking_entity: Node = hitbox.attacker 
	
	# 6. Logica del Backstab: si attiva se un nemico viene colpito dal player
	if owner_node is EnemyBase and attacking_entity is Player:
		# Se guardano nella stessa direzione, è un colpo alle spalle!
		if owner_node.last_facing == attacking_entity.last_facing:
			is_backstab = true
			
	if is_backstab:
		# Moltiplica il danno o rendilo letale
		final_damage *= 2
		# print("BACKSTAB!")
	
	# 7. Passa i dati all'HealthComponent per elaborare danno e rinculo
	health_component.take_damage(
		final_damage, 
		hitbox.global_position, 
		hitbox.knockback_strength
	)
