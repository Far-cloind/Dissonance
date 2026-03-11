extends RefCounted

# 懒加载 SoundFont 读取器 - 用于处理超大 SoundFont 文件
# 只读取需要的音色数据，不加载整个文件

class_name LazySoundFontLoader

# SoundFont 文件路径
var soundfont_path: String = ""

# 文件句柄
var file: FileAccess = null

# SoundFont 基本信息
var info: Dictionary = {}

# 样本数据位置 (延迟加载)
var sample_data_offset: int = 0
var sample_data_size: int = 0

# 预设数据位置
var preset_data_offset: int = 0

# 是否已初始化
var is_initialized: bool = false

# 已加载的样本缓存
var loaded_samples: Dictionary = {}

# 最大缓存样本数
var max_cached_samples: int = 10

func _init(path: String):
	soundfont_path = path

# 初始化 - 只读取文件头信息，不读取样本数据
func initialize() -> bool:
	if is_initialized:
		return true
	
	if not FileAccess.file_exists(soundfont_path):
		push_error("❌ SoundFont 文件不存在: " + soundfont_path)
		return false
	
	file = FileAccess.open(soundfont_path, FileAccess.READ)
	if file == null:
		push_error("❌ 无法打开 SoundFont 文件")
		return false
	
	var file_size = file.get_length()
	print("📊 SoundFont 文件大小:", file_size / (1024*1024*1024), " GB")
	
	# 检查 RIFF 头
	var riff = file.get_buffer(4).get_string_from_ascii()
	if riff != "RIFF":
		push_error("❌ 无效的 SoundFont 文件 (RIFF)")
		return false
	
	# 跳过文件大小 (4 bytes)
	file.get_32()
	
	# 检查 sfbk 头
	var sfbk = file.get_buffer(4).get_string_from_ascii()
	if sfbk != "sfbk":
		push_error("❌ 无效的 SoundFont 文件 (sfbk)")
		return false
	
	# 读取 LIST INFO 块
	if not _read_info_chunk():
		return false
	
	# 记录样本数据位置 (但不读取)
	if not _locate_sample_data():
		return false
	
	is_initialized = true
	print("✅ SoundFont 初始化完成 (懒加载模式)")
	return true

# 读取 INFO 块
func _read_info_chunk() -> bool:
	var list_header = file.get_buffer(4).get_string_from_ascii()
	if list_header != "LIST":
		push_error("❌ 找不到 LIST 块")
		return false
	
	var list_size = file.get_32()
	var list_start = file.get_position()
	
	var info_header = file.get_buffer(4).get_string_from_ascii()
	if info_header != "INFO":
		push_error("❌ 找不到 INFO 块")
		return false
	
	# 读取 INFO 子块
	while file.get_position() < list_start + list_size:
		var chunk_header = file.get_buffer(4).get_string_from_ascii()
		var chunk_size = file.get_32()
		
		match chunk_header:
			"ifil":
				var major = file.get_16()
				var minor = file.get_16()
				info["version"] = "%d.%d" % [major, minor]
			"isng":
				info["sound_engine"] = file.get_buffer(chunk_size).get_string_from_utf8()
			"INAM":
				info["name"] = file.get_buffer(chunk_size).get_string_from_utf8()
			"irom":
				info["rom"] = file.get_buffer(chunk_size).get_string_from_utf8()
			_:
				# 跳过其他块
				file.seek(file.get_position() + chunk_size)
	
	print("📋 SoundFont 信息:", info)
	return true

# 定位样本数据位置
func _locate_sample_data() -> bool:
	# 继续查找 sdta 块
	while file.get_position() < file.get_length():
		var pos = file.get_position()
		var header = file.get_buffer(4).get_string_from_ascii()
		
		if header == "LIST":
			var list_size = file.get_32()
			var list_type = file.get_buffer(4).get_string_from_ascii()
			
			if list_type == "sdta":
				# 找到样本数据块
				sample_data_offset = file.get_position()
				sample_data_size = list_size - 4  # 减去 "sdta" 头
				
				# 跳过样本数据 (不读取)
				file.seek(file.get_position() + sample_data_size)
				print("📍 样本数据位置:", sample_data_offset, "大小:", sample_data_size)
				
				# 继续查找 pdta 块
				return _locate_preset_data()
			else:
				# 跳过其他 LIST 块
				file.seek(file.get_position() + list_size - 4)
		else:
			# 如果不是 LIST，回退并跳过
			file.seek(pos + 1)
	
	push_error("❌ 找不到样本数据块 (sdta)")
	return false

# 定位预设数据位置
func _locate_preset_data() -> bool:
	while file.get_position() < file.get_length():
		var pos = file.get_position()
		var header = file.get_buffer(4).get_string_from_ascii()
		
		if header == "LIST":
			var list_size = file.get_32()
			var list_type = file.get_buffer(4).get_string_from_ascii()
			
			if list_type == "pdta":
				preset_data_offset = file.get_position()
				print("📍 预设数据位置:", preset_data_offset)
				return true
			else:
				file.seek(file.get_position() + list_size - 4)
		else:
			file.seek(pos + 1)
	
	push_error("❌ 找不到预设数据块 (pdta)")
	return false

# 加载特定样本 (按需加载)
func load_sample(sample_index: int) -> PackedByteArray:
	if loaded_samples.has(sample_index):
		return loaded_samples[sample_index]
	
	# TODO: 实现按需加载特定样本
	# 这里需要根据 SoundFont 格式解析样本位置
	
	return PackedByteArray()

# 清理缓存
func clear_cache():
	loaded_samples.clear()

# 关闭文件
func close():
	if file != null:
		file.close()
		file = null
	is_initialized = false
