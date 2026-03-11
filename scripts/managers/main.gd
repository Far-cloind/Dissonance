extends Node2D

# 主场景管理器 - 根据乐器风格创建对应的节奏管理器

var rhythm_manager: Node = null
var instrument_style: InstrumentStyleBase = null
var bgm_player: BGMPlayer = null

func _ready():
	print("主场景初始化...")
	
	# 获取选择的乐器风格
	var style_type = GlobalGameData.selected_style
	instrument_style = StyleFactory.create_style(style_type)
	
	print("选择的风格:", instrument_style.style_name)
	print("风格描述:", instrument_style.get_description())
	
	# 创建 BGM 播放器
	create_bgm_player()
	
	# 创建对应风格的节奏管理器
	create_rhythm_manager()

func create_bgm_player():
	print("🎵 创建 BGM 播放器...")
	
	bgm_player = BGMPlayer.new()
	bgm_player.name = "BGMPlayer"
	add_child(bgm_player)
	
	# 根据风格播放测试 BGM
	match GlobalGameData.selected_style:
		GlobalGameData.STYLE_STRING:
			bgm_player.play_test_bgm("strings")
		GlobalGameData.STYLE_ROCK:
			bgm_player.play_test_bgm("drums")
		GlobalGameData.STYLE_ELECTRONIC:
			bgm_player.play_test_bgm("house")
		_:
			bgm_player.play_test_bgm("piano")
	
	print("✅ BGM 播放器创建完成")

func create_rhythm_manager():
	# 获取风格对应的节奏管理器脚本路径
	var script_path = instrument_style.get_rhythm_manager_script()
	
	print("创建节奏管理器:", script_path)
	
	# 加载脚本
	var rhythm_script = load(script_path)
	if rhythm_script == null:
		push_error("无法加载节奏管理器脚本: " + script_path)
		return
	
	# 创建节奏管理器节点
	rhythm_manager = Node.new()
	rhythm_manager.name = "RhythmManager"
	rhythm_manager.script = rhythm_script
	
	# 添加音频合成器节点
	add_audio_synths(rhythm_manager)
	
	# 添加到场景
	add_child(rhythm_manager)
	
	print("节奏管理器创建完成")

func add_audio_synths(parent: Node):
	# 根据风格添加不同的音频合成器
	match GlobalGameData.selected_style:
		GlobalGameData.STYLE_ROCK:
			add_rock_synths(parent)
		GlobalGameData.STYLE_STRING:
			add_string_synths(parent)
		GlobalGameData.STYLE_ELECTRONIC:
			add_electronic_synths(parent)
		_:
			add_rock_synths(parent)

func add_rock_synths(parent: Node):
	# 摇滚风格：底鼓 + 军鼓
	var kick_synth = AudioStreamPlayer.new()
	kick_synth.name = "KickSynth"
	kick_synth.script = load("res://scripts/audio/kick_synth.gd")
	parent.add_child(kick_synth)
	
	var snare_synth = AudioStreamPlayer.new()
	snare_synth.name = "SnareSynth"
	snare_synth.script = load("res://scripts/audio/snare_synth.gd")
	parent.add_child(snare_synth)
	
	print("🥁 摇滚音频合成器已添加")

func add_string_synths(parent: Node):
	# 弦乐风格：使用新的 SoundFont 播放器
	var string_soundfont = Node.new()
	string_soundfont.name = "StringSoundFont"
	string_soundfont.script = load("res://scripts/audio/string_soundfont.gd")
	parent.add_child(string_soundfont)
	
	print("🎻 弦乐 SoundFont 播放器已添加")

func add_electronic_synths(parent: Node):
	# 电子风格：底鼓 + 军鼓（可以后续替换为电子合成器）
	var kick_synth = AudioStreamPlayer.new()
	kick_synth.name = "KickSynth"
	kick_synth.script = load("res://scripts/audio/kick_synth.gd")
	parent.add_child(kick_synth)
	
	var snare_synth = AudioStreamPlayer.new()
	snare_synth.name = "SnareSynth"
	snare_synth.script = load("res://scripts/audio/snare_synth.gd")
	parent.add_child(snare_synth)
	
	print("🎹 电子音频合成器已添加")
