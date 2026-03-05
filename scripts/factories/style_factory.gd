extends RefCounted

# 风格工厂 - 创建不同的乐器风格实例

class_name StyleFactory

# 创建风格实例
static func create_style(style_type: int) -> InstrumentStyleBase:
	match style_type:
		GlobalGameData.STYLE_ROCK:
			return RockStyle.new()
		GlobalGameData.STYLE_STRING:
			return StringStyle.new()
		GlobalGameData.STYLE_ELECTRONIC:
			return ElectronicStyle.new()
		_:
			return RockStyle.new()  # 默认摇滚风格

# 获取风格名称
static func get_style_name(style_type: int) -> String:
	match style_type:
		GlobalGameData.STYLE_ROCK:
			return "摇滚风格"
		GlobalGameData.STYLE_STRING:
			return "弦乐风格"
		GlobalGameData.STYLE_ELECTRONIC:
			return "电子风格"
		_:
			return "未知风格"

# 获取风格描述
static func get_style_description(style_type: int) -> String:
	var style = create_style(style_type)
	return style.get_description()
