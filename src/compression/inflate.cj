/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 *
 * This is a class library that implements the function of decompressing data.
 * Provides stream decompression interfaces such as inflateInit, inflate, inflateEnd,  and setDictionary.
 */

package xmpp4cj.compression

/* Some constants */
let ENOUGH_LENS: UInt32 = 852
let ENOUGH_DISTS: UInt32 = 592
let MAXBITS: Int64 = 15
let TYPE_CODES: UInt32 = 1
let TYPE_LENS: UInt32 = 2
let TYPE_DISTS: UInt32 = 3

/* Decompression status */
let HEAD: UInt32 = 0
let FLAGS: UInt32 = 1
let TIME: UInt32 = 2
let OS: UInt32 = 3
let EXLEN: UInt32 = 4
let EXTRA: UInt32 = 5
let NAME: UInt32 = 6
let COMMENT: UInt32 = 7
let HCRC: UInt32 = 8
let DICTID: UInt32 = 9
let DICT: UInt32 = 10
let TYPE: UInt32 = 11
let TYPEDO: UInt32 = 12
let STORED: UInt32 = 13
let COPY_: UInt32 = 14
let COPY: UInt32 = 15
let TABLE: UInt32 = 16
let LENLENS: UInt32 = 17
let CODELENS: UInt32 = 18
let LEN_: UInt32 = 19
let LEN: UInt32 = 20
let LENEXT: UInt32 = 21
let DIST: UInt32 = 22
let DISTEXT: UInt32 = 23
let MATCH: UInt32 = 24
let LIT: UInt32 = 25
let CHECK: UInt32 = 26
let LENGTH: UInt32 = 27
let DONE: UInt32 = 28
let BAD: UInt32 = 29
let MEM: UInt32 = 30
let SYNC: UInt32 = 31

struct Code {
    /*
     * Option value description:
     * 00000000 - Original characters from 0 - 255
     * 0000tttt - Level-2 table link. tttt != 0 indicates the start position of the level-2 table.
     * 0001eeee - Length, distance, or eeee indicates the number of digits occupied by the extended value.
     * 01100000 - block terminator
     * 01000000 - Invalid value.
     */
    public Code(var option: UInt8, var bits: UInt8, var value: UInt16) {}
}

