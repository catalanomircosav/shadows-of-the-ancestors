extends Node
class_name SkillsComponent

signal strength_leveled_up(new_level: int)
signal stealth_leveled_up(new_level: int)
signal strength_xp_changed(current_xp: float, required_xp: float)
signal stealth_xp_changed(current_xp: float, required_xp: float)
signal strength_skill_point_earned(level: int)
signal stealth_skill_point_earned(level: int)

# ==========================================
# DIZIONARIO ABILITA' SBLOCCATE
# ==========================================
var unlocked_skills: Dictionary = {
	# --- FORZA ---
	"braccio_di_ferro": false,
	"pelle_dura": false,
	"forza_bruta": false,
	"sete_di_sangue": false,
	"raggio_esteso": false,
	"raffica": false,
	"esecutore": false,
	"berserker": false,
	
	# --- STEALTH ---
	"passo_felpato": false,
	"mimetizzazione": false,
	"punti_vitali": false,
	"via_di_fuga": false,
	"passo_silenzioso": false,
	"aggiramento_tattico": false,
	"fantasma": false,
	"sesto_senso": false
}

@export_category("Strength")
@export var strength_level: int = 1
@export var strength_xp: float = 0.0
@export var strength_xp_required: float = 100.0

@export_category("Stealth")
@export var stealth_level: int = 4
@export var stealth_xp: float = 0.0
@export var stealth_xp_required: float = 100.0

# Modificatore per aumentare la difficoltà di livellamento a ogni livello
@export var xp_curve_multiplier: float = 1.5 

func gain_strength_xp(amount: float) -> void:
	strength_xp += amount
	
	if strength_xp >= strength_xp_required:
		strength_level += 1
		strength_xp -= strength_xp_required
		strength_xp_required *= xp_curve_multiplier
		strength_leveled_up.emit(strength_level)
		
		# --- NUOVO: Controllo Bivio Abilità ---
		if strength_level in [5, 10, 15, 20]:
			strength_skill_point_earned.emit(strength_level)
		# --------------------------------------
		
	strength_xp_changed.emit(strength_xp, strength_xp_required)


func gain_stealth_xp(amount: float) -> void:
	stealth_xp += amount
	
	if stealth_xp >= stealth_xp_required:
		stealth_level += 1
		stealth_xp -= stealth_xp_required
		stealth_xp_required *= xp_curve_multiplier
		stealth_leveled_up.emit(stealth_level)
		
		# --- NUOVO: Controllo Bivio Abilità ---
		if stealth_level in [5, 10, 15, 20]:
			stealth_skill_point_earned.emit(stealth_level)
		# --------------------------------------
		
	stealth_xp_changed.emit(stealth_xp, stealth_xp_required)
	
# ==========================================
# GESTIONE ABILITA'
# ==========================================

## Sblocca un'abilità specifica cambiandone il valore a true
func unlock_skill(skill_name: String) -> void:
	if unlocked_skills.has(skill_name):
		unlocked_skills[skill_name] = true
		print("[SKILL SBLOCCATA] Hai appreso: ", skill_name.to_upper())
	else:
		push_error("Tentativo di sbloccare un'abilità inesistente: " + skill_name)

## Restituisce true se l'abilità richiesta è attiva, altrimenti false
func has_skill(skill_name: String) -> bool:
	return unlocked_skills.get(skill_name, false)
