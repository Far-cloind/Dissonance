extends Node

# BGM 播放器 - 使用 MidiPlayer 播放背景音乐

class_name BGMPlayer

# MidiPlayer 实例
var midi_player: MidiPlayer

# SoundFont 路径
@export var soundfont_path: String = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/DSoundfont Ultimate.sf2"

# 当前播放的 MIDI 文件
var current_midi: String = ""

# 是否循环播放
@export var loop: bool = true

# 是否使用延迟加载
@export var lazy_load: bool = true

func _ready():
	print("🎵 BGM 播放器初始化...")
	
	# 创建 MidiPlayer
	midi_player = MidiPlayer.new()
	midi_player.name = "MidiPlayer"
	add_child(midi_player)
	
	# 连接播放完成信号
	midi_player.finished.connect(_on_midi_finished)
	
	# 延迟加载 SoundFont，避免阻塞主线程
	if lazy_load:
		call_deferred("load_soundfont_deferred")
	else:
		load_soundfont()

func load_soundfont_deferred():
	# 等待一帧后再加载
	await get_tree().process_frame
	load_soundfont()

func load_soundfont():
	print("📂 正在加载 SoundFont...")
	
	if not FileAccess.file_exists(soundfont_path):
		push_error("❌ SoundFont 文件不存在: " + soundfont_path)
		return
	
	# 获取文件大小
	var file = FileAccess.open(soundfont_path, FileAccess.READ)
	if file:
		var file_size = file.get_length()
		file.close()
		
		print("📊 SoundFont 文件大小:", file_size / (1024*1024*1024), " GB")
		
		# 对于超大文件(>2GB)，必须使用按需加载模式
		if file_size > 2 * 1024 * 1024 * 1024:  # 2GB
			print("⚠️ SoundFont 文件非常大，强制使用按需加载模式")
			midi_player.load_all_voices_from_soundfont = false
			# 设置最大复音数，避免内存溢出
			midi_player.max_polyphony = 64
		elif file_size > 1024 * 1024 * 1024:  # 1GB
			print("⚠️ SoundFont 文件很大，使用按需加载模式")
			midi_player.load_all_voices_from_soundfont = false
			midi_player.max_polyphony = 96
		else:
			midi_player.load_all_voices_from_soundfont = true
			midi_player.max_polyphony = 128
			print("✅ SoundFont 大小正常，完全加载模式")
	
	# 设置 SoundFont - 使用 try/catch 处理可能的错误
	print("⏳ 正在设置 SoundFont 路径...")
	midi_player.soundfont = soundfont_path
	
	# 等待 SoundFont 加载完成
	await get_tree().create_timer(0.1).timeout
	
	if midi_player.bank != null:
		print("✅ SoundFont 已加载:", soundfont_path)
	else:
		print("⚠️ SoundFont 加载中，可能需要更长时间...")

# 播放 MIDI 文件
func play_midi(midi_path: String):
	if not FileAccess.file_exists(midi_path):
		push_error("❌ MIDI 文件不存在: " + midi_path)
		return
	
	# 确保 SoundFont 已加载
	if midi_player.bank == null:
		print("⏳ 等待 SoundFont 加载...")
		await get_tree().create_timer(0.5).timeout
		if midi_player.bank == null:
			push_error("❌ SoundFont 未加载，无法播放 MIDI")
			return
	
	current_midi = midi_path
	print("🎼 播放 MIDI:", midi_path)
	
	# 加载并播放
	midi_player.stop()
	midi_player.smf = SMF.new()
	var result = midi_player.smf.read_file(midi_path)
	
	if result.error == OK:
		midi_player.play()
		print("✅ MIDI 播放开始")
	else:
		push_error("❌ MIDI 加载失败: " + str(result.error))

# 停止播放
func stop():
	midi_player.stop()
	print("⏹️ BGM 停止")

# 暂停/继续
func pause():
	midi_player.pause()
	print("⏸️ BGM 暂停")

func resume():
	midi_player.play()
	print("▶️ BGM 继续")

# 设置音量 (0.0 - 1.0)
func set_volume(volume: float):
	midi_player.volume_db = linear_to_db(clamp(volume, 0.0, 1.0))

# 播放完成回调
func _on_midi_finished():
	print("🎵 MIDI 播放完成")
	if loop and current_midi != "":
		print("🔄 循环播放")
		play_midi(current_midi)

# 测试播放不同风格的音乐
func play_test_bgm(style: String):
	var midi_path = ""
	
	match style:
		"strings":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/07Strngs.mid"
		"piano":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/01Piano.mid"
		"guitar":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/04Guitrs.mid"
		"bass":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/06Bass.mid"
		"drums":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/14Drums.mid"
		"house":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/18House.mid"
		"pop":
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/17Pop.mid"
		_:
			midi_path = "res://assets/DSOUNDFONT_Ultimate_4.2.1a/upgrades/demo_songs/01Piano.mid"
	
	# 延迟播放，等待 SoundFont 加载
	call_deferred("_deferred_play", midi_path)

func _deferred_play(midi_path: String):
	play_midi(midi_path)

# 播放指定路径的 MIDI
func play_file(path: String):
	play_midi(path)

# 检查是否准备好播放
func is_ready() -> bool:
	return midi_player.bank != null