/* Static decompression code table of the literal length */
let lenfix: Array<Code> = [Code(96, 7, 0), Code(0, 8, 80), Code(0, 8, 16), Code(20, 8, 115), Code(18, 7, 31),
    Code(0, 8, 112), Code(0, 8, 48), Code(0, 9, 192), Code(16, 7, 10), Code(0, 8, 96), Code(0, 8, 32), Code(0, 9, 160),
    Code(0, 8, 0), Code(0, 8, 128), Code(0, 8, 64), Code(0, 9, 224), Code(16, 7, 6), Code(0, 8, 88), Code(0, 8, 24),
    Code(0, 9, 144), Code(19, 7, 59), Code(0, 8, 120), Code(0, 8, 56), Code(0, 9, 208), Code(17, 7, 17), Code(0, 8, 104),
    Code(0, 8, 40), Code(0, 9, 176), Code(0, 8, 8), Code(0, 8, 136), Code(0, 8, 72), Code(0, 9, 240), Code(16, 7, 4),
    Code(0, 8, 84), Code(0, 8, 20), Code(21, 8, 227), Code(19, 7, 43), Code(0, 8, 116), Code(0, 8, 52), Code(0, 9, 200),
    Code(17, 7, 13), Code(0, 8, 100), Code(0, 8, 36), Code(0, 9, 168), Code(0, 8, 4), Code(0, 8, 132), Code(0, 8, 68),
    Code(0, 9, 232), Code(16, 7, 8), Code(0, 8, 92), Code(0, 8, 28), Code(0, 9, 152), Code(20, 7, 83), Code(0, 8, 124),
    Code(0, 8, 60), Code(0, 9, 216), Code(18, 7, 23), Code(0, 8, 108), Code(0, 8, 44), Code(0, 9, 184), Code(0, 8, 12),
    Code(0, 8, 140), Code(0, 8, 76), Code(0, 9, 248), Code(16, 7, 3), Code(0, 8, 82), Code(0, 8, 18), Code(21, 8, 163),
    Code(19, 7, 35), Code(0, 8, 114), Code(0, 8, 50), Code(0, 9, 196), Code(17, 7, 11), Code(0, 8, 98), Code(0, 8, 34),
    Code(0, 9, 164), Code(0, 8, 2), Code(0, 8, 130), Code(0, 8, 66), Code(0, 9, 228), Code(16, 7, 7), Code(0, 8, 90),
    Code(0, 8, 26), Code(0, 9, 148), Code(20, 7, 67), Code(0, 8, 122), Code(0, 8, 58), Code(0, 9, 212), Code(18, 7, 19),
    Code(0, 8, 106), Code(0, 8, 42), Code(0, 9, 180), Code(0, 8, 10), Code(0, 8, 138), Code(0, 8, 74), Code(0, 9, 244),
    Code(16, 7, 5), Code(0, 8, 86), Code(0, 8, 22), Code(64, 8, 0), Code(19, 7, 51), Code(0, 8, 118), Code(0, 8, 54),
    Code(0, 9, 204), Code(17, 7, 15), Code(0, 8, 102), Code(0, 8, 38), Code(0, 9, 172), Code(0, 8, 6), Code(0, 8, 134),
    Code(0, 8, 70), Code(0, 9, 236), Code(16, 7, 9), Code(0, 8, 94), Code(0, 8, 30), Code(0, 9, 156), Code(20, 7, 99),
    Code(0, 8, 126), Code(0, 8, 62), Code(0, 9, 220), Code(18, 7, 27), Code(0, 8, 110), Code(0, 8, 46), Code(0, 9, 188),
    Code(0, 8, 14), Code(0, 8, 142), Code(0, 8, 78), Code(0, 9, 252), Code(96, 7, 0), Code(0, 8, 81), Code(0, 8, 17),
    Code(21, 8, 131), Code(18, 7, 31), Code(0, 8, 113), Code(0, 8, 49), Code(0, 9, 194), Code(16, 7, 10), Code(0, 8, 97),
    Code(0, 8, 33), Code(0, 9, 162), Code(0, 8, 1), Code(0, 8, 129), Code(0, 8, 65), Code(0, 9, 226), Code(16, 7, 6),
    Code(0, 8, 89), Code(0, 8, 25), Code(0, 9, 146), Code(19, 7, 59), Code(0, 8, 121), Code(0, 8, 57), Code(0, 9, 210),
    Code(17, 7, 17), Code(0, 8, 105), Code(0, 8, 41), Code(0, 9, 178), Code(0, 8, 9), Code(0, 8, 137), Code(0, 8, 73),
    Code(0, 9, 242), Code(16, 7, 4), Code(0, 8, 85), Code(0, 8, 21), Code(16, 8, 258), Code(19, 7, 43), Code(0, 8, 117),
    Code(0, 8, 53), Code(0, 9, 202), Code(17, 7, 13), Code(0, 8, 101), Code(0, 8, 37), Code(0, 9, 170), Code(0, 8, 5),
    Code(0, 8, 133), Code(0, 8, 69), Code(0, 9, 234), Code(16, 7, 8), Code(0, 8, 93), Code(0, 8, 29), Code(0, 9, 154),
    Code(20, 7, 83), Code(0, 8, 125), Code(0, 8, 61), Code(0, 9, 218), Code(18, 7, 23), Code(0, 8, 109), Code(0, 8, 45),
    Code(0, 9, 186), Code(0, 8, 13), Code(0, 8, 141), Code(0, 8, 77), Code(0, 9, 250), Code(16, 7, 3), Code(0, 8, 83),
    Code(0, 8, 19), Code(21, 8, 195), Code(19, 7, 35), Code(0, 8, 115), Code(0, 8, 51), Code(0, 9, 198), Code(17, 7, 11),
    Code(0, 8, 99), Code(0, 8, 35), Code(0, 9, 166), Code(0, 8, 3), Code(0, 8, 131), Code(0, 8, 67), Code(0, 9, 230),
    Code(16, 7, 7), Code(0, 8, 91), Code(0, 8, 27), Code(0, 9, 150), Code(20, 7, 67), Code(0, 8, 123), Code(0, 8, 59),
    Code(0, 9, 214), Code(18, 7, 19), Code(0, 8, 107), Code(0, 8, 43), Code(0, 9, 182), Code(0, 8, 11), Code(0, 8, 139),
    Code(0, 8, 75), Code(0, 9, 246), Code(16, 7, 5), Code(0, 8, 87), Code(0, 8, 23), Code(64, 8, 0), Code(19, 7, 51),
    Code(0, 8, 119), Code(0, 8, 55), Code(0, 9, 206), Code(17, 7, 15), Code(0, 8, 103), Code(0, 8, 39), Code(0, 9, 174),
    Code(0, 8, 7), Code(0, 8, 135), Code(0, 8, 71), Code(0, 9, 238), Code(16, 7, 9), Code(0, 8, 95), Code(0, 8, 31),
    Code(0, 9, 158), Code(20, 7, 99), Code(0, 8, 127), Code(0, 8, 63), Code(0, 9, 222), Code(18, 7, 27), Code(0, 8, 111),
    Code(0, 8, 47), Code(0, 9, 190), Code(0, 8, 15), Code(0, 8, 143), Code(0, 8, 79), Code(0, 9, 254), Code(96, 7, 0),
    Code(0, 8, 80), Code(0, 8, 16), Code(20, 8, 115), Code(18, 7, 31), Code(0, 8, 112), Code(0, 8, 48), Code(0, 9, 193),
    Code(16, 7, 10), Code(0, 8, 96), Code(0, 8, 32), Code(0, 9, 161), Code(0, 8, 0), Code(0, 8, 128), Code(0, 8, 64),
    Code(0, 9, 225), Code(16, 7, 6), Code(0, 8, 88), Code(0, 8, 24), Code(0, 9, 145), Code(19, 7, 59), Code(0, 8, 120),
    Code(0, 8, 56), Code(0, 9, 209), Code(17, 7, 17), Code(0, 8, 104), Code(0, 8, 40), Code(0, 9, 177), Code(0, 8, 8),
    Code(0, 8, 136), Code(0, 8, 72), Code(0, 9, 241), Code(16, 7, 4), Code(0, 8, 84), Code(0, 8, 20), Code(21, 8, 227),
    Code(19, 7, 43), Code(0, 8, 116), Code(0, 8, 52), Code(0, 9, 201), Code(17, 7, 13), Code(0, 8, 100), Code(0, 8, 36),
    Code(0, 9, 169), Code(0, 8, 4), Code(0, 8, 132), Code(0, 8, 68), Code(0, 9, 233), Code(16, 7, 8), Code(0, 8, 92),
    Code(0, 8, 28), Code(0, 9, 153), Code(20, 7, 83), Code(0, 8, 124), Code(0, 8, 60), Code(0, 9, 217), Code(18, 7, 23),
    Code(0, 8, 108), Code(0, 8, 44), Code(0, 9, 185), Code(0, 8, 12), Code(0, 8, 140), Code(0, 8, 76), Code(0, 9, 249),
    Code(16, 7, 3), Code(0, 8, 82), Code(0, 8, 18), Code(21, 8, 163), Code(19, 7, 35), Code(0, 8, 114), Code(0, 8, 50),
    Code(0, 9, 197), Code(17, 7, 11), Code(0, 8, 98), Code(0, 8, 34), Code(0, 9, 165), Code(0, 8, 2), Code(0, 8, 130),
    Code(0, 8, 66), Code(0, 9, 229), Code(16, 7, 7), Code(0, 8, 90), Code(0, 8, 26), Code(0, 9, 149), Code(20, 7, 67),
    Code(0, 8, 122), Code(0, 8, 58), Code(0, 9, 213), Code(18, 7, 19), Code(0, 8, 106), Code(0, 8, 42), Code(0, 9, 181),
    Code(0, 8, 10), Code(0, 8, 138), Code(0, 8, 74), Code(0, 9, 245), Code(16, 7, 5), Code(0, 8, 86), Code(0, 8, 22),
    Code(64, 8, 0), Code(19, 7, 51), Code(0, 8, 118), Code(0, 8, 54), Code(0, 9, 205), Code(17, 7, 15), Code(0, 8, 102),
    Code(0, 8, 38), Code(0, 9, 173), Code(0, 8, 6), Code(0, 8, 134), Code(0, 8, 70), Code(0, 9, 237), Code(16, 7, 9),
    Code(0, 8, 94), Code(0, 8, 30), Code(0, 9, 157), Code(20, 7, 99), Code(0, 8, 126), Code(0, 8, 62), Code(0, 9, 221),
    Code(18, 7, 27), Code(0, 8, 110), Code(0, 8, 46), Code(0, 9, 189), Code(0, 8, 14), Code(0, 8, 142), Code(0, 8, 78),
    Code(0, 9, 253), Code(96, 7, 0), Code(0, 8, 81), Code(0, 8, 17), Code(21, 8, 131), Code(18, 7, 31), Code(0, 8, 113),
    Code(0, 8, 49), Code(0, 9, 195), Code(16, 7, 10), Code(0, 8, 97), Code(0, 8, 33), Code(0, 9, 163), Code(0, 8, 1),
    Code(0, 8, 129), Code(0, 8, 65), Code(0, 9, 227), Code(16, 7, 6), Code(0, 8, 89), Code(0, 8, 25), Code(0, 9, 147),
    Code(19, 7, 59), Code(0, 8, 121), Code(0, 8, 57), Code(0, 9, 211), Code(17, 7, 17), Code(0, 8, 105), Code(0, 8, 41),
    Code(0, 9, 179), Code(0, 8, 9), Code(0, 8, 137), Code(0, 8, 73), Code(0, 9, 243), Code(16, 7, 4), Code(0, 8, 85),
    Code(0, 8, 21), Code(16, 8, 258), Code(19, 7, 43), Code(0, 8, 117), Code(0, 8, 53), Code(0, 9, 203), Code(17, 7, 13),
    Code(0, 8, 101), Code(0, 8, 37), Code(0, 9, 171), Code(0, 8, 5), Code(0, 8, 133), Code(0, 8, 69), Code(0, 9, 235),
    Code(16, 7, 8), Code(0, 8, 93), Code(0, 8, 29), Code(0, 9, 155), Code(20, 7, 83), Code(0, 8, 125), Code(0, 8, 61),
    Code(0, 9, 219), Code(18, 7, 23), Code(0, 8, 109), Code(0, 8, 45), Code(0, 9, 187), Code(0, 8, 13), Code(0, 8, 141),
    Code(0, 8, 77), Code(0, 9, 251), Code(16, 7, 3), Code(0, 8, 83), Code(0, 8, 19), Code(21, 8, 195), Code(19, 7, 35),
    Code(0, 8, 115), Code(0, 8, 51), Code(0, 9, 199), Code(17, 7, 11), Code(0, 8, 99), Code(0, 8, 35), Code(0, 9, 167),
    Code(0, 8, 3), Code(0, 8, 131), Code(0, 8, 67), Code(0, 9, 231), Code(16, 7, 7), Code(0, 8, 91), Code(0, 8, 27),
    Code(0, 9, 151), Code(20, 7, 67), Code(0, 8, 123), Code(0, 8, 59), Code(0, 9, 215), Code(18, 7, 19), Code(0, 8, 107),
    Code(0, 8, 43), Code(0, 9, 183), Code(0, 8, 11), Code(0, 8, 139), Code(0, 8, 75), Code(0, 9, 247), Code(16, 7, 5),
    Code(0, 8, 87), Code(0, 8, 23), Code(64, 8, 0), Code(19, 7, 51), Code(0, 8, 119), Code(0, 8, 55), Code(0, 9, 207),
    Code(17, 7, 15), Code(0, 8, 103), Code(0, 8, 39), Code(0, 9, 175), Code(0, 8, 7), Code(0, 8, 135), Code(0, 8, 71),
    Code(0, 9, 239), Code(16, 7, 9), Code(0, 8, 95), Code(0, 8, 31), Code(0, 9, 159), Code(20, 7, 99), Code(0, 8, 127),
    Code(0, 8, 63), Code(0, 9, 223), Code(18, 7, 27), Code(0, 8, 111), Code(0, 8, 47), Code(0, 9, 191), Code(0, 8, 15),
    Code(0, 8, 143), Code(0, 8, 79), Code(0, 9, 255)]

/* Distance static decompression code table */
let distfix: Array<Code> = [Code(16, 5, 1), Code(23, 5, 257), Code(19, 5, 17), Code(27, 5, 4097), Code(17, 5, 5),
    Code(25, 5, 1025), Code(21, 5, 65), Code(29, 5, 16385), Code(16, 5, 3), Code(24, 5, 513), Code(20, 5, 33),
    Code(28, 5, 8193), Code(18, 5, 9), Code(26, 5, 2049), Code(22, 5, 129), Code(64, 5, 0), Code(16, 5, 2),
    Code(23, 5, 385), Code(19, 5, 25), Code(27, 5, 6145), Code(17, 5, 7), Code(25, 5, 1537), Code(21, 5, 97),
    Code(29, 5, 24577), Code(16, 5, 4), Code(24, 5, 769), Code(20, 5, 49), Code(28, 5, 12289), Code(18, 5, 13),
    Code(26, 5, 3073), Code(22, 5, 193), Code(64, 5, 0)]
let lbase: Array<UInt16> = [3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31, 35, 43, 51, 59, 67, 83, 99, 115,
    131, 163, 195, 227, 258, 0, 0]
let lext: Array<UInt16> = [16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 18, 18, 18, 18, 19, 19, 19, 19, 20, 20, 20,
    20, 21, 21, 21, 21, 16, 198, 196]
let dbase: Array<UInt16> = [1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513, 769, 1025, 1537,
    2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577, 0, 0]
let dext: Array<UInt16> = [16, 16, 16, 16, 17, 17, 18, 18, 19, 19, 20, 20, 21, 21, 22, 22, 23, 23, 24, 24, 25, 25, 26,
    26, 27, 27, 28, 28, 29, 29, 64, 64]

enum ReturnType {
    | BREAK
    | RETURN
    | RET_BREAK
    | OTHER
}

class ReturnValue {
    public var rtype: ReturnType = OTHER
    public var value: Int64 = 0
    public init(rtype!: ReturnType = OTHER, value!: Int64 = 0) {
        this.rtype = rtype
        this.value = value
    }
    public func clear() {
        rtype = OTHER
        value = 0
    }
}

