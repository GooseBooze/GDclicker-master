extends TextureRect
func _ready():
	var texture_rect = $Background
	texture_rect.rect_min_size = get_viewport().size
