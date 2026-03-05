extends AudioStreamPlayer

# 底鼓合成器 - 使用程序化音频生成 kick drum 声音（带混响和振膜稳定）

var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

# 混响参数
var reverb_buffer: Array = []
var reverb_buffer_size: int = 22050
var reverb_decay: float = 0.4
var reverb_mix: float = 0.25

# 振膜稳定参数
var dc_offset: float = 0.001  # 直流偏移，防止振膜完全静止
var noise_floor: float = 0.0002  # 底噪电平
var previous_sample: float = 0.0  # 上一样本值，用于平滑

func _ready():
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.5
	self.stream = stream
	
	reverb_buffer.resize(reverb_buffer_size)
	for i in range(reverb_buffer_size):
		reverb_buffer[i] = 0.0

func play_kick():
	if not playing:
		play()
	playback = get_stream_playback()
	generate_kick_sound()

func generate_kick_sound():
	if playback == null:
		return
	
	var duration: float = 0.25
	var num_samples: int = int(duration * sample_rate)
	
	var start_freq: float = 120.0
	var end_freq: float = 25.0
	
	var attack_time: float = 0.003
	var decay_time: float = 0.15
	
	var reverb_index: int = 0
	
	for i in range(num_samples):
		var t: float = i / sample_rate
		
		var freq_progress: float = t / duration
		var current_freq: float = lerp(start_freq, end_freq, pow(freq_progress, 0.7))
		
		var phase: float = 2.0 * PI * current_freq * t
		var sample: float = sin(phase)
		
		sample += 0.4 * sin(2.0 * phase)
		sample += 0.2 * sin(3.0 * phase)
		sample += 0.1 * sin(0.5 * phase)
		
		var envelope: float = 1.0
		if t < attack_time:
			envelope = t / attack_time
		else:
			var decay_progress: float = (t - attack_time) / decay_time
			envelope = exp(-decay_progress * 3.0)
		
		sample = tanh(sample * 2.0)
		sample *= envelope * 0.7
		
		# 应用混响
		var reverb_sample: float = apply_reverb(sample, reverb_index)
		reverb_index = (reverb_index + 1) % reverb_buffer_size
		
		# 混合干声和湿声
		var final_sample: float = sample * (1.0 - reverb_mix) + reverb_sample * reverb_mix
		
		# === 振膜稳定处理 ===
		# 添加直流偏移
		final_sample += dc_offset
		# 添加轻微底噪
		final_sample += randf_range(-noise_floor, noise_floor)
		# 平滑处理，防止突变
		final_sample = lerp(previous_sample, final_sample, 0.98)
		previous_sample = final_sample
		
		playback.push_frame(Vector2(final_sample, final_sample))
	
	# 播放结束后继续输出稳定信号，防止振膜突然停止
	for i in range(int(sample_rate * 0.05)):  # 额外50ms的稳定信号
		var stable_sample: float = dc_offset + randf_range(-noise_floor, noise_floor)
		stable_sample = lerp(previous_sample, stable_sample, 0.99)
		previous_sample = stable_sample
		playback.push_frame(Vector2(stable_sample, stable_sample))

func apply_reverb(input: float, index: int) -> float:
	var read_index: int = (index + reverb_buffer_size - int(sample_rate * 0.05)) % reverb_buffer_size
	var reverb_sample: float = reverb_buffer[read_index] * reverb_decay
	reverb_buffer[index] = input + reverb_sample
	return reverb_sample

func tanh(x: float) -> float:
	if x > 3.0:
		return 1.0
	elif x < -3.0:
		return -1.0
	return (exp(x) - exp(-x)) / (exp(x) + exp(-x))
