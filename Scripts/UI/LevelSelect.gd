extends Control

var selected_level := 0

signal level_selected
signal cancelled
var active := false

var starting_value := -1

@export var has_speedrun_stuff := false
@export var has_disco_stuff := false

const LEVEL_ICONS := {
	"SMB1": SMB1_ICONS,
	"SMBLL": SMBLL_ICONS,
	"SMBS": SMBS_ICONS,
	"SMBANN": SMB1_ICONS
}

const SMB1_ICONS := [
	"0123",
	"0453",
	"0023",
	"0163",
	"8893",
	"8893",
	"8AB3",
	"8883"
]

const SMBLL_ICONS := [
	"0123",
	"0053",
	"0423",
	"0023",
	"8193",
	"8AB3",
	"8993",
	"88D3",
	"8888",
	"0123",
	"0423",
	"0523",
	"0003"
]

const SMBS_ICONS := [
	"0123",
	"0453",
	"0023",
	"0163",
	"8893",
	"8893",
	"8AB3",
	"CA13"
]

const NUMBER_Y := [
	"Overworld",
	"Underground",
	"Castle",
	"Snow",
	"Space",
	"Volcano"
]

func _ready() -> void:
	for i in %SlotContainer.get_children():
		i.focus_entered.connect(slot_selected.bind(i.get_index()))
	for i in [$Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot1/Icon/RankMedal/SRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot1/Icon/RankMedal/PRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot2/Icon/RankMedal/SRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot2/Icon/RankMedal/PRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot3/Icon/RankMedal/SRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot3/Icon/RankMedal/PRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot4/Icon/RankMedal/SRankParticles, $Panel/MarginContainer/VBoxContainer/HBoxContainer/ScrollContainer/SlotContainer/Slot4/Icon/RankMedal/PRankParticles]:
		start_particle(i)

func start_particle(particle: GPUParticles2D) -> void:
	await get_tree().create_timer(randf_range(0, 5)).timeout
	particle.emitting = true

func _process(_delta: float) -> void:
	if active:
		handle_input()
		Global.level_num = selected_level + 1

func open() -> void:
	if starting_value == -1:
		starting_value = Global.level_num
	print([Global.level_num, starting_value])
	selected_level = Global.level_num - 1
	setup_visuals()
	update_pb()
	show()
	$%SlotContainer.get_child(selected_level).grab_focus()
	await get_tree().create_timer(0.1).timeout
	active = true

const CHARSET := "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

var visited_levels := "0000"

func setup_visuals() -> void:
	%MarathonBits.visible = Global.current_game_mode == Global.GameMode.MARATHON_PRACTICE
	var idx := 0
	for i in %SlotContainer.get_children():
		if i.visible == false:
			continue
		var level_theme = Global.LEVEL_THEMES[Global.current_campaign][Global.world_num - 1]
		visited_levels = (SaveManager.visited_levels.substr((Global.world_num - 1) * 4, 4))
		var level_visited = SaveManager.visited_levels[SaveManager.get_level_idx(Global.world_num, idx + 1)] != "0" or Global.debug_mode
		var num = CHARSET.find(LEVEL_ICONS[Global.current_campaign][Global.world_num - 1][idx])
		if level_visited == false:
			num = 7
		i.get_node("ChallengeModeBits").visible = Global.current_game_mode == Global.GameMode.CHALLENGE
		if Global.current_game_mode == Global.GameMode.CHALLENGE:
			setup_challenge_mode_bits(i.get_node("ChallengeModeBits"), idx + 1)
		i.get_node("Icon").region_rect = Rect2((num % 4) * 56, (num / 4) * 32, 56, 32)
		i.get_node("Icon/Number").region_rect.position.y = clamp(NUMBER_Y.find(level_theme) * 12, 0, 9999)
		i.get_node("Icon/Number").region_rect.position.x = (idx) * 12
		i.get_node("Icon/RankMedal").visible = Global.current_campaign == "SMBANN"
		if Global.current_campaign == "SMBANN":
			i.get_node("Icon/RankMedal").frame = "ZFDCBASP".find(DiscoLevel.level_ranks[SaveManager.get_level_idx(Global.world_num, idx + 1)])
			i.get_node("Icon/RankMedal/SRankParticles").visible = i.get_node("Icon/RankMedal").frame == 6
			i.get_node("Icon/RankMedal/PRankParticles").visible = i.get_node("Icon/RankMedal").frame == 7
		idx += 1

