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

const nil: u128 = 0x00000000000000000000000000000000;
const max: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
test "nil and max" {
    _ = nil;
    _ = max;
    assert(nil == ~max);

    _ = UUID.nil;
    _ = UUID.max;
}

pub const UUID = struct {
    bytes: [16]u8,

    pub const nil: UUID = UUID{ .bytes = [_]u8{0x00} ** 16 };
    pub const max: UUID = UUID{ .bytes = [_]u8{0xFF} ** 16 };

    pub fn reset(uuid: *UUID) void {
        uuid.*.bytes = [_]u8{0x00} ** 16;
    }

    pub const new_v1 = UUID_V1.new;
    pub const new_v3 = UUID_V3.new;
    pub const new_v4 = UUID_V4.new;
    pub const new_v5 = UUID_V5.new;
};

const UUID_V1 = struct {
    fn new(uuid: *UUID, node_id: u64) void {
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

        // On systems utilizing a 64-bit MAC address,
        // the least significant, rightmost 48 bits MAY be used
        uuid.bytes[10] = @as(u8, @truncate(node_id));
        uuid.bytes[11] = @as(u8, @truncate(node_id >> 8));
        uuid.bytes[12] = @as(u8, @truncate(node_id >> 16));
        uuid.bytes[13] = @as(u8, @truncate(node_id >> 24));
        uuid.bytes[14] = @as(u8, @truncate(node_id >> 32));
        uuid.bytes[15] = @as(u8, @truncate(node_id >> 40));

        // Version 1
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x10;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// md5_high 48 | version 4 | md5_mid 12 | variant 2 | md5_low 62
const UUID_V3 = struct {
    fn new(uuid: *UUID, stream: []const u8) void {
        var md5_hash = std.crypto.hash.Md5.init(.{});
        md5_hash.update(stream);

        var out_bytes: [20]u8 = undefined;
        md5_hash.final(&out_bytes);

        @memcpy(uuid.*.bytes[0..15], out_bytes[0..15]);

        // Version 3
        uuid.*.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x30;

        // Variant RFC9562
        uuid.*.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// time_low 32 | time_mid 16 | version 4 | time_high 12 | variant 2 | clock_seq 14 |  node 48
const UUID_V4 = struct {
    fn new(uuid: *UUID) void {
        std.crypto.random.bytes(uuid.*.bytes);

        // Version 4
        uuid.*.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x40;

        // Variant RFC9562
        uuid.*.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// sha1_high 48 | version 4 | sha1_mid 12 | variant 2 | sha1_low 62
const UUID_V5 = struct {
    fn new(uuid: *UUID, stream: []const u8) void {
        var sha1_hash = std.crypto.hash.Sha1.init(.{});
        sha1_hash.update(stream);

        var out_bytes: [20]u8 = undefined;
        sha1_hash.final(&out_bytes);

        @memcpy(uuid.*.bytes[0..15], out_bytes[0..15]);

        // Version 5
        uuid.*.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x50;

        // Variant RFC9562
        uuid.*.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};
