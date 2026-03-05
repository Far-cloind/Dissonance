extends AudioStreamPlayer

# 弦乐合成器 - 模拟真实弦乐器声音（大提琴/小提琴）

var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

# 混响参数
var reverb_buffer: Array = []
var reverb_buffer_size: int = 22050  # 0.5秒延迟
var reverb_decay: float = 0.5
var reverb_mix: float = 0.35

# 振膜稳定参数
var dc_offset: float = 0.001
var noise_floor: float = 0.0001
var previous_sample: float = 0.0

# 弦乐参数 - 更自然的颤音
var vibrato_rate: float = 5.5  # 稍慢的颤音
var vibrato_depth: float = 0.008  # 更浅的颤音

func _ready():
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.5
	self.stream = stream
	
	reverb_buffer.resize(reverb_buffer_size)
	for i in range(reverb_buffer_size):
		reverb_buffer[i] = 0.0

# 播放大提琴低音
func play_low_string():
	if not playing:
		play()
	playback = get_stream_playback()
	generate_cello_sound()

# 播放小提琴高音
func play_high_string():
	if not playing:
		play()
	playback = get_stream_playback()
	generate_violin_sound()

func generate_cello_sound():
	if playback == null:
		return
	
	# 大提琴参数 - 更长的持续音
	var duration: float = 0.6
	var num_samples: int = int(duration * sample_rate)
	
	# C2 音 (65.41 Hz) - 深沉的大提琴低音
	var base_freq: float = 65.41
	
	# 包络时间
	var attack_time: float = 0.15   # 慢速起音
	var decay_time: float = 0.1
	var sustain_level: float = 0.7
	var release_time: float = 0.25  # 缓慢释音
	
	var reverb_index: int = 0
	
	for i in range(num_samples):
		var t: float = i / sample_rate
		
		# 自然的颤音 - 缓慢启动
		var vibrato_ramp: float = min(1.0, t / 0.3)  # 0.3秒内渐强
		var vibrato: float = sin(2.0 * PI * vibrato_rate * t) * vibrato_depth * vibrato_ramp
		var current_freq: float = base_freq * (1.0 + vibrato)
		
		# 相位
		var phase: float = 2.0 * PI * current_freq * t
		
		# 大提琴波形 - 主要是正弦波，少量泛音
		var sample: float = 0.0
		
		# 基频 - 主导
		sample += 1.0 * sin(phase)
		
		# 第一泛音 - 很弱
		sample += 0.15 * sin(2.0 * phase)
		
		# 第二泛音 - 非常弱
		sample += 0.05 * sin(3.0 * phase)
		
		# 添加轻微的弓弦摩擦噪声（更真实）
		var bow_noise: float = randf_range(-0.02, 0.02) * exp(-t * 3.0)
		sample += bow_noise
		
		# 柔和限幅
		sample = soft_clip(sample * 0.5)
		
		# ADSR 包络
		var envelope: float = calculate_cello_envelope(
			t, attack_time, decay_time, sustain_level, release_time, duration
		)
		sample *= envelope * 0.9
		
		# 应用混响
		var reverb_sample: float = apply_reverb(sample, reverb_index)
		reverb_index = (reverb_index + 1) % reverb_buffer_size
		
		# 混合
		var final_sample: float = sample * (1.0 - reverb_mix) + reverb_sample * reverb_mix
		
		# 振膜稳定
		final_sample += dc_offset
		final_sample += randf_range(-noise_floor, noise_floor)
		final_sample = lerp(previous_sample, final_sample, 0.99)
		previous_sample = final_sample
		
		playback.push_frame(Vector2(final_sample, final_sample))
	
	# 尾音稳定
	for i in range(int(sample_rate * 0.1)):
		var stable_sample: float = dc_offset + randf_range(-noise_floor, noise_floor)
		stable_sample = lerp(previous_sample, stable_sample, 0.995)
		previous_sample = stable_sample
		playback.push_frame(Vector2(stable_sample, stable_sample))

