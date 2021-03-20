module blend2d

// ============================================================================
// Context - Definitions
// ============================================================================

struct C.BLContextCore {
	impl &C.BLContextImpl = 0
}
// Rendering Context.
type Context = C.BLContextCore

// Composition & blending operator.
pub enum CompOp {
	src_over		// Source-over [default].
	src_copy		// Source-copy.
	src_in			// Source-in.
	src_out			// Source-out.
	src_atop		// Source-atop.
	dst_over		// Destination-over.
	dst_copy		// Destination-copy [nop].
	dst_in			// Destination-in.
	dst_out			// Destination-out.
	dst_atop		// Destination-atop.
	xor				// Xor.
	clear			// Clear.
	plus			// Plus.
	minus			// Minus.
	modulate		// Modulate.
	multiply		// Multiply.
	screen			// Screen.
	overlay			// Overlay.
	darken			// Darken.
	lighten			// Lighten.
	color_dodge		// Color dodge.
	color_burn		// Color burn.
	linear_burn		// Linear burn.
	linear_light	// Linear light.
	pin_light		// Pin light.
	hard_light		// Hard-light.
	soft_light		// Soft-light.
	difference		// Difference.
	exclusion		// Exclusion.
	count			// Count of composition & blending operators. 
}

// ============================================================================
// Context - Init / Destroy
// ============================================================================

fn C.blContextInitAs(self &C.BLContextCore, image &C.BLImageCore, options &C.BLContextCreateInfo) BLResult
// Create a new rendering Context.
[inline]
pub fn new_context(target &Image) ?&Context {
	context := &Context{}
	res := C.blContextInitAs(context, target, 0)
	if res != 0 {
		return IError(Result{
			msg: "Could not create rendering context."
			result: ResultCode(res)
		})
	}
	return context
}

fn C.blContextDestroy(self &C.BLContextCore) BLResult
// Free the rendering Context data from memory. (Called by V's autofree engine).
[inline]
pub fn (ctx &Context) free() {
	C.blContextDestroy(ctx)
}

// ============================================================================
// Context - Begin / End
// ============================================================================

fn C.blContextEnd(self &C.BLContextCore) BLResult
// Waits for completion of all render commands and detaches the rendering 
// context from the rendering target. After end() completes, the rendering 
// context implementation would be released and replaced by a built-in null 
// instance (no context).
[inline]
pub fn (ctx &Context) end() {
	res := C.blContextEnd(ctx)
	if res != 0 {
		panic(IError(Result{
			msg: "Failed to detach/end rendering context."
			result: ResultCode(res)
		}))
	}
}

// ============================================================================
// Context - Operations
// ============================================================================

// Sets the composition & blending operation type for the context.
[inline]
pub fn (ctx &Context) set_comp_op(comp_op CompOp) {
	res := ctx.impl.virt.setCompOp(ctx.impl, comp_op)
	if res != 0 {
		panic(IError(Result{
			msg: "'Set Comp Op' operation failed for rendering context."
			result: ResultCode(res)
		}))
	}
}

// Fills everything.
[inline]
pub fn (ctx &Context) fill_all() {
	res := ctx.impl.virt.fillAll(ctx.impl)
	if res != 0 {
		panic(IError(Result{
			msg: "'Fill All' operation failed for rendering context."
			result: ResultCode(res)
		}))
	}
}

// Set fill style.
[inline]
pub fn (ctx &Context) set_fill_style(rgba32 Rgba32) {
	func := ctx.impl.virt.setStyleRgba32[C_OpType.fill]
	res := func(ctx.impl, rgba32.value)
	// TODO: cgen checker bug
	// res := ctx.impl.virt.setStyleRgba32[C_OpType.fill](ctx.impl, rgba32.value)
	if res != 0 {
		panic(IError(Result{
			msg: "'Set Fill Style' operation failed for rendering context."
			result: ResultCode(res)
		}))
	}
}

// Fill path.
[inline]
pub fn (ctx &Context) fill_path(path &Path) {
	res := ctx.impl.virt.fillGeometry(ctx.impl, C_BLGeometryType.path, path)
	if res != 0 {
		panic(IError(Result{
			msg: "'Fill Path' operation failed for rendering context."
			result: ResultCode(res)
		}))
	}
}

// ============================================================================
// Context - Internal Definitions
// ============================================================================

// Rendering context [Impl].
struct C.BLContextImpl {
	virt 				&C.BLContextVirt = 0  // Virtual function table.

	refCount 			size_t                // Reference count.
	implType			byte                  // Impl type.
	implTraits		byte                  // Impl traits.
	memPoolData		u16                   // Memory pool data.
	contextType		u32                   // Type of the context, see `BLContextType`.

	state 			&C.BLContextState = 0 // Current state of the context.
}

