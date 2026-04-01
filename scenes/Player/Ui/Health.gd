extends ProgressBar

@export var health_component: CmpHealth 

func _ready() -> void:
	if health_component:
		health_component.health_changed.connect(_on_health_changed)
		# set initial values
		max_value = health_component.health_max
		value = health_component.health_current

func _on_health_changed(current: int, _maximum: int) -> void:
	var tween = create_tween()
	tween.tween_property(self, "value", current, 0.2).set_trans(Tween.TRANS_SINE)
