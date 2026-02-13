extends Node2D

signal level_completed 

@onready var game_button: Button = $MainMenuContainer/ButtonsList/GameButton
@onready var level_button: Button = $MainMenuContainer/ButtonsList/LevelButton
@onready var exit_button: Button = $MainMenuContainer/ButtonsList/ExitButton

@onready var ru_button: TextureButton = $MainMenuContainer/TranslationButtonsContainer/RuButton
@onready var en_button: TextureButton = $MainMenuContainer/TranslationButtonsContainer/EnButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ru_button.pressed.connect(_on_russian_pressed)
	en_button.pressed.connect(_on_english_pressed)
	
	game_button.pressed.connect(_on_new_game_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	
	level_completed.connect(get_tree().root.get_node("Main").on_level_completed)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	game_button.text = tr("UI_NEW_GAME")
	level_button.text = tr("UI_LEVEL_SELECT")
	exit_button.text = tr("UI_EXIT")

func _on_russian_pressed():
	TranslationServer.set_locale("ru")

func _on_english_pressed():
	TranslationServer.set_locale("en")

func _on_exit_pressed():
	get_tree().quit()

func _on_new_game_pressed():
	level_completed.emit()
	print(tr("UI_NEW_GAME"))
