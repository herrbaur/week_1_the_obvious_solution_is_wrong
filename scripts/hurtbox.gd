extends Area2D

signal hit

func _ready():
	body_entered.connect(_on_hazard_touched)  # Tile-Spikes
	area_entered.connect(_on_hazard_touched)  # Slime, Spikes, Abgrund


func _on_hazard_touched(_other):
	hit.emit()
