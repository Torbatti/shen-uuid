const std = @import("std");
const assert = std.debug.assert;

pub const nil: u128 = 0x00000000000000000000000000000000;
pub const max: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
comptime {
    _ = nil;
    _ = max;
    assert(nil == ~max);
}

pub const rfc9562 = @import("rfc9562.zig");
comptime {
    _ = rfc9562.Version;
}