/**
 * This class Inflate implements the uncompression function
 *
 * @since 0.28.4
 */
class Inflate <: Stream {

    /* Current Decompression Status */
    private var mode: UInt32 = HEAD

    /* Last compressed block flag */
    private var last: Bool = false

    /* Data wrapper type: ZLIB_TYPE, or DEFLATE_TYPE (without wrapper) */
    private var wrap: WrapTypeEnum = ZLIB_TYPE

    /* Whether a dictionary is required */
    private var havedict: Bool = false
    private var flags: Int32 = -1
    private var dmax: UInt32 = 32768
    private var check: UInt32 = 0

    /* Check the verification value */
    private var ischeck: Bool = false
    private var total: Int64 = 0
    private var wbits: UInt32 = 0
    private var wsize: UInt32 = 0
    private var whave: UInt32 = 0
    private var wnext: UInt32 = 0
    private var window: Array<UInt8> = Array<UInt8>()
    private var hold: UInt32 = 0
    private var bits: UInt32 = 0
    private var length: UInt32 = 0
    private var offset: UInt32 = 0
    private var extra: UInt32 = 0
    private var lencodes: Array<Code> = Array<Code>()
    private var distcodes: Array<Code> = Array<Code>()
    private var lendyn: Array<Code> = Array<Code>()
    private var distdyn: Array<Code> = Array<Code>()
    private var lenbits: UInt32 = 0
    private var distbits: UInt32 = 0
    private var ncode: UInt32 = 0
    private var nlen: UInt32 = 0
    private var ndist: UInt32 = 0
    private var have: UInt32 = 0
    private var codelens: Array<UInt16> = Array<UInt16>()
    private var work: Array<UInt16> = Array<UInt16>()
    private var back: Int32 = -1
    private var was: UInt32 = 0
    private var flush: UInt32 = Z_NO_FLUSH
    private var initout: Int64 = 0

    /**
     * The Function is Inflate init constructor
     *
     * @since 0.28.4
     */
    public init() {}

    /**
     * Bind the input and output buffers, initialize decompression parameters and status, and apply for memory for the buffer.
     *
     * @param wrap Compressed data outer wrapper type, the default value is ZLIB_TYPE.
     *      Compressed file format: ZLIB_TYPE/DEFLATE_TYPE
     * @param wbits Number of Window Bits, the default value is DEF_WINDOW_BITS.
     *      Window Bits：8-15, DEF_WINDOW_BITS = 15
     * @param ischeck Check the inspection value of raw data and gzip header.
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func inflateInit(wrap!: WrapTypeEnum = ZLIB_TYPE, wbits!: UInt32 = DEF_WINDOW_BITS, ischeck!: Bool = true): UInt32 {
        if (wbits < MIN_WINDOW_BITS || wbits > MAX_WINDOW_BITS) {
            message = error_msg[Int64(Z_BUF_ERROR)]
            return Z_BUF_ERROR
        }
        mode = HEAD
        last = false
        this.wrap = wrap
        havedict = false
        flags = -1
        dmax = 32768
        check = 0
        this.ischeck = ischeck
        total = 0
        this.wbits = wbits
        wsize = 1 << wbits
        whave = 0
        wnext = 0
        hold = 0
        bits = 0
        length = 0
        offset = 0
        extra = 0
        lenbits = 0
        distbits = 0
        ncode = 0
        nlen = 0
        ndist = 0
        have = 0
        back = -1
        was = 0
        try {
            window = Array<UInt8>(Int64(wsize), repeat: 0)
            lendyn = Array<Code>(Int64(ENOUGH_LENS), {_ => Code(0, 0, 0)})
            distdyn = Array<Code>(Int64(ENOUGH_DISTS), {_ => Code(0, 0, 0)})
            codelens = Array<UInt16>(320, repeat: 0)
            work = Array<UInt16>(288, repeat: 0)
        } catch (e: Exception) {
            message = error_msg[Int64(Z_MEM_ERROR)]
            return Z_MEM_ERROR
        }
        return Z_OK
    }

    /**
     * Decompressing Data.
     *
     * @param flush The operation of flushing stored data to a spectified area,the value is:
     *      Z_SYNC_FLUSH: Require inflate() to flush as much output as possible into the output buffer.
     *      Z_BLOCK: This parameter option is useful when merging deflate streams or adding content to existing streams.
     *              It can be used to check the number of bits of data currently consumed.
     *      Z_TREES: It can be used to check the length of the deflate block header for random access in the deflate block later.
     *      Z_FINISH: All decompression operations need to be completed in one call, all inputs will be processed and all
     *              outputs will be flushed out.
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func inflate(flush: UInt32): UInt32 {
        message = ""
        if (mode == TYPE) {
            mode = TYPEDO
        }
        var ret: UInt32 = Z_OK
        var initin: Int64 = avail_in
        initout = avail_out
        var inflateFuncTable: Array<() -> ReturnValue> = [HEADFunc, FLAGSFunc, TIMEFunc, OSFunc, EXLENFunc, EXTRAFunc,
            NAMEFunc, COMMENTFunc, HCRCFunc, DICTIDFunc, DICTFunc, TYPEFunc, TYPEDOFunc, STOREDFunc, COPY_Func,
            COPYFunc, TABLEFunc, LENLENSFunc, CODELENSFunc, LEN_Func, LENFunc, LENEXTFunc, DISTFunc, DISTEXTFunc,
            MATCHFunc, LITFunc, CHECKFunc, LENGTHFunc, DONEFunc, BADFunc, MEMFunc, SYNCFunc]
        var returnValue = ReturnValue(rtype: OTHER, value: 0)
        while (true) {
            returnValue = inflateFuncTable[Int64(mode)]()
            match (returnValue.rtype) {
                case BREAK => break
                case RETURN => return UInt32(returnValue.value)
                case RET_BREAK =>
                    ret = UInt32(returnValue.value)
                    break
                case OTHER => ()
            }
            returnValue.clear()
        }
        initin -= avail_in
        initout -= avail_out
        total_in += initin
        total_out += initout
        total += initout
        var outputstart: Int64 = pos_out - initout
        if (ischeck && initout > 0) {
            if (flags != 0) {
                check = crc32(check, next_out, outputstart, initout)
            } else {
                check = adler32(check, next_out, outputstart, initout)
            }
            adler = check
        }
        if (initout > 0 && mode < BAD && (mode < CHECK || flush != Z_FINISH)) {
            updateWindow(next_out, outputstart, initout)
        }
        makeDataTypeValue()
        if (((initin == 0 && initout == 0) || flush == Z_FINISH) && ret == Z_OK) {
            ret = Z_BUF_ERROR
        }
        return ret
    }

    private func makeDataTypeValue() {
        data_type = Int32(bits)
        if (last) {
            data_type += 64
        }
        if (mode == TYPE) {
            data_type += 128
        }
        if (mode == LEN_ || mode == COPY_) {
            data_type += 256
        }
    }

    /**
     * This command is invoked after the uncompression is complete to check the uncompression status
     *
     * @return The return type of UInt32
     * @since 0.28.4
     */
    public func inflateEnd(): UInt32 {
        return Z_OK
    }

    /**
     * Set dictionary
     * When the wraptype type is DEFLATE_TYPE, it is called after inflateinit and before inflate
     * When the wraptype type is ZLIB_TYPE, Return Z in inflate_ NEED_ Called after dict (return value of function: z\need\dict = 2)
     * If a dictionary is set during compression, the same dictionary must be set before decompression
     *
     * @param dict Set the data in array dict as a dictionary
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func setDictionary(dict: Array<UInt8>): UInt32 {
        if (mode < HEAD || mode > SYNC) {
            message = error_msg[Int64(Z_STREAM_ERROR)]
            return Z_STREAM_ERROR
        }
        match (wrap) {
            case DEFLATE_TYPE => ()
            case _ =>
                if (mode != DICT) {
                    message = error_msg[Int64(Z_STREAM_ERROR)]
                    return Z_STREAM_ERROR
                }
        }
        if (mode == DICT) {
            var dictid: UInt32 = adler32(0, Array<UInt8>(), 0, 0)
            dictid = adler32(dictid, dict, 0, dict.size)
            if (dictid != check) {
                message = "dictionary data error"
                return Z_DATA_ERROR
            }
        }
        updateWindow(dict, 0, dict.size)
        havedict = true
        message = ""
        return Z_OK
    }

    /**
     * Skip illegal compressed data during decompression and start decompression from the next full refresh point
     * when flush is Z_FULL_FLUSH, Ccmpressed data with full refresh points is generated
     *
     * @return The return type of UInt32
     * @since 0.28.4
     */
    public func inflateSync(): UInt32 {
        var len: Int64
        var buf: Array<UInt8> = Array<UInt8>(4, repeat: 0)

        if (mode < HEAD || mode > SYNC) {
            message = error_msg[Int64(Z_STREAM_ERROR)]
            return Z_STREAM_ERROR
        }
        if (avail_in == 0 && bits < 8) {
            return Z_BUF_ERROR
        }

        if (mode != SYNC) {
            mode = SYNC
            hold <<= bits & 7
            bits -= bits & 7
            len = 0
            while (bits >= 8) {
                buf[len] = UInt8(hold & 0xFF)
                len++
                hold >>= 8
                bits -= 8
            }
            have = 0
            syncSearch(have, buf, len)
        }

        len = syncSearch(have, next_in, avail_in)
        avail_in -= len
        pos_in += len
        total_in += len

        if (have != 4) {
            return Z_DATA_ERROR
        }

        var t_in: Int64 = total_in
        var t_out: Int64 = total_out
        inflateReset()
        total_in = t_in
        total_out = t_out
        mode = TYPE
        return Z_OK
    }

