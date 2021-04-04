extends Node2D 

var flockScene = preload("res://Scenes/Flock.tscn") # Will load when parsing the script.

var separation = 1.5;
var cohesion = 1.3;
var alignment = 0.8
var showAlignment = true

# Called when the node enters the scene tree for the first time.
func _ready():
	$GuiControls.get_node("VBoxContainer").get_node("SeparationSlider").value = separation
	$GuiControls.get_node("VBoxContainer").get_node("CohesionSlider").value = cohesion
	$GuiControls.get_node("VBoxContainer").get_node("AlignmentSlider").value = alignment

	$GuiControls.get_node("VBoxContainer").get_node("HBoxContainer").get_node("DisplayVelocityCheckbox").pressed = alignment

	updateLabels()

	randomize() 
	for i in range(100):
		var flock = flockScene.instance()
		#flock.scale(0.5, 0.5)
		add_child(flock)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	separation = $GuiControls.get_node("VBoxContainer").get_node("SeparationSlider").value
	cohesion = $GuiControls.get_node("VBoxContainer").get_node("CohesionSlider").value
	alignment = $GuiControls.get_node("VBoxContainer").get_node("AlignmentSlider").value

	showAlignment = $GuiControls.get_node("VBoxContainer").get_node("HBoxContainer").get_node("DisplayVelocityCheckbox").pressed

	updateLabels()

func updateLabels():
	$GuiControls.get_node("VBoxContainer").get_node("SeparationLabel").text = "Seaparation: " + String(separation)
	$GuiControls.get_node("VBoxContainer").get_node("CohesionLabel").text = "Cohesion: " + String(cohesion)
	$GuiControls.get_node("VBoxContainer").get_node("AlignmentLabel").text = "Alignment: " + String(alignment)
