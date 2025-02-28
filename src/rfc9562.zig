const std = @import("std");
const root = @import("root");

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

pub const v1 = struct {
    bytes: [16]u8 = [_]u8{0} ** 16,

    pub fn init() void {
        var uuid = v1{};
        std.crypto.random.bytes(&uuid.bytes);

        // var bytes: [16]u8 = [_]u8{0} ** 16;
        // const bytes: [16]u8 = [_]u8{0} ** 16;

        // 60-bit starting timestamp
        const time = @as(u60, @intCast(@as(i60, @truncate(std.time.timestamp() >> 4))));

        // const time = std.time.milliTimestamp();
        // const time = @as(u60, @intCast(@truncate(std.time.timestamp() >> 4)));
        // bytes[1] = @as(u8, @truncate(@as(u60, time << 52 >> 52)));
        // bytes[2] = @as(u8, @truncate(@as(u60, time << 44 >> 52)));
        // bytes[3] = @as(u8, @truncate(@as(u60, time << 36 >> 52)));

        std.debug.print("{0b} ", .{time});
        // std.debug.print("{any} ", .{bytes});

    }
};