    private func initBits(): Unit {
        hold = 0
        bits = 0
    }

    private func pullByte(): Bool {
        if (avail_in == 0) {
            return true
        }
        avail_in--
        hold += UInt32(next_in[pos_in]) << bits
        pos_in++
        bits += 8
        return false
    }

    private func needBits(n: UInt32): Bool {
        while (bits < n) {
            if (pullByte()) {
                return true
            }
        }
        return false
    }

    private func getBits(n: UInt32): UInt32 {
        return hold & ((1 << n) - 1)
    }

    private func dropBits(n: UInt32): Unit {
        hold >>= n
        bits -= n
    }

    private func byteBits(): Unit {
        hold >>= bits & 7
        bits -= bits & 7
    }

    private func inflateTable(tabletype: UInt32, midcodelen: UInt32, symnums: UInt32, lens: Array<UInt16>,
        codetable: Array<Code>): Bool {
        var here: Code = Code(0, 0, 0)
        var left: Int32
        var max: UInt32
        var min: UInt32
        var root: UInt32
        var lstart: Int64 = 0
        var flag: Bool
        if (tabletype == TYPE_DISTS) {
            lstart = Int64(nlen)
        }
        /* Counts the number of occurrences of each code length, which is stored in the count array. */
        var count: Array<UInt16> = Array<UInt16>(MAXBITS + 1, repeat: 0)
        var i: Int64 = lstart
        while (i < (lstart + Int64(symnums))) {
            count[Int64(lens[i])] = count[Int64(lens[i])] + 1
            i++
        }
        /* The maximum code length whose frequency is greater than 0 is found. */
        var (maxM, rootM, hereM, flagM) = findMaxCodeFunc(tabletype, midcodelen, count, codetable)
        max = maxM
        root = rootM
        here = hereM
        flag = flagM
        if (!flag) {
            return false
        }
        var (minR, rootMin) = findMinCodeFunc(max, root, count)
        min = minR
        root = rootMin
        var (leftV, flagV) = checkCodeValidityFunc(tabletype, max, count)
        left = leftV
        flag = flagV
        if (flag) {
            return true
        }
        var offs = Array<UInt16>(MAXBITS + 1, repeat: 0)
        i = 1
        while (i < MAXBITS) {
            offs[i + 1] = offs[i] + count[i]
            i++
        }
        i = lstart
        while (i < (lstart + Int64(symnums))) {
            if (lens[i] != 0) {
                work[Int64(offs[Int64(lens[i])])] = UInt16(i - lstart)
                offs[Int64(lens[i])] = offs[Int64(lens[i])] + 1
            }
            i++
        }
        var extra: Array<UInt16>
        var used: UInt32
        var (matchsym, base, extraM, usedM, flagT) = matchTableTypeFunc(tabletype, root)
        extra = extraM
        used = usedM
        flag = flagT
        if (flag) {
            return true
        }
        inflateTableMainFunc(tabletype, codetable, lens, extra, min, max, root, used, here, matchsym, base, count,
            lstart, left)
    }

    private func inflateFast(): Unit {
        var here: Code = Code(0, 0, 0)
        var lmask: UInt32 = (1 << lenbits) - 1
        while (avail_in > 5 && avail_out > 257) {
            inflateFastBitsFunc()
            here = lencodes[Int64(hold & lmask)]
            hold >>= UInt32(here.bits)
            bits -= UInt32(here.bits)
            here = inflateFastBitsFunc(here)
            var breakFlag = inflateFastHereFunc(here)
            if (breakFlag) {
                break
            }
        }
    }

    private func updateWindow(buf: Array<UInt8>, start: Int64, length: Int64): Unit {
        /* 1. If the amount of data to be updated is greater than wsize, copy the data at the end of wsize to the cyclic array window. */
        var i: Int64 = 0
        if (length > Int64(wsize)) {
            let pos: Int64 = start + length - Int64(wsize)
            while (i < Int64(wsize)) {
                window[i] = buf[pos + i]
                i++
            }
            wnext = 0
            whave = wsize
        } else { /* 2. The amount of data to be updated is less than wsize. */
            /* 2.1 Copy data to the [wnext, wsize) range. */
            var pos: Int64 = start
            var dist: UInt32 = wsize - wnext
            if (Int64(dist) > length) {
                dist = UInt32(length)
            }
            i = Int64(wnext)
            while (i < Int64(wnext + dist)) {
                window[i] = buf[pos]
                pos++
                i++
            }
            /* 2.2 The [wnext, wsize) range is insufficient. The remaining data is copied to [0,remain). */
            var remain: Int64 = length - Int64(dist)
            if (remain > 0) {
                i = 0
                while (i < remain) {
                    window[i] = buf[pos]
                    pos++
                    i++
                }
                wnext = UInt32(remain)
                whave = wsize
            } else { /* 2.3 [wnext, wsize] is sufficient. You only need to update wnext and whave. */
                wnext += dist
                if (wnext == wsize) {
                    wnext = 0
                }
                if (whave < wsize) {
                    whave += dist
                }
            }
        }
    }

    private func syncSearch(have: UInt32, buf: Array<UInt8>, length: Int64): Int64 {
        var got: UInt32
        got = have
        var next: Int64 = 0
        while (next < length && got < 4) {
            let res: UInt8 = if (got < 2) {
                0
            } else {
                0xFF
            }
            if (buf[next] == res) {
                got++
            } else if (buf[next] != 0) {
                got = 0
            } else {
                got = 4 - got
            }
            next++
        }
        this.have = got
        return next
    }

    private func inflateReset(): UInt32 {
        if (mode < HEAD || mode > SYNC) {
            return Z_STREAM_ERROR
        }
        wsize = 0
        whave = 0
        wnext = 0
        total_in = 0
        total_out = 0
        total = 0
        mode = HEAD
        message = ""
        last = false
        havedict = false
        dmax = 32768
        hold = 0
        bits = 0
        lencodes = Array<Code>()
        distcodes = Array<Code>()
        back = -1
        return Z_OK
    }

    private func HEADFunc(): ReturnValue {
        var len: UInt32 = 0
        match (wrap) {
            case DEFLATE_TYPE => mode = TYPEDO
            case ZLIB_TYPE =>
                if (needBits(16)) {
                    return ReturnValue(rtype: BREAK)
                }
                if ((((getBits(8) << 8) + (hold >> 8)) % 31) != 0) {
                    makeModeAndMessage(BAD, "incorrect header check")
                    return ReturnValue(rtype: OTHER)
                }
                if (getBits(4) != METHOD_DEFLATE) {
                    makeModeAndMessage(BAD, "unknown compression method")
                    return ReturnValue(rtype: OTHER)
                }
                dropBits(4)
                len = getBits(4) + 8
                if (wbits == 0) {
                    wbits = len
                }
                if (len > 15 || len > wbits) {
                    makeModeAndMessage(BAD, "invalid window size")
                    return ReturnValue(rtype: OTHER)
                }
                makeValue(len)
                initBits()
        }
        return ReturnValue(rtype: OTHER)
    }

    private func makeModeAndMessage(mMode: UInt32, mMessage: String) {
        mode = mMode
        message = mMessage
    }

    private func makeValue(len: UInt32) {
        dmax = 1 << len
        flags = 0
        check = adler32(0, Array<UInt8>(), 0, 0)
        adler = check
        mode = if ((hold & 0x200) != 0) {
            DICTID
        } else {
            TYPE
        }
    }

    private func FLAGSFunc(): ReturnValue {
        var buf: Array<UInt8> = Array<UInt8>()
        if (needBits(16)) {
            return ReturnValue(rtype: BREAK)
        }
        flags = Int32(hold)
        if (UInt32(flags & 0xFF) != METHOD_DEFLATE) {
            message = "unknown compression method"
            mode = BAD
        } else if ((flags & 0xE000) != 0) {
            message = "unknown header flags set"
            mode = BAD
        } else {
            if (ischeck && (flags & 0x0200) != 0) {
                buf = [UInt8(hold & 0xFF), UInt8((hold >> 8) & 0xFF)]
                check = crc32(check, buf, 0, 2)
            }
            initBits()
            mode = TIME
        }
        return ReturnValue(rtype: OTHER)
    }

    private func TIMEFunc(): ReturnValue {
        var buf: Array<UInt8> = Array<UInt8>()
        if (needBits(32)) {
            return ReturnValue(rtype: BREAK)
        }
        if (ischeck && (flags & 0x0200) != 0) {
            buf = [UInt8(hold & 0xFF), UInt8((hold >> 8) & 0xFF), UInt8((hold >> 16) & 0xFF), UInt8((hold >> 24) & 0xFF)]
            check = crc32(check, buf, 0, 4)
        }
        initBits()
        mode = OS
        return ReturnValue(rtype: OTHER)
    }

    private func OSFunc(): ReturnValue {
        var buf: Array<UInt8> = Array<UInt8>()
        if (needBits(16)) {
            return ReturnValue(rtype: BREAK)
        }
        if (ischeck && (flags & 0x0200) != 0) {
            buf = [UInt8(hold & 0xFF), UInt8((hold >> 8) & 0xFF)]
            check = crc32(check, buf, 0, 2)
        }
        initBits()
        mode = EXLEN
        return ReturnValue(rtype: OTHER)
    }

