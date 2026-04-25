extends Node

var _torches: Array[Node] = []
var _player: Player = null
var _visibility: float = 0.0

func register_player(player: Node) -> void:
	_player = player

func register_torch(torch: Node) -> void:
	if not _torches.has(torch):
		_torches.append(torch)

func unregister_torch(torch: Node) -> void:
	_torches.erase(torch)

func get_visibility() -> float:
	return _visibility
	
func _process(_delta: float) -> void:
	if _player == null or _torches.is_empty():
		return
	
	var total_visibility: float = 0.0
	
	for torch in _torches:
		if not is_instance_valid(torch):
			continue
		if not torch.is_lit:
			continue
		
		var radius: float = torch.light.texture_scale * 64.0 / 2.0
		var distance: float = _player.global_position.distance_to(torch.global_position)
		var contribution: float = clamp(1.0 - (distance / radius), 0.0, 1.0)
		contribution *= torch.current_base_energy
		total_visibility += contribution
	
	total_visibility *= _player.light_multiplier
	total_visibility = clamp(total_visibility, 0.0, 1.0)
	_visibility = total_visibility
	# print("Visibilità player: %.2f" % total_visibility)
