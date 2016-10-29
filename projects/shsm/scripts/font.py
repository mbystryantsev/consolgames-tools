import struct

class FontInfo:
	__slots__ = (
		'version',
		'family',
		'kerning',
		'charWidth',
		'charHeight',
		'chars',
		'unk1',
		'unk2',
		'unk3',
		'unkData',
		'buttonRectsSection',
		'buttonRectsData',
		'textColorsSection',
		'textColorsData',
		'kerningSection',
		'unk11',
		'unk12',
		'unk13',
		'unkFontData',
		'charData'
		)

class SectionInfo:
	__slots__ = ('index', 'type', 'size', 'count', 'tag')
	
class KerningRecord:
	__slots__ = ('a', 'b', 'kerning')
	
class CharRecord:
	__slots__ = ('code', 'width', 'unk', 'yy', 'ww', 'hh', 'pos', 'size', 'unk2')

def readSectionInfo(file):
	info = SectionInfo()
	(info.index, info.type, info.size, info.count, info.tag) = struct.unpack('<HHIHH', file.read(12))
	return info

def writeSectionInfo(file, info):
	file.write(struct.pack('<HHIHH', info.index, info.type, info.size, info.count, info.tag))
	
def loadFontInfo(filename):
	file = open(filename, 'rb')

	info = FontInfo()
	(info.version, info.unk1, info.unk2, info.unk3) = struct.unpack('<hhhh', file.read(8))
	
	if not info.version in [5, 6]:
		raise Exception('Unsupported version: ' + version)
	
	if info.version == 6:
		(info.family,) = struct.unpack('32s', file.read(32))

	# Unknown data
	info.unkData = file.read(32)
	
	# Button rects
	info.buttonRectsSection = readSectionInfo(file)
	info.buttonRectsData = file.read(info.buttonRectsSection.size)
	
	# Text colors
	info.textColorsSection = readSectionInfo(file)
	info.textColorsData = file.read(info.textColorsSection.size)

	# Read kerning
	info.kerningSection = readSectionInfo(file)
	
	info.kerning = []
	for i in range(info.kerningSection.count):
		record = KerningRecord()
		(record.a, record.b, record.kerning) = struct.unpack('<HHh', file.read(6))
		info.kerning.append(record)
		
	(info.unk11, info.unk12, fontDataSize, charCount, info.charWidth, info.charHeight, info.unk13) = struct.unpack('<HHIhhhH', file.read(16))
		
	# Skip unknown data
	if info.version == 6:
		info.unkFontData = file.read(32)
	else:
		info.unkFontData = ""

	info.chars = []
	for i in range(charCount):
		char = CharRecord()
		(char.code, char.width, char.unk, char.yy, char.ww, char.hh, char.pos, char.size, char.unk2) = struct.unpack('<HhBBBBIHH', file.read(16))
		info.chars.append(char)
		
	info.charData = file.read()
	
	file.close()
	
	return info

def saveFontInfo(info, filename):
	if not info.version in [5, 6]:
		raise Exception('Unsupported version: ' + version)

	file = open(filename, 'wb')

	file.write(struct.pack('<hhhh', info.version, info.unk1, info.unk2, info.unk3))
	
	if info.version == 6:
		 file.write(struct.pack('32s', info.family))
	
	# Unknown data
	file.write(info.unkData)
	
	# Button rects
	writeSectionInfo(file, info.buttonRectsSection)
	file.write(info.buttonRectsData)
	
	# Text colors
	writeSectionInfo(file, info.textColorsSection)
	file.write(info.textColorsData)

	# Kerning
	info.kerningSection.count = len(info.kerning)
	info.kerningSection.size = info.kerningSection.count * 6
	writeSectionInfo(file, info.kerningSection)

	for record in info.kerning:
		file.write(struct.pack('<HHh', record.a, record.b, record.kerning))

	charCount    = len(info.chars)
	fontDataSize = len(info.chars) * 16 + len(info.charData)
	file.write(struct.pack('<HHIhhhH', info.unk11, info.unk12, fontDataSize, charCount, info.charWidth, info.charHeight, info.unk13))

	# Skip unknown data
	if info.version == 6:
		file.write(info.unkFontData)

	for char in info.chars:
		file.write(struct.pack('<HhBBBBIHH', char.code, char.width, char.unk, char.yy, char.ww, char.hh, char.pos, char.size, char.unk2))

	file.write(info.charData)
		
	file.close()