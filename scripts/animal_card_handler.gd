extends CardHandler
class_name AnimalCardHandler

@export_group("Internal Nodes")
@export var button: TextureButton

func _ready() -> void:
    disable_click()

func enable_click() -> void:
    if button:
        button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
        button.disabled = false

func disable_click() -> void:
    if button:
        button.mouse_default_cursor_shape = Control.CURSOR_ARROW
        button.disabled = true