import subprocess
import os
import struct
import sys
import environment
import patcher
import argparse
import font
from textures import *
from hash import *
from tests import *

def cleanResources(cleanTextures = True):
	sys.stdout.write("Clean... ")

	filelist = glob.glob(os.path.join(resourcesPath, '*'))
	for f in filelist:
		if os.path.isfile(f) and os.path.basename(f) != 'readme.txt' and (cleanTextures or os.path.splitext(f) != textures.textureExt):
			os.remove(f)
			
	print "done."

def convertMergeMap(inputPath, outputPath, append = False):
	src = open(inputPath, 'r')
	out = open(outputPath, 'ab' if append else 'wb')

	for line in src:		
		line = line.split('#')[0].strip()
		if not line:
			continue
		
		names = line.split(' ')
		hashFrom = hashFromName(names[0])
		hashTo = hashFromName(names[1])
		out.write(struct.pack('<LL', hashFrom, hashTo))
	
	src.close()
	out.close()
	
def convertText(resourcePath):
	textConv = os.path.join(environment.toolsPath, 'TextConv.exe')

	hieraPath = os.path.join(environment.contentPath, 'text', 'hiera.list')
	hiera = [environment.platform]
	if os.path.exists(hieraPath):
		hiera = open(hieraPath, 'r').read().splitlines()

	sourcePaths = []
	for platform in hiera:
		sourcePath = os.path.join(environment.contentPath, 'text', platform)
		if not os.path.exists(sourcePath):
			raise Exception('Path for platform from hiera not found: ' + platform)

		sourcePaths.append(sourcePath)
		if environment.platform == platform:
			break

	for file in (['Strings'] + (['BootStrings'] if not environment.isOrigins else [])):
		baseFile = os.path.join(environment.rootContentPath, 'eng', 'text', environment.platform, file + '.txt')
		filename = file + '.Eng'
		outFile = os.path.join(resourcePath, filename if environment.isOrigins else hashToStr(calcHash(filename)))
		subprocess.check_call([textConv, '-bs', baseFile, outFile] + sourcePaths)

	messagesPath = os.path.join(environment.contentPath, 'misc', 'messages.txt')
	messagesPlatformPath = os.path.join(environment.contentPath, 'misc', environment.platform, 'messages.txt')
	
	if os.path.exists(messagesPath):
		subprocess.check_call([textConv, '-b', messagesPath, os.path.join(resourcePath, 'messages.bin')])	
	if os.path.exists(messagesPlatformPath):
		subprocess.check_call([textConv, '-b', messagesPlatformPath, os.path.join(resourcePath, 'messages_' + environment.platform + '.bin')])	

def convertCmiMaps(resourcePath, keepConverted = False):
	maps = [
		('mp_hosp', ['r', 'd']),
		('mp_Asylum1', ['R', 'D']),
		('mp_Asylum2', ['R', 'D']),
		('mp_AsylumB', ['R', 'D']),
		('mp_Motel1', ['R', 'D']),
		('mp_Motel2', ['R', 'D']),
		('mp_Theatre', ['R', 'D']),
		('mp_Town', ['']),
		('mp_darktown', [''])
	];
	
	cmiTool = os.path.join(environment.toolsPath, 'CmiTool.exe')

	for (name, variations) in maps:
		for variation in variations:
			filename = name + variation + '.cmi'
			destFilename = os.path.join(resourcePath, filename)
			
			bgPath = os.path.join(environment.rootContentPath, 'eng', 'maps', environment.platform, name + variation + '_bg.png')
			layer0Path = os.path.join(environment.rootContentPath, 'eng', 'maps', environment.platform, name + variation + '_0.png')
			layer1Path = os.path.join(environment.contentPath, 'maps', environment.platform, name + '.psd')
			
			if keepConverted and os.path.exists(destFilename):
				sourceDate = max(os.path.getmtime(bgPath), os.path.getmtime(layer0Path), os.path.getmtime(layer1Path))
				destDate = os.path.getmtime(destFilename)
				if destDate > sourceDate:
					print 'Skipping ' + filename + '...'
					continue
			
			print 'Converting ' + filename + '...'
			subprocess.check_call([cmiTool, '--encode', layer1Path, layer0Path, bgPath, destFilename], shell = True)

def generateExecutablePatch(resourcePath):
	targetPatch = os.path.join(resourcePath, 'patch.dat')
	subprocess.check_call(['copy', '/Y', os.path.join(environment.commonContentPath, 'data', environment.platform, 'patch.dat'), targetPatch], shell = True)
	
	languageDependPatch = os.path.join(environment.contentPath, 'data',  environment.platform, 'patch.dat')
	if os.path.exists(languageDependPatch):
		subprocess.check_call(['echo.', '>>', targetPatch], shell = True)
		subprocess.check_call(['type', languageDependPatch, '>>', targetPatch], shell = True)
			
