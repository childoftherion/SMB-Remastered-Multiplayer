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
	host.disabled = Multiplayer.connected
	join.disabled = Multiplayer.connected
	port.editable = !Multiplayer.connected
	join_ip.editable = !Multiplayer.connected
	username.editable = !Multiplayer.connected
	pass


func on_host_pressed() -> void:
	Multiplayer.username = username.text
	Multiplayer.host(int(port.text))


func on_join_pressed() -> void:
	Multiplayer.username = username.text
	Multiplayer.join(str(join_ip.text), int(port.text))
