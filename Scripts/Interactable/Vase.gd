extends StaticBody2D

@export var break_impulse: float = 250.0
@export var break_decay: float = 1.5

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Area2D = $Hurtbox

var is_broken: bool = false

func _ready() -> void:
	print("Vaso pronto — hurtbox monitoring: ", hurtbox.monitoring, " monitorable: ", hurtbox.monitorable)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
func _on_hurtbox_area_entered(area: Area2D) -> void:
	print("Vaso colpito da: ", area.name, " | è Hitbox: ", area is Hitbox)
	
	if is_broken:
		return
		
	if area is Hitbox:
		break_vase()

func break_vase() -> void:
	is_broken = true
	hurtbox.set_deferred("monitoring", false)
	hurtbox.set_deferred("monitorable", false)
	$CollisionShape2D.set_deferred("disabled", true)
	NoiseManager.emit_noise(global_position, break_impulse, break_decay)
	anim_sprite.play("break")