func setup_challenge_mode_bits(container: HBoxContainer, level_num := 1) -> void:
	for i in [container.get_node("1"), container.get_node("2"), container.get_node("3"), container.get_node("4"), container.get_node("5"), container.get_node("6")]:
		var collected = ChallengeModeHandler.is_coin_collected(int(i.name) - 1, ChallengeModeHandler.red_coins_collected[Global.world_num - 1][level_num - 1])
		i.get_node("Full").visible = collected
	container.get_node("Score/Full").visible = ChallengeModeHandler.top_challenge_scores[Global.world_num - 1][level_num - 1] >= ChallengeModeHandler.CHALLENGE_TARGETS[Global.current_campaign][Global.world_num - 1][level_num - 1]

func update_pb() -> void:
	if has_speedrun_stuff == false: return
	var best_warpless_time = SpeedrunHandler.best_level_warpless_times[Global.world_num - 1][selected_level]
	print(SpeedrunHandler.best_level_warpless_times)
	var best_any_time = SpeedrunHandler.best_level_any_times.get(str(Global.world_num) + "-" + str(selected_level + 1), -1)
	%FullRunPB.text = "--:--:--" if best_warpless_time == -1 else SpeedrunHandler.gen_time_string(SpeedrunHandler.format_time(best_warpless_time))
	%WarpRunPB.text = "--:--:--" if best_any_time == -1 else SpeedrunHandler.gen_time_string(SpeedrunHandler.format_time(best_any_time))
	%Flag.visible = selected_level < 3
	%Axe.visible = selected_level >= 3
	$Panel/MarginContainer/VBoxContainer/MarathonBits/VBoxContainer/Warp.modulate = Color.WHITE if SpeedrunHandler.WARP_LEVELS[Global.current_campaign].has(str(Global.world_num) + "-" + str(selected_level + 1)) else Color(0.25, 0.25, 0.25)
	var gold_warpless_time = SpeedrunHandler.LEVEL_GOLD_WARPLESS_TIMES[Global.current_campaign][Global.world_num - 1][selected_level]
	var gold_any_time := -1.0
	if SpeedrunHandler.LEVEL_GOLD_ANY_TIMES[Global.current_campaign].has(str(Global.world_num) + "-" + str(selected_level + 1)):
		gold_any_time = SpeedrunHandler.LEVEL_GOLD_ANY_TIMES[Global.current_campaign][str(Global.world_num) + "-" + str(selected_level + 1)]
	for i in %FullRunMedals.get_children():
		var target_time = gold_warpless_time * SpeedrunHandler.MEDAL_CONVERSIONS[i.get_index()]
		i.get_node("Full").visible = best_warpless_time <= target_time and best_warpless_time > 0
	if gold_any_time != -1:
		for i in %WarpRunMedals.get_children():
			var target_time = gold_any_time * SpeedrunHandler.MEDAL_CONVERSIONS[i.get_index()]
			i.get_node("Full").visible = best_any_time <= target_time and best_any_time > 0
	else:
		for i in %WarpRunMedals.get_children():
			i.get_node("Full").hide()

func handle_input() -> void:
	selected_level = clamp(selected_level, 0, 3)
	if Input.is_action_just_pressed("ui_accept"):
		if visited_levels[selected_level] == "0" and selected_level != 0 and not Global.debug_mode:
			AudioManager.play_sfx("bump")
		else:
			select_world()
	elif Input.is_action_just_pressed("ui_back"):
		close()
		cleanup()
		cancelled.emit()
		return

func select_world() -> void:
	if owner is Level:
		owner.level_id = selected_level + 1
	Global.level_num = selected_level + 1
	level_selected.emit()
	close()

func slot_selected(idx := 0) -> void:
	selected_level = idx
	update_pb()

func cleanup() -> void:
	await get_tree().process_frame
	Global.level_num = starting_value
	starting_value = -1
	Global.level_num = clamp(Global.level_num, 1, 4)
	if owner is Level:
		owner.level_id = clamp(owner.level_id, 1, 8)

func close() -> void:
	active = false
	hide()