    private func EXLENFunc(): ReturnValue {
        var buf: Array<UInt8> = Array<UInt8>()
        if ((flags & 0x0400) != 0) {
            if (needBits(16)) {
                return ReturnValue(rtype: BREAK)
            }
            length = hold
            if (ischeck && (flags & 0x0200) != 0) {
                buf = [UInt8(hold & 0xFF), UInt8((hold >> 8) & 0xFF)]
                check = crc32(check, buf, 0, 2)
            }
            initBits()
        }
        mode = EXTRA
        return ReturnValue(rtype: OTHER)
    }

    private func EXTRAFunc(): ReturnValue {
        var copy: Int64 = 0
        if ((flags & 0x0400) != 0) {
            copy = Int64(length)
            if (copy > avail_in) {
                copy = avail_in
            }
            if (copy != 0) {
                var i: Int64 = 0
                while (i < copy) {
                    pos_in++
                    i++
                }
                if (ischeck && (flags & 0x0200) != 0) {
                    check = crc32(check, next_in, pos_in - copy, copy)
                }
                avail_in -= copy
                length -= UInt32(copy)
            }
            if (length != 0) {
                return ReturnValue(rtype: BREAK)
            }
        }
        length = 0
        mode = NAME
        return ReturnValue(rtype: OTHER)
    }

    private func NAMEFunc(): ReturnValue {
        if ((flags & 0x0800) != 0) {
            NAMEAndCOMMENTInnerFunc()
        }
        length = 0
        mode = COMMENT
        return ReturnValue(rtype: OTHER)
    }

    private func COMMENTFunc(): ReturnValue {
        if ((flags & 0x1000) != 0) {
            NAMEAndCOMMENTInnerFunc()
        }
        mode = HCRC
        return ReturnValue(rtype: OTHER)
    }

    private func HCRCFunc(): ReturnValue {
        if ((flags & 0x0200) != 0) {
            if (needBits(16)) {
                return ReturnValue(rtype: BREAK)
            }
            if (ischeck && hold != (check & 0xFFFF)) {
                message = "header crc mismatch"
                mode = BAD
                return ReturnValue(rtype: OTHER)
            }
        }
        initBits()
        check = crc32(0, Array<UInt8>(), 0, 0)
        adler = check
        mode = TYPE
        return ReturnValue(rtype: OTHER)
    }

    private func DICTIDFunc(): ReturnValue {
        if (needBits(32)) {
            return ReturnValue(rtype: BREAK)
        }
        check = ((hold >> 24) & 0xFF) + ((hold >> 8) & 0xFF00) + ((hold & 0xFF00) << 8) + ((hold & 0xFF) << 24)
        adler = check
        initBits()
        mode = DICT
        return ReturnValue(rtype: OTHER)
    }

    private func DICTFunc(): ReturnValue {
        if (!havedict) {
            return ReturnValue(rtype: RETURN, value: Int64(Z_NEED_DICT))
        }
        check = adler32(0, Array<UInt8>(), 0, 0)
        adler = check
        mode = TYPE
        return ReturnValue(rtype: OTHER)
    }

    private func TYPEFunc(): ReturnValue {
        if (flush == Z_BLOCK || flush == Z_TREES) {
            return ReturnValue(rtype: BREAK)
        }
        mode = TYPEDO
        return ReturnValue(rtype: OTHER)
    }

    private func TYPEDOFunc(): ReturnValue {
        if (last) {
            byteBits()
            mode = CHECK
        } else {
            if (needBits(3)) {
                return ReturnValue(rtype: BREAK)
            }
            last = if (getBits(1) != 0) {
                true
            } else {
                false
            }
            dropBits(1)
            match (getBits(2)) {
                case 0 => mode = STORED
                case 1 =>
                    mode = LEN_
                    lencodes = lenfix
                    lenbits = 9
                    distcodes = distfix
                    distbits = 5
                    if (flush == Z_TREES) {
                        dropBits(2)
                        return ReturnValue(rtype: BREAK)
                    }
                case 2 =>
                    lencodes = lendyn
                    distcodes = distdyn
                    mode = TABLE
                case _ =>
                    message = "invalid block type"
                    mode = BAD
            }
            dropBits(2)
        }
        return ReturnValue(rtype: OTHER)
    }

    private func STOREDFunc(): ReturnValue {
        byteBits()
        if (needBits(32)) {
            return ReturnValue(rtype: BREAK)
        }
        if ((hold & 0xFFFF) != ((hold >> 16) ^ 0xFFFF)) {
            message = "invalid stored block lengths"
            mode = BAD
        } else {
            length = hold & 0xFFFF
            initBits()
            mode = COPY_
            if (flush == Z_TREES) {
                return ReturnValue(rtype: BREAK)
            }
        }
        return ReturnValue(rtype: OTHER)
    }

    private func COPY_Func(): ReturnValue {
        mode = COPY
        return ReturnValue(rtype: OTHER)
    }

    private func COPYFunc(): ReturnValue {
        var copy: Int64 = Int64(length)
        if (copy > 0) {
            if (copy > avail_in) {
                copy = avail_in
            }
            if (copy > avail_out) {
                copy = avail_out
            }
            if (copy == 0) {
                return ReturnValue(rtype: BREAK)
            }
            var i: Int64 = 0
            while (i < copy) {
                next_out[pos_out] = next_in[pos_in]
                pos_out++
                pos_in++
                i++
            }
            avail_in -= copy
            avail_out -= copy
            length -= UInt32(copy)
        } else {
            mode = TYPE
        }
        return ReturnValue(rtype: OTHER)
    }

    private func TABLEFunc(): ReturnValue {
        if (needBits(14)) {
            return ReturnValue(rtype: BREAK)
        }
        nlen = getBits(5) + 257
        dropBits(5)
        ndist = getBits(5) + 1
        dropBits(5)
        ncode = getBits(4) + 4
        dropBits(4)
        if (nlen > 286 || ndist > 30) {
            message = "too many length or distance symbols"
            mode = BAD
        } else {
            have = 0
            mode = LENLENS
        }
        return ReturnValue(rtype: OTHER)
    }

    private func LENLENSFunc(): ReturnValue {
        var isbreak: Bool = false
        var error: Bool = false
        while (have < ncode) {
            if (needBits(3)) {
                isbreak = true
                break
            }
            codelens[bl_order[Int64(have)]] = UInt16(getBits(3))
            have++
            dropBits(3)
        }
        if (isbreak) {
            return ReturnValue(rtype: BREAK)
        }
        while (have < 19) {
            codelens[bl_order[Int64(have)]] = 0
            have++
        }
        lenbits = 7
        error = inflateTable(TYPE_CODES, lenbits, 19, codelens, lencodes)
        if (error) {
            message = "invalid code lengths set"
            mode = BAD
        } else {
            have = 0
            mode = CODELENS
        }
        return ReturnValue(rtype: OTHER)
    }

    //拆分第一个while
    private func dofirstWhile(): (Bool, Code) {
        var isbreak: Bool = false
        var here: Code = Code(0, 0, 0)
        while (true) {
            here = lencodes[Int64(getBits(lenbits))]
            if (UInt32(here.bits) <= bits) {
                break
            }
            if (pullByte()) {
                isbreak = true
                break
            }
        }
        return (isbreak, here)
    }

    private func doValueLess16(here: Code) {
        dropBits(UInt32(here.bits))
        codelens[Int64(have)] = here.value
        have++
    }

    private func doValueLessEqualMore16(here: Code, mIsbreak: Bool, mLen: UInt32, mCopy: Int64): (Bool, Int64, UInt32, 
        Int64) {
        var isbreak: Bool = mIsbreak
        var len: UInt32 = mLen
        var copy: Int64 = mCopy
        if (here.value == 16) {
            if (needBits(UInt32(here.bits) + 2)) {
                isbreak = true
                return (isbreak, 1, len, copy) //1表示break
            }
            dropBits(UInt32(here.bits))
            if (have == 0) {
                makeModeAndMessage(BAD, "invalid bit length repeat")
                return (isbreak, 2, len, copy) //2表示continue
            }
            len = UInt32(codelens[Int64(have) - 1])
            copy = 3 + Int64(getBits(2))
            dropBits(2)
            return (isbreak, 0, len, copy) //0表示正常
        } else if (here.value == 17) {
            if (needBits(UInt32(here.bits) + 3)) {
                isbreak = true
                return (isbreak, 1, len, copy) //1表示break
            }
            dropBits(UInt32(here.bits))
            len = 0
            copy = 3 + Int64(getBits(3))
            dropBits(3)
            return (isbreak, 0, len, copy) //0表示正常
        } else {
            if (needBits(UInt32(here.bits) + 7)) {
                isbreak = true
                return (isbreak, 1, len, copy)
            }
            dropBits(UInt32(here.bits))
            len = 0
            copy = 11 + Int64(getBits(7))
            dropBits(7)
            return (isbreak, 0, len, copy) //0表示正常
        }
    }

