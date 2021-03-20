module blend2d

// ============================================================================
// RGBA - Definitions
// ============================================================================

struct Rgba32_Components {
	b byte
	g byte
	r byte
	a byte
}
// 32-bit RGBA color (8-bits per component) stored as 0xAARRGGBB.
pub union Rgba32 {
	Rgba32_Components
	value             u32
}

// ============================================================================
// RGBA - Init
// ============================================================================

// Returns a new 32-bit RGBA color (Rgba32).
[inline]
pub fn new_rgba32(value u32) Rgba32 {
	return Rgba32 {
		value: value
	}
}