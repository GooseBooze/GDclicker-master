extends Node2D

# ==== Save Feature ====
const SAVE_FILE_PATH := "user://savegame.json"
const AUTO_SAVE_INTERVAL := 10.0  # Seconds between each auto-save
var pointer_scene = preload("res://scenes/Pointer.tscn")

# ==== Additional Variables ====


# ==== Cookie Stats ====
var cookies: float = 0.0
var cookies_per_second: float = 0.0
var accumulated_cookies: float = 0.0

# ==== Base Costs ====
const BASE_POINTER_UPGRADE_COST = 15
const BASE_GRANDMA_COST = 100
const BASE_FARM_COST = 1100
const BASE_MINE_COST = 12000
const BASE_FACTORY_COST = 130000
const BASE_BANK_COST = 1400000

# ==== Upgrade Counters ====
var grandma_count: int = 0
var farm_count: int = 0
var mine_count: int = 0
var factory_count: int = 0
var bank_count: int = 0
var pointer_count: int = 0

# ==== Scene and UI References ====
@onready var cookie_label = $UI/HBoxContainer/CenterContainer/CookieCounterBG/CounterLabel
@onready var cookie_button = $UI/HBoxContainer/CenterContainer/CookieButton
@onready var timer = $Timer
@onready var upgrade_button = $UI/HBoxContainer/Panel/ScrollContainer/VBoxContainer/UpgradeButton
@onready var pointer_holder = $UI/HBoxContainer/CenterContainer/PointerHolder
@onready var grandma_button = $UI/HBoxContainer/Panel/ScrollContainer/VBoxContainer/GrandmaButton
@onready var farm_button = $UI/HBoxContainer/Panel/ScrollContainer/VBoxContainer/FarmButton
@onready var mine_button = $UI/HBoxContainer/Panel/ScrollContainer/VBoxContainer/MineButton
@onready var factory_button = $UI/HBoxContainer/Panel/ScrollContainer/VBoxContainer/FactoryButton
@onready var bank_button = $UI/HBoxContainer/Panel/ScrollContainer/VBoxContainer/BankButton
@onready var auto_save_timer = $AutoSaveTimer
@onready var music_controller = $Music

#Pointersignal
signal PointerSignal

# Save Game Progress
func auto_save():
	var save_data = {
		"cookies": cookies,
		"pointer_count": pointer_count,
		"grandma_count": grandma_count,
		"farm_count": farm_count,
		"mine_count": mine_count,
		"factory_count": factory_count,
		"bank_count": bank_count
	}
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))
	file.close()

func clear_pointers():
	for child in pointer_holder.get_children():
		child.queue_free()

# Load Game Progress
func load_game():
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if !file:
		return
	
	var data = JSON.parse_string(file.get_as_text())
	if typeof(data) == TYPE_DICTIONARY:
		cookies = data.get("cookies", 0.0)
		pointer_count = data.get("pointer_count", 0)
		grandma_count = data.get("grandma_count", 0)
		farm_count = data.get("farm_count", 0)
		mine_count = data.get("mine_count", 0)
		factory_count = data.get("factory_count", 0)
		bank_count = data.get("bank_count", 0)
		
		# Recalculate cookies per second
		cookies_per_second = calculate_cps()
		
		# Respawn the pointers based on the saved pointer count
		await PointerSignal
		for i in range(pointer_count):
			spawn_pointer(i + 1)  # Spawn each pointer with a delay
	
	update_label()



func _on_wipe_save_button_pressed():
	# Delete saved file
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_data = {
			"cookies": 0,
			"pointer_count": 0,
			"grandma_count": 0,
			"farm_count": 0,
			"mine_count": 0,
			"factory_count": 0,
			"bank_count": 0
		}
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("Save data wiped.")
	else:
		print("No save file to wipe.")
	
	# Optionally reload the scene to reset state
	get_tree().reload_current_scene()

# Calculate cookies per second based on owned buildings
func calculate_cps() -> float:
	return (grandma_count * 1.0) + (farm_count * 8.0) + (mine_count * 50.0) + (factory_count * 100.0) + (bank_count * 200.0) + (pointer_count * 0.1)

func _ready():
	load_game()
	timer.timeout.connect(on_timer_timeout)
	auto_save_timer.wait_time = AUTO_SAVE_INTERVAL
	auto_save_timer.timeout.connect(auto_save)
	auto_save_timer.start()
	
	# Load the Music scene and add it as a child
	var music_scene = preload("res://scenes/Music.tscn")
	music_controller = music_scene.instantiate()
	add_child(music_controller)

	# Start the music
	music_controller.play_random_track()
	
	if cookies_per_second > 0:
		timer.start()

	update_label()
	update_upgrade_button_text()
	update_grandma_button_text()
	update_farm_button_text()
	update_mine_button_text()
	update_factory_button_text()
	update_bank_button_text()

func _process(delta):
	if cookie_button.global_position != Vector2.ZERO:
		PointerSignal.emit()
	accumulated_cookies += cookies_per_second * delta
	if accumulated_cookies >= 1.0:
		cookies += int(accumulated_cookies)
		accumulated_cookies -= int(accumulated_cookies)
	update_label()



