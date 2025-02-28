const std = @import("std");
const assert = std.debug.assert;

pub const nil_uuid: u128 = 0x00000000000000000000000000000000;
pub const max_uuid: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

comptime {
    _ = nil_uuid;
    _ = max_uuid;
    assert(nil_uuid == ~max_uuid);
}
