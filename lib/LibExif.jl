module LibExif

using libexif_jll
export libexif_jll

@enum ExifByteOrder::UInt32 begin
    EXIF_BYTE_ORDER_MOTOROLA = 0
    EXIF_BYTE_ORDER_INTEL = 1
end

function exif_byte_order_get_name(order)
    ccall((:exif_byte_order_get_name, libexif), Ptr{Cchar}, (ExifByteOrder,), order)
end

mutable struct _ExifContentPrivate end

const ExifContentPrivate = _ExifContentPrivate

struct _ExifContent
    entries::Ptr{Ptr{Cvoid}} # entries::Ptr{Ptr{ExifEntry}}
    count::Cuint
    parent::Ptr{Cvoid} # parent::Ptr{ExifData}
    priv::Ptr{ExifContentPrivate}
end

function Base.getproperty(x::_ExifContent, f::Symbol)
    f === :entries && return Ptr{Ptr{ExifEntry}}(getfield(x, f))
    f === :parent && return Ptr{ExifData}(getfield(x, f))
    return getfield(x, f)
end

const ExifContent = _ExifContent

@enum ExifTag::UInt32 begin
    EXIF_TAG_INTEROPERABILITY_INDEX = 1
    EXIF_TAG_INTEROPERABILITY_VERSION = 2
    EXIF_TAG_NEW_SUBFILE_TYPE = 254
    EXIF_TAG_IMAGE_WIDTH = 256
    EXIF_TAG_IMAGE_LENGTH = 257
    EXIF_TAG_BITS_PER_SAMPLE = 258
    EXIF_TAG_COMPRESSION = 259
    EXIF_TAG_PHOTOMETRIC_INTERPRETATION = 262
    EXIF_TAG_FILL_ORDER = 266
    EXIF_TAG_DOCUMENT_NAME = 269
    EXIF_TAG_IMAGE_DESCRIPTION = 270
    EXIF_TAG_MAKE = 271
    EXIF_TAG_MODEL = 272
    EXIF_TAG_STRIP_OFFSETS = 273
    EXIF_TAG_ORIENTATION = 274
    EXIF_TAG_SAMPLES_PER_PIXEL = 277
    EXIF_TAG_ROWS_PER_STRIP = 278
    EXIF_TAG_STRIP_BYTE_COUNTS = 279
    EXIF_TAG_X_RESOLUTION = 282
    EXIF_TAG_Y_RESOLUTION = 283
    EXIF_TAG_PLANAR_CONFIGURATION = 284
    EXIF_TAG_RESOLUTION_UNIT = 296
    EXIF_TAG_TRANSFER_FUNCTION = 301
    EXIF_TAG_SOFTWARE = 305
    EXIF_TAG_DATE_TIME = 306
    EXIF_TAG_ARTIST = 315
    EXIF_TAG_WHITE_POINT = 318
    EXIF_TAG_PRIMARY_CHROMATICITIES = 319
    EXIF_TAG_SUB_IFDS = 330
    EXIF_TAG_TRANSFER_RANGE = 342
    EXIF_TAG_JPEG_PROC = 512
    EXIF_TAG_JPEG_INTERCHANGE_FORMAT = 513
    EXIF_TAG_JPEG_INTERCHANGE_FORMAT_LENGTH = 514
    EXIF_TAG_YCBCR_COEFFICIENTS = 529
    EXIF_TAG_YCBCR_SUB_SAMPLING = 530
    EXIF_TAG_YCBCR_POSITIONING = 531
    EXIF_TAG_REFERENCE_BLACK_WHITE = 532
    EXIF_TAG_XML_PACKET = 700
    EXIF_TAG_RELATED_IMAGE_FILE_FORMAT = 4096
    EXIF_TAG_RELATED_IMAGE_WIDTH = 4097
    EXIF_TAG_RELATED_IMAGE_LENGTH = 4098
    EXIF_TAG_CFA_REPEAT_PATTERN_DIM = 33421
    EXIF_TAG_CFA_PATTERN = 33422
    EXIF_TAG_BATTERY_LEVEL = 33423
    EXIF_TAG_COPYRIGHT = 33432
    EXIF_TAG_EXPOSURE_TIME = 33434
    EXIF_TAG_FNUMBER = 33437
    EXIF_TAG_IPTC_NAA = 33723
    EXIF_TAG_IMAGE_RESOURCES = 34377
    EXIF_TAG_EXIF_IFD_POINTER = 34665
    EXIF_TAG_INTER_COLOR_PROFILE = 34675
    EXIF_TAG_EXPOSURE_PROGRAM = 34850
    EXIF_TAG_SPECTRAL_SENSITIVITY = 34852
    EXIF_TAG_GPS_INFO_IFD_POINTER = 34853
    EXIF_TAG_ISO_SPEED_RATINGS = 34855
    EXIF_TAG_OECF = 34856
    EXIF_TAG_TIME_ZONE_OFFSET = 34858
    EXIF_TAG_EXIF_VERSION = 36864
    EXIF_TAG_DATE_TIME_ORIGINAL = 36867
    EXIF_TAG_DATE_TIME_DIGITIZED = 36868
    EXIF_TAG_COMPONENTS_CONFIGURATION = 37121
    EXIF_TAG_COMPRESSED_BITS_PER_PIXEL = 37122
    EXIF_TAG_SHUTTER_SPEED_VALUE = 37377
    EXIF_TAG_APERTURE_VALUE = 37378
    EXIF_TAG_BRIGHTNESS_VALUE = 37379
    EXIF_TAG_EXPOSURE_BIAS_VALUE = 37380
    EXIF_TAG_MAX_APERTURE_VALUE = 37381
    EXIF_TAG_SUBJECT_DISTANCE = 37382
    EXIF_TAG_METERING_MODE = 37383
    EXIF_TAG_LIGHT_SOURCE = 37384
    EXIF_TAG_FLASH = 37385
    EXIF_TAG_FOCAL_LENGTH = 37386
    EXIF_TAG_SUBJECT_AREA = 37396
    EXIF_TAG_TIFF_EP_STANDARD_ID = 37398
    EXIF_TAG_MAKER_NOTE = 37500
    EXIF_TAG_USER_COMMENT = 37510
    EXIF_TAG_SUB_SEC_TIME = 37520
    EXIF_TAG_SUB_SEC_TIME_ORIGINAL = 37521
    EXIF_TAG_SUB_SEC_TIME_DIGITIZED = 37522
    EXIF_TAG_XP_TITLE = 40091
    EXIF_TAG_XP_COMMENT = 40092
    EXIF_TAG_XP_AUTHOR = 40093
    EXIF_TAG_XP_KEYWORDS = 40094
    EXIF_TAG_XP_SUBJECT = 40095
    EXIF_TAG_FLASH_PIX_VERSION = 40960
    EXIF_TAG_COLOR_SPACE = 40961
    EXIF_TAG_PIXEL_X_DIMENSION = 40962
    EXIF_TAG_PIXEL_Y_DIMENSION = 40963
    EXIF_TAG_RELATED_SOUND_FILE = 40964
    EXIF_TAG_INTEROPERABILITY_IFD_POINTER = 40965
    EXIF_TAG_FLASH_ENERGY = 41483
    EXIF_TAG_SPATIAL_FREQUENCY_RESPONSE = 41484
    EXIF_TAG_FOCAL_PLANE_X_RESOLUTION = 41486
    EXIF_TAG_FOCAL_PLANE_Y_RESOLUTION = 41487
    EXIF_TAG_FOCAL_PLANE_RESOLUTION_UNIT = 41488
    EXIF_TAG_SUBJECT_LOCATION = 41492
    EXIF_TAG_EXPOSURE_INDEX = 41493
    EXIF_TAG_SENSING_METHOD = 41495
    EXIF_TAG_FILE_SOURCE = 41728
    EXIF_TAG_SCENE_TYPE = 41729
    EXIF_TAG_NEW_CFA_PATTERN = 41730
    EXIF_TAG_CUSTOM_RENDERED = 41985
    EXIF_TAG_EXPOSURE_MODE = 41986
    EXIF_TAG_WHITE_BALANCE = 41987
    EXIF_TAG_DIGITAL_ZOOM_RATIO = 41988
    EXIF_TAG_FOCAL_LENGTH_IN_35MM_FILM = 41989
    EXIF_TAG_SCENE_CAPTURE_TYPE = 41990
    EXIF_TAG_GAIN_CONTROL = 41991
    EXIF_TAG_CONTRAST = 41992
    EXIF_TAG_SATURATION = 41993
    EXIF_TAG_SHARPNESS = 41994
    EXIF_TAG_DEVICE_SETTING_DESCRIPTION = 41995
    EXIF_TAG_SUBJECT_DISTANCE_RANGE = 41996
    EXIF_TAG_IMAGE_UNIQUE_ID = 42016
    EXIF_TAG_GAMMA = 42240
    EXIF_TAG_PRINT_IMAGE_MATCHING = 50341
    EXIF_TAG_PADDING = 59932
