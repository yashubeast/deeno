extends Node
class_name CmpAds

@export var ads_fov: float = 50.0
@export var default_fov: float = 75.0
@export var ads_speed: float = 10.0
@export var camera: Camera3D

var is_ads := false

func process(delta: float) -> void:
	var target_fov = ads_fov if is_ads else default_fov
	camera.fov = lerp(camera.fov, target_fov, delta * ads_speed)

func enter() -> void:
	is_ads = true

func exit() -> void:
	is_ads = false
