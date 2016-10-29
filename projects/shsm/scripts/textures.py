import environment
import sys
from glob import glob
from os import path
import hash
import copy
import subprocess

c_ignoredFiles = ['LocaleUIEng', 'LocaleUIIta', 'LocaleUISpa', 'LocaleUIFre', 'LocaleUIJap']

def rasterSize(width, height, mipmapCount):
	totalSize = 0
	for i in range(1, mipmapCount + 1):
		totalSize = totalSize + width * height / 2
		width = max(8, width / 2)
		height = max(8, height / 2)
		
	return totalSize
	
def textureList(texturePath):
	ignore = set(['thumbs.db'])
	fileList = glob(path.join(texturePath, '*'))
	textures = {}
	for file in fileList:
		basename = path.basename(file)
		if basename in ignore:
			continue
		
		if path.isdir(file):
			subdirTextures = textureList(file)
			for textureName, texturePath in subdirTextures.iteritems():
				if textureName in textures:
					raise Exception('Duplicated texture: ' + textureName + ', first path: "' + textures[textureName]+ '", second path: "' + texturePath + '"')
			textures.update(subdirTextures)
		else:
			(texture, ext) = path.splitext(basename)
			if ext.lower() not in ['.png', '.psd']:
				raise Exception('Unknown extension: ' + ext)
			
			if not texture in textures or ext.lower() == '.psd':
				textures[texture] = file
			
	return textures

def writeFields(file, values, fields):
	for field in fields:
		if field != fields[0]:
			file.write(';')
		file.write(values[field])
	file.write('\n')

def simplifyCsv(csvPath, textures, destPath):
	csv = open(csvPath, 'r')
	header = csv.readline().strip()
	headerValues = header.split(';')

	fileNameIndex = headerValues.index("fileName") if "fileName" in headerValues else -1
	fileHashIndex = headerValues.index("fileHash") if "fileHash" in headerValues else -1
	textureNameIndex = headerValues.index("textureName")
	widthIndex = headerValues.index("width")
	heightIndex = headerValues.index("height")
	mipmapCountIndex = headerValues.index("mipmapCount")
	rasterPositionIndex = headerValues.index("rasterPosition")
	rasterSizeIndex = headerValues.index("rasterSize")
	palettePositionIndex = headerValues.index("palettePosition")
	paletteSizeIndex = headerValues.index("paletteSize")
	formatIndex = headerValues.index("format")
	paletteFormatIndex = headerValues.index("paletteFormat")
	
	outCsv = open(destPath, 'w')
	outCsv.write(('fileHash' if fileNameIndex == -1 else 'fileName') + ';textureName;format;width;height;mipmapCount;rasterPosition;rasterSize;paletteFormat;palettePosition;paletteSize\n')
	
	for line in csv:
		values = line.strip().split(';')
		textureName = values[textureNameIndex]
		if textureName in textures:
			writeFields(outCsv, values, [fileHashIndex if fileNameIndex == -1 else fileNameIndex] + [textureNameIndex, formatIndex, widthIndex, heightIndex, mipmapCountIndex, rasterPositionIndex, rasterSizeIndex, paletteFormatIndex, palettePositionIndex, paletteSizeIndex])
			
class TextureSpec:
	__slots__ = ('format', 'width', 'height', 'mipmapCount', 'paletteFormat')
	def __init__(self, format, width, height, mipmapCount, paletteFormat):		
		self.format = format	
		self.paletteFormat = paletteFormat
		self.width = width
		self.height = height
		self.mipmapCount = mipmapCount
	