//! Rendering context state.
struct C.BLContextState {
}

// Rendering context [Virtual Function Table].
struct C.BLContextVirt {
	destroy						fn (mut impl &C.BLContextImpl) BLResult
	flush						fn (mut impl &C.BLContextImpl, flags u32) BLResult

	queryProperty				fn (impl &C.BLContextImpl, propertyId u32, mut valueOut voidptr) BLResult

	save						fn (mut impl &C.BLContextImpl, mut cookie &C.BLContextCookie) BLResult
	restore						fn (mut impl &C.BLContextImpl, cookie &C.BLContextCookie) BLResult

	matrixOp					fn (mut impl &C.BLContextImpl, opType u32, opData voidptr) BLResult
	userToMeta					fn (mut impl &C.BLContextImpl) BLResult

	setHint						fn (mut impl &C.BLContextImpl, hintType u32, value u32) BLResult
	setHints					fn (mut impl &C.BLContextImpl, hints &C.BLContextHints) BLResult
	setFlattenMode				fn (mut impl &C.BLContextImpl, mode u32) BLResult
	setFlattenTolerance			fn (mut impl &C.BLContextImpl, tolerance f64) BLResult
	setApproximationOptions		fn (mut impl &C.BLContextImpl, options &C.BLApproximationOptions) BLResult
 
	setCompOp					fn (mut impl &C.BLContextImpl, compOp u32) BLResult
	setGlobalAlpha				fn (mut impl &C.BLContextImpl, alpha f64) BLResult
 
	setStyleAlpha[2]			fn (mut impl &C.BLContextImpl, alpha f64) BLResult
	getStyle[2]					fn (impl &C.BLContextImpl, mut out &C.BLStyleCore) BLResult
	setStyle[2]					fn (mut impl &C.BLContextImpl, style &C.BLStyleCore) BLResult
	setStyleRgba[2]				fn (mut impl &C.BLContextImpl, rgba &C.BLRgba) BLResult
	setStyleRgba32[2]			fn (/*TODO check: mut*/ impl &C.BLContextImpl, rgba32 u32) BLResult
	setStyleRgba64[2]			fn (mut impl &C.BLContextImpl, rgba64 u64) BLResult
	setStyleObject[2]			fn (mut impl &C.BLContextImpl, object voidptr) BLResult
 
	setFillRule					fn (mut impl &C.BLContextImpl, fillRule u32) BLResult
 
	setStrokeWidth				fn (mut impl &C.BLContextImpl, width f64) BLResult
	setStrokeMiterLimit			fn (mut impl &C.BLContextImpl, miterLimit f64) BLResult
	setStrokeCap		 		fn (mut impl &C.BLContextImpl, position u32, strokeCap u32) BLResult
	setStrokeCaps				fn (mut impl &C.BLContextImpl, strokeCap u32) BLResult
	setStrokeJoin				fn (mut impl &C.BLContextImpl, strokeJoin u32) BLResult
	setStrokeDashOffset			fn (mut impl &C.BLContextImpl, dashOffset f64) BLResult
	setStrokeDashArray			fn (mut impl &C.BLContextImpl, dashArray &C.BLArrayCore) BLResult
	setStrokeTransformOrder		fn (mut impl &C.BLContextImpl, transformOrder u32) BLResult
	setStrokeOptions	  		fn (mut impl &C.BLContextImpl, options &C.BLStrokeOptionsCore) BLResult
 
	clipToRectI					fn (mut impl &C.BLContextImpl, rect &C.BLRectI) BLResult
	clipToRectD					fn (mut impl &C.BLContextImpl, rect &C.BLRect) BLResult
	restoreClipping				fn (mut impl &C.BLContextImpl) BLResult
 
	clearAll					fn (mut impl &C.BLContextImpl) BLResult
	clearRectI					fn (mut impl &C.BLContextImpl, rect &C.BLRectI) BLResult
	clearRectD					fn (mut impl &C.BLContextImpl, rect &C.BLRect) BLResult
 
	fillAll						fn (mut impl &C.BLContextImpl) BLResult
	fillRectI					fn (mut impl &C.BLContextImpl, rect &C.BLRectI) BLResult
	fillRectD					fn (mut impl &C.BLContextImpl, rect &C.BLRect) BLResult
	fillPathD					fn (mut impl &C.BLContextImpl, path &C.BLPathCore) BLResult
	fillGeometry				fn (mut impl &C.BLContextImpl, geometryType u32, geometryData voidptr) BLResult
	fillTextI					fn (mut impl &C.BLContextImpl, pt &C.BLPointI, font &C.BLFontCore, text voidptr, size size_t, encoding u32) BLResult
	fillTextD					fn (mut impl &C.BLContextImpl, pt &C.BLPoint, font &C.BLFontCore, text voidptr, size size_t, encoding u32) BLResult
	fillGlyphRunI				fn (mut impl &C.BLContextImpl, pt &C.BLPointI, font &C.BLFontCore, glyphRun &C.BLGlyphRun) BLResult
	fillGlyphRunD				fn (mut impl &C.BLContextImpl, pt &C.BLPoint, font &C.BLFontCore, glyphRun &C.BLGlyphRun) BLResult

