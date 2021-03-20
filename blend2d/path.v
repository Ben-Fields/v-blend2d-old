module blend2d

// ============================================================================
// Path - Definitions
// ============================================================================

struct C.BLPathCore {
}
// Path.
type Path = C.BLPathCore

// ============================================================================
// Path - Init / Destroy
// ============================================================================

fn C.blPathInit(self &C.BLPathCore) BLResult
// Create a new Path.
[inline]
pub fn new_path() &Path {
	path := &Path{}
	C.blPathInit(path)
	return path
}

fn C.blPathDestroy(self &C.BLPathCore) BLResult
// Free the Path data from memory. (Called by V's autofree engine).
[inline]
pub fn (path &Path) free() {
	C.blPathDestroy(path)
}

// ============================================================================
// Path - Operations
// ============================================================================

fn C.blPathMoveTo(self &C.BLPathCore, x0 f64, y0 f64) BLResult
// Move to [x0, y0].
[inline]
pub fn (path &Path) move_to(x0 f64, y0 f64) {
	res := C.blPathMoveTo(path, x0, y0)
	if res != 0 {
		panic(IError(Result{
			msg: "'Move To' operation failed for path."
			result: ResultCode(res)
		}))
	}
}

fn C.blPathCubicTo(self &C.BLPathCore, x1 f64, y1 f64, x2 f64, y2 f64, x3 f64, y3 f64) BLResult
// Add a cubic curve to [x1, y1], [x2, y2], and [x3, y3].
[inline]
pub fn (path &Path) cubic_to(x1 f64, y1 f64, x2 f64, y2 f64, x3 f64, y3 f64) {
	res := C.blPathCubicTo(path, x1, y1, x2, y2, x3, y3)
	if res != 0 {
		panic(IError(Result{
			msg: "'Cubic To' operation failed for path."
			result: ResultCode(res)
		}))
	}
}