def generateResources(resourcePath, rebuildTextures = True):
	print 'Running tests...'
	testStrings()

	print 'Converting mergemap...';
	convertMergeMap(os.path.join(environment.commonContentPath, 'mergemap.txt'), os.path.join(resourcePath, 'mergemap.bin'))

	print 'Building fonts...'
	fontFile = 'Font_EUR.kft'
	fontPlatformPath = os.path.join(environment.contentPath, 'fonts', environment.platform, fontFile)
	fontCommonPath = os.path.join(environment.contentPath, 'fonts', fontFile)
	if os.path.exists(fontPlatformPath):
		subprocess.check_call(['copy', '/Y', fontPlatformPath, resourcePath], shell = True)
	else:
		originalFontInfo = font.loadFontInfo(os.path.join(environment.rootContentPath, 'eng', 'fonts', environment.platform, fontFile))
		fontInfo = font.loadFontInfo(fontCommonPath)
		properties = ['unk1', 'unk2', 'unk3', 'unkData', 'buttonRectsSection', 'buttonRectsData', 'textColorsSection', 'textColorsData', 'unk11', 'unk12', 'unk13', 'unkFontData']
		for property in properties:
			fontInfo.__dict__[property] = originalFontInfo.__dict__[property]
		font.saveFontInfo(fontInfo, os.path.join(resourcePath, fontFile))
			
	print 'Copying manifest...'
	subprocess.check_call(['copy', '/Y', os.path.join(environment.commonContentPath, 'data', environment.platform, 'manifest.ini'), os.path.join(resourcePath, 'manifest.ini')], shell = True)
	
	print 'Generating executable patch...'
	generateExecutablePatch(resourcePath)
	
	if not environment.isOrigins:	
		print 'Copying map...'
		mapFilename = 'UI_Map.rws'
		subprocess.check_call(['copy', '/Y', os.path.join(environment.contentPath, mapFilename), os.path.join(resourcePath, hashToStr(calcHash(mapFilename)))], shell = True)
	else:
		print 'Converting maps...'
		convertCmiMaps(resourcePath, True)
		
		print 'Copying files...'
		subprocess.check_call(['copy', '/Y', os.path.join(environment.contentPath, 'misc', environment.platform, 'mainmenu.xml'), os.path.join(resourcePath, 'mainmenu.xml')], shell = True)
		subprocess.check_call(['copy', '/Y', os.path.join(environment.contentPath, 'video', environment.platform, 'LogoN.pss'), os.path.join(resourcePath, 'LogoN.pss')], shell = True)
		subprocess.check_call(['copy', '/Y', os.path.join(environment.contentPath, 'video', environment.platform, 'LogoW.pss'), os.path.join(resourcePath, 'LogoW.pss')], shell = True)
		subprocess.check_call(['copy', '/Y', os.path.join(environment.commonContentPath, 'data', environment.platform, 'files.list'), os.path.join(resourcePath, 'files.list')], shell = True)
		
	
	print 'Convering text...'
	convertText(resourcePath)
	
	print 'Generating textures database...'
	textures = allTexturesList(texturesHiera(environment.platform, environment.texturesRootPath), environment.texturesRootPath)
	simplifyCsv(path.join(environment.commonContentPath, 'data', environment.platform, 'textures.csv'), textures.keys(), path.join(resourcePath, 'textures.csv'))

	print 'Converting textures...'
	convertTextures(environment.platform, path.join(environment.commonContentPath, 'data', environment.platform, 'textures.csv'), environment.texturesRootPath, resourcePath, not rebuildTextures)

	print 'Converting images...'
	convertImages(resourcePath)
	
	print 'All resources converted!'
	
def buildPatcher(release = False, compiler = 'vs2008'):
	# TODO: Add ps2 and psp versions support
	
	# Removing files from last building
	print 'Cleanup...'
	patcher.cleanProjectsDir()
	
	# Found path for build tools
	print 'Preparing environment...'
	environment.prepareEnvironment(compiler)

	# Export project fron SVN repo
	patcher.exportPatcherProject()

	# Generate translation resources
	print 'Generating resources...'
	generateResources(os.path.join(environment.patcherResourcesPath, environment.platform), release)
	
	print 'Generating Visual Studio projects files...'
	
	# Generate version and build number
	version = patcher.generateVersion()

	# Generate header with version info
	patcher.generateVersionInfo(version)
	
	# Generate game-specific patch config and copy resources
	patcher.generatePatcherSpec()
	
	# Make Visual Studio makefiles from Qt .pro files
	patcher.createMakefiles(release, compiler)
	
	# Generate qt resources description file
	print "Generating qrc... "
	patcher.generateQrc()
	
	# Compile patcher
	print "Building projects..."
	patcher.buildPatcherProjects()
	
	# Copy and compress patcher file
	print "Preparing file..."
	patcher.preparePatchFile(not release, version)
	
	print "Done!"

################################################

def createParser():
	parser = argparse.ArgumentParser(prog='PROG')
	parser.add_argument('--lang', choices = ['rus', 'pol'], default = 'rus', help = 'Target language')
	parser.add_argument('--platform', choices = ['wii', 'ps2', 'psp'], default = 'wii', help = 'Target platform')
	parser.add_argument('--game', choices = ['shsm', 'origins'], default = 'shsm', help = 'Target game')
	
	subparsers = parser.add_subparsers(dest = 'action')
	
	parser_patcher = subparsers.add_parser('buildPatcher', help = 'Build patcher')
	parser_patcher.add_argument('--compiler', choices = ['vs2008', 'vs2010', 'vs2012', 'vs2013', 'vs2014'], default = 'vs2008', help = 'Compiler for build')
	parser_patcher.add_argument('--release', action = 'store_true', help = 'Release build')

	parser_resources = subparsers.add_parser('buildResources', help='Build resources')
	
	return parser
	
def parseArgs():
	args = createParser().parse_args()
	
	environment.setup(args.lang, args.platform, args.game == 'origins')

	print 'Language-specific content path: ' + environment.contentPath
	print 'Platform specified: ' + environment.platform	
	if args.game == 'origins':
		print 'Silent Hill Origins mode specified'

	return args

def printUsage():
	createParser().print_help()

if __name__ == "__main__":
	args = parseArgs()
	
	if args.action == 'buildResources':
		generateResources(environment.resourcesPath)
	elif args.action == 'buildPatcher':
		buildPatcher(args.release, args.compiler)
	elif action == '':
		printUsage()
	else:
		raise Exception('Invalid action: ' + action)