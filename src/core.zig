// TODO: WHERE IS THE 0 VARIANT?
// ietf : Reserved. Network Computing System (NCS) backward compatibility, and includes Nil UUID as per Section 5.9.
// but it doesnt mention variant 0
pub const Variant = enum {
    reserved_ncs_backward, // 1-7 includes Nil UUID
    rfc9562, // 8-9,A-B
    reserved_microsoft, // C-D
    reserved_future, // E-F includes Max UUID
};

pub fn variant(int: u4) Variant {
    return switch (int) {
        // 0b0000...0b0111 => .reserved_ncs_backward, // nil is missing??
        0b0001...0b0111 => .reserved_ncs_backward,
        0b1000...0b1011 => .rfc9562,
        0b1100...0b1101 => .reserved_microsoft,
        0b1110...0b1111 => .reserved_future,
        else => @panic("TODO"),
    };
}
