import environment
import subprocess
import os
import glob
import re
import ConfigParser
from datetime import datetime, timedelta

svnRepoPath = 'https://mysvn.ru/consolgames/tools/trunk/';
svnProjectPath = 'game-specific/Shattered Memories/'
svnExportPaths = [
	['Common', svnProjectPath + 'Common'],
	['CommonQt', svnProjectPath + 'CommonQt'],
	['Compression', svnProjectPath + 'Compression'],
	['PatcherLib', svnProjectPath + 'PatcherLib'],
	['StreamParserLib', svnProjectPath + 'StreamParserLib'],
	['Patcher', svnProjectPath + 'Patcher'],
	['Patcher.pro', svnProjectPath + 'Patcher.pro'],
	['ShatteredMemories.pri', svnProjectPath + 'Patcher.pri'],
	['make_vs_patcher_projects.bat', svnProjectPath + 'make_vs_patcher_projects.bat'],
	[os.path.join('externals', 'core'), 'core'],
	[os.path.join('externals', 'WiiStreams'), 'platform-specific/wii/streams'],
	[os.path.join('externals', 'WiiStreams', 'WiiStreams.pro'), svnProjectPath + 'externals/WiiStreams/WiiStreams.pro'],
	[os.path.join('externals', 'zlib'), 'externals/zlib'],
	[os.path.join('externals', 'zlib', 'zlib.pro'), svnProjectPath + 'externals/zlib/zlib.pro'],
]

svnUser = 'svnuser'
svnPass = 'ololopass'

# (major, minor, revision)
def getVersion():
	versionInfoPath = os.path.join(environment.contentPath, 'patcher', 'version')
	versionInfo = open(versionInfoPath, 'r').read().strip()
	m = re.match(r'^(\d+)\.(\d+)([a-zA-Z]*)$', versionInfo)
	return (int(m.group(1)), int(m.group(2)), m.group(3))
	
def cleanProjectsDir():
	if os.path.exists(environment.patcherRootPath):
		subprocess.check_call(['rmdir', environment.patcherRootPath, '/S', '/Q'], shell = True)

def exportPatcherProject():
	for pair in svnExportPaths:
		path = pair[0]
		svnPath = svnRepoPath + pair[1]
		exportPath = os.path.join(environment.patcherRootPath, path)
		print 'SVN export from ', svnPath, 'to', exportPath
		subprocess.check_call(['svn.exe', 'export', '--no-auth-cache', '--force', '-q', '--username', svnUser, '--password', svnPass, svnPath, exportPath])

def generatePatcherSpec():
	config = ConfigParser.ConfigParser()
	config.read(os.path.join(environment.contentPath, 'patcher', 'manifest.ini'))
	
	f = open(os.path.join(environment.patcherRootPath, 'Patcher', 'PatchSpec.h'), 'w')
	f.write('#pragma once\n\n')
	
	for (name, value) in config.items('main'):
		f.write('#define %s "%s"\n' % (name.upper().ljust(16), value))
	f.write('#define PLATFORMS        "%s"\n' % (environment.platform))

	copyDependendFiles()

def copyDependendFiles():
	subprocess.check_call(['copy', '/Y', os.path.join(environment.commonContentPath, 'patcher', 'icon.ico'), os.path.join(environment.patcherProjectPath, 'resources', 'icon.ico')], shell = True)
	subprocess.check_call(['copy', '/Y', os.path.join(environment.commonContentPath, 'patcher', 'watermark.png'), os.path.join(environment.patcherProjectPath, 'resources', 'watermark.png')], shell = True)
	subprocess.check_call(['copy', '/Y', os.path.join(environment.contentPath, 'patcher', 'staff.txt'), os.path.join(environment.patcherProjectPath, 'resources', 'staff.txt')], shell = True)

def generateVersion():
	(verMaj, verMin, rev) = getVersion()

	now = datetime.today().time()
	buildMaj = (datetime.today() - datetime(2010, 1, 1)).days
	buildMin = now.hour * 60 + now.minute
	
	return (verMaj, verMin, buildMaj, buildMin, rev)

def patchBasename():
	suffixMap = {
		'wii': 'Wii',
		'ps2': 'PS2',
		'psp': 'PSP'
	}
	suffix = suffixMap[environment.platform]

	basename = 'SH0Patch' if environment.isOrigins else 'SHSMPatch'
	
	if not environment.isOrigins:
		basename = basename + suffix
		
	return basename