    private func doValueLessEqualMore16Below(len: UInt32, mCopy: Int64): (Int64, Int64) {
        var copy: Int64 = mCopy
        if (have + UInt32(copy) > nlen + ndist) {
            makeModeAndMessage(BAD, "invalid bit length repeat")
            return (2, copy)
        } else {
            while (copy > 0) {
                codelens[Int64(have)] = UInt16(len)
                have++
                copy--
            }
            return (0, copy)
        }
    }

    private func CODELENSFuncFinalRetuen(isbreak: Bool, mError: Bool): ReturnValue {
        var error: Bool = mError
        if (isbreak) {
            return ReturnValue(rtype: BREAK)
        }
        if (mode == BAD) {
            return ReturnValue(rtype: OTHER)
        }
        if (codelens[256] == 0) {
            makeModeAndMessage(BAD, "invalid code -- missing end-of-block")
            return ReturnValue(rtype: OTHER)
        }
        lenbits = 9
        error = inflateTable(TYPE_LENS, lenbits, nlen, codelens, lencodes)
        if (error) {
            makeModeAndMessage(BAD, "invalid literal/lengths set")
            return ReturnValue(rtype: OTHER)
        }
        distbits = 6
        error = inflateTable(TYPE_DISTS, distbits, ndist, codelens, distcodes)
        if (error) {
            makeModeAndMessage(BAD, "invalid distances set")
            return ReturnValue(rtype: OTHER)
        } else {
            mode = LEN_
            if (flush == Z_TREES) {
                return ReturnValue(rtype: BREAK)
            }
        }
        return ReturnValue(rtype: OTHER)
    }

    private func CODELENSFunc(): ReturnValue {
        var isbreak: Bool = false
        var error: Bool = false
        var here: Code = Code(0, 0, 0)
        var len: UInt32 = 0
        var copy: Int64 = 0
        while (have < nlen + ndist) {
            let bcGroup: (Bool, Code) = dofirstWhile()
            isbreak = bcGroup[0]
            here = bcGroup[1]
            if (isbreak) {
                break
            }
            if (here.value < 16) {
                doValueLess16(here)
            } else {
                let res: (Bool, Int64, UInt32, Int64) = doValueLessEqualMore16(here, isbreak, len, copy)
                isbreak = res[0]
                len = res[2]
                copy = res[3]
                if (res[1] == 1) {
                    break
                } else if (res[1] == 2) {
                    continue
                }
                let res2 = doValueLessEqualMore16Below(len, copy)
                copy = res2[1]
                if (res2[0] == 2) {
                    continue
                }
            }
        }
        return CODELENSFuncFinalRetuen(isbreak, error)
    }

    private func LEN_Func(): ReturnValue {
        mode = LEN
        return ReturnValue(rtype: OTHER)
    }

    private func LENFunc(): ReturnValue {
        var here: Code = Code(0, 0, 0)
        var isbreak: Bool = false
        var link: Code = Code(0, 0, 0)
        if (avail_in >= 6 && avail_out >= 258) {
            inflateFast()
            if (mode == TYPE) {
                back = -1
            }
            return ReturnValue(rtype: OTHER)
        }
        back = 0
        while (true) {
            here = lencodes[Int64(getBits(lenbits))]
            if (UInt32(here.bits) <= bits) {
                break
            }
            if (pullByte()) {
                isbreak = true
                break
            }
        }
        if (isbreak) {
            return ReturnValue(rtype: BREAK)
        }
        if (here.option != 0 && (here.option & 0xF0) == 0) {
            /* here is the link node of the level-2 table. */
            link = here
            while (true) {
                here = lencodes[Int64(link.value) + Int64(getBits(UInt32(link.bits + link.option)) >> UInt32(link.bits))]
                if (UInt32(link.bits + here.bits) <= bits) {
                    break
                }
                if (pullByte()) {
                    isbreak = true
                    break
                }
            }
            if (isbreak) {
                return ReturnValue(rtype: BREAK)
            }
            dropBits(UInt32(link.bits))
            back += Int32(link.bits)
        }
        dropBits(UInt32(here.bits))
        back += Int32(here.bits)
        length = UInt32(here.value)
        //modify1
        modeValue(here)
        return ReturnValue(rtype: OTHER)
    }

    private func modeValue(here: Code) {
        if (here.option == 0) {
            /* here is the original character. */
            mode = LIT
        } else if ((here.option & 32) != 0) {
            /* here is a block terminator */
            back = -1
            mode = TYPE
        } else if ((here.option & 64) != 0) {
            /* here Invalid. */
            message = "invalid literal/length code"
            mode = BAD
        } else {
            /* here is length */
            extra = UInt32(here.option & 0x0F)
            mode = LENEXT
        }
    }

    private func LENEXTFunc(): ReturnValue {
        if (extra != 0) {
            if (needBits(extra)) {
                return ReturnValue(rtype: BREAK)
            }
            length += getBits(extra)
            dropBits(extra)
            back += Int32(extra)
        }
        was = length
        mode = DIST
        return ReturnValue(rtype: OTHER)
    }

    private func DISTFunc(): ReturnValue {
        var here: Code = Code(0, 0, 0)
        var isbreak: Bool = false
        var link: Code = Code(0, 0, 0)
        while (true) {
            here = distcodes[Int64(getBits(distbits))]
            if (UInt32(here.bits) <= bits) {
                break
            }
            if (pullByte()) {
                isbreak = true
                break
            }
        }
        if (isbreak) {
            return ReturnValue(rtype: BREAK)
        }
        if ((here.option & 0xF0) == 0) {
            /* here is the link node of the level-2 table. */
            link = here
            while (true) {
                here = distcodes[Int64(link.value) + Int64(getBits(UInt32(link.bits + link.option)) >> UInt32(link.bits))]
                if (UInt32(link.bits + here.bits) < bits) {
                    break
                }
                if (pullByte()) {
                    isbreak = true
                    break
                }
            }
            if (isbreak) {
                return ReturnValue(rtype: BREAK)
            }
            dropBits(UInt32(link.bits))
            back += Int32(link.bits)
        }
        dropBits(UInt32(here.bits))
        back += Int32(here.bits)
        if ((here.option & 64) != 0) {
            /* here Invalid */
            message = "invalid distance code"
            mode = BAD
        } else {
            /* here is distance */
            offset = UInt32(here.value)
            extra = UInt32(here.option & 0x0F)
            mode = DISTEXT
        }
        return ReturnValue(rtype: OTHER)
    }

    private func DISTEXTFunc(): ReturnValue {
        if (extra != 0) {
            if (needBits(extra)) {
                return ReturnValue(rtype: BREAK)
            }
            offset += getBits(extra)
            dropBits(extra)
            back += Int32(extra)
        }
        if (offset > dmax) {
            message = "invalid distance too far back"
            mode = BAD
        } else {
            mode = MATCH
        }
        return ReturnValue(rtype: OTHER)
    }

    private func MATCHFunc(): ReturnValue {
        var copy: Int64 = 0
        var copyfrom: Int64 = 0
        var copybuf: Array<UInt8> = Array<UInt8>()
        if (avail_out == 0) {
            return ReturnValue(rtype: BREAK)
        }
        copy = pos_out
        /* The matching start position is in the window. */
        if (Int64(offset) > copy) {
            copy = Int64(offset) - copy
            /* Remaining distance > Data size in the window, Error reporting. */
            if (copy > Int64(whave)) {
                message = "invalid distance too far back"
                mode = BAD
                return ReturnValue(rtype: OTHER)
            } else if (copy > Int64(wnext)) {
                /* The matching start position is in the [wnext, wsize) range. */
                copy -= Int64(wnext)
                copyfrom = Int64(wsize) - copy
            } else {
                /* The matching start position is in the range [0, wnext). */
                copyfrom = Int64(wnext) - copy
            }
            if (copy > Int64(length)) {
                copy = Int64(length)
            }
            copybuf = window
        } else {
            /* The match start position is in the output buffer and is copied directly. */
            copyfrom = copy - Int64(offset)
            copy = Int64(length)
            copybuf = next_out
        }
        if (copy > avail_out) {
            /* The output buffer is insufficient. Copy part of the buffer first. */
            copy = avail_out
        }
        avail_out -= copy
        length -= UInt32(copy)
        var i: Int64 = copyfrom
        while (i < (copyfrom + copy)) {
            next_out[pos_out] = copybuf[i]
            pos_out++
            i++
        }
        if (length == 0) {
            mode = LEN
        }
        return ReturnValue(rtype: OTHER)
    }

    private func LITFunc(): ReturnValue {
        if (avail_out == 0) {
            return ReturnValue(rtype: BREAK)
        }
        next_out[pos_out] = UInt8(length & 0xFF)
        avail_out--
        pos_out++
        mode = LEN
        return ReturnValue(rtype: OTHER)
    }

    private func CHECKFunc(): ReturnValue {
        match (wrap) {
            case DEFLATE_TYPE => ()
            case _ =>
                if (needBits(32)) {
                    return ReturnValue(rtype: BREAK)
                }
                var newdatalen: Int64 = initout - avail_out
                initout = avail_out
                total_out += newdatalen
                total += newdatalen
                if (ischeck && newdatalen > 0) {
                    if (flags != 0) {
                        check = crc32(check, next_out, pos_out - Int64(newdatalen), newdatalen)
                    } else {
                        check = adler32(check, next_out, pos_out - Int64(newdatalen), newdatalen)
                    }
                    adler = check
                }
                if (ischeck) {
                    var realcheck: UInt32 = hold
                    if (flags == 0) {
                        realcheck = ((hold >> 24) & 0xFF) + ((hold >> 8) & 0xFF00) + ((hold & 0xFF00) << 8) + ((hold &
                            0xFF) << 24)
                    }
                    if (realcheck != check) {
                        message = "incorrect data check"
                        mode = BAD
                        return ReturnValue(rtype: OTHER)
                    }
                    initBits()
                }
        }
        mode = LENGTH
        return ReturnValue(rtype: OTHER)
    }

