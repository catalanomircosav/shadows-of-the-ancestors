extends Node
class_name SkillsComponent

signal strength_leveled_up(new_level: int)
signal stealth_leveled_up(new_level: int)

@export_category("Strength")
@export var strength_level: int = 1
@export var strength_xp: float = 0.0
@export var strength_xp_required: float = 100.0

@export_category("Stealth")
@export var stealth_level: int = 1
@export var stealth_xp: float = 0.0
@export var stealth_xp_required: float = 100.0

# Modificatore per aumentare la difficoltà di livellamento a ogni livello
@export var xp_curve_multiplier: float = 1.5 

## Aggiunge XP alla Forza. Se supera la soglia, sale di livello.
func gain_strength_xp(amount: float) -> void:
	strength_xp += amount
	print("[STATS-FORZA] XP guadagnati: +", amount, " | Totale: ", strength_xp, "/", strength_xp_required)
	
	if strength_xp >= strength_xp_required:
		strength_level += 1
		strength_xp -= strength_xp_required
		strength_xp_required *= xp_curve_multiplier
		strength_leveled_up.emit(strength_level)
		print("[LEVEL-UP] FORZA salita al livello: ", strength_level, " (Prossimo livello a: ", strength_xp_required, ")")

## Aggiunge XP allo Stealth. Se supera la soglia, sale di livello.
func gain_stealth_xp(amount: float) -> void:
	stealth_xp += amount
	print("[STATS-STEALTH] XP guadagnati: +", amount, " | Totale: ", stealth_xp, "/", stealth_xp_required)
	
	if stealth_xp >= stealth_xp_required:
		stealth_level += 1
		stealth_xp -= stealth_xp_required
		stealth_xp_required *= xp_curve_multiplier
		stealth_leveled_up.emit(stealth_level)
		print("[LEVEL-UP] STEALTH salito al livello: ", stealth_level, " (Prossimo livello a: ", stealth_xp_required, ")")
