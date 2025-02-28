const std = @import("std");
const assert = std.debug.assert;

pub const nil: u128 = 0x00000000000000000000000000000000;
pub const max: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
comptime {
    _ = nil;
    _ = max;
    assert(nil == ~max);
}

// TODO: WHERE IS THE 0 VARIANT?
// ietf : Reserved. Network Computing System (NCS) backward compatibility, and includes Nil UUID as per Section 5.9.
// but it doesnt mention variant 0
pub const Variant = enum {
    reserved_ncs_backward, // 1-7 includes Nil UUID
    rfc9562, // 8-9,A-B
    reserved_microsoft, // C-D
    reserved_future, // E-F includes Max UUID

    pub fn fromInt(int: u4) Variant {
        return switch (int) {
            // 0b0000...0b0111 => .reserved_ncs_backward, // nil is missing??
            0b0001...0b0111 => .reserved_ncs_backward,
            0b1000...0b1011 => .rfc9562,
            0b1100...0b1101 => .reserved_microsoft,
            0b1110...0b1111 => .reserved_future,
            else => @panic("TODO"),
        };
    }
};
comptime {
    _ = Variant;

    // assert(Variant.fromInt(0) == .reserved_ncs_backward); // TODO: THIS SHOULD NOT PANIC!
    assert(Variant.fromInt(1) == .reserved_ncs_backward);
    assert(Variant.fromInt(2) == .reserved_ncs_backward);
    assert(Variant.fromInt(3) == .reserved_ncs_backward);
    assert(Variant.fromInt(4) == .reserved_ncs_backward);
    assert(Variant.fromInt(5) == .reserved_ncs_backward);
    assert(Variant.fromInt(6) == .reserved_ncs_backward);
    assert(Variant.fromInt(7) == .reserved_ncs_backward);

    assert(Variant.fromInt(8) == .rfc9562);
    assert(Variant.fromInt(9) == .rfc9562);
    assert(Variant.fromInt(10) == .rfc9562);
    assert(Variant.fromInt(0xA) == .rfc9562);
    assert(Variant.fromInt(11) == .rfc9562);
    assert(Variant.fromInt(0xB) == .rfc9562);

    assert(Variant.fromInt(12) == .reserved_microsoft);
    assert(Variant.fromInt(0xC) == .reserved_microsoft);
    assert(Variant.fromInt(13) == .reserved_microsoft);
    assert(Variant.fromInt(0xD) == .reserved_microsoft);

    assert(Variant.fromInt(14) == .reserved_future);
    assert(Variant.fromInt(0xE) == .reserved_future);
    assert(Variant.fromInt(15) == .reserved_future);
    assert(Variant.fromInt(0xF) == .reserved_future);
}

pub const rfc9562 = @import("rfc9562.zig");
comptime {
    _ = rfc9562.Version;
}
