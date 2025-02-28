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
