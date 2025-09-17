extends Node2D
@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var username: Label = $Username
@export var resource_setter: ResourceSetterNew
static var idx := 0
@export var player_id := 0
@export var force_power_state := ""
@export var force_character := ""
var character := ""
var recording := []

var current_power_state := ""

func _ready() -> void:
	Global.player_characters_changed.connect(update)
	Global.level_theme_changed.connect(update)
	
func update() -> void:
	character = Player.CHARACTERS[int(Global.player_characters[player_id])]
	var power_state = Global.player_power_states[player_id]
	if force_power_state != "":
		power_state = force_power_state
	if force_character != "":
		character = force_character
	if resource_setter != null:
		var path = "res://Assets/Sprites/Players/" + character + "/" + Player.POWER_STATES[int(power_state)] + ".json"
		if Player.CHARACTERS.find(character) > 3:
			path = path.replace("res://Assets/Sprites/Players/", "user://custom_characters/")
		var json = resource_setter.get_resource(load(path))
		sprite.sprite_frames = json
		if sprite.sprite_frames == null: 
			return
		if sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame):
			sprite.offset.y = -(sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_height() / 2.0)
			
func delete() -> void:
	idx = 0

func apply_data(data) -> void:
	username.text = data["username"]
	global_position.x = int(data["position"]["x"])
	global_position.y = int(data["position"]["y"])
	sprite.animation = str(data["animation"])
	sprite.frame = int(data["frame"])
	sprite.scale.x = int(data["scale_x"])
	if resource_setter != null:
		var path = "res://Assets/Sprites/Players/" + data["character"] + "/" + Player.POWER_STATES[int(data["power_state"])] + ".json"
		var json = resource_setter.get_resource(load(path))
		sprite.sprite_frames = json
		if sprite.sprite_frames == null: 
			return
		if sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame):
			sprite.offset.y = -(sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame).get_height() / 2.0)
