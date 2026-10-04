extends Node

var score = 0

@onready var score_label = $ScoreLabel

func _ready():
	GameStats.start_run()
	
func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins. Thats wayyy too many... I would never let a capitalist pig through here."
