extends Node

# 弦乐 SoundFont 播放器 - 使用采样或合成模拟真实弦乐

class_name StringSoundFont

# 音频输出
var audio_player: AudioStreamPlayer
var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

# 混响参数
var reverb_buffer: Array = []
var reverb_buffer_size: int = 22050
var reverb_decay: float = 0.4
var reverb_mix: float = 0.3

# 当前播放的音符
var active_notes: Array = []

# 振膜稳定
var dc_offset: float = 0.001
var noise_floor: float = 0.0001
var previous_sample: float = 0.0

func _ready():
	_setup_audio_stream()
	_initialize_reverb()

func _setup_audio_stream():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.2
	audio_player.stream = stream
	audio_player.play()
	
	playback = audio_player.get_stream_playback()

func _initialize_reverb():
	reverb_buffer.resize(reverb_buffer_size)
	for i in range(reverb_buffer_size):
		reverb_buffer[i] = 0.0

# 播放大提琴音符 (C2-G3)
func play_cello_note(midi_note: int = 36, velocity: float = 1.0):
	_play_string_note("cello", midi_note, velocity, 0.8)

# 播放小提琴音符 (G3-E6)
func play_violin_note(midi_note: int = 67, velocity: float = 0.9):
	_play_string_note("violin", midi_note, velocity, 0.5)

# 播放低音弦乐（强拍）
func play_low_string():
	# C2 (36) - 深沉的大提琴低音
	play_cello_note(36, 1.0)

# 播放高音弦乐（弱拍）
func play_high_string():
	# G4 (67) - 明亮的小提琴音
	play_violin_note(67, 0.85)

func _play_string_note(instrument: String, midi_note: int, velocity: float, duration: float):
	var frequency = 440.0 * pow(2.0, (midi_note - 69) / 12.0)
	
	var note_data = {
		"instrument": instrument,
		"frequency": frequency,
		"midi_note": midi_note,
		"velocity": velocity,
		"duration": duration,
		"time": 0.0,
		"phase": 0.0,
		"vibrato_phase": 0.0
	}
	
	active_notes.append(note_data)

func stop_all():
	active_notes.clear()

func _process(delta):
	if playback == null or active_notes.is_empty():
		return
	
	var frames_to_fill = playback.get_frames_available()
	var reverb_index = 0
	
	for i in range(frames_to_fill):
		var mixed_sample: float = 0.0
		
		for j in range(active_notes.size() - 1, -1, -1):
			var note = active_notes[j]
			
			var sample = generate_string_sample(note)
			var envelope = calculate_string_envelope(note)
			sample *= envelope * note.velocity
			
			mixed_sample += sample
			
			# 更新
			note.time += 1.0 / sample_rate
			note.phase += 2.0 * PI * note.frequency / sample_rate
			note.vibrato_phase += 2.0 * PI * 5.5 / sample_rate
			
			if note.time >= note.duration:
				active_notes.remove_at(j)
		
		# 混响
		var reverb_sample = apply_reverb(mixed_sample, reverb_index)
		reverb_index = (reverb_index + 1) % reverb_buffer_size
		var final_sample = mixed_sample * (1.0 - reverb_mix) + reverb_sample * reverb_mix
		
		# 限幅和稳定
		final_sample = clamp(final_sample, -0.9, 0.9)
		final_sample += dc_offset
		final_sample += randf_range(-noise_floor, noise_floor)
		final_sample = lerp(previous_sample, final_sample, 0.99)
		previous_sample = final_sample
		
		playback.push_frame(Vector2(final_sample, final_sample))

func generate_string_sample(note: Dictionary) -> float:
	var instrument = note.instrument
	var phase = note.phase
	var t = note.time
	
	# 颤音 - 缓慢启动
	var vibrato_ramp = min(1.0, t / 0.4)
	var vibrato = sin(note.vibrato_phase) * 0.005 * vibrato_ramp
	var modulated_phase = phase + vibrato * sin(phase)
	
	var sample = 0.0
	
	if instrument == "cello":
		# 大提琴 - 温暖、深沉
		sample += 1.0 * sin(modulated_phase)
		sample += 0.25 * sin(2.0 * modulated_phase)
		sample += 0.08 * sin(3.0 * modulated_phase)
		sample += 0.03 * sin(4.0 * modulated_phase)
		sample *= 0.7
		
		# 弓弦噪声
		if t < 0.1:
			sample += randf_range(-0.03, 0.03) * (1.0 - t * 10.0)
		
	elif instrument == "violin":
		# 小提琴 - 明亮、歌唱性
		sample += 1.0 * sin(modulated_phase)
		sample += 0.4 * sin(2.0 * modulated_phase)
		sample += 0.15 * sin(3.0 * modulated_phase)
		sample += 0.05 * sin(4.0 * modulated_phase)
		sample *= 0.55
		
		# 弓弦噪声
		if t < 0.08:
			sample += randf_range(-0.02, 0.02) * (1.0 - t * 12.5)
	
	return sample

func calculate_string_envelope(note: Dictionary) -> float:
	var t = note.time
	var duration = note.duration
	
	# 弦乐包络 - 缓慢起音和释音
	var attack = 0.12
	var decay = 0.08
	var sustain = 0.75
	var release = 0.2
	
	if t < attack:
		return t / attack
	elif t < attack + decay:
		return 1.0 - (1.0 - sustain) * (t - attack) / decay
	elif t < duration - release:
		return sustain
	else:
		return sustain * max(0.0, (duration - t) / release)

func apply_reverb(input: float, index: int) -> float:
	var delay_samples = int(sample_rate * 0.05)
	var read_index = (index + reverb_buffer_size - delay_samples) % reverb_buffer_size
	var reverb_sample = reverb_buffer[read_index] * reverb_decay
	reverb_buffer[index] = input + reverb_sample
	return reverb_sample
