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
  fun exif_data_new : ExifData*
  type ExifMem = Void*
  fun exif_data_new_mem(x0 : ExifMem) : ExifData*
  fun exif_data_new_from_file(path : LibC::Char*) : ExifData*
  fun exif_data_new_from_data(data : UInt8*, size : LibC::UInt) : ExifData*
  fun exif_data_load_data(data : ExifData*, d : UInt8*, size : LibC::UInt)
  fun exif_data_save_data(data : ExifData*, d : UInt8**, ds : LibC::UInt*)
  enum ExifByteOrder
    ExifByteOrderMotorola = 0
    ExifByteOrderIntel    = 1
  end
  fun exif_data_get_byte_order(data : ExifData*) : ExifByteOrder
  fun exif_data_set_byte_order(data : ExifData*, order : ExifByteOrder)
  fun exif_data_ref(data : ExifData*)
  fun exif_data_unref(data : ExifData*)
  fun exif_data_free(data : ExifData*)
  type ExifMnoteData = Void*
  fun exif_data_get_mnote_data(d : ExifData*) : ExifMnoteData
  fun exif_data_fix(d : ExifData*)
  alias ExifDataForeachContentFunc = (ExifContent*, Void* -> Void)
  fun exif_data_foreach_content(data : ExifData*, func : ExifDataForeachContentFunc, user_data : Void*)
  enum ExifDataOption
    ExifDataOptionIgnoreUnknownTags   = 1
    ExifDataOptionFollowSpecification = 2
    ExifDataOptionDontChangeMakerNote = 4
  end
  fun exif_data_option_get_name(o : ExifDataOption) : LibC::Char*
  fun exif_data_option_get_description(o : ExifDataOption) : LibC::Char*
  fun exif_data_set_option(d : ExifData*, o : ExifDataOption)
  fun exif_data_unset_option(d : ExifData*, o : ExifDataOption)
  enum ExifDataType
    ExifDataTypeUncompressedChunky = 0
    ExifDataTypeUncompressedPlanar = 1
    ExifDataTypeUncompressedYcc    = 2
    ExifDataTypeCompressed         = 3
    ExifDataTypeCount              = 4
    ExifDataTypeUnknown            = 4
  end
  fun exif_data_set_data_type(d : ExifData*, dt : ExifDataType)
  fun exif_data_get_data_type(d : ExifData*) : ExifDataType
  fun exif_data_dump(data : ExifData*)
  type ExifLog = Void*
  fun exif_data_log(data : ExifData*, log : ExifLog)
  fun exif_mnote_data_ref(x0 : ExifMnoteData)
  fun exif_mnote_data_unref(x0 : ExifMnoteData)
  fun exif_mnote_data_load(d : ExifMnoteData, buf : UInt8*, buf_size : LibC::UInt)
  fun exif_mnote_data_count(d : ExifMnoteData) : LibC::UInt
  fun exif_mnote_data_get_id(d : ExifMnoteData, n : LibC::UInt) : LibC::UInt
  fun exif_mnote_data_get_name(d : ExifMnoteData, n : LibC::UInt) : LibC::Char*
  fun exif_mnote_data_get_title(d : ExifMnoteData, n : LibC::UInt) : LibC::Char*
  fun exif_mnote_data_get_description(d : ExifMnoteData, n : LibC::UInt) : LibC::Char*
  fun exif_mnote_data_get_value(d : ExifMnoteData, n : LibC::UInt, val : LibC::Char*, maxlen : LibC::UInt) : LibC::Char*
  fun exif_content_new : ExifContent*
  fun exif_content_new_mem(x0 : ExifMem) : ExifContent*
  fun exif_content_ref(content : ExifContent*)
  fun exif_content_unref(content : ExifContent*)
  fun exif_content_free(content : ExifContent*)
  fun exif_content_add_entry(c : ExifContent*, entry : ExifEntry*)
  fun exif_content_remove_entry(c : ExifContent*, e : ExifEntry*)
  fun exif_content_get_entry(content : ExifContent*, tag : ExifTag) : ExifEntry*
  fun exif_content_fix(c : ExifContent*)
  alias ExifContentForeachEntryFunc = (ExifEntry*, Void* -> Void)
  fun exif_content_foreach_entry(content : ExifContent*, func : ExifContentForeachEntryFunc, user_data : Void*)
  enum ExifIfd
    ExifIfd0                = 0
    ExifIfd1                = 1
    ExifIfdExif             = 2
    ExifIfdGps              = 3
    ExifIfdInteroperability = 4
    ExifIfdCount            = 5
  end
  fun exif_content_get_ifd(c : ExifContent*) : ExifIfd
  fun exif_content_dump(content : ExifContent*, indent : LibC::UInt)
  fun exif_content_log(content : ExifContent*, log : ExifLog)
  fun exif_entry_new : ExifEntry*
  fun exif_entry_new_mem(x0 : ExifMem) : ExifEntry*
  fun exif_entry_ref(entry : ExifEntry*)
  fun exif_entry_unref(entry : ExifEntry*)
  fun exif_entry_free(entry : ExifEntry*)
  fun exif_entry_initialize(e : ExifEntry*, tag : ExifTag)
  fun exif_entry_fix(entry : ExifEntry*)
  fun exif_entry_get_value(entry : ExifEntry*, val : LibC::Char*, maxlen : LibC::UInt) : LibC::Char*
  fun exif_entry_dump(entry : ExifEntry*, indent : LibC::UInt)
  fun exif_ifd_get_name(ifd : ExifIfd) : LibC::Char*
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
  fun exif_log_unref(log : ExifLog)
  type ExifLoader = Void*
  fun exif_loader_new : ExifLoader
  fun exif_loader_write(loader : ExifLoader, buf : UInt8*, sz : LibC::UInt) : UInt8
  fun exif_loader_get_data(loader : ExifLoader) : ExifData*
  fun exif_loader_unref(loader : ExifLoader)
end