def generateVersionInfo(version):
	(verMaj, verMin, buildMaj, buildMin, revision) = version

	f = open(os.path.join(environment.patcherProjectPath, 'version.h'), 'w')
	
	f.write('#pragma once\n\n')
	f.write('#define VER_MAJOR %d\n' % verMaj)
	f.write('#define VER_MINOR %d\n' % verMin)
	f.write('#define BUILD_MAJOR %d\n' % buildMaj)
	f.write('#define BUILD_MINOR %d\n' % buildMin)
	f.write('#define VER_STAGE "%s"\n\n' % revision)
	f.write('#define VER_FILEVERSION %d,%d,%d,%d\n' % (verMaj, verMin, buildMaj, buildMin))
	f.write('#define VER_FILEVERSION_STR "%d.%d.%d.%d\\0"\n\n' % (verMaj, verMin, buildMaj, buildMin))
	f.write('#define VER_PRODUCTVERSION %d,%d,0,0\n' % (verMaj, verMin))
	f.write('#define VER_PRODUCTVERSION_STR "%d.%d%s\\0"\n\n' % (verMaj, verMin, revision))
	f.write('#define PATCH_FILENAME "%s.exe"\n\n' % patchBasename())
	f.close()

def preparePatchFile(isTestBuild = False, version = [1, 0, 0, 0]):
	postfix = ''
	if isTestBuild:
		postfix = '.%d.%d.%d.%d' % (version[0], version[1], version[2], version[3])
	basename = patchBasename()
	targetName = basename + '.exe'
	archiveName = basename + postfix + '.7z'
	sourcePath = os.path.join(environment.patcherProjectPath, 'release', 'Patcher.exe')
	targetDir = os.path.join(environment.basePath, 'builds')
	if isTestBuild:
		targetDir = os.path.join(targetDir, 'testing')
	else:
		targetDir = os.path.join(targetDir, 'release')
	targetPath = os.path.join(targetDir, targetName)
	targetArchivePath = os.path.join(targetDir, archiveName)	
	
	subprocess.check_call(['copy', '/Y', sourcePath, targetPath], shell = True)
	if os.path.exists(targetArchivePath):
		os.remove(targetArchivePath)
	subprocess.check_call(['7z.exe', 'a', '-mx=9', targetArchivePath, targetPath])
	
def createMakefiles(release = False, vs = 'vs2008'):
	spec = 'win32-msvc' + vs[2:]
	configDependOptions = ['CONFIG+=static external_build', 'DEFINES+=PRODUCTION'] if release else ['CONFIG+=static external_build console', 'DEFINES+=CG_LOG_ENABLED']
	args = ['qmake.exe', '-spec', spec, '-r', 'QMAKE_LFLAGS+=/OPT:REF'] + configDependOptions + ['Patcher.pro']
	print 'Running `%s` from %s...' % (' '.join(args), environment.patcherRootPath)
	subprocess.check_call(args, cwd = environment.patcherRootPath)

def buildPatcherProjects():
	args = ['nmake.exe']
	print 'Running `%s` from %s...' % (' '.join(args), environment.patcherRootPath)
	subprocess.check_call(args, cwd = environment.patcherRootPath)

def writeQrcFileList(dir, qrc, prefix):
	filelist = glob.glob(os.path.join(dir, '*'))
	for f in filelist:
		if os.path.isfile(f):
			f = os.path.basename(f)
			if f != 'readme.txt' and f != 'dummy':
				line = '\t\t<file>' + (prefix + f).replace('&', '&amp;') + '</file>\n'
				qrc.write(line)
		elif os.path.isdir(f):
			writeQrcFileList(f, qrc, prefix + os.path.basename(f) + '/')
	
def generateQrcFile(dir, filename, prefix = ''):
	qrc = open(filename, 'w')
	qrc.write('<!DOCTYPE RCC>\n')
	qrc.write('<RCC version="1.0">\n')
	qrc.write('\t<qresource>\n')
	
	writeQrcFileList(dir, qrc, prefix)	
	
	qrc.write('\t</qresource>\n')
	qrc.write('</RCC>\n')

def generateQrc(resourcesPath = environment.patcherResourcesPath):
	generateQrcFile(resourcesPath, os.path.join(environment.patcherProjectPath, 'patchdata.qrc'), 'patchdata/')

	