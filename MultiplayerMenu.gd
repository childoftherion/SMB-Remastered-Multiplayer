extends CanvasLayer

@onready var host: Button = $Panel/VBoxContainer/Host
@onready var join: Button = $Panel/VBoxContainer/Join
@onready var port: LineEdit = $Panel/VBoxContainer/Port
@onready var join_ip: LineEdit = $Panel/VBoxContainer/JoinIP
@onready var username: LineEdit = $Panel/VBoxContainer/Username
@onready var status: RichTextLabel = $Panel/VBoxContainer/Status

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func on_host_pressed() -> void:
	Multiplayer.username = username.text
	host.disabled = true
	join.disabled = true
	port.editable = false
	join_ip.editable = false
	username.editable = false
	Multiplayer.host(int(port.text))


func on_join_pressed() -> void:
	Multiplayer.username = username.text
	host.disabled = true
	join.disabled = true
	port.editable = false
	join_ip.editable = false
	username.editable = false
	Multiplayer.join(str(join_ip.text), int(port.text))
