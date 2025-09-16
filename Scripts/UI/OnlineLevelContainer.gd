class_name OnlineLevelContainer
extends Button

var level_name := ""
var level_author := ""
var level_thumbnail = null
var level_id := ""
var thumbnail_url := ""

var difficulty := "Easy"
var featured = false

signal level_selected(container: OnlineLevelContainer)

const DIFFICULTY_TO_STAR_TRANSLATION := {
	"Easy": 0,
	"Medium": 2,
	"Hard": 3,
	"Extreme": 4
}

static var cached_thumbnails := {}

func _ready() -> void:
	set_process(false)
	setup_visuals()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and visible:
		level_selected.emit(self)

func setup_visuals() -> void:
	%LevelName.text = Global.sanitize_string(level_name)
	%LevelAuthor.text = level_author
	if featured:
		self_modulate = Color.YELLOW
	var idx := 0
	print(difficulty)
	var difficulty_int = DIFFICULTY_TO_STAR_TRANSLATION[difficulty]
	for i in %DifficultyStars.get_children():
		i.region_rect.position.x = 24 if idx > difficulty_int else [0, 0, 8, 8, 16][difficulty_int]
		idx += 1
	get_thumbnail()

func get_thumbnail() -> void:
	if cached_thumbnails.has(level_id):
		%LevelIcon.texture = cached_thumbnails[level_id]
		$MarginContainer/HBoxContainer/HSplitContainer/LeftHalf/LevelIcon/Error.hide()
		return
	if thumbnail_url == "":
		$MarginContainer/HBoxContainer/HSplitContainer/LeftHalf/LevelIcon/Label.hide()
		$MarginContainer/HBoxContainer/HSplitContainer/LeftHalf/LevelIcon/Error.show()
		return
	$ThumbnailDownloader.request(thumbnail_url, [], HTTPClient.METHOD_GET)

func on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var image = Image.new()
	if thumbnail_url.contains(".webp"):
		image.load_webp_from_buffer(body)
	elif thumbnail_url.contains(".jpeg") or thumbnail_url.contains(".jpg"):
		image.load_jpg_from_buffer(body)
	else:
		image.load_png_from_buffer(body)
	%LevelIcon.texture = ImageTexture.create_from_image(image)
	cached_thumbnails[level_id] = %LevelIcon.texture
