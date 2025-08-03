extends Control

@export var optionsField: Label

var musicPlayer : AudioStreamPlayer2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	musicPlayer = $musicPlayer
	musicPlayer.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Map.tscn")

func _on_options_pressed() -> void:
	optionsField.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()
