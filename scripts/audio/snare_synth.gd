extends AudioStreamPlayer

# 军鼓合成器 - 使用程序化音频生成 snare drum 声音（带混响和振膜稳定）

var playback: AudioStreamGeneratorPlayback
var sample_rate: float = 44100.0

# 混响参数
var reverb_buffer: Array = []
var reverb_buffer_size: int = 22050
var reverb_decay: float = 0.5
var reverb_mix: float = 0.3

# 振膜稳定参数
var dc_offset: float = 0.001  # 直流偏移
var noise_floor: float = 0.0002  # 底噪电平
var previous_sample: float = 0.0  # 上一样本值

func _ready():
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = sample_rate
	stream.buffer_length = 0.5
	self.stream = stream
	
	reverb_buffer.resize(reverb_buffer_size)
	for i in range(reverb_buffer_size):
		reverb_buffer[i] = 0.0

func play_snare():
	if not playing:
		play()
	playback = get_stream_playback()
	generate_snare_sound()

func generate_snare_sound():
	if playback == null:
		return
	
	var duration: float = 0.2
	var num_samples: int = int(duration * sample_rate)
	
	var tone_freq: float = 180.0
	var tone_decay: float = 0.08
	
	var noise_decay: float = 0.12
	var noise_amount: float = 0.8
	
	var reverb_index: int = 0
	
	for i in range(num_samples):
		var t: float = i / sample_rate
		
		var tone_phase: float = 2.0 * PI * tone_freq * t
		var tone_sample: float = sin(tone_phase)
		tone_sample += 0.5 * sin(2.0 * tone_phase)
		tone_sample *= 0.25
		
		var tone_envelope: float = exp(-t / tone_decay * 5.0)
		tone_sample *= tone_envelope
		
		var noise_sample: float = randf_range(-1.0, 1.0)
		if i > 0:
			noise_sample = (noise_sample + randf_range(-1.0, 1.0)) * 0.5
		noise_sample *= noise_amount
		
		var noise_envelope: float = exp(-t / noise_decay * 3.0)
		noise_sample *= noise_envelope
		
		var sample: float = tone_sample + noise_sample
		
		sample = tanh(sample * 1.5)
		sample *= 0.6
		
		var reverb_sample: float = apply_reverb(sample, reverb_index)
		reverb_index = (reverb_index + 1) % reverb_buffer_size
		
		var final_sample: float = sample * (1.0 - reverb_mix) + reverb_sample * reverb_mix
		
		# === 振膜稳定处理 ===
		final_sample += dc_offset
		final_sample += randf_range(-noise_floor, noise_floor)
		final_sample = lerp(previous_sample, final_sample, 0.98)
		previous_sample = final_sample
		
		playback.push_frame(Vector2(final_sample, final_sample))
	
	# 播放结束后继续输出稳定信号
	for i in range(int(sample_rate * 0.05)):
		var stable_sample: float = dc_offset + randf_range(-noise_floor, noise_floor)
		stable_sample = lerp(previous_sample, stable_sample, 0.99)
		previous_sample = stable_sample
		playback.push_frame(Vector2(stable_sample, stable_sample))

func apply_reverb(input: float, index: int) -> float:
	var read_index: int = (index + reverb_buffer_size - int(sample_rate * 0.04)) % reverb_buffer_size
	var reverb_sample: float = reverb_buffer[read_index] * reverb_decay
	reverb_buffer[index] = input + reverb_sample
	return reverb_sample

func tanh(x: float) -> float:
	if x > 3.0:
		return 1.0
	elif x < -3.0:
		return -1.0
	return (exp(x) - exp(-x)) / (exp(x) + exp(-x))
