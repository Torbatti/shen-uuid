const std = @import("std");
const root = @import("root");
const assert = std.debug.assert;

pub const Version = enum(u4) {
    unused = 0,
    time_based_greg = 1,
    dce_security = 2,
    name_based_md5 = 3,
    random = 4,
    name_based_sha1 = 5,
    time_based_greg_reordered = 6,
    time_based_epoch = 7,
    custom = 8,
    future,
};

pub const nil: u128 = 0x00000000000000000000000000000000;
pub const max: u126 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
test "nil and max" {
    _ = nil;
    _ = max;
    assert(nil == ~max);
}

pub const v1 = struct {
    bytes: [16]u8 = [_]u8{0} ** 16,

    pub fn init() v1 {
        var uuid = v1{};

        // 60-bit starting timestamp
        const time = @as(u60, @intCast(@as(i60, @truncate(std.time.milliTimestamp()))));

        // time_low
        uuid.bytes[0] = @as(u8, @truncate(time));
        uuid.bytes[1] = @as(u8, @truncate(time >> 8));
        uuid.bytes[2] = @as(u8, @truncate(time >> 16));
        uuid.bytes[3] = @as(u8, @truncate(time >> 24));

        // time_mid
        uuid.bytes[4] = @as(u8, @truncate(time >> 32));
        uuid.bytes[5] = @as(u8, @truncate(time >> 40));

        // time_high
        uuid.bytes[6] = @as(u8, @truncate(time >> 48));
        uuid.bytes[7] = @as(u8, @truncate(time >> 56));

        // clock_seq
        std.crypto.random.bytes(&uuid.bytes[8..9]); // occupies clock sequence bytes

        // TODO: MACADRESS MISSING
        std.crypto.random.bytes(&uuid.bytes[10..15]); // TODO : REPLACE WITH MACADDRESS

        // Version 1
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x10;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;

        std.debug.print("{0b} ", .{time});
        // std.debug.print("{any} ", .{bytes});

        return uuid;
    }
};

pub const v4 = struct {
    bytes: [16]u8 = [_]u8{0} ** 16,

    pub fn init() v4 {
        var uuid = v4{};
        std.crypto.random.bytes(&uuid.bytes);

        // Version 4
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x40;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;

        return uuid;
    }
};
