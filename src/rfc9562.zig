const std = @import("std");
const root = @import("root");
const assert = std.debug.assert;

pub const UUID = struct {
    bytes: [16]u8,

    pub const nil: UUID = UUID{ .bytes = [_]u8{0x00} ** 16 };
    pub const max: UUID = UUID{ .bytes = [_]u8{0xFF} ** 16 };

    pub const toU128 = uuidToU128;

    pub fn reset(uuid: *UUID) void {
        uuid.*.bytes = [_]u8{0x00} ** 16;
    }

    pub const new_v1 = UUID_V1.new;
    pub const new_v3 = UUID_V3.new;
    pub const new_v4 = UUID_V4.new;
    pub const new_v5 = UUID_V5.new;
    pub const new_v6 = UUID_V6.new;
    pub const new_v7 = UUID_V7.new;

    pub const new_v8 = UUID_V8.new;
    pub const new_v8_sha256 = UUID_V8.new_sha256;
    pub const new_v8_sha512 = UUID_V8.new_sha512;
};

pub const Version = enum(u4) {
    unused = 0,
    time_based_greg = 1,
    dce_security = 2,
    name_based_md5 = 3,
    random = 4,
    name_based_sha1 = 5,
    time_based_greg_reordered = 6,
    time_based_unix = 7,
    custom = 8,
    future,
};

pub fn getVersion(uuid: UUID) Version {
    switch (uuid.bytes[7] & 0xF0) {
        0x00 => return Version.unused,
        0x10 => return Version.time_based_greg,
        0x20 => return Version.dce_security,
        0x30 => return Version.name_based_md5,
        0x40 => return Version.random,
        0x50 => return Version.name_based_sha1,
        0x60 => return Version.time_based_greg_reordered,
        0x70 => return Version.time_based_unix,
        0x80 => return Version.custom,
        else => return Version.future,
    }
}

pub fn setVersion(uuid: *UUID, ver: Version) void {
    switch (ver) {
        Version.unused => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x00;
        },
        Version.time_based_greg => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x10;
        },
        Version.dce_security => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x20;
        },
        Version.name_based_md5 => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x30;
        },
        Version.random => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x40;
        },
        Version.name_based_sha1 => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x50;
        },
        Version.time_based_greg_reordered => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x60;
        },
        Version.time_based_unix => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x70;
        },
        Version.custom => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x80;
        },
        Version.future => {
            uuid.*.bytes[8] = (uuid.*.bytes[8] & 0x3f) | 0x90;
        },
    }
}

fn uuidToU128(uuid: UUID) u128 {
    var uuid128: u128 = 0;

    uuid128 = uuid128 | @as(u128, uuid.bytes[0]) << 8 * 0;
    uuid128 = uuid128 | @as(u128, uuid.bytes[1]) << 8 * 1;
    uuid128 = uuid128 | @as(u128, uuid.bytes[2]) << 8 * 2;
    uuid128 = uuid128 | @as(u128, uuid.bytes[3]) << 8 * 3;

    uuid128 = uuid128 | @as(u128, uuid.bytes[4]) << 8 * 4;
    uuid128 = uuid128 | @as(u128, uuid.bytes[5]) << 8 * 5;
    uuid128 = uuid128 | @as(u128, uuid.bytes[6]) << 8 * 6;
    uuid128 = uuid128 | @as(u128, uuid.bytes[7]) << 8 * 7;

    uuid128 = uuid128 | @as(u128, uuid.bytes[8]) << 8 * 8;
    uuid128 = uuid128 | @as(u128, uuid.bytes[9]) << 8 * 9;
    uuid128 = uuid128 | @as(u128, uuid.bytes[10]) << 8 * 10;
    uuid128 = uuid128 | @as(u128, uuid.bytes[11]) << 8 * 11;

    uuid128 = uuid128 | @as(u128, uuid.bytes[12]) << 8 * 12;
    uuid128 = uuid128 | @as(u128, uuid.bytes[13]) << 8 * 13;
    uuid128 = uuid128 | @as(u128, uuid.bytes[14]) << 8 * 14;
    uuid128 = uuid128 | @as(u128, uuid.bytes[15]) << 8 * 15;

    return uuid128;
}

test "uuid to u128 - nil and max" {
    const nil = UUID.nil;
    const max = UUID.max;

    const nil_u128 = nil.toU128();
    const max_u128 = max.toU128();

    try std.testing.expect(nil_u128 == 0);
    try std.testing.expect(max_u128 == ~nil_u128);
}

