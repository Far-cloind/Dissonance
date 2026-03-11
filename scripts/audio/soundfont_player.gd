extends Node

# SoundFont 播放器 - 使用 sf2 音源播放 MIDI 音符
# 需要配合 Godot MIDI 插件使用

class_name SoundFontPlayer

# SoundFont 文件路径
@export var soundfont_path: String = "res://assets/audio/soundfonts/default.sf2"

# 音色映射表 (乐器类型 -> MIDI 音色号)
var instrument_presets: Dictionary = {
	"cello": 42,      # 大提琴
	"violin": 40,     # 小提琴
	"piano": 0,       # 大钢琴
	"guitar": 24,     # 尼龙弦吉他
	"bass": 32,       # 电贝斯
}

# 音符频率表 (C0 - B8)
var note_frequencies: Dictionary = {}

# 音频输出
var audio_player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

# 当前播放的音符
var active_notes: Array = []

func _ready():
	_initialize_note_frequencies()
	_setup_audio_stream()

func _initialize_note_frequencies():
	# 初始化 MIDI 音符频率表
	# MIDI 音符 60 = C4 = 261.63 Hz
	for midi_note in range(128):
		var freq = 440.0 * pow(2.0, (midi_note - 69) / 12.0)
		note_frequencies[midi_note] = freq

func _setup_audio_stream():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.1
	audio_player.stream = stream
	audio_player.play()
	
	playback = audio_player.get_stream_playback()

# 播放指定音符
func play_note(instrument: String, midi_note: int, velocity: float = 1.0, duration: float = 0.5):
	if not note_frequencies.has(midi_note):
		push_error("无效的 MIDI 音符: " + str(midi_note))
		return
	
	var preset = instrument_presets.get(instrument, 0)
	var frequency = note_frequencies[midi_note]
	
	var note_data = {
		"instrument": instrument,
		"preset": preset,
		"frequency": frequency,
		"midi_note": midi_note,
		"velocity": velocity,
		"duration": duration,
		"time": 0.0,
		"phase": 0.0
	}
	
	active_notes.append(note_data)
	
	print("🎵 播放音符:", instrument, "MIDI:", midi_note, "频率:", frequency)

# 播放和弦
func play_chord(instrument: String, midi_notes: Array, velocity: float = 0.8, duration: float = 0.6):
	for note in midi_notes:
		play_note(instrument, note, velocity, duration)

# 停止所有音符
func stop_all():
	active_notes.clear()

func _process(delta):
	if playback == null or active_notes.is_empty():
		return
	
	# 生成音频帧
	var frames_to_fill = playback.get_frames_available()
	
	for i in range(frames_to_fill):
		var mixed_sample: float = 0.0
		
		# 处理每个活跃的音符
		for j in range(active_notes.size() - 1, -1, -1):
			var note = active_notes[j]
			
			# 生成波形
			var sample = generate_instrument_waveform(note)
			
			# 应用包络
			var envelope = calculate_envelope(note)
			sample *= envelope * note.velocity
			
			mixed_sample += sample
			
			# 更新音符时间
			note.time += 1.0 / sample_rate
			note.phase += 2.0 * PI * note.frequency / sample_rate
			
			# 检查音符是否结束
			if note.time >= note.duration:
				active_notes.remove_at(j)
		
		# 限幅
		mixed_sample = clamp(mixed_sample, -1.0, 1.0)
		
		# 推送到音频输出
		playback.push_frame(Vector2(mixed_sample, mixed_sample))

func generate_instrument_waveform(note: Dictionary) -> float:
	var instrument = note.instrument
	var phase = note.phase
	
	match instrument:
		"cello":
			return generate_cello_waveform(phase)
		"violin":
			return generate_violin_waveform(phase)
		"piano":
			return generate_piano_waveform(phase)
		"bass":
			return generate_bass_waveform(phase)
		_:
			return sin(phase)

func generate_cello_waveform(phase: float) -> float:
	# 大提琴 - 温暖的正弦波为主
	var sample = 0.0
	sample += 1.0 * sin(phase)
	sample += 0.3 * sin(2.0 * phase)
	sample += 0.1 * sin(3.0 * phase)
	return sample * 0.7

func generate_violin_waveform(phase: float) -> float:
	# 小提琴 - 更明亮，更多高频
	var sample = 0.0
	sample += 1.0 * sin(phase)
	sample += 0.5 * sin(2.0 * phase)
	sample += 0.25 * sin(3.0 * phase)
	sample += 0.1 * sin(4.0 * phase)
	return sample * 0.5

func generate_piano_waveform(phase: float) -> float:
	# 钢琴 - 丰富的泛音，快速衰减
	var sample = 0.0
	sample += 1.0 * sin(phase)
	sample += 0.6 * sin(2.0 * phase)
	sample += 0.4 * sin(3.0 * phase)
	sample += 0.2 * sin(4.0 * phase)
	return sample * 0.5

func generate_bass_waveform(phase: float) -> float:
	# 贝斯 - 低沉，较少泛音
	var sample = 0.0
	sample += 1.0 * sin(phase)
	sample += 0.2 * sin(2.0 * phase)
	return sample * 0.8

func calculate_envelope(note: Dictionary) -> float:
	var t = note.time
	var duration = note.duration
	
	# 简单的 ADSR 包络
	var attack = 0.05
	var decay = 0.1
	var sustain = 0.7
	var release = 0.2
	
	if t < attack:
		return t / attack
	elif t < attack + decay:
		return 1.0 - (1.0 - sustain) * (t - attack) / decay
	elif t < duration - release:
		return sustain
	else:
		return sustain * (duration - t) / release

# 获取 MIDI 音符号 (C4 = 60)
func get_midi_note(note_name: String, octave: int) -> int:
	var note_offsets = {
		"C": 0, "C#": 1, "Db": 1,
		"D": 2, "D#": 3, "Eb": 3,
		"E": 4,
		"F": 5, "F#": 6, "Gb": 6,
		"G": 7, "G#": 8, "Ab": 8,
		"A": 9, "A#": 10, "Bb": 10,
		"B": 11
	}
	
	var offset = note_offsets.get(note_name, 0)
	return 12 * (octave + 1) + offset