end

@enum ExifFormat::UInt32 begin
    EXIF_FORMAT_BYTE = 1
    EXIF_FORMAT_ASCII = 2
    EXIF_FORMAT_SHORT = 3
    EXIF_FORMAT_LONG = 4
    EXIF_FORMAT_RATIONAL = 5
    EXIF_FORMAT_SBYTE = 6
    EXIF_FORMAT_UNDEFINED = 7
    EXIF_FORMAT_SSHORT = 8
    EXIF_FORMAT_SLONG = 9
    EXIF_FORMAT_SRATIONAL = 10
    EXIF_FORMAT_FLOAT = 11
    EXIF_FORMAT_DOUBLE = 12
end

mutable struct _ExifEntryPrivate end

const ExifEntryPrivate = _ExifEntryPrivate

mutable struct _ExifEntry
    tag::ExifTag
    format::ExifFormat
    components::Culong
    data::Ptr{Cuchar}
    size::Cuint
    parent::Ptr{ExifContent}
    priv::Ptr{ExifEntryPrivate}
end

function Base.getproperty(x::Ptr{_ExifEntry}, f::Symbol)
    f === :tag && return Ptr{ExifTag}(x + 0)
    f === :format && return Ptr{ExifFormat}(x + 4)
    f === :components && return Ptr{Culong}(x + 8)
    f === :data && return Ptr{Ptr{Cuchar}}(x + 16)
    f === :size && return Ptr{Cuint}(x + 24)
    f === :parent && return Ptr{Ptr{ExifContent}}(x + 32)
    f === :priv && return Ptr{Ptr{ExifEntryPrivate}}(x + 40)
    return getfield(x, f)