    private func LENGTHFunc(): ReturnValue {
        mode = DONE
        return ReturnValue(rtype: OTHER)
    }

    private func DONEFunc(): ReturnValue {
        message = "inflate completed"
        return ReturnValue(rtype: RET_BREAK, value: Int64(Z_STREAM_END))
    }

    private func BADFunc(): ReturnValue {
        return ReturnValue(rtype: RET_BREAK, value: Int64(Z_DATA_ERROR))
    }

    private func MEMFunc(): ReturnValue {
        return ReturnValue(rtype: RETURN, value: Int64(Z_MEM_ERROR))
    }

    private func SYNCFunc(): ReturnValue {
        return ReturnValue(rtype: RETURN, value: Int64(Z_STREAM_ERROR))
    }

    private func findMaxCodeFunc(tabletype: UInt32, midcodelen: UInt32, count: Array<UInt16>, codetable: Array<Code>): (UInt32, 
        UInt32, Code, Bool) {
        var max: UInt32 = UInt32(MAXBITS)
        var root: UInt32 = 0
        var here: Code = Code(0, 0, 0)
        while (max > 0) {
            if (count[Int64(max)] != 0) {
                break
            }
            max--
        }
        if (max == 0) {
            here = Code(64, 1, 0)
            codetable[0] = here
            if (tabletype == TYPE_DISTS) {
                distbits = 1
            } else {
                lenbits = 1
            }
            return (max, root, here, false)
        }
        root = midcodelen
        if (root > max) {
            root = max
        }
        return (max, root, here, true)
    }

    private func findMinCodeFunc(max: UInt32, rootNum: UInt32, count: Array<UInt16>): (UInt32, UInt32) {
        var min: UInt32 = 1
        var root: UInt32 = rootNum
        while (min < max) {
            if (count[Int64(min)] != 0) {
                break
            }
            min++
        }
        if (root < min) {
            root = min
        }
        return (min, root)
    }

    private func checkCodeValidityFunc(tabletype: UInt32, max: UInt32, count: Array<UInt16>): (Int32, Bool) {
        var left: Int32 = 1
        var i: Int64 = 1
        while (i <= MAXBITS) {
            left <<= 1
            left -= Int32(count[i])
            if (left < 0) {
                return (left, true)
            }
            i++
        }
        if (left > 0 && (tabletype == TYPE_CODES || max != 1)) {
            return (left, true)
        }
        return (left, false)
    }

    private func matchTableTypeFunc(tabletype: UInt32, root: UInt32): (UInt16, Array<UInt16>, Array<UInt16>, UInt32, 
        Bool) {
        var matchsym: UInt16 = 0
        var base: Array<UInt16> = [0]
        var extra: Array<UInt16> = [0]
        var used: UInt32 = 1 << root
        match {
            case tabletype == TYPE_CODES =>
                base = []
                extra = []
                matchsym = 20
            case tabletype == TYPE_LENS =>
                base = lbase
                extra = lext
                matchsym = 257
            case tabletype == TYPE_DISTS =>
                base = dbase
                extra = dext
                matchsym = 0
            case _ => return (matchsym, base, extra, used, true)
        }
        if (tabletype == TYPE_LENS && used > ENOUGH_LENS || tabletype == TYPE_DISTS && used > ENOUGH_DISTS) {
            return (matchsym, base, extra, used, true)
        }
        return (matchsym, base, extra, used, false)
    }

    private func inflateTableMainFunc(tabletype: UInt32, codetable_Array: Array<Code>, lens: Array<UInt16>,
        extra: Array<UInt16>, minNum: UInt32, max: UInt32, root: UInt32, usedNum: UInt32, here_Code: Code,
        matchsym: UInt16, base: Array<UInt16>, count: Array<UInt16>, lstart: Int64, leftNum: Int32): Bool {
        var codetable: Array<Code> = codetable_Array
        /*
         * When a level-1 table is created, the value is 0.
         * When a level-2 table is created, the value is the maximum code length (threshold code length) of the level-1 table.
         */
        var here: Code = here_Code
        var used: UInt32 = usedNum
        var left: Int32 = leftNum
        var min: UInt32 = minNum
        var (huff, drop, incr, fill, low, len, mask, curr, pos, start, sym): (UInt32, UInt32, UInt32, UInt32, UInt32, 
            UInt32, UInt32, UInt32, Int64, Int64, Int64) = (0, 0, 0, 0, 0xFFFFFFFF, min, used - 1, root, 0, 0, 0)
        while (true) {
            here.bits = UInt8((len - drop) & 0xFF)
            /* Symbols of Code Length Trees or literal */
            let getmatch = getMatchSym(sym, matchsym, here, pos, extra, base)
            here = getmatch[0]
            pos = getmatch[1]
            /*
             * When the code value is in the positive order, the increment is 1.
             * However, the Huffman encoding saves the value in the reverse order.
             * Therefore, the increment is 1 << len.
             * In the level-2 table, the maximum code length of the level-1 table needs to be subtracted from the value drop.
             */
            incr = 1 << (len - drop)
            /* Size of the current code table */
            fill = 1 << curr
            /* Saves the size of the current code table, which will be used when calculating the start position of the next code table. */
            min = fill
            /* Save the encoding information to the code table (the subscript is the extended virtual code value). */
            pos = start + Int64(huff >> drop)
            do {
                fill -= incr
                codetable[pos + Int64(fill)] = here
            } while (fill != 0)
            /*
             * Calculate the code value of the next character: In positive order, the code value of the current character plus 1 (huff + 1).
             * However, the reverse order value is used here.
             * The calculation logic is as follows: Find the first bit that is 0 from the most significant bit,
             * set this bit to 1, and set the preceding bits (high bits) to 0.
             * The search starts from the most significant bit.
             * Therefore, you can set the most significant bit to 1 and set the other bits to 0.
             * Then, you can determine whether the most significant bit is 0.
             */
            incr = 1 << (len - 1)
            /* Determine whether a bit is 0. */
            /* If the previous bit is 1, carry is generated. The next bit needs to be determined. */
            huff = getHuff(incr, huff)
            sym++
            /*
             * Complete the construction of a character code table.
             * The number of characters corresponding to the current code length decreases by one.
             */
            count[Int64(len)] = count[Int64(len)] - 1
            if (count[Int64(len)] == 0) {
                /* End. Encoding information of all characters that appear has been saved to the code table. */
                if (len == max) {
                    break
                }
                /* Obtains the code length of the next character. */
                len = UInt32(lens[lstart + Int64(work[sym])])
            }
            /*
             * When the code length exceeds the threshold code length,
             * the level-2 code table is constructed and information about the level-2 code table is initialized.
             */
            if (len > root && (huff & mask) != low) {
                if (drop == 0) {
                    drop = root
                }
                /* Start subscript of the next table */
                start += Int64(min)
                /* Calculate the size of the level-2 table and save it in the left. */
                curr = len - drop
                curr = getLeft(left, curr, drop, max, count)
                /* Check the size of the code table. */
                used += 1 << curr
                if ((tabletype == TYPE_LENS && used > ENOUGH_LENS) || (tabletype == TYPE_DISTS && used > ENOUGH_DISTS)) {
                    return true
                }
                /* The level-1 code table stores the information about the next level-2 code table. */
                low = huff & mask
                here.option = UInt8(curr & 0xFF)
                here.bits = UInt8(root & 0xFF)
                here.value = UInt16(start)
                codetable[Int64(low)] = here
                codetable[Int64(low)] = here
            }
        }
        getTable(huff, here, len, drop, codetable)
        getDistbits(tabletype, root)
        return false
    }

    private func getTable(huff: UInt32, hereCode: Code, len: UInt32, drop: UInt32, codetable_Array: Array<Code>): Unit {
        var here: Code = hereCode
        var codetable: Array<Code> = codetable_Array
        if (huff != 0) {
            here.option = 64
            here.bits = UInt8((len - drop) & 0xFF)
            here.value = 0
            codetable[Int64(huff)] = here
        }
    }
    private func getMatchSym(sym: Int64, matchsym: UInt16, hereCode: Code, posNum: Int64, extra: Array<UInt16>,
        base: Array<UInt16>): (Code, Int64) {
        var here: Code = hereCode
        var pos: Int64 = posNum
        if (work[sym] + 1 < matchsym) {
            here.option = 0
            here.value = work[sym]
        } else if (work[sym] >= matchsym) {
            /* length or distance (Reference value + number of extended bit) */
            pos = Int64(work[sym] - matchsym)
            here.option = UInt8(extra[pos] & 0xFF)
            here.value = base[pos]
        } else {
            /* Block end symbol */
            here.option = 32 + 64
            here.value = 0
        }
        return (here, pos)
    }

