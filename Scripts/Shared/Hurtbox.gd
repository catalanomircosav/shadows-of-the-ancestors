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
	var final_damage: int = hitbox.get_final_damage(owner_node) 
	var is_backstab: bool = false
	var attacking_entity: Node = hitbox.attacker
	
	# 6. Logica del Backstab: si attiva se un nemico viene colpito dal player
	if owner_node is EnemyBase and attacking_entity is Player:
		# Se guardano nella stessa direzione, è un colpo alle spalle!
		if owner_node.last_facing == attacking_entity.last_facing:
			is_backstab = true
			
	if is_backstab:
		# Moltiplicatore base del Backstab (es. danno doppio senza abilità)
		var backstab_multiplier: float = 2.0
		
		# ---- LOGICA LIVELLO 10 STEALTH: PUNTI VITALI ----
		# Controlliamo se chi attacca è il Player e se ha l'abilità
		if attacking_entity is Player and attacking_entity.skills and attacking_entity.skills.has_skill("punti_vitali"):
			backstab_multiplier = 4.0 # Danno quadruplicato!
			print("[STEALTH] 🎯 Punti Vitali! Danno critico x4!")
		# -------------------------------------------------
		# ---- NUOVO: LOGICA LIVELLO 15 STEALTH: LAMA RIGENERATRICE ----
		if attacking_entity is Player and attacking_entity.skills.has_skill("lama_rigeneratrice"):
			if attacking_entity.health:
				var heal_amount = 10
				attacking_entity.health.heal(heal_amount)
				print("[STEALTH] 🩸 Lama Rigeneratrice! +", heal_amount, " HP")
		# -------------------------------------------------------------
		# ---- NUOVO: LOGICA LIVELLO 20 STEALTH: FANTASMA ----
		if attacking_entity is Player and attacking_entity.has_method("activate_ghost_mode"):
			attacking_entity.activate_ghost_mode()
		# ----------------------------------------------------
		
		final_damage = int(final_damage * backstab_multiplier)
		
	# ---- NUOVO: LOGICA "PELLE DURA" (DIFESA) ----
	# Controlliamo se chi sta subendo il colpo (owner_node) ha le abilità
	if "skills" in owner_node and owner_node.skills:
		if owner_node.skills.has_skill("pelle_dura"):
			final_damage -= 5
			# Evitiamo che i danni diventino negativi finendo per curare l'entità
			if final_damage < 0:
				final_damage = 0
	# ---------------------------------------------
	
	# ---- NUOVO: LOG DI DEBUG DEL COMBATTIMENTO ----
	var attacker_name = attacking_entity.name if attacking_entity else "Sconosciuto"
	var defender_name = owner_node.name
	
	if is_backstab:
		print("[COMBAT] 🗡️ BACKSTAB! " + attacker_name + " infligge " + str(final_damage) + " danni a " + defender_name)
	else:
		print("[COMBAT] ⚔️ " + attacker_name + " infligge " + str(final_damage) + " danni a " + defender_name)
	# -----------------------------------------------
	
	# 7. Passa i dati all'HealthComponent per elaborare danno e rinculo
	health_component.take_damage(
		final_damage, 
		hitbox.global_position, 
		hitbox.get_final_knockback()
	)