end

function Base.setproperty!(x::Ptr{_ExifEntry}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const ExifEntry = _ExifEntry

function exif_content_get_entry(content, tag)
    ccall((:exif_content_get_entry, libexif), Ptr{ExifEntry}, (Ptr{ExifContent}, ExifTag), content, tag)
end

function exif_entry_get_value(entry, val, maxlen)
    ccall((:exif_entry_get_value, libexif), Ptr{Cchar}, (Ptr{ExifEntry}, Ptr{Cchar}, Cuint), entry, val, maxlen)
end

function exif_content_new()
    ccall((:exif_content_new, libexif), Ptr{ExifContent}, ())
end

mutable struct _ExifMem end

const ExifMem = _ExifMem

function exif_content_new_mem(arg1)
    ccall((:exif_content_new_mem, libexif), Ptr{ExifContent}, (Ptr{ExifMem},), arg1)
end

function exif_content_ref(content)
    ccall((:exif_content_ref, libexif), Cvoid, (Ptr{ExifContent},), content)
end

function exif_content_unref(content)
    ccall((:exif_content_unref, libexif), Cvoid, (Ptr{ExifContent},), content)
end

function exif_content_free(content)
    ccall((:exif_content_free, libexif), Cvoid, (Ptr{ExifContent},), content)
end

function exif_content_add_entry(c, entry)
    ccall((:exif_content_add_entry, libexif), Cvoid, (Ptr{ExifContent}, Ptr{ExifEntry}), c, entry)
end

function exif_content_remove_entry(c, e)
    ccall((:exif_content_remove_entry, libexif), Cvoid, (Ptr{ExifContent}, Ptr{ExifEntry}), c, e)
end

function exif_content_fix(c)
    ccall((:exif_content_fix, libexif), Cvoid, (Ptr{ExifContent},), c)
end

# typedef void ( * ExifContentForeachEntryFunc ) ( ExifEntry * , void * user_data )
const ExifContentForeachEntryFunc = Ptr{Cvoid}

function exif_content_foreach_entry(content, func, user_data)
    ccall((:exif_content_foreach_entry, libexif), Cvoid, (Ptr{ExifContent}, ExifContentForeachEntryFunc, Ptr{Cvoid}), content, func, user_data)
end

@enum ExifIfd::UInt32 begin
    EXIF_IFD_0 = 0
    EXIF_IFD_1 = 1
    EXIF_IFD_EXIF = 2
    EXIF_IFD_GPS = 3
    EXIF_IFD_INTEROPERABILITY = 4
    EXIF_IFD_COUNT = 5
end

function exif_content_get_ifd(c)
    ccall((:exif_content_get_ifd, libexif), ExifIfd, (Ptr{ExifContent},), c)
end

function exif_content_dump(content, indent)
    ccall((:exif_content_dump, libexif), Cvoid, (Ptr{ExifContent}, Cuint), content, indent)
end

mutable struct _ExifLog end

const ExifLog = _ExifLog

function exif_content_log(content, log)
    ccall((:exif_content_log, libexif), Cvoid, (Ptr{ExifContent}, Ptr{ExifLog}), content, log)
end

@enum ExifDataType::UInt32 begin
    EXIF_DATA_TYPE_UNCOMPRESSED_CHUNKY = 0
    EXIF_DATA_TYPE_UNCOMPRESSED_PLANAR = 1
    EXIF_DATA_TYPE_UNCOMPRESSED_YCC = 2
    EXIF_DATA_TYPE_COMPRESSED = 3
    EXIF_DATA_TYPE_COUNT = 4
    # EXIF_DATA_TYPE_UNKNOWN = 4
end

mutable struct _ExifDataPrivate end

const ExifDataPrivate = _ExifDataPrivate

struct _ExifData
    ifd::NTuple{5, Ptr{ExifContent}}
    data::Ptr{Cuchar}
    size::Cuint
    priv::Ptr{ExifDataPrivate}
end

const ExifData = _ExifData

function exif_data_new()
    ccall((:exif_data_new, libexif), Ptr{ExifData}, ())
end

function exif_data_new_mem(arg1)
    ccall((:exif_data_new_mem, libexif), Ptr{ExifData}, (Ptr{ExifMem},), arg1)
end

function exif_data_new_from_file(path)
    ccall((:exif_data_new_from_file, libexif), Ptr{ExifData}, (Ptr{Cchar},), path)
end

function exif_data_new_from_data(data, size)
    ccall((:exif_data_new_from_data, libexif), Ptr{ExifData}, (Ptr{Cuchar}, Cuint), data, size)
end

function exif_data_load_data(data, d, size)
    ccall((:exif_data_load_data, libexif), Cvoid, (Ptr{ExifData}, Ptr{Cuchar}, Cuint), data, d, size)
end

function exif_data_save_data(data, d, ds)
    ccall((:exif_data_save_data, libexif), Cvoid, (Ptr{ExifData}, Ptr{Ptr{Cuchar}}, Ptr{Cuint}), data, d, ds)
end

function exif_data_ref(data)
    ccall((:exif_data_ref, libexif), Cvoid, (Ptr{ExifData},), data)
end

function exif_data_unref(data)
    ccall((:exif_data_unref, libexif), Cvoid, (Ptr{ExifData},), data)
end

function exif_data_free(data)
    ccall((:exif_data_free, libexif), Cvoid, (Ptr{ExifData},), data)
end

function exif_data_get_byte_order(data)
    ccall((:exif_data_get_byte_order, libexif), ExifByteOrder, (Ptr{ExifData},), data)
end

function exif_data_set_byte_order(data, order)
    ccall((:exif_data_set_byte_order, libexif), Cvoid, (Ptr{ExifData}, ExifByteOrder), data, order)
end

mutable struct _ExifMnoteDataPriv end

const ExifMnoteDataPriv = _ExifMnoteDataPriv

struct _ExifMnoteDataMethods
    free::Ptr{Cvoid}
    save::Ptr{Cvoid}
    load::Ptr{Cvoid}
    set_offset::Ptr{Cvoid}
    set_byte_order::Ptr{Cvoid}
    count::Ptr{Cvoid}
    get_id::Ptr{Cvoid}
    get_name::Ptr{Cvoid}
    get_title::Ptr{Cvoid}
    get_description::Ptr{Cvoid}
    get_value::Ptr{Cvoid}
end

const ExifMnoteDataMethods = _ExifMnoteDataMethods

struct _ExifMnoteData
    priv::Ptr{ExifMnoteDataPriv}
    methods::ExifMnoteDataMethods
    log::Ptr{ExifLog}
    mem::Ptr{ExifMem}
end

const ExifMnoteData = _ExifMnoteData

function exif_data_get_mnote_data(d)
    ccall((:exif_data_get_mnote_data, libexif), Ptr{ExifMnoteData}, (Ptr{ExifData},), d)
end

function exif_data_fix(d)
    ccall((:exif_data_fix, libexif), Cvoid, (Ptr{ExifData},), d)
end

# typedef void ( * ExifDataForeachContentFunc ) ( ExifContent * , void * user_data )
const ExifDataForeachContentFunc = Ptr{Cvoid}

function exif_data_foreach_content(data, func, user_data)
    ccall((:exif_data_foreach_content, libexif), Cvoid, (Ptr{ExifData}, ExifDataForeachContentFunc, Ptr{Cvoid}), data, func, user_data)
end

@enum ExifDataOption::UInt32 begin
    EXIF_DATA_OPTION_IGNORE_UNKNOWN_TAGS = 1
    EXIF_DATA_OPTION_FOLLOW_SPECIFICATION = 2
    EXIF_DATA_OPTION_DONT_CHANGE_MAKER_NOTE = 4
end

function exif_data_option_get_name(o)
    ccall((:exif_data_option_get_name, libexif), Ptr{Cchar}, (ExifDataOption,), o)
end

function exif_data_option_get_description(o)
    ccall((:exif_data_option_get_description, libexif), Ptr{Cchar}, (ExifDataOption,), o)
end

function exif_data_set_option(d, o)
    ccall((:exif_data_set_option, libexif), Cvoid, (Ptr{ExifData}, ExifDataOption), d, o)
end

function exif_data_unset_option(d, o)
    ccall((:exif_data_unset_option, libexif), Cvoid, (Ptr{ExifData}, ExifDataOption), d, o)
end

function exif_data_set_data_type(d, dt)
    ccall((:exif_data_set_data_type, libexif), Cvoid, (Ptr{ExifData}, ExifDataType), d, dt)
end

function exif_data_get_data_type(d)
    ccall((:exif_data_get_data_type, libexif), ExifDataType, (Ptr{ExifData},), d)
end

function exif_data_dump(data)
    ccall((:exif_data_dump, libexif), Cvoid, (Ptr{ExifData},), data)
end

function exif_data_log(data, log)
    ccall((:exif_data_log, libexif), Cvoid, (Ptr{ExifData}, Ptr{ExifLog}), data, log)
end

function exif_entry_new()
    ccall((:exif_entry_new, libexif), Ptr{ExifEntry}, ())
end

function exif_entry_new_mem(arg1)
    ccall((:exif_entry_new_mem, libexif), Ptr{ExifEntry}, (Ptr{ExifMem},), arg1)
end

function exif_entry_ref(entry)
    ccall((:exif_entry_ref, libexif), Cvoid, (Ptr{ExifEntry},), entry)
end

function exif_entry_unref(entry)
    ccall((:exif_entry_unref, libexif), Cvoid, (Ptr{ExifEntry},), entry)
end

function exif_entry_free(entry)
    ccall((:exif_entry_free, libexif), Cvoid, (Ptr{ExifEntry},), entry)
end

function exif_entry_initialize(e, tag)
    ccall((:exif_entry_initialize, libexif), Cvoid, (Ptr{ExifEntry}, ExifTag), e, tag)
end

function exif_entry_fix(entry)
    ccall((:exif_entry_fix, libexif), Cvoid, (Ptr{ExifEntry},), entry)
end

function exif_entry_dump(entry, indent)
    ccall((:exif_entry_dump, libexif), Cvoid, (Ptr{ExifEntry}, Cuint), entry, indent)
end

function exif_format_get_name(format)
    ccall((:exif_format_get_name, libexif), Ptr{Cchar}, (ExifFormat,), format)
end

function exif_format_get_size(format)
    ccall((:exif_format_get_size, libexif), Cuchar, (ExifFormat,), format)
end

function exif_ifd_get_name(ifd)
    ccall((:exif_ifd_get_name, libexif), Ptr{Cchar}, (ExifIfd,), ifd)
end

mutable struct _ExifLoader end

const ExifLoader = _ExifLoader

function exif_loader_new()
    ccall((:exif_loader_new, libexif), Ptr{ExifLoader}, ())
end

function exif_loader_new_mem(mem)
    ccall((:exif_loader_new_mem, libexif), Ptr{ExifLoader}, (Ptr{ExifMem},), mem)
end

function exif_loader_ref(loader)
    ccall((:exif_loader_ref, libexif), Cvoid, (Ptr{ExifLoader},), loader)
end

function exif_loader_unref(loader)
    ccall((:exif_loader_unref, libexif), Cvoid, (Ptr{ExifLoader},), loader)
end

function exif_loader_write_file(loader, fname)
    ccall((:exif_loader_write_file, libexif), Cvoid, (Ptr{ExifLoader}, Ptr{Cchar}), loader, fname)
end

function exif_loader_write(loader, buf, sz)
    ccall((:exif_loader_write, libexif), Cuchar, (Ptr{ExifLoader}, Ptr{Cuchar}, Cuint), loader, buf, sz)
end

function exif_loader_reset(loader)
    ccall((:exif_loader_reset, libexif), Cvoid, (Ptr{ExifLoader},), loader)
end

function exif_loader_get_data(loader)
    ccall((:exif_loader_get_data, libexif), Ptr{ExifData}, (Ptr{ExifLoader},), loader)
end

function exif_loader_get_buf(loader, buf, buf_size)
    ccall((:exif_loader_get_buf, libexif), Cvoid, (Ptr{ExifLoader}, Ptr{Ptr{Cuchar}}, Ptr{Cuint}), loader, buf, buf_size)
end

function exif_loader_log(loader, log)
    ccall((:exif_loader_log, libexif), Cvoid, (Ptr{ExifLoader}, Ptr{ExifLog}), loader, log)
end

function exif_log_new()
    ccall((:exif_log_new, libexif), Ptr{ExifLog}, ())
end

function exif_log_new_mem(arg1)
    ccall((:exif_log_new_mem, libexif), Ptr{ExifLog}, (Ptr{ExifMem},), arg1)
end

function exif_log_ref(log)
    ccall((:exif_log_ref, libexif), Cvoid, (Ptr{ExifLog},), log)
end

function exif_log_unref(log)
    ccall((:exif_log_unref, libexif), Cvoid, (Ptr{ExifLog},), log)
end

function exif_log_free(log)
    ccall((:exif_log_free, libexif), Cvoid, (Ptr{ExifLog},), log)
end

@enum ExifLogCode::UInt32 begin
    EXIF_LOG_CODE_NONE = 0
    EXIF_LOG_CODE_DEBUG = 1
    EXIF_LOG_CODE_NO_MEMORY = 2
    EXIF_LOG_CODE_CORRUPT_DATA = 3
end

function exif_log_code_get_title(code)
    ccall((:exif_log_code_get_title, libexif), Ptr{Cchar}, (ExifLogCode,), code)
end

function exif_log_code_get_message(code)
    ccall((:exif_log_code_get_message, libexif), Ptr{Cchar}, (ExifLogCode,), code)
end

# typedef void ( * ExifLogFunc ) ( ExifLog * log , ExifLogCode , const char * domain , const char * format , va_list args , void * data )
const ExifLogFunc = Ptr{Cvoid}

function exif_log_set_func(log, func, data)
    ccall((:exif_log_set_func, libexif), Cvoid, (Ptr{ExifLog}, ExifLogFunc, Ptr{Cvoid}), log, func, data)
end

# typedef void * ( * ExifMemAllocFunc ) ( ExifLong s )
const ExifMemAllocFunc = Ptr{Cvoid}

# typedef void * ( * ExifMemReallocFunc ) ( void * p , ExifLong s )
const ExifMemReallocFunc = Ptr{Cvoid}

# typedef void ( * ExifMemFreeFunc ) ( void * p )
const ExifMemFreeFunc = Ptr{Cvoid}

function exif_mem_new(a, r, f)
    ccall((:exif_mem_new, libexif), Ptr{ExifMem}, (ExifMemAllocFunc, ExifMemReallocFunc, ExifMemFreeFunc), a, r, f)
end

function exif_mem_ref(arg1)
    ccall((:exif_mem_ref, libexif), Cvoid, (Ptr{ExifMem},), arg1)
end

function exif_mem_unref(arg1)
    ccall((:exif_mem_unref, libexif), Cvoid, (Ptr{ExifMem},), arg1)
end

const ExifLong = UInt32

function exif_mem_alloc(m, s)
    ccall((:exif_mem_alloc, libexif), Ptr{Cvoid}, (Ptr{ExifMem}, ExifLong), m, s)
end

function exif_mem_realloc(m, p, s)
    ccall((:exif_mem_realloc, libexif), Ptr{Cvoid}, (Ptr{ExifMem}, Ptr{Cvoid}, ExifLong), m, p, s)
end

function exif_mem_free(m, p)
    ccall((:exif_mem_free, libexif), Cvoid, (Ptr{ExifMem}, Ptr{Cvoid}), m, p)
end

function exif_mem_new_default()
    ccall((:exif_mem_new_default, libexif), Ptr{ExifMem}, ())
end

function exif_mnote_data_construct(arg1, mem)
    ccall((:exif_mnote_data_construct, libexif), Cvoid, (Ptr{ExifMnoteData}, Ptr{ExifMem}), arg1, mem)
end

function exif_mnote_data_set_byte_order(arg1, arg2)
    ccall((:exif_mnote_data_set_byte_order, libexif), Cvoid, (Ptr{ExifMnoteData}, ExifByteOrder), arg1, arg2)
end

function exif_mnote_data_set_offset(arg1, arg2)
    ccall((:exif_mnote_data_set_offset, libexif), Cvoid, (Ptr{ExifMnoteData}, Cuint), arg1, arg2)
end

function exif_mnote_data_ref(arg1)
    ccall((:exif_mnote_data_ref, libexif), Cvoid, (Ptr{ExifMnoteData},), arg1)
end

function exif_mnote_data_unref(arg1)
    ccall((:exif_mnote_data_unref, libexif), Cvoid, (Ptr{ExifMnoteData},), arg1)
end

function exif_mnote_data_load(d, buf, buf_siz)
    ccall((:exif_mnote_data_load, libexif), Cvoid, (Ptr{ExifMnoteData}, Ptr{Cuchar}, Cuint), d, buf, buf_siz)
end

function exif_mnote_data_save(d, buf, buf_siz)
    ccall((:exif_mnote_data_save, libexif), Cvoid, (Ptr{ExifMnoteData}, Ptr{Ptr{Cuchar}}, Ptr{Cuint}), d, buf, buf_siz)
end

function exif_mnote_data_count(d)
    ccall((:exif_mnote_data_count, libexif), Cuint, (Ptr{ExifMnoteData},), d)
end

function exif_mnote_data_get_id(d, n)
    ccall((:exif_mnote_data_get_id, libexif), Cuint, (Ptr{ExifMnoteData}, Cuint), d, n)
end

function exif_mnote_data_get_name(d, n)
    ccall((:exif_mnote_data_get_name, libexif), Ptr{Cchar}, (Ptr{ExifMnoteData}, Cuint), d, n)
end

function exif_mnote_data_get_title(d, n)
    ccall((:exif_mnote_data_get_title, libexif), Ptr{Cchar}, (Ptr{ExifMnoteData}, Cuint), d, n)
end

function exif_mnote_data_get_description(d, n)
    ccall((:exif_mnote_data_get_description, libexif), Ptr{Cchar}, (Ptr{ExifMnoteData}, Cuint), d, n)
end

function exif_mnote_data_get_value(d, n, val, maxlen)
    ccall((:exif_mnote_data_get_value, libexif), Ptr{Cchar}, (Ptr{ExifMnoteData}, Cuint, Ptr{Cchar}, Cuint), d, n, val, maxlen)
end

function exif_mnote_data_log(arg1, arg2)
    ccall((:exif_mnote_data_log, libexif), Cvoid, (Ptr{ExifMnoteData}, Ptr{ExifLog}), arg1, arg2)
end

@enum ExifSupportLevel::UInt32 begin
    EXIF_SUPPORT_LEVEL_UNKNOWN = 0
    EXIF_SUPPORT_LEVEL_NOT_RECORDED = 1
    EXIF_SUPPORT_LEVEL_MANDATORY = 2
    EXIF_SUPPORT_LEVEL_OPTIONAL = 3
end

function exif_tag_from_name(name)
    ccall((:exif_tag_from_name, libexif), ExifTag, (Ptr{Cchar},), name)
end

function exif_tag_get_name_in_ifd(tag, ifd)
    ccall((:exif_tag_get_name_in_ifd, libexif), Ptr{Cchar}, (ExifTag, ExifIfd), tag, ifd)
end

function exif_tag_get_title_in_ifd(tag, ifd)
    ccall((:exif_tag_get_title_in_ifd, libexif), Ptr{Cchar}, (ExifTag, ExifIfd), tag, ifd)
end

function exif_tag_get_description_in_ifd(tag, ifd)
    ccall((:exif_tag_get_description_in_ifd, libexif), Ptr{Cchar}, (ExifTag, ExifIfd), tag, ifd)
end

function exif_tag_get_support_level_in_ifd(tag, ifd, t)
    ccall((:exif_tag_get_support_level_in_ifd, libexif), ExifSupportLevel, (ExifTag, ExifIfd, ExifDataType), tag, ifd, t)
end

function exif_tag_get_name(tag)
    ccall((:exif_tag_get_name, libexif), Ptr{Cchar}, (ExifTag,), tag)
end

function exif_tag_get_title(tag)
    ccall((:exif_tag_get_title, libexif), Ptr{Cchar}, (ExifTag,), tag)
end

function exif_tag_get_description(tag)
    ccall((:exif_tag_get_description, libexif), Ptr{Cchar}, (ExifTag,), tag)
end

function exif_tag_table_get_tag(n)
    ccall((:exif_tag_table_get_tag, libexif), ExifTag, (Cuint,), n)
end

function exif_tag_table_get_name(n)
    ccall((:exif_tag_table_get_name, libexif), Ptr{Cchar}, (Cuint,), n)
end

function exif_tag_table_count()
    ccall((:exif_tag_table_count, libexif), Cuint, ())
end

const ExifByte = Cuchar

const ExifSByte = Int8

const ExifAscii = Ptr{Cchar}

const ExifShort = UInt16

const ExifSShort = Int16

const ExifSLong = Int32

struct ExifRational
    numerator::ExifLong
    denominator::ExifLong
end

const ExifUndefined = Cchar

struct ExifSRational
    numerator::ExifSLong
    denominator::ExifSLong
end

function exif_get_short(b, order)
    ccall((:exif_get_short, libexif), ExifShort, (Ptr{Cuchar}, ExifByteOrder), b, order)
end

function exif_get_sshort(b, order)
    ccall((:exif_get_sshort, libexif), ExifSShort, (Ptr{Cuchar}, ExifByteOrder), b, order)
end

function exif_get_long(b, order)
    ccall((:exif_get_long, libexif), ExifLong, (Ptr{Cuchar}, ExifByteOrder), b, order)
end

function exif_get_slong(b, order)
    ccall((:exif_get_slong, libexif), ExifSLong, (Ptr{Cuchar}, ExifByteOrder), b, order)
end

function exif_get_rational(b, order)
    ccall((:exif_get_rational, libexif), ExifRational, (Ptr{Cuchar}, ExifByteOrder), b, order)
end

function exif_get_srational(b, order)
    ccall((:exif_get_srational, libexif), ExifSRational, (Ptr{Cuchar}, ExifByteOrder), b, order)
end

function exif_set_short(b, order, value)
    ccall((:exif_set_short, libexif), Cvoid, (Ptr{Cuchar}, ExifByteOrder, ExifShort), b, order, value)
end

function exif_set_sshort(b, order, value)
    ccall((:exif_set_sshort, libexif), Cvoid, (Ptr{Cuchar}, ExifByteOrder, ExifSShort), b, order, value)
end

function exif_set_long(b, order, value)
    ccall((:exif_set_long, libexif), Cvoid, (Ptr{Cuchar}, ExifByteOrder, ExifLong), b, order, value)
end

function exif_set_slong(b, order, value)
    ccall((:exif_set_slong, libexif), Cvoid, (Ptr{Cuchar}, ExifByteOrder, ExifSLong), b, order, value)
end

function exif_set_rational(b, order, value)
    ccall((:exif_set_rational, libexif), Cvoid, (Ptr{Cuchar}, ExifByteOrder, ExifRational), b, order, value)
end

function exif_set_srational(b, order, value)
    ccall((:exif_set_srational, libexif), Cvoid, (Ptr{Cuchar}, ExifByteOrder, ExifSRational), b, order, value)
end

function exif_convert_utf16_to_utf8(out, in, maxlen)
    ccall((:exif_convert_utf16_to_utf8, libexif), Cvoid, (Ptr{Cchar}, Ptr{Cushort}, Cint), out, in, maxlen)
end

function exif_array_set_byte_order(arg1, arg2, arg3, o_orig, o_new)
    ccall((:exif_array_set_byte_order, libexif), Cvoid, (ExifFormat, Ptr{Cuchar}, Cuint, ExifByteOrder, ExifByteOrder), arg1, arg2, arg3, o_orig, o_new)
end

const EXIF_TAG_GPS_VERSION_ID = 0x0000

const EXIF_TAG_GPS_LATITUDE_REF = 0x0001

const EXIF_TAG_GPS_LATITUDE = 0x0002

const EXIF_TAG_GPS_LONGITUDE_REF = 0x0003

const EXIF_TAG_GPS_LONGITUDE = 0x0004

const EXIF_TAG_GPS_ALTITUDE_REF = 0x0005

const EXIF_TAG_GPS_ALTITUDE = 0x0006

const EXIF_TAG_GPS_TIME_STAMP = 0x0007

const EXIF_TAG_GPS_SATELLITES = 0x0008

const EXIF_TAG_GPS_STATUS = 0x0009

const EXIF_TAG_GPS_MEASURE_MODE = 0x000a

const EXIF_TAG_GPS_DOP = 0x000b

const EXIF_TAG_GPS_SPEED_REF = 0x000c

const EXIF_TAG_GPS_SPEED = 0x000d

const EXIF_TAG_GPS_TRACK_REF = 0x000e

const EXIF_TAG_GPS_TRACK = 0x000f

const EXIF_TAG_GPS_IMG_DIRECTION_REF = 0x0010

const EXIF_TAG_GPS_IMG_DIRECTION = 0x0011

const EXIF_TAG_GPS_MAP_DATUM = 0x0012

const EXIF_TAG_GPS_DEST_LATITUDE_REF = 0x0013

const EXIF_TAG_GPS_DEST_LATITUDE = 0x0014

const EXIF_TAG_GPS_DEST_LONGITUDE_REF = 0x0015

const EXIF_TAG_GPS_DEST_LONGITUDE = 0x0016

const EXIF_TAG_GPS_DEST_BEARING_REF = 0x0017

const EXIF_TAG_GPS_DEST_BEARING = 0x0018

const EXIF_TAG_GPS_DEST_DISTANCE_REF = 0x0019

const EXIF_TAG_GPS_DEST_DISTANCE = 0x001a

const EXIF_TAG_GPS_PROCESSING_METHOD = 0x001b

const EXIF_TAG_GPS_AREA_INFORMATION = 0x001c

const EXIF_TAG_GPS_DATE_STAMP = 0x001d

const EXIF_TAG_GPS_DIFFERENTIAL = 0x001e

const EXIF_TAG_UNKNOWN_C4A5 = EXIF_TAG_PRINT_IMAGE_MATCHING

const EXIF_TAG_SUBSEC_TIME = EXIF_TAG_SUB_SEC_TIME

end # module