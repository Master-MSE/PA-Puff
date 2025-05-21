extends LineEdit

func _ready():
	text = ""
	max_length = 15  # 255.255.255.255
	caret_column = text.length()
	set_placeholder("IP (ex: 192.168.0.1)")

func _on_text_changed(new_text: String) -> void:
	var raw_digits = ""
	for c in new_text:
		if c.is_valid_int():
			raw_digits += c

	var ip = ""
	for i in range(raw_digits.length()):
		ip += raw_digits[i]
		if (i == 2 or i == 5 or i == 8) and i < raw_digits.length() - 1:
			ip += "."

	# Bloque le signal temporairement pour éviter la boucle infinie
	disconnect("text_changed", Callable(self, "_on_text_changed"))
	text = ip
	caret_column = text.length()
	connect("text_changed", Callable(self, "_on_text_changed"))