def loadTexturesSpecs(csvPath):
	specs = {}
	
	csv = open(csvPath, 'r')
	header = csv.readline().strip()
	headerValues = header.split(';')
	
	fileNameIndex = headerValues.index("fileName") if "fileName" in headerValues else -1
	fileHashIndex = headerValues.index("fileHash") if "fileHash" in headerValues else -1
	textureNameIndex = headerValues.index("textureName")
	formatIndex = headerValues.index("format")
	widthIndex = headerValues.index("width")
	heightIndex = headerValues.index("height")
	mipmapCountIndex = headerValues.index("mipmapCount")
	paletteFormatIndex = headerValues.index("paletteFormat")
	
	for line in csv:
		values = line.strip().split(';')
		textureName = values[textureNameIndex]
		fileName = values[fileNameIndex] if fileNameIndex != -1 else ''
	
		if fileName in c_ignoredFiles:
			continue

		format        = values[formatIndex]
		width         = int(values[widthIndex])
		height        = int(values[heightIndex])
		mipmapCount   = int(values[mipmapCountIndex])
		paletteFormat = values[paletteFormatIndex]
		textureSpec   = TextureSpec(format, width, height, mipmapCount, paletteFormat)

		if textureName in specs:
			specList = specs[textureName]
			found = False
			for spec in specList:
				if spec.format == format and spec.paletteFormat == paletteFormat and spec.width == width and spec.height == height:
					found = True
					break
			if not found:
				specs[textureName].append(textureSpec)
		else:
			specs[textureName] = [textureSpec]

	return specs
	
def texturesHiera(platform, texturesRootPath):
	hieraPath = path.join(texturesRootPath, 'hiera.list')
	if path.exists(hieraPath):
		hiera = open(hieraPath, 'r').read().splitlines()
		hiera.reverse()
		return hiera[hiera.index(platform):]
	return [environment.platform]

def allTexturesList(hiera, texturesRootPath):
	allTextures = {}
	for hieraPlatform in hiera:
		textures = textureList(path.join(texturesRootPath, hieraPlatform))
		allTextures.update(textures)

	return allTextures

def convertTextures(platform, csvPath, texturesRootPath, resourcesPath, onlyModified = False):
	specs = loadTexturesSpecs(csvPath)
	
	convPath = path.join(environment.toolsPath, 'TextureConv.exe')

	hiera = texturesHiera(platform, texturesRootPath)
	textures = allTexturesList(hiera, texturesRootPath)
	
	def convert(filename, isExternal):
		if not texture in specs:
			if isExternal:
				return
			raise Exception('Texture specs not found: "' + texture + '"')
	
		specList = specs[texture]
	
		for spec in specList:
			textureFilename = '%s.%dx%d.%s.%s.TXTR' % (texture, spec.width, spec.height, spec.format, spec.paletteFormat)
			destFilename = path.join(resourcesPath, textureFilename)
		
			# Skip the file if it is not modified since the last conversion
			if onlyModified and path.exists(destFilename):
				sourceDate = path.getmtime(filename)
				destDate = path.getmtime(destFilename)
				if destDate > sourceDate:
					print 'Skipping', texture
					return

			sys.stdout.write('Converting ' + texture + (' (%dx%d, %s, %s, external = %r)' % (spec.width, spec.height, spec.format, spec.paletteFormat, isExternal)) + '... ')
		
			subprocess.check_call([convPath, '-e', platform, spec.format, filename, destFilename, str(spec.mipmapCount), str(spec.width), str(spec.height)])
	
	rootPathAbs = path.abspath(path.join(texturesRootPath, platform))
	for (texture, filename) in textures.iteritems():
		convert(filename, not path.abspath(filename).startswith(rootPathAbs))

def convertImages(resourcesPath):
	imagesPath = path.join(environment.contentPath, 'images', environment.platform)

	# Convert to jpeg all other images
	convPath = path.join(environment.toolsPath, 'TextureConv.exe')
	filelist = glob(path.join(imagesPath, '*'))
	for filename in filelist:
		if path.isfile(filename):
			(fullBasename, ext) = path.splitext(filename)
			basename = path.basename(fullBasename)
			imageName = basename + '.jpg'
			
			if environment.isOrigins:
				resultName = imageName
			else:
				resultName = basename if hash.isHash(basename) else hash.hashToStr(hash.calcHash(imageName))
			
			destFilename = path.join(resourcesPath, resultName)
			
			if ext.lower() != '.jpg':
				print 'Encoding ' + imageName + '...'
				subprocess.check_call([convPath, '-j', filename, destFilename])
			else:			
				# Just copy all images already in jpeg format
				print 'Copying ' + imageName + '...'
				subprocess.check_call(['copy', '/Y', filename, destFilename], shell = True)

if __name__ == "__main__":
	simplifyCsv(path.join(environment.commonContentPath, 'data', 'wii', 'textures.csv'), textureList(environment.texturesPath), path.join(environment.resourcesPath, 'textures.csv'))
	convertTextures(environment.texturesRootPath, environment.platform, environment.resourcesPath)