// time_low 32 | time_mid 16 | version 4 | time_high 12 | variant 2 | clock_seq 14 |  node 48
const UUID_V1 = struct {
    fn new(uuid: *UUID, node_id: u64) void {
        // greg timestamp
        const time = @as(u64, @intCast(std.time.milliTimestamp() + ((-std.time.epoch.clr) << 10)));

        // time_low
        uuid.bytes[0] = @as(u8, @truncate(time >> 24));
        uuid.bytes[1] = @as(u8, @truncate(time >> 16));
        uuid.bytes[2] = @as(u8, @truncate(time >> 8));
        uuid.bytes[3] = @as(u8, @truncate(time));

        // time_mid
        uuid.bytes[4] = @as(u8, @truncate(time >> 40));
        uuid.bytes[5] = @as(u8, @truncate(time >> 32));

        // time_high
        uuid.bytes[6] = @as(u8, @truncate(time >> 56));
        uuid.bytes[7] = @as(u8, @truncate(time >> 48));

        // clock_seq
        std.crypto.random.bytes(&uuid.bytes[8..10]); // occupies clock sequence bytes

        // On systems utilizing a 64-bit MAC address,
        // the least significant, rightmost 48 bits MAY be used
        uuid.bytes[10] = @as(u8, @truncate(node_id >> 40));
        uuid.bytes[11] = @as(u8, @truncate(node_id >> 32));
        uuid.bytes[12] = @as(u8, @truncate(node_id >> 24));
        uuid.bytes[13] = @as(u8, @truncate(node_id >> 16));
        uuid.bytes[14] = @as(u8, @truncate(node_id >> 8));
        uuid.bytes[15] = @as(u8, @truncate(node_id));

        // Version 1
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x10;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// random_a 48 | version 4 | random_b 12 | variant 2 | random_c 62
const UUID_V3 = struct {
    fn new(uuid: *UUID, stream: []const u8) void {
        var md5_hash = std.crypto.hash.Md5.init(.{});
        md5_hash.update(stream);

        var out_bytes: [20]u8 = undefined;
        md5_hash.final(&out_bytes);

        @memcpy(uuid.*.bytes[0..], out_bytes[0..16]);

        // Version 3
        uuid.*.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x30;

        // Variant RFC9562
        uuid.*.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// md5_high 48 | version 4 | md5_mid 12 | variant 2 | md5_low 62
const UUID_V4 = struct {
    fn new(uuid: *UUID) void {
        std.crypto.random.bytes(&uuid.bytes);

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

        @memcpy(uuid.*.bytes[0..], out_bytes[0..16]);

        // Version 5
        uuid.*.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x50;

        // Variant RFC9562
        uuid.*.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// time_high 32 | time_mid 16 | version 4 | time_low 12 | variant 2 | clock_seq 14 |  node 48
const UUID_V6 = struct {
    fn new(uuid: *UUID, node_id: u64) void {
        // greg timestamp
        const time = @as(u64, @intCast(std.time.milliTimestamp() + ((-std.time.epoch.clr) << 10)));

        // time_high
        uuid.bytes[0] = @as(u8, @truncate(time >> 56));
        uuid.bytes[1] = @as(u8, @truncate(time >> 48));
        uuid.bytes[2] = @as(u8, @truncate(time >> 40));
        uuid.bytes[3] = @as(u8, @truncate(time >> 32));

        // time_mid
        uuid.bytes[4] = @as(u8, @truncate(time >> 24));
        uuid.bytes[5] = @as(u8, @truncate(time >> 16));

        // time_low
        uuid.bytes[6] = @as(u8, @truncate(time >> 8));
        uuid.bytes[7] = @as(u8, @truncate(time));

        // clock_seq
        std.crypto.random.bytes(uuid.bytes[8..10]); // occupies clock sequence bytes

        // On systems utilizing a 64-bit MAC address,
        // the least significant, rightmost 48 bits MAY be used
        uuid.bytes[10] = @as(u8, @truncate(node_id >> 40));
        uuid.bytes[11] = @as(u8, @truncate(node_id >> 32));
        uuid.bytes[12] = @as(u8, @truncate(node_id >> 24));
        uuid.bytes[13] = @as(u8, @truncate(node_id >> 16));
        uuid.bytes[14] = @as(u8, @truncate(node_id >> 8));
        uuid.bytes[15] = @as(u8, @truncate(node_id));

        // Version 6
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x10;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// unix_ts_ms 48 | version 4 | rand_a 12 | variant 2 | rand_b 62
const UUID_V7 = struct {
    fn new(uuid: *UUID) void {
        // unix timestamp
        const time = @as(u64, @intCast(std.time.milliTimestamp()));

        // time_high
        uuid.bytes[0] = @as(u8, @truncate(time >> 40));
        uuid.bytes[1] = @as(u8, @truncate(time >> 32));
        uuid.bytes[2] = @as(u8, @truncate(time >> 24));
        uuid.bytes[3] = @as(u8, @truncate(time >> 16));
        uuid.bytes[4] = @as(u8, @truncate(time >> 8));
        uuid.bytes[5] = @as(u8, @truncate(time));

        // rand_a and rand_b
        std.crypto.random.bytes(uuid.bytes[6..16]); // occupies clock sequence bytes

        // Version 7
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x10;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};

// custom_a 48 | version 4 | custom_b 12 | variant 2 | custom_c 62
const UUID_V8 = struct {

    // TODO: notify that 6 bits are resereved for variant and versions
    fn new(uuid: *UUID, stream: [16]u8) void {
        @memcpy(uuid.*.bytes[0..], stream[0..16]);

        // Version 8
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x80;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }

    fn new_sha256(uuid: *UUID, stream: []const u8) void {
        var sha1_hash = std.crypto.hash.sha2.Sha256.init(.{});
        sha1_hash.update(stream);

        var out_bytes: [20]u8 = undefined;
        sha1_hash.final(&out_bytes);

        @memcpy(uuid.*.bytes[0..], out_bytes[0..16]);

        // Version 8
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x80;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }

    fn new_sha512(uuid: *UUID, stream: []const u8) void {
        var sha1_hash = std.crypto.hash.sha2.Sha512.init(.{});
        sha1_hash.update(stream);

        var out_bytes: [20]u8 = undefined;
        sha1_hash.final(&out_bytes);

        @memcpy(uuid.*.bytes[0..], out_bytes[0..16]);

        // Version 8
        uuid.bytes[6] = (uuid.bytes[6] & 0x0f) | 0x80;

        // Variant RFC9562
        uuid.bytes[8] = (uuid.bytes[8] & 0x3f) | 0x80;
    }
};