	strokeRectI					fn (mut impl &C.BLContextImpl, rect &C.BLRectI) BLResult
	strokeRectD					fn (mut impl &C.BLContextImpl, rect &C.BLRect) BLResult
	strokePathD					fn (mut impl &C.BLContextImpl, path &C.BLPathCore) BLResult
	strokeGeometry				fn (mut impl &C.BLContextImpl, geometryType u32, geometryData voidptr) BLResult
	strokeTextI					fn (mut impl &C.BLContextImpl, pt &C.BLPointI, font &C.BLFontCore,  text voidptr, size size_t, encoding u32) BLResult
	strokeTextD					fn (mut impl &C.BLContextImpl, pt &C.BLPoint, font &C.BLFontCore, text voidptr, size size_t, encoding u32) BLResult
	strokeGlyphRunI				fn (mut impl &C.BLContextImpl, pt &C.BLPointI, font &C.BLFontCore, glyphRun &C.BLGlyphRun) BLResult
	strokeGlyphRunD				fn (mut impl &C.BLContextImpl, pt &C.BLPoint, font &C.BLFontCore, glyphRun &C.BLGlyphRun) BLResult

	blitImageI					fn (mut impl &C.BLContextImpl, pt &C.BLPointI, img &C.BLImageCore, imgArea &C.BLRectI) BLResult
	blitImageD					fn (mut impl &C.BLContextImpl, pt &C.BLPoint, img &C.BLImageCore, imgArea &C.BLRectI) BLResult
	blitScaledImageI			fn (mut impl &C.BLContextImpl, rect &C.BLRectI, img &C.BLImageCore, imgArea &C.BLRectI) BLResult
	blitScaledImageD			fn (mut impl &C.BLContextImpl, rect &C.BLRect, img &C.BLImageCore, imgArea &C.BLRectI) BLResult
}



// struct C.BLContextCookie {
// }
// struct C.BLContextHints {
// }
// struct C.BLApproximationOptions {
// }
// struct C.BLStyleCore {
// }
// struct C.BLRgba {
// }
// struct C.BLArrayCore {
// }
// struct C.BLStrokeOptionsCore {
// }
// struct C.BLPathCore {
// }
// struct C.BLFontCore {
// }
// struct C.BLGlyphRun {
// }
// struct C.BLPointI {
// }
// struct C.BLPoint {
// }
// struct C.BLRect {
// }
// struct C.BLRectI {
// }

// Used to select the correct function from the virtual function
// table when there are multiple. Used primarily in the various 
// set_fill_style() functions.
enum C_BLContextOpType {
	fill   = 0 // Fill operation type.
	stroke = 1 // Stroke operation type.
	count  = 2 // Count of rendering operations.
}
enum C_OpType {
	fill   = 0 // TODO: int(C_BLContextOpType.fill)   is error
	stroke = 1 // TODO: int(C_BLContextOpType.stroke) is error
}

// Used as parameter to ctx.impl.virt.fillGeometry() in ex. fill_path().
enum C_BLGeometryType {
	@none = 0        // No geometry provided.
	boxi = 1        // BLBoxI struct.
	boxd = 2        // BLBox struct.
	recti = 3       // BLRectI struct.
	rectd = 4       // BLRect struct.
	circle = 5      // BLCircle struct.
	ellipse = 6     // BLEllipse struct.
	round_rect = 7  // BLRoundRect struct.
	arc = 8         // BLArc struct.
	chord = 9       // BLArc struct representing chord.
	pie = 10        // BLArc struct representing pie.
	line = 11       // BLLine struct.
	triangle = 12    // BLTriangle struct.
	polylinei = 13   // BLArrayView<BLPointI> representing a polyline.
	polylined = 14   // BLArrayView<BLPoint> representing a polyline.
	polygoni = 15    // BLArrayView<BLPointI> representing a polygon.
	polygond = 16    // BLArrayView<BLPoint> representing a polygon.
	array_view_boxi = 17  // BLArrayView<BLBoxI> struct.
	array_view_boxd = 18  // BLArrayView<BLBox> struct.
	array_view_recti = 19  // BLArrayView<BLRectI> struct.
	array_view_rectd = 20  // BLArrayView<BLRect> struct.
	path = 21             // BLPath (or BLPathCore).
	region = 22           // BLRegion (or BLRegionCore).

	count = 23  // Count of geometry types.

	// TODO: simple_last = triangle // The last simple type.  is error
}