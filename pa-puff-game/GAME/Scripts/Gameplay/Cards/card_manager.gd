extends Node

var card_list: Array[CardBase] = []

# Set this to your cards folder
@export_dir var cards_folder: String = "res://GAME/Ressources/Game Data/Cards/"

func _ready():
	load_cards()

func load_cards():
	card_list.clear()
	
	var dir = DirAccess.open(cards_folder)
	if dir == null:
		push_error("Cannot open cards folder: " + cards_folder)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if file_name.ends_with(".tres"):
			var file_path = cards_folder.path_join(file_name)
			var card_data = load(file_path)
			if card_data is CardBase:
				card_list.append(card_data)
			else:
				push_warning("Skipped non-CardBase file: " + file_name)
		file_name = dir.get_next()
	
	dir.list_dir_end()
	print("Loaded %d card(s)." % card_list.size())

func get_card() -> CardBase:
	if card_list.is_empty():
		push_warning("Card list is empty.")
		return null
	return card_list[randi() % card_list.size()]