# ===== Click Handlers =====
func on_cookie_clicked():
	cookies += 1
	update_label()

func on_upgrade_clicked():
	var cost = get_pointer_upgrade_cost()
	if cookies >= cost:
		cookies -= cost
		pointer_count += 1
		cookies_per_second += 0.1
		spawn_pointer(pointer_count)
		update_upgrade_button_text()
		update_label()

func on_grandma_clicked():
	var cost = get_grandma_cost()
	if cookies >= cost:
		cookies -= cost
		grandma_count += 1
		cookies_per_second += 1
		if timer.is_stopped():
			timer.start()
		update_grandma_button_text()
		update_label()

func on_farm_clicked():
	var cost = get_farm_cost()
	if cookies >= cost:
		cookies -= cost
		farm_count += 1
		cookies_per_second += 8
		if timer.is_stopped():
			timer.start()
		update_farm_button_text()
		update_label()

func on_mine_clicked():
	var cost = get_mine_cost()
	if cookies >= cost:
		cookies -= cost
		mine_count += 1
		cookies_per_second += 47
		if timer.is_stopped():
			timer.start()
		update_mine_button_text()
		update_label()

func on_factory_clicked():
	var cost = get_factory_cost()
	if cookies >= cost:
		cookies -= cost
		factory_count += 1
		cookies_per_second += 260
		if timer.is_stopped():
			timer.start()
		update_factory_button_text()
		update_label()

func on_bank_clicked():
	var cost = get_bank_cost()
	if cookies >= cost:
		cookies -= cost
		bank_count += 1
		cookies_per_second += 1400
		if timer.is_stopped():
			timer.start()
		update_bank_button_text()
		update_label()

# Calculate dynamic cost based on how many of the item you own

# Pointer upgrade cost scales with the number of upgrades you already have
func get_pointer_upgrade_cost() -> int:
	if pointer_count < 1:
		return int(BASE_POINTER_UPGRADE_COST)
	else:
		return int(BASE_POINTER_UPGRADE_COST * 1.15 ** pointer_count)

func get_grandma_cost() -> int:
	return int(BASE_GRANDMA_COST * 1.15 ** grandma_count)

func get_farm_cost() -> int:
	return int(BASE_FARM_COST * 1.15 ** farm_count)

func get_mine_cost() -> int:
	return int(BASE_MINE_COST * 1.15 ** mine_count)

func get_factory_cost() -> int:
	return int(BASE_FACTORY_COST * 1.15 ** factory_count)

func get_bank_cost() -> int:
	return int(BASE_BANK_COST * 1.15 ** bank_count)

# ===== UI Update Methods =====

func update_label():
	cookie_label.text = "Cookies: %d\nCPS: %.1f" % [cookies, cookies_per_second]

func update_upgrade_button_text():
	upgrade_button.text = "Upgrade Pointer (+0.1 CPS)\nCost: %d cookies" % get_pointer_upgrade_cost()

func update_grandma_button_text():
	grandma_button.text = "Hire Grandma (+1 CPS)\nCost: %d cookies" % get_grandma_cost()

func update_farm_button_text():
	farm_button.text = "Buy Farm (+8 CPS)\nCost: %d cookies" % get_farm_cost()

func update_mine_button_text():
	mine_button.text = "Buy Mine (+47 CPS)\nCost: %d cookies" % get_mine_cost()

func update_factory_button_text():
	factory_button.text = "Buy Factory (+260 CPS)\nCost: %d cookies" % get_factory_cost()

func update_bank_button_text():
	bank_button.text = "Buy Bank (+1400 CPS)\nCost: %d cookies" % get_bank_cost()

func on_timer_timeout():
	pass

# ===== Visual Pointer Spawn System =====

# Spawn Pointers with a Delay
func spawn_pointer(index: int):
	# Only spawn if index > 0
	if index == 0:
		return
	
	# Create a pointer instance from the preloaded scene
	var pointer = pointer_scene.instantiate()
	pointer.index = index
	
	# Set up pointer position in a circle
	var base_radius = 100
	var radius_step = 15
	var base_slots = 50
	var total = 0
	var ring = 0
	var ring_slots = base_slots
	
	# Calculate ring and slot positioning
	while index > total + ring_slots:
		total += ring_slots
		ring += 1
		ring_slots = base_slots + ring * 10
	
	var position_in_ring = index - total
	var angle = -TAU * float(position_in_ring) / float(ring_slots)
	angle -= deg_to_rad(90)
	
	var radius = base_radius + ring * radius_step
	var cookie_center = cookie_button.global_position + Vector2(128, 128)  # or cookie_button.position + cookie_button.rect_size / 2
	
	pointer.original_position = cookie_center + Vector2(cos(angle) * radius, sin(angle) * radius)
	
	pointer.rotation = angle - deg_to_rad(90)
	
	pointer_holder.add_child(pointer)


func _on_mute_button_toggled(button_pressed: bool) -> void:
	music_controller.mute_music(!button_pressed)
