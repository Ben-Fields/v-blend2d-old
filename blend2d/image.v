module blend2d

// ============================================================================
// Image - Definitions
// ============================================================================

struct C.BLImageCore {
	pub:
	impl &C.BLImageImpl = 0 // TEMPORARY- TODO
}
// Image.
pub type Image = C.BLImageCore

//TEMPORARY- TODO
struct C.BLImageImpl {
	pub:
  pixelData voidptr  // Pixel data.

  refCount size_t  // Reference count.
  implType byte  // Impl type.
  implTraits byte  // Impl traits.
  memPoolData u16  // Memory pool data.

  format byte  // Image format.
  flags byte  // Image flags.
  depth u16  // Image depth (in bits).
  size C.BLSizeI  // Image size.
  stride i64  // Image stride.
}

// Image Pixel Format.
pub enum Format {
	@none				// None or invalid pixel format.
	prgb32				// 32-bit premultiplied ARGB pixel format (8-bit components).
	xrgb32				// 32-bit (X)RGB pixel format (8-bit components, alpha ignored).
	a8					// 8-bit alpha-only pixel format.
	count				// Count of pixel formats.
	reserved_count		// Count of pixel formats (reserved for future use).
}

// ============================================================================
// Image - Init / Destroy
// ============================================================================

fn C.blImageInitAs(self &C.BLImageCore, w int, h int, format Format) BLResult
// Create a new Image with the specified dimensions and format.
[inline]
pub fn new_image(w int, h int, format Format) ?&Image {
	img := &Image{}
	res := C.blImageInitAs(img, w, h, format)
	if res != 0 {
		return IError(Result{
			msg: "Could not create image."
			result: ResultCode(res)
		})
	}
	return img
}

fn C.blImageDestroy(self &C.BLImageCore) BLResult
// Free the Image data from memory. (Called by V's autofree engine).
[inline]
pub fn (img &Image) free() {
	C.blImageDestroy(img)
}

// ============================================================================
// Image - I/O
// ============================================================================

fn C.blImageWriteToFile(self &C.BLImageCore, filename charptr, codec &C.BLImageCodecCore) BLResult
// Write image to file using the specified codec.
[inline]
pub fn (img &Image) write_to_file(filename string, codec &ImageCodec) ? {
	res := C.blImageWriteToFile(img, filename.str, codec)
	if res != 0 {
		return IError(Result{
			msg: "Could not write image to file."
			result: ResultCode(res)
		})
	}
}

fn C.blImageWriteToData(self &C.BLImageCore, dst &C.BLArrayCore, codec &C.BLImageCodecCore) BLResult
// Write image to memory using the specified codec. Returns the written data.
[inlne]
pub fn (img &Image) write_to_memory(codec &ImageCodec) ?(byteptr, size_t) {
	// out := &Array{}
	out := new_array<byte>()
	println(typeof(out))
	println("Data len before write: ${int(out.impl.size)}")
	println("Data before write: ${byteptr(out.impl.data)}")
	res := C.blImageWriteToData(img, out, codec)
	println("Data len after write: ${int(out.impl.size)}")
	println("Data after write: ${out.impl.data}")
	if res != 0 {
		return IError(Result{
			msg: "Could not write image to memory."
			result: ResultCode(res)
		})
	}
	// TODO: return byte array
	return out.impl.data, out.impl.size
}


// TEMPORARY. TODO - move elsewhere (BLArray)

struct C.BLArrayCore {
	impl &C.BLArrayImpl = 0
}
// Blend2D Array.
pub type Array = C.BLArrayCore

fn C.blArrayInit(self &C.BLArrayCore, arrayTypeId u32) BLResult
// Create a new Blend2D Array.
[inline]
pub fn new_array<T>() &Array {
	arr := &Array{}
	res := C.blArrayInit(arr, sizeof(T)) //
	if res != 0 {
		panic(IError(Result{
			msg: "Could not create array."
			result: ResultCode(res)
		}))
	}
	return arr
}

fn C.blArrayDestroy(self &C.BLArrayCore) BLResult
// Free the Array data from memory. (Called by V's autofree engine).
[inlne]
pub fn (arr &Array) free() {
	C.blArrayDestroy(arr)
}

struct C.BLArrayImpl {
	capacity size_t                 // Array capacity.

	refCount size_t                 // Reference count.
	implType byte                   // Impl type.
	implTraits byte                 // Impl traits.
	memPoolData u16                 // Memory pool data.

	itemSize byte                   // Item size in bytes.
	dispatchType byte               // Function dispatch used to handle arrays that don't store simple items.
	reserved []byte = []byte{len:2} // Reserved, must be set to 0.

	// These members are part of sub data structures that can't be represented in V.
	// Declaring them directly like this seems to be sufficient for access.
	// union {
	// struct {
	data voidptr	  // Array data (as `void`).
	size size_t		  // Array size.
	// }
	view C.BLDataView // Array data and size as a view.
	// }
}