    private func getLeft(lefts: Int32, currs: UInt32, drop: UInt32, max: UInt32, count: Array<UInt16>): UInt32 {
        var left: Int32 = lefts
        var curr: UInt32 = currs
        left = Int32(1 << curr)
        while (curr + drop < max) {
            left -= Int32(count[Int64(curr + drop)])
            /* left > 0 indicates that leaf nodes with longer code lengths are stored in the level-2 code table. */
            if (left <= 0) {
                break
            }
            curr++
            left <<= 1
        }
        return curr
    }

    private func getDistbits(tabletype: UInt32, root: UInt32): Unit {
        if (tabletype == TYPE_DISTS) {
            distbits = root
        } else {
            lenbits = root
        }
    }

    private func getHuff(incrs: UInt32, huffs: UInt32): UInt32 {
        var huff: UInt32 = huffs
        var incr: UInt32 = incrs
        while ((huff & incr) != 0) {
            incr >>= 1
        }
        if (incr != 0) {
            /* High Position 0 (Because the most significant bits are all 1, add 1 and then carry it into 0.)
             * The bit that does not carry is also set to 0.
             */
            huff &= incr - 1
            /* This position without carrying 1 */
            huff += incr
        } else {
            huff = 0
        }
        return huff
    }

    private func inflateFastBitsFunc(): Unit {
        if (bits < 15) {
            hold += UInt32(next_in[pos_in]) << bits
            pos_in++
            avail_in--
            bits += 8
            hold += UInt32(next_in[pos_in]) << bits
            pos_in++
            avail_in--
            bits += 8
        }
    }

    private func inflateFastBitsFunc(hereCode: Code): Code {
        var here: Code = hereCode
        if (here.option != 0 && (here.option & 0xF0) == 0) {
            here = lencodes[Int64(here.value) + Int64(hold & ((1 << UInt32(here.option)) - 1))]
            hold >>= UInt32(here.bits)
            bits -= UInt32(here.bits)
        }
        return here
    }

    private func doOption0(here: Code) {
        next_out[pos_out] = UInt8(here.value & 0xFF)
        pos_out++
        avail_out--
    }

    private func doExtraNot0(mExtra: UInt32, mLen: UInt32): (UInt32, UInt32) {
        var len: UInt32 = mLen
        var extra: UInt32 = mExtra
        if (extra != 0) {
            if (bits < extra) {
                hold += UInt32(next_in[pos_in]) << bits
                pos_in++
                avail_in--
                bits += 8
            }
            len += hold & ((1 << extra) - 1)
            hold >>= extra
            bits -= extra
        }
        return (len, extra)
    }

    private func afterDistcodes(mHere: Code): Code {
        var here: Code = mHere
        hold >>= UInt32(here.bits)
        bits -= UInt32(here.bits)
        if ((here.option & 0xF0) == 0) {
            here = distcodes[Int64(here.value) + Int64(hold & ((1 << UInt32(here.option)) - 1))]
            hold >>= UInt32(here.bits)
            bits -= UInt32(here.bits)
        }
        return here
    }

    private func bitsLessextra(extra: UInt32) {
        if (bits < extra) {
            hold += UInt32(next_in[pos_in]) << bits
            pos_in++
            avail_in--
            bits += 8
            if (bits < extra) {
                hold += UInt32(next_in[pos_in]) << bits
                pos_in++
                avail_in--
                bits += 8
            }
        }
    }

    private func wnextEqual0(mExtra: UInt32, mLen: UInt32, copyfrom: UInt32): (UInt32, UInt32) {
        var len: UInt32 = mLen
        var extra: UInt32 = mExtra
        if (len > extra) {
            len -= extra
        } else {
            extra = len
            len = 0
        }
        var i: Int64 = Int64(copyfrom)
        while (i < Int64(copyfrom + extra)) {
            next_out[pos_out] = window[i]
            pos_out++
            avail_out--
            i++
        }
        return (extra, len)
    }

    private func wnextlessExtra(mExtra: UInt32, mLen: UInt32, mCopyfrom: UInt32): (UInt32, UInt32, UInt32) {
        var len: UInt32 = mLen
        var extra: UInt32 = mExtra
        var copyfrom: UInt32 = mCopyfrom
        copyfrom = wsize + wnext - extra
        extra -= wnext
        if (extra < len) {
            len -= extra
        } else {
            extra = len
            len = 0
        }
        var i: Int64 = Int64(copyfrom)
        while (i < Int64(copyfrom + extra)) {
            next_out[pos_out] = window[i]
            pos_out++
            avail_out--
            i++
        }
        if (len > 0) {
            copyfrom = 0
            if (len > wnext) {
                extra = wnext
                len -= wnext
            } else {
                extra = len
                len = 0
            }
            i = Int64(copyfrom)
            while (i < Int64(copyfrom + extra)) {
                next_out[pos_out] = window[i]
                pos_out++
                avail_out--
                i++
            }
        }
        return (extra, len, copyfrom)
    }

    private func wnextMoreExtra(mExtra: UInt32, mLen: UInt32, copyfrom: UInt32): (UInt32, UInt32) {
        var len: UInt32 = mLen
        var extra: UInt32 = mExtra
        if (extra < len) {
            len -= extra
        } else {
            extra = len
            len = 0
        }
        var i: Int64 = Int64(copyfrom)
        while (i < Int64(copyfrom + extra)) {
            next_out[pos_out] = window[i]
            pos_out++
            avail_out--
            i++
        }
        return (extra, len)
    }

    private func doFor(copyfrom: UInt32, len: UInt32) {
        var i: Int64 = Int64(copyfrom)
        while (i < Int64(copyfrom + len)) {
            next_out[pos_out] = next_out[i]
            pos_out++
            avail_out--
            i++
        }
    }

    private func chouTwice(mHere: Code, mLen: UInt32, mDist: UInt32, mExtra: UInt32, mStopError: Int64,
        mCopyfrom: UInt32): (Code, UInt32, UInt32, UInt32, Int64, UInt32, Int64) {
        var here: Code = mHere
        var len: UInt32 = mLen
        var dist: UInt32 = mDist
        var extra: UInt32 = mExtra
        var stopError: Int64 = mStopError
        var copyfrom: UInt32 = mCopyfrom
        if (dist > dmax) {
            makeModeAndMessage(BAD, "invalid distance too far back")
            return (here, len, dist, extra, stopError, copyfrom, 1) //表示return true
        }
        hold >>= extra
        bits -= extra
        if (dist > UInt32(pos_out)) {
            extra = dist - UInt32(pos_out)
            if (extra > whave) {
                makeModeAndMessage(BAD, "invalid distance too far back")
                return (here, len, dist, extra, stopError, copyfrom, 1) //表示return true
            }
            if (wnext == 0) {
                copyfrom = wsize - extra
                let res1 = wnextEqual0(extra, len, copyfrom)
                extra = res1[0]
                len = res1[1]
            } else if (wnext < extra) {
                let res2 = wnextlessExtra(extra, len, copyfrom)
                extra = res2[0]
                len = res2[1]
                copyfrom = res2[2]
            } else {
                copyfrom = wnext - extra
                let res3 = wnextMoreExtra(extra, len, copyfrom)
                extra = res3[0]
                len = res3[1]
            }
            if (len > 0) {
                copyfrom = 0
                doFor(copyfrom, len)
            }
        } else {
            copyfrom = UInt32(pos_out) - dist
            doFor(copyfrom, len)
            stopError = 0
        }
        return (here, len, dist, extra, stopError, copyfrom, 0) //表示return true
    }

    private func inflateFastHereFunc(hereCode: Code): Bool {
        var here: Code = hereCode
        var dmask: UInt32 = (1 << distbits) - 1
        var len: UInt32 = 0
        var dist: UInt32 = 0
        var extra: UInt32 = 0
        var stopError: Int64 = 0
        var copyfrom: UInt32 = 0
        if (here.option == 0) {
            doOption0(here)
        } else if ((here.option & 16) != 0) {
            len = UInt32(here.value) // /* length */
            extra = UInt32(here.option & 0x0F)
            let res0 = doExtraNot0(extra, len)
            len = res0[0]
            extra = res0[1]
            inflateFastBitsFunc()
            here = distcodes[Int64(hold & dmask)] ///* distances */

            //这里开始
            here = afterDistcodes(here)
            if ((here.option & 16) != 0) {
                dist = UInt32(here.value)
                extra = UInt32(here.option & 0x0F)
                bitsLessextra(extra)
                dist += hold & ((1 << extra) - 1)
                //这里开始
                let resT = chouTwice(here, len, dist, extra, stopError, copyfrom)
                here = resT[0]
                len = resT[1]
                dist = resT[2]
                extra = resT[3]
                stopError = resT[4]
                copyfrom = resT[5]
                if (resT[6] == 1) {
                    return true
                }
            } else {
                makeModeAndMessage(BAD, "invalid distance code")
                return true
            }
        } else if ((here.option & 32) != 0) {
            mode = TYPE
            return true
        } else {
            makeModeAndMessage(BAD, "invalid literal/length code")
            return true
        }
        return false
    }

    func NAMEAndCOMMENTInnerFunc(): ReturnValue {
        var copy: Int64 = 0
        if (avail_in == 0) {
            return ReturnValue(rtype: BREAK)
        }
        copy = 0
        while (true) {
            copy++
            if (copy >= avail_in) {
                break
            }
        }
        if (ischeck && (flags & 0x0200) != 0) {
            check = crc32(check, next_in, pos_in, copy)
        }
        avail_in -= copy
        pos_in += copy
        return ReturnValue(rtype: OTHER)
    }
}