func generate_violin_sound():
	if playback == null:
		return
	
	# 小提琴参数
	var duration: float = 0.4
	var num_samples: int = int(duration * sample_rate)
	
	# G4 音 (392 Hz) - 明亮的小提琴音
	var base_freq: float = 392.0
	
	# 包络时间
	var attack_time: float = 0.08
	var decay_time: float = 0.05
	var sustain_level: float = 0.8
	var release_time: float = 0.2
	
	var reverb_index: int = 0
	
	for i in range(num_samples):
		var t: float = i / sample_rate
		
		# 更快的颤音，但也很浅
		var vibrato_ramp: float = min(1.0, t / 0.2)
		var vibrato: float = sin(2.0 * PI * vibrato_rate * 1.3 * t) * vibrato_depth * 1.2 * vibrato_ramp
		var current_freq: float = base_freq * (1.0 + vibrato)
		
		var phase: float = 2.0 * PI * current_freq * t
		
		# 小提琴波形 - 更多高频但控制得当
		var sample: float = 0.0
		
		# 基频
		sample += 1.0 * sin(phase)
		
		# 第一泛音 - 中等
		sample += 0.25 * sin(2.0 * phase)
		
		# 第二泛音 - 较弱
		sample += 0.1 * sin(3.0 * phase)
		
		# 第三泛音 - 很弱
		sample += 0.03 * sin(4.0 * phase)
		
		# 轻微的弓弦噪声
		var bow_noise: float = randf_range(-0.015, 0.015) * exp(-t * 4.0)
		sample += bow_noise
		
		# 柔和限幅
		sample = soft_clip(sample * 0.45)
		
		# ADSR 包络
		var envelope: float = calculate_cello_envelope(
			t, attack_time, decay_time, sustain_level, release_time, duration
		)
		sample *= envelope * 0.75
		
		# 应用混响
		var reverb_sample: float = apply_reverb(sample, reverb_index)
		reverb_index = (reverb_index + 1) % reverb_buffer_size
		
		# 混合
		var final_sample: float = sample * (1.0 - reverb_mix) + reverb_sample * reverb_mix
		
		# 振膜稳定
		final_sample += dc_offset
		final_sample += randf_range(-noise_floor, noise_floor)
		final_sample = lerp(previous_sample, final_sample, 0.99)
		previous_sample = final_sample
		
		playback.push_frame(Vector2(final_sample, final_sample))
	
	# 尾音稳定
	for i in range(int(sample_rate * 0.08)):
		var stable_sample: float = dc_offset + randf_range(-noise_floor, noise_floor)
		stable_sample = lerp(previous_sample, stable_sample, 0.995)
		previous_sample = stable_sample
		playback.push_frame(Vector2(stable_sample, stable_sample))

func calculate_cello_envelope(t: float, attack: float, decay: float, sustain: float, release: float, total: float) -> float:
	# 弦乐 ADSR 包络 - 更自然
	if t < attack:
		# Attack - 缓慢启动
		return t / attack
	elif t < attack + decay:
		# Decay - 衰减到 sustain
		var decay_progress: float = (t - attack) / decay
		return 1.0 - (1.0 - sustain) * decay_progress
	elif t < total - release:
		# Sustain - 保持
		return sustain
	else:
		# Release - 缓慢释放
		var release_progress: float = (t - (total - release)) / release
		return max(0.0, sustain * (1.0 - release_progress))

func apply_reverb(input: float, index: int) -> float:
	var delay_samples: int = int(sample_rate * 0.06)  # 60ms 延迟
	var read_index: int = (index + reverb_buffer_size - delay_samples) % reverb_buffer_size
	var reverb_sample: float = reverb_buffer[read_index] * reverb_decay
	reverb_buffer[index] = input + reverb_sample
	return reverb_sample

func soft_clip(x: float) -> float:
	# 软削波
	if x > 0.8:
		return 0.8 + 0.2 * tanh((x - 0.8) / 0.2)
	elif x < -0.8:
		return -0.8 - 0.2 * tanh((-x - 0.8) / 0.2)
	return x

func tanh(x: float) -> float:
	# 双曲正切函数
	var e_pos: float = exp(x)
	var e_neg: float = exp(-x)
	return (e_pos - e_neg) / (e_pos + e_neg)
