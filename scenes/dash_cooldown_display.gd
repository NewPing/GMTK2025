extends Control

@onready var dash_label: Label = $ProgressBar/Label
@onready var progress_bar: ProgressBar = $ProgressBar

func _ready() -> void:
	progress_bar.max_value = 1.0 # Progress in range [0, 1]
	progress_bar.value = 0.0
	progress_bar.custom_minimum_size.x = 100 # Set a fixed width
	progress_bar.custom_minimum_size.y = 10 # Set a fixed height

# Call this to update the UI
# progress: 0.0 (empty) to 1.0 (full/ready)
func update_progress(progress: float) -> void:
	progress_bar.value = progress
