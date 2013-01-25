unit DXConsts;

interface

resourcestring
  SNone = '(None)';
  SUnknownError = 'Unknown Error (%d)';

  SDirectDraw = 'DirectDraw';
  SDirect3DRM = 'Direct3D RetainedMode';
  SDirectSound = 'DirectSound';
  SDirectSoundCapture = 'DirectSoundCapture';
  SDirectDrawClipper = 'Clipper';
  SDirectDrawPalette = 'Palette';
  SDirectDrawSurface = 'Surface';
  SDirectDrawPrimarySurface = 'Primary surface';
  SDirectSoundBuffer = 'Sound Buffer';
  SDirectSoundPrimaryBuffer = 'Primary Sound Buffer';
  SDirectSoundCaptureBuffer = 'Sound Capture Buffer';
  STexture = 'Texture';
  SDirectPlay = 'DirectPlay';
  SOverlay = 'Overlay';

  SNotMade = '%s not created.';
  SStreamNotOpend = 'Stream not opened.';
  SWaveStreamNotSet = 'Unable to set wave stream.';
  SCannotMade = 'Unable to create %s.';
  SCannotInitialized = 'Unable to initialize %s.';
  SCannotChanged = 'Unable to change %s.';
  SCannotLock = 'Unable to lock %s.';
  SCannotOpened = 'Unable to open %s.';
  SCannotLoadGraphic = 'Unable to load "%s".';
  SCannotLoadGraphicFile = 'Unable to load file "%s".';

  SDLLNotLoaded = 'Library "%s" not loaded.';
  SImageNotFound = 'Image "%s" not found.';
  SWaveNotFound = 'Wave "%s" not found.';
  SEffectNotFound = 'Effect "%s" not found.';
  SListIndexError = 'List index out of bounds (%d)';
  SScanline = 'Scanline index out of bounds (%d)';
  SNoForm = 'Form not found';
  SSinceDirectX5 = 'DirectX 5 required.';
  SSinceDirectX6 = 'DirectX 6 required.';
  SSinceDirectX7 = 'DirectX 7 required.';
  S3DDeviceNotFound = '3D Device not found.';
  SDisplayModeChange = 'Unable to set display mode (%dx%d %dbit)';
  SDisplayModeCannotAcquired = 'Unknown display mode.';
  SInvalidDIB = 'Invalid DIB.';
  SInvalidDIBBitCount = 'Invalid DIB bit count (%d).';
  SInvalidDIBPixelFormat = 'Invalid DIB pixel format.';
  SInvalidBitCountOfResult = 'Invalid resulting bit count.';
  SInvalidWave = 'Invalid wave.';
  SInvalidDisplayBitCount = 'Invalid bit count.';
  SInvalidWaveFormat = 'Invalid wave format.';
  SNotSupported = '%s not supported.';
  SStreamOpend = 'Stream is already opened.';
  SNecessaryDirectInputUseMouse = 'You need a mouse to use DirectInput.';
  SSetOwnerDXDrawError = 'DXDraw Owner Setup Error.';

  SNotSupportGraphicFile = 'Invalid graphic file.';
  SInvalidDXTFile = 'Invalid DXT file.';


  {  DirectPlay  }
  SDXPlayNotConnectedNow = 'TDXPlay not installed.';
  SDXPlayProviderNotFound = 'Provider "%s" not found.';
  SDXPlayProviderSpecifiedGUIDNotFound = 'Provider specified GUID not found.';
  SDXPlayModemListCannotBeAcquired = 'Unable to acquire modem list.';
  SDXPlaySessionListCannotBeAcquired = 'Unable to aquire session list.';
  SDXPlaySessionNotFound = 'Session "%s" not found.';
  SDXPlaySessionCannotOpened = 'Unable to open session "%s".';
  SDXPlayPlayerNotFound = 'Player ID not found.';
  SDXPlayMessageIllegal = 'Illegal message.';
  SDXPlayPlayerNameIsNotSpecified = 'Player name is not specified.';
  SDXPlaySessionNameIsNotSpecified = 'Session name is not specified.';

  DXPlayFormNext = 'Next';
  DXPlayFormComplete = 'Complete';

const
  SDIBSize = '(%dx%d)';
  SDIBColor = '%d color';
  SDIBBitSize = '%d bytes';
  SDIBBitSize_K = '%d Kb';

const
  SWaveLength = '%.4g seconds';
  SWaveFrequency = '%dHz';
  SWaveBitCount = '%d bits';
  SWaveMono = 'Mono';
  SWaveStereo = 'Stereo';
  SWaveSize = '%d bytes';

const
  SKeyLeft = 'Left';
  SKeyUp = 'Up';
  SKeyRight = 'Right';
  SKeyDown = 'Down';

const
  SFFBEffectEditor = 'Effect %s editor.';

implementation

end.
