@[Link("libexif")]
lib LibExif
  struct X_ExifData
    ifd : ExifContent*[5]
    data : UInt8*
    size : LibC::UInt
    priv : ExifDataPrivate
  end

  type ExifData = X_ExifData

  struct X_ExifContent
    entries : ExifEntry**
    count : LibC::UInt
    parent : ExifData*
    priv : ExifContentPrivate
  end

  type ExifContent = X_ExifContent

  struct X_ExifEntry
    tag : ExifTag
    format : ExifFormat
    components : LibC::ULong
    data : UInt8*
    size : LibC::UInt
    parent : ExifContent*
    priv : ExifEntryPrivate
  end

  type ExifEntry = X_ExifEntry
  enum ExifTag
    ExifTagInteroperabilityIndex               =     1
    ExifTagInteroperabilityVersion             =     2
    ExifTagNewSubfileType                      =   254
    ExifTagImageWidth                          =   256
    ExifTagImageLength                         =   257
    ExifTagBitsPerSample                       =   258
    ExifTagCompression                         =   259
    ExifTagPhotometricInterpretation           =   262
    ExifTagFillOrder                           =   266
    ExifTagDocumentName                        =   269
    ExifTagImageDescription                    =   270
    ExifTagMake                                =   271
    ExifTagModel                               =   272
    ExifTagStripOffsets                        =   273
    ExifTagOrientation                         =   274
    ExifTagSamplesPerPixel                     =   277
    ExifTagRowsPerStrip                        =   278
    ExifTagStripByteCounts                     =   279
    ExifTagXResolution                         =   282
    ExifTagYResolution                         =   283
    ExifTagPlanarConfiguration                 =   284
    ExifTagResolutionUnit                      =   296
    ExifTagTransferFunction                    =   301
    ExifTagSoftware                            =   305
    ExifTagDateTime                            =   306
    ExifTagArtist                              =   315
    ExifTagWhitePoint                          =   318
    ExifTagPrimaryChromaticities               =   319
    ExifTagSubIfds                             =   330
    ExifTagTransferRange                       =   342
    ExifTagJpegProc                            =   512
    ExifTagJpegInterchangeFormat               =   513
    ExifTagJpegInterchangeFormatLength         =   514
    ExifTagYcbcrCoefficients                   =   529
    ExifTagYcbcrSubSampling                    =   530
    ExifTagYcbcrPositioning                    =   531
    ExifTagReferenceBlackWhite                 =   532
    ExifTagXmlPacket                           =   700
    ExifTagRelatedImageFileFormat              =  4096
    ExifTagRelatedImageWidth                   =  4097
    ExifTagRelatedImageLength                  =  4098
    ExifTagImageDepth                          = 32997
    ExifTagCfaRepeatPatternDim                 = 33421
    ExifTagCfaPattern                          = 33422
    ExifTagBatteryLevel                        = 33423
    ExifTagCopyright                           = 33432
    ExifTagExposureTime                        = 33434
    ExifTagFnumber                             = 33437
    ExifTagIptcNaa                             = 33723
    ExifTagImageResources                      = 34377
    ExifTagExifIfdPointer                      = 34665
    ExifTagInterColorProfile                   = 34675
    ExifTagExposureProgram                     = 34850
    ExifTagSpectralSensitivity                 = 34852
    ExifTagGpsInfoIfdPointer                   = 34853
    ExifTagIsoSpeedRatings                     = 34855
    ExifTagOecf                                = 34856
    ExifTagTimeZoneOffset                      = 34858
    ExifTagSensitivityType                     = 34864
    ExifTagStandardOutputSensitivity           = 34865
    ExifTagRecommendedExposureIndex            = 34866
    ExifTagIsoSpeed                            = 34867
    ExifTagIsoSpeedLatitudeYyy                 = 34868
    ExifTagIsoSpeedLatitudeZzz                 = 34869
    ExifTagExifVersion                         = 36864
    ExifTagDateTimeOriginal                    = 36867
    ExifTagDateTimeDigitized                   = 36868
    ExifTagOffsetTime                          = 36880
    ExifTagOffsetTimeOriginal                  = 36881
    ExifTagOffsetTimeDigitized                 = 36882
    ExifTagComponentsConfiguration             = 37121
    ExifTagCompressedBitsPerPixel              = 37122
    ExifTagShutterSpeedValue                   = 37377
    ExifTagApertureValue                       = 37378
    ExifTagBrightnessValue                     = 37379
    ExifTagExposureBiasValue                   = 37380
    ExifTagMaxApertureValue                    = 37381
    ExifTagSubjectDistance                     = 37382
    ExifTagMeteringMode                        = 37383
    ExifTagLightSource                         = 37384
    ExifTagFlash                               = 37385
    ExifTagFocalLength                         = 37386
    ExifTagSubjectArea                         = 37396
    ExifTagTiffEpStandardId                    = 37398
    ExifTagMakerNote                           = 37500
    ExifTagUserComment                         = 37510
    ExifTagSubSecTime                          = 37520
    ExifTagSubSecTimeOriginal                  = 37521
    ExifTagSubSecTimeDigitized                 = 37522
    ExifTagXpTitle                             = 40091
    ExifTagXpComment                           = 40092
    ExifTagXpAuthor                            = 40093
    ExifTagXpKeywords                          = 40094
    ExifTagXpSubject                           = 40095
    ExifTagFlashPixVersion                     = 40960
    ExifTagColorSpace                          = 40961
    ExifTagPixelXDimension                     = 40962
    ExifTagPixelYDimension                     = 40963
    ExifTagRelatedSoundFile                    = 40964
    ExifTagInteroperabilityIfdPointer          = 40965
    ExifTagFlashEnergy                         = 41483
    ExifTagSpatialFrequencyResponse            = 41484
    ExifTagFocalPlaneXResolution               = 41486
    ExifTagFocalPlaneYResolution               = 41487
    ExifTagFocalPlaneResolutionUnit            = 41488
    ExifTagSubjectLocation                     = 41492
    ExifTagExposureIndex                       = 41493
    ExifTagSensingMethod                       = 41495
    ExifTagFileSource                          = 41728
    ExifTagSceneType                           = 41729
    ExifTagNewCfaPattern                       = 41730
    ExifTagCustomRendered                      = 41985
    ExifTagExposureMode                        = 41986
    ExifTagWhiteBalance                        = 41987
    ExifTagDigitalZoomRatio                    = 41988
    ExifTagFocalLengthIn35MmFilm               = 41989
    ExifTagSceneCaptureType                    = 41990
    ExifTagGainControl                         = 41991
    ExifTagContrast                            = 41992
    ExifTagSaturation                          = 41993
    ExifTagSharpness                           = 41994
    ExifTagDeviceSettingDescription            = 41995
    ExifTagSubjectDistanceRange                = 41996
    ExifTagImageUniqueId                       = 42016
    ExifTagCameraOwnerName                     = 42032
    ExifTagBodySerialNumber                    = 42033
    ExifTagLensSpecification                   = 42034
    ExifTagLensMake                            = 42035
    ExifTagLensModel                           = 42036
    ExifTagLensSerialNumber                    = 42037
    ExifTagCompositeImage                      = 42080
    ExifTagSourceImageNumberOfCompositeImage   = 42081
    ExifTagSourceExposureTimesOfCompositeImage = 42082
    ExifTagGamma                               = 42240
    ExifTagPrintImageMatching                  = 50341
    ExifTagPadding                             = 59932
  end
  enum ExifFormat
    ExifFormatByte      =  1
    ExifFormatAscii     =  2
    ExifFormatShort     =  3
    ExifFormatLong      =  4
    ExifFormatRational  =  5
    ExifFormatSbyte     =  6
    ExifFormatUndefined =  7
    ExifFormatSshort    =  8
    ExifFormatSlong     =  9
    ExifFormatSrational = 10
    ExifFormatFloat     = 11
    ExifFormatDouble    = 12
  end
  type ExifEntryPrivate = Void*
  type ExifContentPrivate = Void*
  type ExifDataPrivate = Void*
  fun exif_data_new_from_file(path : LibC::Char*) : ExifData*
  fun exif_data_ref(data : ExifData*)
  type ExifMnoteData = Void*
  fun exif_data_get_mnote_data(d : ExifData*) : ExifMnoteData
  alias ExifDataForeachContentFunc = (ExifContent*, Void* -> Void)
  fun exif_data_foreach_content(data : ExifData*, func : ExifDataForeachContentFunc, user_data : Void*)
  fun exif_content_new : ExifContent*
  fun exif_content_get_entry(content : ExifContent*, tag : ExifTag) : ExifEntry*
  fun exif_entry_get_value(entry : ExifEntry*, val : LibC::Char*, maxlen : LibC::UInt) : LibC::Char*
  enum ExifIfd
    ExifIfd0                = 0
    ExifIfd1                = 1
    ExifIfdExif             = 2
    ExifIfdGps              = 3
    ExifIfdInteroperability = 4
    ExifIfdCount            = 5
  end
  fun exif_ifd_get_name(ifd : ExifIfd) : LibC::Char*
  fun exif_mnote_data_ref(x0 : ExifMnoteData)
  type ExifLog = Void*
  fun exif_log_new : ExifLog
  enum ExifLogCode
    ExifLogCodeNone        = 0
    ExifLogCodeDebug       = 1
    ExifLogCodeNoMemory    = 2
    ExifLogCodeCorruptData = 3
  end
  alias X__GnucVaList = LibC::VaList
  alias VaList = X__GnucVaList
  alias ExifLogFunc = (ExifLog, ExifLogCode, LibC::Char*, LibC::Char*, VaList, Void* -> Void)
  fun exif_log_set_func(log : ExifLog, func : ExifLogFunc, data : Void*)
  fun exif_data_new : ExifData*
  fun exif_data_log(data : ExifData*, log : ExifLog)
  fun exif_data_load_data(data : ExifData*, d : UInt8*, size : LibC::UInt)
  fun exif_log_unref(log : ExifLog)
  fun exif_data_free(data : ExifData*)
  type ExifLoader = Void*
  fun exif_loader_new : ExifLoader
  fun exif_loader_write(loader : ExifLoader, buf : UInt8*, sz : LibC::UInt) : UInt8
  fun exif_loader_get_data(loader : ExifLoader) : ExifData*
  fun exif_loader_unref(loader : ExifLoader)
end
