extends Area2D
class_name Hitbox
# ==============================================================================
# SCRIPT: hitbox.gd (Ex SwordHitbox)
# DESCRIZIONE: Componente universale per le aree di collisione offensive.
# Funziona sia per il Player che per i Nemici. Tiene traccia delle entità 
# colpite per evitare danni multipli nello stesso attacco.
# ==============================================================================

# ------------------------------------------------------------------------------
# VARIABILI ESPORTATE (Modificabili dall'editor per ogni entità)
# ------------------------------------------------------------------------------
signal hit_landed(target: Node)
@export var damage: int = 10
@export var knockback_strength: float = 200.0 

# ------------------------------------------------------------------------------
# VARIABILI PUBBLICHE
# ------------------------------------------------------------------------------
# Riferimento all'entità che sta sferrando l'attacco (utile all'Hurtbox per il backstab)
var attacker: Node

# ------------------------------------------------------------------------------
# VARIABILI PRIVATE
# ------------------------------------------------------------------------------
var _hit_this_swing: Array = []


# ==============================================================================
# METODI DI CLASSE (BUILT-IN)
# ==============================================================================

func _ready() -> void:
	# Assume che il genitore (o un nonno) sia l'entità che attacca.
	# Se l'albero è Entità -> Hitbox, get_parent() va benissimo.
	# Se è Entità -> Attacchi -> Hitbox, potresti usare get_parent().get_parent() o owner.
	attacker = get_parent()


# ==============================================================================
# METODI PUBBLICI
# ==============================================================================

## Abilita l'hitbox all'inizio di un colpo e svuota la lista dei bersagli colpiti.
func enable() -> void:
	_hit_this_swing.clear()
	$CollisionShape2D.disabled = false

## Disabilita l'hitbox alla fine di un colpo, terminando i danni.
func disable() -> void:
	$CollisionShape2D.disabled = true

## Verifica se un determinato bersaglio (nodo) è già stato colpito durante questo attacco.
func already_hit(target: Node) -> bool:
	return target in _hit_this_swing

## Registra un bersaglio nella lista di quelli colpiti per ignorarlo ai frame successivi.
func register_hit(target: Node) -> void:
	_hit_this_swing.append(target)
	hit_landed.emit(target)
	
## Calcola il danno finale tenendo conto delle abilità. 
## Ora accetta 'target' per leggere la salute del nemico!
func get_final_damage(target: Node = null) -> int:
	var final_dmg: float = float(damage)
	
	if attacker and "skills" in attacker and attacker.skills:
		
		# ---- LIVELLO 5 ----
		if attacker.skills.has_skill("braccio_di_ferro"):
			final_dmg *= 1.15
			
		# ---- LIVELLO 20: BERSERKER (Danno) ----
		if attacker.skills.has_skill("berserker"):
			var hp = attacker.get_node_or_null("HealthComponent")
			if hp and hp.current_health <= (hp.max_health * 0.40):
				final_dmg *= 2.0
				
		# ---- LIVELLO 20: ESECUTORE ----
		if target and attacker.skills.has_skill("esecutore"):
			var target_hp = target.get_node_or_null("HealthComponent")
			if target_hp and target_hp.current_health <= (target_hp.max_health * 0.30):
				final_dmg *= 2.0
				
	return int(final_dmg)
	
	## Calcola la forza del rinculo finale tenendo conto delle abilità
func get_final_knockback() -> float:
	var final_kb: float = knockback_strength
	
	# Se chi attacca è il Player (o ha il nodo skills)...
	if attacker and "skills" in attacker and attacker.skills:
		# Controlla se ha "Forza Bruta"
		if attacker.skills.has_skill("forza_bruta"):
			final_kb *= 1.8 # Aumenta il knockback dell'80% (modifica a piacere)
			
	return final_kb
