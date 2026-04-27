extends Area2D
class_name Hurtbox
# ==============================================================================
# SCRIPT: hurtbox.gd (Hurtbox)
# DESCRIZIONE: Componente che gestisce la ricezione dei colpi fisici. Rileva 
# l'ingresso di hitbox offensive, verifica la validità del colpo e inoltra 
# i danni al componente della salute (HealthComponent).
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
	
	# Ignora qualsiasi area che non sia specificamente la spada del giocatore
	if not hitbox is SwordHitbox:
		return

	# Presume che il genitore diretto sia l'entità proprietaria da registrare
	var owner_node: Node = get_parent()
	
	# Verifica tramite l'hitbox se questo colpo è già stato processato per questa entità
	if hitbox.already_hit(owner_node):
		return
		
	# Registra l'entità per evitare colpi multipli durante lo stesso fendente
	hitbox.register_hit(owner_node)
	
	var final_damage: int = hitbox.damage
	var is_backstab: bool = false
	
	# Presupponendo che l'hitbox possa farti accedere al player che l'ha generata
	# e che owner_node sia il tuo EnemyBase
	var player = hitbox.owner # o get_parent(), a seconda del tuo albero
	
	if owner_node is EnemyBase and player is Player:
		# Se guardano nella stessa direzione, è un colpo alle spalle!
		if owner_node.last_facing == player.last_facing:
			is_backstab = true
			
	if is_backstab:
		# Moltiplica il danno o rendilo letale (es. 999)
		final_damage *= 2
		# print("BACKSTAB!")
	
	# Passa i dati dell'impatto all'HealthComponent per elaborare il danno e il rinculo
	health_component.take_damage(
		final_damage, 
		hitbox.global_position, 
		hitbox.knockback_strength
	)
