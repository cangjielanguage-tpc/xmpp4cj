/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2022-2024. All rights reserved.
 */

/**
 * @file
 *
 * This is a class library that implements compression functions.
 * Provides streaming compression interfaces such as deflateInit, deflate, deflateEnd, deflateBound, and setDictionary.
 */

package cangjie_tpc::xmpp4cj.compression1

import std.math.*

/* Some constants */
let LENGTH_CODES: UInt32 = 29
let LITERALS: UInt32 = 256
let L_CODES: UInt32 = LITERALS + 1 + LENGTH_CODES
let D_CODES: UInt32 = 30
let BL_CODES: UInt32 = 19
let HEAP_SIZE: UInt32 = 2 * L_CODES + 1
let MAX_BITS: UInt32 = 15
let BUF_SIZE: UInt32 = 16
let TOO_FAR: UInt32 = 4096
let MIN_LOOKAHEAD: UInt32 = MAX_MATCH + MIN_MATCH + 1
let MAX_STORED: UInt32 = 65535
let MAX_BL_BITS: UInt32 = 7
let END_BLOCK: Int64 = 256
let REP_3_6: Int64 = 16
let REPZ_3_10: Int64 = 17
let REPZ_11_138: Int64 = 18
let SMALLEST: Int64 = 1

/* Compressed state */
let INIT_STATE: UInt32 = 101
let BUSY_STATE: UInt32 = 107
let FINISH_STATE: UInt32 = 108

/*
 * Compressed Block Status
 * return value of the deflateStored deflateFast deflateSlow function
 */
let NEED_MORE: UInt32 = 201
let BLOCK_DONE: UInt32 = 202
let FINISH_STARTED: UInt32 = 203
let FINISH_DONE: UInt32 = 204

class CTData {
    public CTData(var freq_code: UInt16, var dad_len: UInt16) {}
}

class StaticTreeDesc {
    public StaticTreeDesc(var static_tree: Array<CTData>, var extra_bits: Array<UInt8>, var extra_base: UInt32,
        var max_element: UInt32, var max_length: UInt32) {}
}

class TreeDescription {
    public TreeDescription(var dyn_tree: Array<CTData>, var max_code: UInt32, var static_desc: StaticTreeDesc) {}
}

struct Config {
    public Config(var good_length: UInt32, var max_lazy: UInt32, var nice_length: UInt32, var max_chain: UInt32) {}
}

/* Static Huffman compression code table of literal length */
let static_ltree: Array<CTData> = [CTData(12, 8), CTData(140, 8), CTData(76, 8), CTData(204, 8), CTData(44, 8),
    CTData(172, 8), CTData(108, 8), CTData(236, 8), CTData(28, 8), CTData(156, 8), CTData(92, 8), CTData(220, 8),
    CTData(60, 8), CTData(188, 8), CTData(124, 8), CTData(252, 8), CTData(2, 8), CTData(130, 8), CTData(66, 8),
    CTData(194, 8), CTData(34, 8), CTData(162, 8), CTData(98, 8), CTData(226, 8), CTData(18, 8), CTData(146, 8),
    CTData(82, 8), CTData(210, 8), CTData(50, 8), CTData(178, 8), CTData(114, 8), CTData(242, 8), CTData(10, 8),
    CTData(138, 8), CTData(74, 8), CTData(202, 8), CTData(42, 8), CTData(170, 8), CTData(106, 8), CTData(234, 8),
    CTData(26, 8), CTData(154, 8), CTData(90, 8), CTData(218, 8), CTData(58, 8), CTData(186, 8), CTData(122, 8),
    CTData(250, 8), CTData(6, 8), CTData(134, 8), CTData(70, 8), CTData(198, 8), CTData(38, 8), CTData(166, 8),
    CTData(102, 8), CTData(230, 8), CTData(22, 8), CTData(150, 8), CTData(86, 8), CTData(214, 8), CTData(54, 8),
    CTData(182, 8), CTData(118, 8), CTData(246, 8), CTData(14, 8), CTData(142, 8), CTData(78, 8), CTData(206, 8),
    CTData(46, 8), CTData(174, 8), CTData(110, 8), CTData(238, 8), CTData(30, 8), CTData(158, 8), CTData(94, 8),
    CTData(222, 8), CTData(62, 8), CTData(190, 8), CTData(126, 8), CTData(254, 8), CTData(1, 8), CTData(129, 8),
    CTData(65, 8), CTData(193, 8), CTData(33, 8), CTData(161, 8), CTData(97, 8), CTData(225, 8), CTData(17, 8),
    CTData(145, 8), CTData(81, 8), CTData(209, 8), CTData(49, 8), CTData(177, 8), CTData(113, 8), CTData(241, 8),
    CTData(9, 8), CTData(137, 8), CTData(73, 8), CTData(201, 8), CTData(41, 8), CTData(169, 8), CTData(105, 8),
    CTData(233, 8), CTData(25, 8), CTData(153, 8), CTData(89, 8), CTData(217, 8), CTData(57, 8), CTData(185, 8),
    CTData(121, 8), CTData(249, 8), CTData(5, 8), CTData(133, 8), CTData(69, 8), CTData(197, 8), CTData(37, 8),
    CTData(165, 8), CTData(101, 8), CTData(229, 8), CTData(21, 8), CTData(149, 8), CTData(85, 8), CTData(213, 8),
    CTData(53, 8), CTData(181, 8), CTData(117, 8), CTData(245, 8), CTData(13, 8), CTData(141, 8), CTData(77, 8),
    CTData(205, 8), CTData(45, 8), CTData(173, 8), CTData(109, 8), CTData(237, 8), CTData(29, 8), CTData(157, 8),
    CTData(93, 8), CTData(221, 8), CTData(61, 8), CTData(189, 8), CTData(125, 8), CTData(253, 8), CTData(19, 9),
    CTData(275, 9), CTData(147, 9), CTData(403, 9), CTData(83, 9), CTData(339, 9), CTData(211, 9), CTData(467, 9),
    CTData(51, 9), CTData(307, 9), CTData(179, 9), CTData(435, 9), CTData(115, 9), CTData(371, 9), CTData(243, 9),
    CTData(499, 9), CTData(11, 9), CTData(267, 9), CTData(139, 9), CTData(395, 9), CTData(75, 9), CTData(331, 9),
    CTData(203, 9), CTData(459, 9), CTData(43, 9), CTData(299, 9), CTData(171, 9), CTData(427, 9), CTData(107, 9),
    CTData(363, 9), CTData(235, 9), CTData(491, 9), CTData(27, 9), CTData(283, 9), CTData(155, 9), CTData(411, 9),
    CTData(91, 9), CTData(347, 9), CTData(219, 9), CTData(475, 9), CTData(59, 9), CTData(315, 9), CTData(187, 9),
    CTData(443, 9), CTData(123, 9), CTData(379, 9), CTData(251, 9), CTData(507, 9), CTData(7, 9), CTData(263, 9),
    CTData(135, 9), CTData(391, 9), CTData(71, 9), CTData(327, 9), CTData(199, 9), CTData(455, 9), CTData(39, 9),
    CTData(295, 9), CTData(167, 9), CTData(423, 9), CTData(103, 9), CTData(359, 9), CTData(231, 9), CTData(487, 9),
    CTData(23, 9), CTData(279, 9), CTData(151, 9), CTData(407, 9), CTData(87, 9), CTData(343, 9), CTData(215, 9),
    CTData(471, 9), CTData(55, 9), CTData(311, 9), CTData(183, 9), CTData(439, 9), CTData(119, 9), CTData(375, 9),
    CTData(247, 9), CTData(503, 9), CTData(15, 9), CTData(271, 9), CTData(143, 9), CTData(399, 9), CTData(79, 9),
    CTData(335, 9), CTData(207, 9), CTData(463, 9), CTData(47, 9), CTData(303, 9), CTData(175, 9), CTData(431, 9),
    CTData(111, 9), CTData(367, 9), CTData(239, 9), CTData(495, 9), CTData(31, 9), CTData(287, 9), CTData(159, 9),
    CTData(415, 9), CTData(95, 9), CTData(351, 9), CTData(223, 9), CTData(479, 9), CTData(63, 9), CTData(319, 9),
    CTData(191, 9), CTData(447, 9), CTData(127, 9), CTData(383, 9), CTData(255, 9), CTData(511, 9), CTData(0, 7),
    CTData(64, 7), CTData(32, 7), CTData(96, 7), CTData(16, 7), CTData(80, 7), CTData(48, 7), CTData(112, 7),
    CTData(8, 7), CTData(72, 7), CTData(40, 7), CTData(104, 7), CTData(24, 7), CTData(88, 7), CTData(56, 7),
    CTData(120, 7), CTData(4, 7), CTData(68, 7), CTData(36, 7), CTData(100, 7), CTData(20, 7), CTData(84, 7),
    CTData(52, 7), CTData(116, 7), CTData(3, 8), CTData(131, 8), CTData(67, 8), CTData(195, 8), CTData(35, 8),
    CTData(163, 8), CTData(99, 8), CTData(227, 8)]

/*
 * Compressed code table of the distance interval number in the static huffman policy
 * Fixed 5 bits indicate the range number from 0 to 29. The code value is in reverse order.
 */
let static_dtree: Array<CTData> = [CTData(0, 5), CTData(16, 5), CTData(8, 5), CTData(24, 5), CTData(4, 5), CTData(20, 5),
    CTData(12, 5), CTData(28, 5), CTData(2, 5), CTData(18, 5), CTData(10, 5), CTData(26, 5), CTData(6, 5), CTData(22, 5),
    CTData(14, 5), CTData(30, 5), CTData(1, 5), CTData(17, 5), CTData(9, 5), CTData(25, 5), CTData(5, 5), CTData(21, 5),
    CTData(13, 5), CTData(29, 5), CTData(3, 5), CTData(19, 5), CTData(11, 5), CTData(27, 5), CTData(7, 5), CTData(23, 5)]

/* Mapping between distance values and ranges */
let dist_code: Array<UInt8> = [0, 1, 2, 3, 4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9,
    9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11, 11,
    11, 11, 11, 11, 11, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12,
    12, 12, 12, 12, 12, 12, 12, 12, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13,
    13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14,
    14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
    15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15,
    15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 16, 17, 18, 18,
    19, 19, 20, 20, 20, 20, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24,
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
    26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27,
    27, 27, 27, 27, 27, 27, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
    28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28,
    28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
    29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29,
    29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29, 29]

/* Mapping between literal length values and ranges */
let length_code: Array<UInt8> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13, 13, 14,
    14, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18,
    18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21,
    21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22,
    23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24,
    24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25,
    25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 25, 26, 26, 26, 26, 26, 26, 26,
    26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 26, 27, 27, 27, 27,
    27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 27, 28]

/* Mapping between literal length ranges and basic values */
let base_length: Array<UInt32> = [0, 1, 2, 3, 4, 5, 6, 7, 8, 10, 12, 14, 16, 20, 24, 28, 32, 40, 48, 56, 64, 80, 96,
    112, 128, 160, 192, 224, 0]

/* Mapping between distance range numbers and basic values */
let base_dist: Array<UInt32> = [0, 1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64, 96, 128, 192, 256, 384, 512, 768, 1024,
    1536, 2048, 3072, 4096, 6144, 8192, 12288, 16384, 24576]

/* Mapping between the range number and the number of extended bits */
let extra_lbits: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0]
let extra_dbits: Array<UInt8> = [0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 11, 12,
    12, 13, 13]
let extra_blbits: Array<UInt8> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 3, 7]
let static_l_desc = StaticTreeDesc(static_ltree, extra_lbits, LITERALS + UInt32(1), L_CODES, MAX_BITS)
let static_d_desc = StaticTreeDesc(static_dtree, extra_dbits, 0, D_CODES, MAX_BITS)
let static_bl_desc = StaticTreeDesc([], extra_blbits, 0, BL_CODES, MAX_BL_BITS)

/**
 * This class Deflate implements the compression function.
 *
 * @since 0.28.4
 */
class Deflate <: Stream {

    /* Compressed state */
    private var status: UInt32 = INIT_STATE

    private var lit_bufsize: Int64 = 1 << (DEF_MEM_LEVEL + 6)

    /* Wait for the buffer to save the compressed data */
    private var pending_buf: Array<UInt8> = Array<UInt8>()
    private var pending_buf_size: Int64 = lit_bufsize * 4

    /* Read position of pending_buf */
    private var pending_start: Int64 = 0

    /* Number of bytes in pending_buf that are not read to the output buffer */
    private var pending: Int64 = 0

    /* Compressed data outer wrapper type: ZLIB_TYPE format, or DEFLATE_TYPE */
    private var wrap: WrapTypeEnum = ZLIB_TYPE

    /* Flags whether the format trailer (ZLIB_TYPE) has been written to pending_buf */
    private var writedtail: Bool = false

    /* compression algorithm: Only one DEFLATE_TYPE = 8 */
    private var method: UInt32 = METHOD_DEFLATE
    private var last_flush: UInt32 = Z_UNKNOWN_FLUSH

    /* Controls the size of the sliding window and the size of the prev array */
    private var w_bits: UInt32 = 15

    /* 1 << w_bits */
    private var w_size: UInt32 = 1 << w_bits

    /* Mask = w_size - 1 */
    private var w_mask: UInt32 = w_size - 1

    /* Sliding window, compression table */
    private var window: Array<UInt8> = Array<UInt8>()

    /* Sliding window size = w_size * 2 */
    private var window_size: UInt32 = w_size * 2

    /* prev [current position] = previous position (hash value is the same as current position) */
    private var prev: Array<UInt16> = Array<UInt16>()

    /* head [hash value] = position */
    private var head: Array<UInt16> = Array<UInt16>()

    /* Hash value */
    private var ins_h: UInt16 = 0

    /* Number of bits of the hash value */
    private var hash_bits: UInt32 = DEF_MEM_LEVEL + 7

    /* 1 << hash_bits */
    private var hash_size: UInt32 = 1 << hash_bits

    /* hash_mask = hash_size - 1 */
    private var hash_mask: UInt32 = hash_size - 1

    /* Number of left scrolling bits of the rolling hash */
    private var hash_shift: UInt32 = ((hash_bits + MIN_MATCH - 1) / MIN_MATCH)

    /* Uncompressed data in the sliding window */
    private var lookahead: UInt32 = 0
    private var block_start: Int64 = 0

    /* Current compression position (in sliding window) */
    private var strstart: UInt32 = 0
    private var match_start: Int64 = 0
    private var match_length: UInt32 = MIN_MATCH - 1
    private var prev_start: Int64 = 0
    private var prev_length: UInt32 = MIN_MATCH - 1
    private var match_available: Bool = false

    private let configuration_table: Array<Config> = [
        Config(0, 0, 0, 0),
        Config(4, 4, 8, 4),
        Config(4, 5, 16, 8),
        Config(4, 6, 32, 32),
        Config(4, 4, 16, 16),
        Config(8, 16, 32, 32),
        Config(8, 16, 128, 128),
        Config(8, 32, 128, 256),
        Config(32, 128, 258, 1024),
        Config(32, 258, 258, 4096)
    ]

    /* Compression level 0 - 9 */
    private var level: UInt32 = LEVEL_DEFAULT_COMPRESSION

    /* Number of forward search times in the longest match (following the prev chain) */
    private var max_chain_length: UInt32 = configuration_table[Int64(level)].max_chain

    /* The value is the same as max_chain_length. This parameter is used when level is less than 4. */
    private var max_insert_length: UInt32 = max_chain_length

    /* Maximum number of times that a lazy match moves backwards */
    private var max_lazy_match: UInt32 = configuration_table[Int64(level)].max_lazy

    /*
     * Good matching length.
     * If the length is greater than or equal to this length, the current chain_length is reduced.
     */
    private var good_length: UInt32 = configuration_table[Int64(level)].good_length

    /*
     * Very good match length.
     * If the length is greater than or equal to this length, the longest match ends.
     */
    private var nice_length: UInt32 = configuration_table[Int64(level)].nice_length

    /* Compression Policy */
    private var strategy: UInt32 = Z_DEFAULT_STRATEGY

    private var dyn_ltree: Array<CTData> = Array<CTData>()
    private var dyn_dtree: Array<CTData> = Array<CTData>()
    private var bl_tree: Array<CTData> = Array<CTData>()

    private var l_desc: TreeDescription = TreeDescription(dyn_ltree, 0, static_l_desc)
    private var d_desc: TreeDescription = TreeDescription(dyn_dtree, 0, static_d_desc)
    private var bl_desc: TreeDescription = TreeDescription(bl_tree, 0, static_bl_desc)

    private var bl_count: Array<UInt16> = Array<UInt16>()

    private var heap: Array<UInt32> = Array<UInt32>()
    private var heap_len: UInt32 = 0
    private var heap_max: Int64 = Int64(HEAP_SIZE)
    private var depth: Array<UInt8> = Array<UInt8>()

    private var sym_buf: Array<UInt8> = pending_buf
    private var sym_next: Int64 = lit_bufsize
    private var sym_end: Int64 = (lit_bufsize - 1) * 3 + lit_bufsize

    private var opt_len: Int64 = 0
    private var static_len: Int64 = 0
    private var insert: UInt32 = 0

    private var bits_buf: UInt16 = 0
    private var bits_valid: UInt32 = 0

    private var max_dist: UInt32 = w_size - MIN_LOOKAHEAD

    private var stored_len: UInt32 = 0
    private var stored_state: UInt32 = 0

    /**
     * The Function is Deflate init constructor
     *
     * @since 0.28.4
     */
    public init() {}

    /**
     * Bind the input and output buffers, initialize the compression parameters and status, and apply for memory for the buffer.
     *
     * @param wrap Compressed data outer wrapper type, the default value is ZLIB_TYPE.
     *              Compressed file format: ZLIB_TYPE/DEFLATE_TYPE
     * @param level Compression level, the default value is LEVEL_DEFAULT_COMPRESSION.
     *              Compression level:0-9, LEVEL_DEFAULT_COMPRESSION = 6
     * @param wbits Number of Window Bits, the default value is DEF_WINDOW_BITS.
     *              Window Bits:8-15, DEF_WINDOW_BITS = 15
     * @param mlevel Memory Level, the default value is DEF_MEM_LEVEL.
     *              Memory Level: 1-9, DEF_MEM_LEVEL = 8
     * @param strategy Compression Policy, the default value is Z_DEFAULT_STRATEGY.
     *              Z_DEFAULT_STRATEGY:20
     *              Z_FILTERED:21
     *              Z_HUFFMAN_ONLY:22
     *              Z_RLE:23
     *              Z_FIXED:24
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func deflateInit(wrap!: WrapTypeEnum = ZLIB_TYPE, level!: UInt32 = LEVEL_DEFAULT_COMPRESSION,
        wbits!: UInt32 = DEF_WINDOW_BITS, mlevel!: UInt32 = DEF_MEM_LEVEL, strategy!: UInt32 = Z_DEFAULT_STRATEGY): UInt32 {
        if (deflateValInit(wrap: wrap, level: level, wbits: wbits, mlevel: mlevel, strategy: strategy) == -1) {
            return Z_STREAM_ERROR
        }
        deflateInitMemVal(mlevel: mlevel)
        match_length = MIN_MATCH - 1
        prev_length = MIN_MATCH - 1
        match_available = false
        ins_h = 0
        max_lazy_match = configuration_table[Int64(level)].max_lazy
        good_length = configuration_table[Int64(level)].good_length
        nice_length = configuration_table[Int64(level)].nice_length
        max_chain_length = configuration_table[Int64(level)].max_chain
        max_insert_length = max_chain_length
        bits_buf = 0
        bits_valid = 0
        heap_len = 0
        heap_max = Int64(HEAP_SIZE)
        opt_len = 0
        static_len = 0
        stored_len = 0
        stored_state = 0
        if (initTryCatchError()) {
            return Z_MEM_ERROR
        }
        sym_buf = pending_buf
        bl_desc = TreeDescription(bl_tree, 0, static_bl_desc)
        d_desc = TreeDescription(dyn_dtree, 0, static_d_desc)
        l_desc = TreeDescription(dyn_ltree, 0, static_l_desc)
        treeInit()
        return Z_OK
    }

    private func deflateInitMemVal(mlevel!: UInt32 = DEF_MEM_LEVEL): Unit {
        w_size = 1 << w_bits
        w_mask = w_size - 1
        hash_bits = mlevel + 7
        hash_size = 1 << hash_bits
        hash_mask = hash_size - 1
        hash_shift = ((hash_bits + MIN_MATCH - 1) / MIN_MATCH)
        window_size = w_size * 2
        lit_bufsize = 1 << (mlevel + 6)
        sym_next = lit_bufsize
        sym_end = (lit_bufsize - 1) * 3 + lit_bufsize
        pending_start = 0
        pending = 0
        pending_buf_size = lit_bufsize * 4
        max_dist = w_size - MIN_LOOKAHEAD
        block_start = 0
        match_start = 0
        prev_start = 0
        strstart = 0
        lookahead = 0
        insert = 0
    }

    private func deflateValInit(wrap!: WrapTypeEnum = ZLIB_TYPE, level!: UInt32 = LEVEL_DEFAULT_COMPRESSION,
        wbits!: UInt32 = DEF_WINDOW_BITS, mlevel!: UInt32 = DEF_MEM_LEVEL, strategy!: UInt32 = Z_DEFAULT_STRATEGY): Int64 {
        if (level < LEVEL_NO_COMPRESSION || level > LEVEL_BEST_COMPRESSION || strategy < Z_DEFAULT_STRATEGY ||
            strategy > Z_FIXED || mlevel < MIN_MEM_LEVEL || mlevel > MAX_MEM_LEVEL || wbits < MIN_WINDOW_BITS || wbits >
            MAX_WINDOW_BITS) {
            message = error_msg[Int64(Z_STREAM_ERROR)]
            return -1
        }
        initMatchWrap(wrap)
        this.level = level
        this.strategy = strategy
        this.wrap = wrap
        if (wbits == 8) {
            w_bits = 9
        } else {
            w_bits = wbits
        }
        return 0
    }

    /**
     * Compressing data.
     *
     * @param flush Compressing data,flush type:
     *      Z_NO_FLUSH: Calculate the amount of data that needs to be buffered before the output result,
     *                  so as to maximize the compression rate.
     *      Z_SYNC_FLUSH: All non output results will be flushed to the output buffer and will be single byte
     *                  Align bits.
     *      Z_PARTIAL_FLUSH: All non output results will be flushed into the output buffer, but the output
     *                  Alignment is not done in bytes.
     *      Z_BLOCK: A deflate block has been completed and released. The decompression program may need to wait for the next
     *                  block to be ejected before decompression. This feature can be used to control the throughput of deflate blocks.
     *      Z_FULL_FLUSH: All outputs will look like Z_ SYNC_ Flush is flushed out like flush, and the compression state
     *                  will be reset, so that if the previously compressed data is damaged or has random access requirements,
     *                  the decompression program can restart from this point.
     *      Z_FINISH: All inputs are processed and all outputs are flushed out.
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func deflate(flush: UInt32): UInt32 {
        if (flush >= Z_TREES || flush < Z_NO_FLUSH) {
            return Z_STREAM_ERROR
        }
        if (avail_out == 0 || (avail_in != 0 && next_in.size == 0) || (status == FINISH_STATE && flush != Z_FINISH)) {
            message = error_msg[Int64(Z_STREAM_ERROR)]
            return Z_STREAM_ERROR
        }
        let old_flush: UInt32 = last_flush
        last_flush = flush
        if (pending != 0) {
            flushPending()
            if (avail_out == 0) {
                last_flush = Z_UNKNOWN_FLUSH
                return Z_OK
            }
        } else if (avail_in == 0 && flush != Z_FINISH && compareFlush(flush, old_flush)) {
            message = error_msg[Int64(Z_BUF_ERROR)]
            return Z_BUF_ERROR
        }
        let (flag, ret) = deflateStatusJudgment()
        if (flag) {
            return ret
        }
        var checkRes = deflateCheck(flush)
        if (checkRes[0] == -1) {
            return checkRes[1]
        }
        if (flush != Z_FINISH) {
            return Z_OK
        }
        if (writedtail) {
            message = error_msg[Int64(Z_STREAM_END)]
            return Z_STREAM_END
        }
        if (deflateMatchWrap()) {
            return Z_STREAM_END
        }
        writedtail = true
        flushPending()
        if (pending != 0) {
            return Z_OK
        }
        message = error_msg[Int64(Z_STREAM_END)]
        return Z_STREAM_END
    }

    private func extractStatus(bstate: UInt32) {
        if (bstate == FINISH_STARTED || bstate == FINISH_DONE) {
            status = FINISH_STATE
        }
    }

    private func deflateCheck(flush: UInt32): (Int32, UInt32) {
        if (avail_in != 0 || lookahead != 0 || (flush != Z_NO_FLUSH && status != FINISH_STATE)) {
            var bstate: UInt32
            if (level == 0) {
                bstate = deflateStored(flush)
            } else if (strategy == Z_HUFFMAN_ONLY) {
                bstate = deflateHuffman(flush)
            } else if (strategy == Z_RLE) {
                bstate = deflateRLE(flush)
            } else {
                bstate = deflateByLevel(flush)
            }
            extractStatus(bstate)
            if (bstate == NEED_MORE || bstate == FINISH_STARTED) {
                if (avail_out == 0) {
                    last_flush = Z_UNKNOWN_FLUSH
                }
                return (-1, Z_OK)
            }
            if (bstate == BLOCK_DONE) {
                if (flush == Z_PARTIAL_FLUSH) {
                    flushEmptyStaticBlock()
                } else if (flush != Z_BLOCK) {
                    storedBlock(0, 0, false)
                    if (flush == Z_FULL_FLUSH) {
                        var i: Int64 = 0
                        while (i < head.size) {
                            head[i] = 0
                            i++
                        }
                        if (lookahead == 0) {
                            strstart = 0
                            block_start = 0
                            insert = 0
                        }
                    }
                }
                flushPending()
                if (avail_out == 0) {
                    last_flush = Z_UNKNOWN_FLUSH
                    return (-1, Z_OK)
                }
            }
        }
        return (0, Z_OK)
    }

    /**
     * This command is invoked after the compression is complete to check the compression status.
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func deflateEnd(): UInt32 {
        if (status == BUSY_STATE) {
            message = error_msg[Int64(Z_DATA_ERROR)]
            return Z_DATA_ERROR
        }
        return Z_OK
    }

    /**
     * Calculate the maximum size of compressed data based on the source data size.
     *
     * @param sourceLen Source data size
     *
     * @return Int64 Returns maximum size of compressed data of the Int64 type.
     * @since 0.28.4
     */
    public func deflateBound(sourceLen: Int64): Int64 {
        var complen: Int64 = sourceLen + ((sourceLen + 7) >> 3) + ((sourceLen + 63) >> 6) + 5
        var wraplen: Int64
        match (wrap) {
            case DEFLATE_TYPE => wraplen = 0
            case ZLIB_TYPE => wraplen = 6 + if (strstart > 0) {
                4
            } else {
                0
            }
        }
        if (w_bits != 15 || hash_bits != 8 + 7) {
            return complen + wraplen
        }
        return sourceLen + (sourceLen >> 12) + (sourceLen >> 14) + (sourceLen >> 25) + 13 - 6 + wraplen
    }

    /**
     * After initialization is complete and before compression starts, call this function to set the dictionary.
     * The zlib file format supports the dictionary.
     *
     * @param dict Set dictionary data
     *
     * @return UInt32 Returns a value of the UInt32 type.
     * @since 0.28.4
     */
    public func setDictionary(dict: Array<UInt8>): UInt32 {
        if (status < INIT_STATE || status > FINISH_STATE || dict.size == 0) {
            return Z_STREAM_ERROR
        }
        match (wrap) {
            case ZLIB_TYPE =>
                if (status != INIT_STATE || lookahead > 0) {
                    return Z_STREAM_ERROR
                }
                adler = adler32(adler, dict, 0, dict.size)
            case DEFLATE_TYPE =>
                if (lookahead > 0) {
                    return Z_STREAM_ERROR
                }
        }

        var start: Int64 = 0
        if (dict.size >= Int64(w_size)) {
            match (wrap) {
                case DEFLATE_TYPE =>
                    var i: Int64 = 0
                    while (i < head.size) {
                        head[i] = 0
                        i++
                    }
                    strstart = 0
                    block_start = 0
                    insert = 0
                case _ => ()
            }
            start = dict.size - Int64(w_size)
        }
        var tmpwrap: WrapTypeEnum = wrap
        wrap = DEFLATE_TYPE
        var avail: Int64 = avail_in
        var posin: Int64 = pos_in
        var next: Array<UInt8> = next_in
        avail_in = dict.size - start
        pos_in = start
        next_in = dict
        fillWindow()
        setDictionaryVal()
        next_in = next
        avail_in = avail
        pos_in = posin
        wrap = tmpwrap
        return Z_OK
    }

    private func setDictionaryVal() {
        var str: UInt32
        var n: UInt32
        while (lookahead >= MIN_MATCH) {
            str = strstart
            n = lookahead - (MIN_MATCH - 1)
            do {
                updateHash(ins_h, window[Int64(str + MIN_MATCH - 1)])
                prev[Int64(str & w_mask)] = head[Int64(ins_h)]
                head[Int64(ins_h)] = UInt16(str)
                str++
                n--
            } while (n > 0)
            strstart = str
            lookahead = MIN_MATCH - 1
            fillWindow()
        }
        strstart += lookahead
        block_start = Int64(strstart)
        insert = lookahead
        lookahead = 0
        match_length = MIN_MATCH - 1
        prev_length = MIN_MATCH - 1
        match_available = false
    }

    private func compareFlush(curflush: UInt32, oldflush: UInt32): Bool {
        if (oldflush == Z_UNKNOWN_FLUSH) {
            return false
        }
        var curflushRank = (curflush * 2) - if (curflush > Z_FINISH) {
            9
        } else {
            0
        }
        var oldflushRank = (oldflush * 2) - if (oldflush > Z_FINISH) {
            9
        } else {
            0
        }
        if (curflushRank <= oldflushRank) {
            return true
        }
        return false
    }

    private func putByte(data: UInt8): Unit {
        pending_buf[Int64(pending_start + pending)] = data
        pending++
    }

    private func putShortMSB(data: UInt16): Unit {
        putByte(UInt8(data >> 8))
        putByte(UInt8(data & 0xFF))
    }

    private func putShort(data: UInt16): Unit {
        putByte(UInt8(data & 0xFF))
        putByte(UInt8(data >> 8))
    }

    private func sendBits(value: UInt32, length: UInt32): Unit {
        if (length > BUF_SIZE - bits_valid) {
            bits_buf |= UInt16((value << bits_valid) & 0xFFFF)
            putShort(bits_buf)
            bits_buf = UInt16((value >> (BUF_SIZE - bits_valid)) & 0xFFFF)
            bits_valid = bits_valid + length - BUF_SIZE
        } else {
            bits_buf |= UInt16((value << bits_valid) & 0xFFFF)
            bits_valid += length
        }
    }

    private func writeZlibHead(): Unit {
        var header: UInt32 = (method + ((w_bits - 8) << 4)) << 8
        var level_flags: UInt32
        if (strategy >= Z_HUFFMAN_ONLY || level < 2) {
            level_flags = 0
        } else if (level < 6) {
            level_flags = 1
        } else if (level == 6) {
            level_flags = 2
        } else {
            level_flags = 3
        }
        header |= (level_flags << 6)
        if (strstart != 0) {
            header |= PRESET_DICT
        }
        header += 31 - (header % 31)
        putShortMSB(UInt16(header))
        if (strstart != 0) {
            putShortMSB(UInt16(adler >> 16))
            putShortMSB(UInt16(adler & 0xFFFF))
        }
    }

    private func flushPending(): Unit {
        bitsFlush()
        var len: Int64 = pending
        if (len > Int64(avail_out)) {
            len = avail_out
        }
        if (len == 0) {
            return
        }
        var i: Int64 = 0
        while (i < len) {
            next_out[pos_out] = pending_buf[pending_start]
            pos_out++
            pending_start++
            i++
        }
        avail_out -= len
        total_out += len
        pending -= Int64(len)
        if (pending == 0) {
            pending_start = 0
        }
    }

    private func tallyDistance(distance: UInt32, length: UInt32): Bool {
        var dist: UInt32 = distance
        pending_buf[sym_next] = UInt8(dist & 0xFF)
        sym_next++
        pending_buf[sym_next] = UInt8((dist >> 8) & 0xFF)
        sym_next++
        pending_buf[sym_next] = UInt8(length & 0xFF)
        sym_next++
        dist--
        dyn_ltree[Int64(length_code[Int64(length)]) + Int64(LITERALS) + 1].freq_code++
        if (dist < 256) {
            dyn_dtree[Int64(dist_code[Int64(dist)])].freq_code++
        } else {
            dyn_dtree[Int64(dist_code[256 + Int64(dist >> 7)])].freq_code++
        }
        return sym_next == sym_end
    }

    private func tallyLiteral(c: UInt8): Bool {
        sym_buf[sym_next] = 0
        sym_next++
        sym_buf[sym_next] = 0
        sym_next++
        sym_buf[sym_next] = c
        sym_next++
        dyn_ltree[Int64(c)].freq_code++
        return sym_next == sym_end
    }

    private func deflateStored(flush: UInt32): UInt32 {
        var min_block: UInt32 = UInt32(min(pending_buf_size - 5, Int64(w_size)))
        var len: UInt32 = 0
        var left: UInt32 = 0
        var have: UInt32 = 0
        var last: UInt32 = 0
        var used: UInt32 = UInt32(avail_in)
        do {
            len = MAX_STORED
            have = (bits_valid + 42) >> 3
            if (avail_out < Int64(have)) {
                break
            }
            have = UInt32(avail_out) - have
            left = strstart - UInt32(block_start)
            if (len > left + UInt32(avail_in)) {
                len = left + UInt32(avail_in)
            }
            if (len > have) {
                len = have
            }
            if (len < min_block && ((len == 0 && flush != Z_FINISH) || flush == Z_NO_FLUSH || len != left + UInt32(avail_in))) {
                break
            }
            if (flush == Z_FINISH && len == left + UInt32(avail_in)) {
                last = 1
            } else {
                last = 0
            }
            storedBlock(0, 0, last == 1)
            putLenNumToPendingBuf(len)
            flushPending()
            if (left != 0 && left > len) {
                left = len
            }
            if (left != 0) {
                putWindowToOutBuf(Int64(left))
                len -= left
            }
            if (len != 0) {
                putReadBufNum(Int64(len))
            }
        } while (last == 0)
        used -= UInt32(avail_in)
        handleUsedNumInDeflateStored(used)
        if (last != 0) {
            return FINISH_DONE
        }
        if (flush != Z_NO_FLUSH && flush != Z_FINISH && avail_in == 0 && Int64(strstart) == block_start) {
            return BLOCK_DONE
        }
        have = window_size - strstart - 1
        if (avail_in > Int64(have) && block_start >= Int64(w_size)) {
            putWindowInDeflateStored(w_size)
            have += w_size
        }
        if (Int64(have) > avail_in) {
            have = UInt32(avail_in)
        }
        if (have != 0) {
            handleHaveNumInDeflateStored(have)
        }
        have = (bits_valid + 42) >> 3
        have = UInt32(min(pending_buf_size - Int64(have), Int64(MAX_STORED)))
        min_block = UInt32(min(Int64(have), Int64(w_size)))
        left = strstart - UInt32(block_start)
        if (left >= min_block || ((left != 0 || flush == Z_FINISH) && flush != Z_NO_FLUSH && avail_in == 0 && left <=
            have)) {
            len = UInt32(min(Int64(left), Int64(have)))
            if (flush == Z_FINISH && avail_in == 0 && len == left) {
                last = 1
            } else {
                last = 0
            }
            deflateStoredBlock(last, len)
        }
        if (last != 0) {
            return FINISH_STARTED
        }
        return NEED_MORE
    }

    private func deflateStoredBlock(last: UInt32, len: UInt32) {
        storedBlock(UInt32(block_start), len, last != 0)
        block_start += Int64(len)
        flushPending()
    }

    private func putWindowInDeflateStored(w_size: UInt32): Unit {
        block_start -= Int64(w_size)
        strstart -= w_size
        var i: Int64 = 0
        while (i < Int64(strstart)) {
            window[i] = window[i + Int64(w_size)]
            i++
        }
    }

    private func handleHaveNumInDeflateStored(have: UInt32): Unit {
        readBuf(window, strstart, have)
        strstart += have
    }

    private func handleUsedNumInDeflateStored(used: UInt32): Unit {
        if (used != 0 && used >= w_size) {
            var i: Int64 = 0
            while (i < Int64(w_size)) {
                window[i] = next_in[pos_in - Int64(w_size)]
                i++
                pos_in++
            }
            strstart = w_size
        }
        if (used != 0 && used < w_size && window_size - strstart <= used) {
            strstart -= w_size
            var j: Int64 = 0
            while (j < Int64(strstart)) {
                window[j] = window[j + Int64(w_size)]
                j++
            }
        }
        if (used != 0 && used < w_size) {
            var k: Int64 = 0
            while (k < Int64(used)) {
                window[k + Int64(strstart)] = next_in[pos_in - Int64(used)]
                k++
                pos_in++
            }
            strstart += used
        }
        if (used != 0) {
            block_start = Int64(strstart)
            insert += UInt32(min(Int64(used), Int64(w_size - insert)))
        }
    }

    private func putReadBufNum(len: Int64): Unit {
        readBuf(next_out, UInt32(pos_out), UInt32(len))
        pos_out += len
        avail_out -= len
        total_out += len
    }

    private func putWindowToOutBuf(left: Int64): Unit {
        var i: Int64 = 0
        while (i < left) {
            next_out[pos_out + i] = window[block_start + i]
            i++
        }
        pos_out += left
        avail_out -= left
        total_out += left
        block_start += left
    }

    private func putLenNumToPendingBuf(len: UInt32): Unit {
        pending_buf[pending_start + pending - 4] = UInt8(len & 0xFF)
        pending_buf[pending_start + pending - 3] = UInt8((len >> 8) & 0xFF)
        pending_buf[pending_start + pending - 2] = UInt8((!len) & 0xFF)
        pending_buf[pending_start + pending - 1] = UInt8((!len >> 8) & 0xFF)
    }

    private func deflateHuffman(flush: UInt32): UInt32 {
        var bflush: Bool
        while (true) {
            if (lookahead == 0) {
                fillWindow()
                if (lookahead == 0) {
                    if (flush == Z_NO_FLUSH) {
                        return NEED_MORE
                    }
                    break
                }
            }
            match_length = 0
            bflush = tallyLiteral(window[Int64(strstart)])
            lookahead--
            strstart++
            if (bflush) {
                flushBlock(block_start, Int64(strstart) - block_start, false)
                block_start = Int64(strstart)
                flushPending()
                if (avail_out == 0) {
                    return NEED_MORE
                }
            }
        }
        insert = 0
        deflateInner(flush)
        return BLOCK_DONE
    }

    private func deflateRLE(flush: UInt32): UInt32 {
        var res = deflateRLEGetStart(flush)
        if (res[0] == -1) {
            return UInt32(res[1])
        }
        block_start = res[1]
        strstart = res[2]
        insert = 0
        deflateInner(flush)
        return BLOCK_DONE
    }

    private func deflateRLEGetStart(flush: UInt32): (Int64, Int64, UInt32) {
        var bflush: Bool
        var prev: UInt8
        var scanPos: Int64
        var scanEnd: Int64
        while (true) {
            if (lookahead <= MAX_MATCH) {
                fillWindow()
                if (lookahead <= MAX_MATCH && flush == Z_NO_FLUSH) {
                    return (-1, Int64(NEED_MORE), 0)
                }
                if (lookahead == 0) {
                    break
                }
            }
            match_length = 0
            if (lookahead >= MIN_MATCH && strstart > 0) {
                scanPos = Int64(strstart) - 1
                prev = window[Int64(scanPos)]
                if (lookahead > MAX_MATCH) {
                    scanEnd = Int64(strstart + MAX_MATCH)
                } else {
                    scanEnd = Int64(strstart + lookahead)
                }
                while (scanPos < scanEnd) {
                    if (prev != window[scanPos]) {
                        break
                    }
                    scanPos++
                }
                match_length = UInt32(scanPos) - strstart
            }
            if (match_length >= MIN_MATCH) {
                bflush = tallyDistance(1, match_length - MIN_MATCH)
                lookahead -= match_length
                strstart += match_length
                match_length = 0
            } else {
                bflush = tallyLiteral(window[Int64(strstart)])
                lookahead--
                strstart++
            }
            if (bflush) {
                flushBlock(block_start, Int64(strstart) - block_start, false)
                block_start = Int64(strstart)
                flushPending()
                if (avail_out == 0) {
                    return (-1, Int64(NEED_MORE), 0)
                }
            }
        }
        return (0, block_start, strstart)
    }

    private func deflateFast(flush: UInt32): UInt32 {
        var res = deflateFastGetStart(flush)
        if (res[0] == -1) {
            return UInt32(res[1])
        }
        block_start = res[1]
        strstart = res[2]
        insert = if (strstart < MIN_MATCH - 1) {
            strstart
        } else {
            MIN_MATCH - 1
        }
        if (flush == Z_FINISH) {
            flushBlock(block_start, Int64(strstart) - block_start, true)
            block_start = Int64(strstart)
            flushPending()
            if (avail_out == 0) {
                return FINISH_STARTED
            }
            return FINISH_DONE
        }
        if (sym_next > lit_bufsize) {
            flushBlock(block_start, Int64(strstart) - block_start, false)
            block_start = Int64(strstart)
            flushPending()
            if (avail_out == 0) {
                return NEED_MORE
            }
        }
        return BLOCK_DONE
    }

    private func deflateFastGetStart(flush: UInt32): (Int64, Int64, UInt32) {
        var hash_head: UInt32 = 0
        var bflush: Bool
        while (true) {
            if (lookahead < MIN_LOOKAHEAD) {
                fillWindow()
                if (lookahead < MIN_LOOKAHEAD && flush == Z_NO_FLUSH) {
                    return (-1, Int64(NEED_MORE), 0)
                }
                if (lookahead == 0) {
                    break
                }
            }
            hash_head = 0
            if (lookahead >= MIN_MATCH) {
                hash_head = insertString(strstart)
            }
            if (hash_head != 0 && (strstart - hash_head) <= max_dist) {
                match_length = longestMatch(hash_head)
            }
            if (match_length >= MIN_MATCH) {
                bflush = tallyDistance(UInt32(Int64(strstart) - match_start), match_length - MIN_MATCH)
                lookahead -= match_length
                if (match_length <= max_insert_length && lookahead >= MIN_MATCH) {
                    match_length--
                    do {
                        strstart++
                        insertString(strstart)
                        match_length--
                    } while (match_length != 0)
                    strstart++
                } else {
                    strstart += match_length
                    match_length = 0
                    ins_h = UInt16(window[Int64(strstart)])
                    updateHash(ins_h, window[Int64(strstart) + 1])
                }
            } else {
                bflush = tallyLiteral(window[Int64(strstart)])
                lookahead--
                strstart++
            }
            if (bflush) {
                flushBlock(block_start, Int64(strstart) - block_start, false)
                block_start = Int64(strstart)
                flushPending()
                if (avail_out == 0) {
                    return (-1, Int64(NEED_MORE), 0)
                }
            }
        }
        return (0, block_start, strstart)
    }

    private func deflateSlowMinMatch(bflushs: Bool): (Int64, UInt32, Bool) {
        var bflush: Bool = bflushs
        if (prev_length >= MIN_MATCH && match_length <= prev_length) {
            var max_insert: UInt32 = strstart + lookahead - MIN_MATCH
            bflush = tallyDistance(UInt32(Int64(strstart) - 1 - prev_start), prev_length - MIN_MATCH)
            lookahead -= prev_length - 1
            do {
                strstart++
                if (strstart <= max_insert) {
                    updateHash(ins_h, window[Int64(strstart) + 2])
                    prev[Int64(strstart & w_mask)] = head[Int64(ins_h)]
                    head[Int64(ins_h)] = UInt16(strstart)
                }
                prev_length--
            } while (prev_length > 2)
            match_available = false
            match_length = MIN_MATCH - 1
            strstart++
            if (bflush) {
                flushBlock(block_start, Int64(strstart) - block_start, false)
                block_start = Int64(strstart)
                flushPending()
                if (avail_out == 0) {
                    return (-1, NEED_MORE, false)
                }
            }
        } else if (match_available) {
            bflush = tallyLiteral(window[Int64(strstart) - 1])
            if (bflush) {
                flushBlock(block_start, Int64(strstart) - block_start, false)
                block_start = Int64(strstart)
                flushPending()
            }
            strstart++
            lookahead--
            if (avail_out == 0) {
                return (-1, NEED_MORE, false)
            }
        } else {
            match_available = true
            strstart++
            lookahead--
        }
        return (0, 0, bflush)
    }

    private func deflateSlow(flush: UInt32): UInt32 {
        var hash_head: UInt32 = 0
        var bflush: Bool = false
        while (true) {
            if (lookahead < MIN_LOOKAHEAD) {
                fillWindow()
                if (lookahead < MIN_LOOKAHEAD && flush == Z_NO_FLUSH) {
                    return NEED_MORE
                }
                if (lookahead == 0) {
                    break
                }
            }
            hash_head = 0
            if (lookahead >= MIN_MATCH) {
                hash_head = insertString(strstart)
            }
            prev_length = match_length
            prev_start = match_start
            match_length = MIN_MATCH - 1
            if (hash_head != 0 && prev_length < max_lazy_match && strstart - hash_head <= max_dist) {
                match_length = longestMatch(hash_head)
                /* to do: I don't know why. */
                if ((strategy == Z_FILTERED && match_length <= 5) || (match_length == MIN_MATCH &&
                    UInt32(Int64(strstart) - match_start) > TOO_FAR)) {
                    match_length = MIN_MATCH - 1
                }
            }
            var res = deflateSlowMinMatch(bflush)
            if (res[0] == -1) {
                return res[1]
            }
            bflush = res[2]
        }
        if (match_available) {
            bflush = tallyLiteral(window[Int64(strstart) - 1])
            match_available = false
        }
        insert = if (strstart < MIN_MATCH - 1) {
            strstart
        } else {
            MIN_MATCH - 1
        }
        if (flush == Z_FINISH) {
            flushBlock(block_start, Int64(strstart) - block_start, true)
            block_start = Int64(strstart)
            flushPending()
            if (avail_out == 0) {
                return FINISH_STARTED
            }
            return FINISH_DONE
        }
        if (sym_next > lit_bufsize) {
            flushBlock(block_start, Int64(strstart) - block_start, false)
            block_start = Int64(strstart)
            flushPending()
            if (avail_out == 0) {
                return NEED_MORE
            }
        }
        return BLOCK_DONE
    }

    private func fillWindow(): Unit {
        var n: UInt32
        var more: UInt32
        var offset: UInt32
        do {
            more = window_size - lookahead - strstart
            if (strstart >= window_size - MIN_LOOKAHEAD) {
                offset = w_size - more
                var i: Int64 = 0
                while (i < Int64(offset)) {
                    window[i] = window[i + Int64(w_size)]
                    i++
                }
                match_start -= Int64(w_size)
                strstart -= w_size
                block_start -= Int64(w_size)
                if (insert > strstart) {
                    insert = strstart
                }
                slideHash(UInt16(w_size))
                more += w_size
            }
            if (avail_in == 0) {
                break
            }
            n = readBuf(window, strstart + lookahead, more)
            lookahead += n
            /* to do: */
            if (lookahead + insert >= MIN_MATCH) {
                var str: Int64 = Int64(strstart - insert)
                updateHash(UInt16(window[str]), window[str + 1])
                while (insert != 0) {
                    updateHash(ins_h, window[str + Int64(MIN_MATCH) - 1])
                    prev[str & Int64(w_mask)] = head[Int64(ins_h)]
                    head[Int64(ins_h)] = UInt16(str)
                    str++
                    insert--
                    if (lookahead + insert < MIN_MATCH) {
                        break
                    }
                }
            }
        } while (lookahead < MIN_LOOKAHEAD && avail_in != 0)
    }

    private func slideHash(offset: UInt16): Unit {
        var i: Int64 = 0
        var j: Int64 = 0
        while (i < head.size) {
            head[i] = if (head[i] > offset) {
                head[i] - offset
            } else {
                0
            }
            i++
        }
        while (j < prev.size) {
            prev[j] = if (prev[j] > offset) {
                prev[j] - offset
            } else {
                0
            }
            j++
        }
    }

    private func updateHash(hash: UInt16, c: UInt8): Unit {
        ins_h = ((hash << hash_shift) ^ UInt16(c)) & UInt16(hash_mask)
    }

    private func insertString(pos: UInt32): UInt32 {
        updateHash(ins_h, window[Int64(pos) + 2])
        let prev_pos: UInt32 = UInt32(head[Int64(ins_h)])
        prev[Int64(pos & w_mask)] = UInt16(prev_pos)
        head[Int64(ins_h)] = UInt16(pos)
        return prev_pos
    }

    private func readBuf(buf: Array<UInt8>, start: UInt32, size: UInt32): UInt32 {
        var len: Int64 = avail_in
        if (len > Int64(size)) {
            len = Int64(size)
        }
        if (len == 0) {
            return 0
        }
        avail_in -= len
        var i: Int64 = 0
        while (i < len) {
            buf[Int64(start) + i] = next_in[pos_in]
            pos_in++
            i++
        }
        match (wrap) {
            case ZLIB_TYPE => adler = adler32(adler, buf, Int64(start), len)
            case _ => ()
        }
        total_in += len
        return UInt32(len)
    }

    private func longestMatch(curmatch: UInt32): UInt32 {
        var len: UInt32
        var cur_match: UInt32 = curmatch
        var chain_length: UInt32 = max_chain_length
        var best_len: UInt32 = prev_length
        var nice_len: UInt32 = nice_length
        var limit: UInt32 = if (strstart > max_dist) {
            strstart - max_dist
        } else {
            0
        }
        var cur_pos: UInt32 = strstart
        var max_pos: UInt32 = strstart + if (lookahead >= MAX_MATCH) {
            MAX_MATCH
        } else {
            lookahead
        }
        if (prev_length >= good_length) {
            chain_length >>= 2
        }
        if (nice_len > lookahead) {
            nice_len = lookahead
        }
        do {
            var match_pos: UInt32 = cur_match
            if (window[Int64(match_pos + best_len)] != window[Int64(cur_pos + best_len)] ||
                window[Int64(match_pos + best_len - 1)] != window[Int64(cur_pos + best_len - 1)] ||
                window[Int64(match_pos)] != window[Int64(cur_pos)] || window[Int64(match_pos + 1)] != window[Int64(cur_pos +
                    1)]) {
                cur_match = UInt32(prev[Int64(cur_match & w_mask)])
                chain_length--
                continue
            }
            match_pos += 2
            cur_pos += 2
            while (cur_pos < max_pos) {
                if (window[Int64(match_pos)] != window[Int64(cur_pos)]) {
                    break
                }
                cur_pos++
                match_pos++
            }
            len = cur_pos - strstart
            cur_pos = strstart
            if (len > best_len) {
                match_start = Int64(cur_match)
                best_len = len
                if (len >= nice_len) {
                    break
                }
            }
            cur_match = UInt32(prev[Int64(cur_match & w_mask)])
            chain_length--
        } while (cur_match > limit && chain_length != 0)
        if (best_len > lookahead) {
            return lookahead
        }
        return best_len
    }

    private func treeInit(): Unit {
        initStaticTree()
        l_desc.dyn_tree = dyn_ltree
        l_desc.static_desc = static_l_desc
        d_desc.dyn_tree = dyn_dtree
        d_desc.static_desc = static_d_desc
        bl_desc.dyn_tree = bl_tree
        bl_desc.static_desc = static_bl_desc
        bits_buf = 0
        bits_valid = 0
        initBlock()
    }

    /* to do */
    private func initStaticTree() {}

    private func initBlock(): Unit {
        var i: Int64 = 0
        var j: Int64 = 0
        var k: Int64 = 0
        while (i < Int64(L_CODES)) {
            dyn_ltree[i].freq_code = 0
            i++
        }
        while (j < Int64(D_CODES)) {
            dyn_dtree[j].freq_code = 0
            j++
        }
        while (k < Int64(BL_CODES)) {
            bl_tree[k].freq_code = 0
            k++
        }
        dyn_ltree[END_BLOCK].freq_code = 1
        opt_len = 0
        static_len = 0
        sym_next = lit_bufsize
    }

    private func bitsReverse(code: UInt32, len: Int32): UInt32 {
        var result: UInt32 = 0
        var val: UInt32 = code
        var length: Int32 = len
        do {
            result |= val & 1
            val >>= 1
            result <<= 1
            length -= 1
        } while (length > 0)
        return result >> 1
    }

    private func bitsFlush(): Unit {
        if (bits_valid == 16) {
            putShort(bits_buf)
            bits_buf = 0
            bits_valid = 0
        } else if (bits_valid >= 8) {
            putByte(UInt8(bits_buf & 0xFF))
            bits_buf >>= 8
            bits_valid -= 8
        }
    }

    private func bitsFlushAlign(): Unit {
        if (bits_valid > 8) {
            putShort(bits_buf)
        } else if (bits_valid > 0) {
            putByte(UInt8(bits_buf & 0xFF))
        }
        bits_buf = 0
        bits_valid = 0
    }

    private func flushBlock(start: Int64, stored_lenb: Int64, last: Bool): Unit {
        var opt_lenb: Int64 = 0
        var static_lenb: Int64 = 0
        var max_bindex: UInt32 = 0
        if (level > 0) {
            match {
                case data_type == Z_UNKNOWN => data_type = detectDataType()
                case _ => ()
            }
            buildTree(l_desc)
            buildTree(d_desc)
            max_bindex = buildBLTree()
            opt_lenb = (opt_len + 3 + 7) >> 3
            static_lenb = (static_len + 3 + 7) >> 3
            if (static_lenb <= opt_lenb) {
                opt_lenb = static_lenb
            }
        } else {
            static_lenb = stored_lenb + 5
            opt_lenb = static_lenb
        }
        var last_val: UInt32 = if (last) {
            1
        } else {
            0
        }
        if (stored_lenb + 4 <= opt_lenb && start >= 0) {
            storedBlock(UInt32(start), UInt32(stored_lenb), last)
        } else if (strategy == Z_FIXED || static_lenb == opt_lenb) {
            sendBits((STATIC_TREES << 1) + last_val, 3)
            compressBlock(static_ltree, static_dtree)
        } else {
            sendBits((DYN_TREES << 1) + last_val, 3)
            sendAllTrees(l_desc.max_code + 1, d_desc.max_code + 1, max_bindex + 1)
            compressBlock(dyn_ltree, dyn_dtree)
        }
        initBlock()
        if (last) {
            bitsFlushAlign()
        }
    }

    private func flushEmptyStaticBlock(): Unit {
        sendBits(STATIC_TREES << 1, 3)
        sendBits(UInt32(static_ltree[END_BLOCK].freq_code), UInt32(static_ltree[END_BLOCK].dad_len))
        bitsFlush()
    }

    private func detectDataType(): Int32 {
        var black_mask: UInt32 = 0xF3FFC07F
        var i: Int64 = 0
        var j: Int64 = 32
        while (i <= 31) {
            if ((black_mask & 1) != 0 && dyn_ltree[i].freq_code != 0) {
                return Z_BINARY
            }
            i++
        }
        if (dyn_ltree[9].freq_code != 0 || dyn_ltree[10].freq_code != 0 || dyn_ltree[13].freq_code != 0) {
            return Z_TEXT
        }
        while (j < Int64(LITERALS)) {
            if (dyn_ltree[j].freq_code != 0) {
                return Z_TEXT
            }
            j++
        }
        return Z_BINARY
    }

    private func downHeap(tree: Array<CTData>, pos: Int64): Unit {
        var k: Int64 = pos
        var v: Int64 = Int64(heap[k])
        var j: Int64 = Int64(k << 1)
        var n: Int64
        var m: Int64
        while (j <= Int64(heap_len)) {
            n = Int64(heap[j + 1])
            m = Int64(heap[j])
            if (j < Int64(heap_len) && (tree[n].freq_code < tree[m].freq_code || (tree[n].freq_code == tree[m].freq_code &&
                depth[n] <= depth[m]))) {
                j++
            }
            n = v
            m = Int64(heap[j])
            if (tree[n].freq_code < tree[m].freq_code || (tree[n].freq_code == tree[m].freq_code && depth[n] <= depth[m])) {
                break
            }
            heap[k] = heap[j]
            k = j
            j <<= 1
        }
        heap[k] = UInt32(v)
    }

    private func genBitLength(desc: TreeDescription): Unit {
        var tree: Array<CTData> = desc.dyn_tree
        var max_code: Int64 = Int64(desc.max_code)
        var stree: Array<CTData> = desc.static_desc.static_tree
        var extra: Array<UInt8> = desc.static_desc.extra_bits
        var base: Int64 = Int64(desc.static_desc.extra_base)
        var max_length: Int64 = Int64(desc.static_desc.max_length)
        var j: Int64 = 0
        while (j <= Int64(MAX_BITS)) {
            bl_count[j] = 0
            j++
        }
        tree[Int64(heap[heap_max])].dad_len = 0
        var (n, m, bits, i, overflow): (Int64, Int64, Int64, Int64, Int32) = (0, 0, 0, heap_max + 1, 0)
        var xbits: UInt32
        var freq: UInt16
        while (i < Int64(HEAP_SIZE)) {
            n = Int64(heap[i])
            i++
            bits = Int64(tree[Int64(tree[n].dad_len)].dad_len + 1)
            if (bits > max_length) {
                bits = max_length
                overflow++
            }
            tree[n].dad_len = UInt16(bits)
            if (n > max_code) {
                continue
            }
            bl_count[bits] = bl_count[bits] + 1
            xbits = 0
            if (n >= base) {
                xbits = UInt32(extra[n - base])
            }
            freq = tree[n].freq_code
            opt_len += Int64(freq) * (bits + Int64(xbits))
            if (stree.size > 0) {
                static_len += Int64(freq) * (Int64(stree[n].dad_len) + Int64(xbits))
            }
        }
        if (overflow == 0) {
            return
        }
        bits = getOverflow(overflow, bits, max_length)
        var h: Int64 = Int64(HEAP_SIZE)
        while (bits != 0) {
            n = Int64(bl_count[bits])
            while (n != 0) {
                h--
                m = Int64(heap[h])
                if (m > max_code) {
                    continue
                }
                if (tree[m].dad_len != UInt16(bits)) {
                    getOpt(opt_len, bits, tree, m)
                    tree[m].dad_len = UInt16(bits)
                }
                n--
            }
            bits--
        }
    }

    private func getOpt(opt_lens: Int64, bits: Int64, tree: Array<CTData>, m: Int64): Unit {
        var opt_len: Int64 = opt_lens
        if (UInt32(bits) >= UInt32(tree[m].dad_len)) {
            opt_len += (bits - Int64(tree[m].dad_len)) * Int64(tree[m].freq_code)
        } else {
            opt_len += (Int64(tree[m].dad_len) - bits) * Int64(tree[m].freq_code)
        }
    }

    private func getOverflow(overflows: Int32, bit: Int64, max_length: Int64): Int64 {
        var bits: Int64 = bit
        var overflow: Int32 = overflows
        do {
            bits = max_length - 1
            while (bl_count[bits] == 0) {
                bits--
            }
            bl_count[bits] = bl_count[bits] - 1
            bl_count[bits + 1] = bl_count[bits + 1] + 2
            bl_count[max_length] = bl_count[max_length] - 1
            overflow -= 2
        } while (overflow > 0)
        bits = max_length
        return bits
    }

    private func genCodes(tree: Array<CTData>, max_code: UInt32, bl_count: Array<UInt16>): Unit {
        var code: UInt32 = 0
        var max_bits: Int64 = Int64(MAX_BITS)
        var next_code: Array<UInt16> = Array<UInt16>(max_bits + 1, repeat: 0)
        var i: Int64 = 1
        while (i <= max_bits) {
            code = (code + UInt32(bl_count[i - 1])) << 1
            next_code[i] = UInt16(code)
            i++
        }
        var len: UInt16
        var j: Int64 = 0
        while (j <= Int64(max_code)) {
            len = tree[j].dad_len
            if (len == 0) {
                j++
                continue
            }
            tree[j].freq_code = UInt16(bitsReverse(UInt32(next_code[Int64(len)]), Int32(len)))
            next_code[Int64(len)] = next_code[Int64(len)] + 1
            j++
        }
    }

    private func buildTree(desc: TreeDescription): Unit {
        var tree: Array<CTData> = desc.dyn_tree
        var stree: Array<CTData> = desc.static_desc.static_tree
        var element: Int64 = Int64(desc.static_desc.max_element)
        var max_code: Int32 = -1
        var node: Int64
        heap_len = 0
        heap_max = Int64(HEAP_SIZE)
        var i: Int64 = 0
        while (i < element) {
            if (tree[i].freq_code != 0) {
                heap_len++
                heap[Int64(heap_len)] = UInt32(i)
                max_code = Int32(i)
                depth[i] = 0
            } else {
                tree[i].dad_len = 0
            }
            i++
        }
        while (heap_len < 2) {
            heap_len++
            if (max_code < 2) {
                max_code++
                heap[Int64(heap_len)] = UInt32(max_code)
                node = Int64(max_code)
            } else {
                heap[Int64(heap_len)] = 0
                node = 0
            }
            tree[node].freq_code = 1
            depth[node] = 0
            opt_len--
            if (stree.size > 0) {
                static_len -= Int64(stree[node].dad_len)
            }
        }
        desc.max_code = UInt32(max_code)
        var j: Int64 = Int64(heap_len / 2)
        while (j > 1) {
            downHeap(tree, j)
            j--
        }
        node = element
        var res = buildGetTree(node, heap_max, tree)
        heap_max = res[0]
        tree = res[1]
        heap[heap_max] = heap[SMALLEST]
        genBitLength(desc)
        genCodes(tree, UInt32(max_code), bl_count)
    }

    private func buildGetTree(nodes: Int64, heap_maxs: Int64, tree: Array<CTData>): (Int64, Array<CTData>) {
        var top1: Int64
        var top2: Int64
        var node: Int64 = nodes
        var heap_max: Int64 = heap_maxs
        do {
            top1 = Int64(heap[SMALLEST])
            heap[SMALLEST] = heap[Int64(heap_len)]
            heap_len--
            downHeap(tree, SMALLEST)
            top2 = Int64(heap[SMALLEST])
            heap_max--
            heap[heap_max] = UInt32(top1)
            heap_max--
            heap[heap_max] = UInt32(top2)
            tree[node].freq_code = tree[top1].freq_code + tree[top2].freq_code
            depth[node] = UInt8(if (depth[top1] >= depth[top2]) {
                depth[top1] + 1
            } else {
                depth[top2] + 1
            })
            tree[top1].dad_len = UInt16(node)
            tree[top2].dad_len = UInt16(node)
            heap[SMALLEST] = UInt32(node)
            node++
            downHeap(tree, SMALLEST)
        } while (heap_len >= 2)
        heap_max--
        return (heap_max, tree)
    }

    private func scanTree(tree: Array<CTData>, max_code: UInt32): Unit {
        var prevlen: Int32 = -1
        var curlen: Int32
        var nextlen: Int32 = Int32(tree[0].dad_len)
        var count: Int32 = 0
        var max_count: Int32 = 7
        var min_count: Int32 = 4
        if (nextlen == 0) {
            max_count = 138
            min_count = 3
        }
        tree[Int64(max_code) + 1].dad_len = UInt16(0xFFFF)
        var n: Int64 = 0
        while (n <= Int64(max_code)) {
            curlen = nextlen
            nextlen = Int32(tree[n + 1].dad_len)
            n++
            count++
            if (count < max_count && curlen == nextlen) {
                continue
            } else if (count < min_count) {
                bl_tree[Int64(curlen)].freq_code += UInt16(count)
            } else if (curlen != 0) {
                if (curlen != prevlen) {
                    bl_tree[Int64(curlen)].freq_code++
                }
                bl_tree[REP_3_6].freq_code++
            } else if (count <= 10) {
                bl_tree[REPZ_3_10].freq_code++
            } else {
                bl_tree[REPZ_11_138].freq_code++
            }
            count = 0
            prevlen = curlen
            if (nextlen == 0) {
                max_count = 138
                min_count = 3
            } else if (curlen == nextlen) {
                max_count = 6
                min_count = 3
            } else {
                max_count = 7
                min_count = 4
            }
        }
    }

    private func buildBLTree(): UInt32 {
        scanTree(dyn_ltree, l_desc.max_code)
        scanTree(dyn_dtree, d_desc.max_code)
        buildTree(bl_desc)
        var max_bindex: UInt32 = BL_CODES - 1
        while (max_bindex >= 3) {
            if (bl_tree[bl_order[Int64(max_bindex)]].dad_len != 0) {
                break
            }
            max_bindex--
        }
        opt_len += 3 * (Int64(max_bindex) + 1) + 5 + 5 + 4
        return max_bindex
    }

    private func storedBlock(startNum: UInt32, length: UInt32, last: Bool): Unit {
        var start = Int64(startNum)
        var len = UInt16(length)
        var last_val: UInt32 = if (last) {
            1
        } else {
            0
        }
        sendBits((STORED_BLOCK << 1) + last_val, 3)
        bitsFlushAlign()
        putShort(len & 0xFFFF)
        putShort((len ^ 0xFFFF) & 0xFFFF)
        if (len > 0) {
            var i: Int64 = 0
            while (i < Int64(len)) {
                pending_buf[Int64(pending_start + pending)] = window[start]
                pending++
                start++
                i++
            }
        }
    }

    private func compressBlock(ltree: Array<CTData>, dtree: Array<CTData>): Unit {
        var dist: UInt32
        var sx: Int64 = lit_bufsize
        var lc: Int64
        var code: Int64
        var extra: UInt32
        var index: Int64
        if (sym_next != lit_bufsize) {
            do {
                dist = UInt32(sym_buf[sx]) & 0xFF
                sx++
                dist += (UInt32(sym_buf[sx]) & 0xFF) << 8
                sx++
                lc = Int64(sym_buf[sx])
                sx++
                if (dist == 0) {
                    sendBits(UInt32(ltree[lc].freq_code), UInt32(ltree[lc].dad_len))
                } else {
                    code = Int64(length_code[lc])
                    index = code + Int64(LITERALS) + 1
                    sendBits(UInt32(ltree[index].freq_code), UInt32(ltree[index].dad_len))
                    extra = UInt32(extra_lbits[code])
                    if (extra != 0) {
                        lc -= Int64(base_length[code])
                        sendBits(UInt32(lc), extra)
                    }
                    dist--
                    if (dist < 256) {
                        code = Int64(dist_code[Int64(dist)])
                    } else {
                        code = Int64(dist_code[256 + (Int64(dist) >> 7)])
                    }
                    sendBits(UInt32(dtree[code].freq_code), UInt32(dtree[code].dad_len))
                    extra = UInt32(extra_dbits[code])
                    if (extra != 0) {
                        dist -= base_dist[code]
                        sendBits(dist, extra)
                    }
                }
            } while (sx < sym_next)
        }
        sendBits(UInt32(ltree[END_BLOCK].freq_code), UInt32(ltree[END_BLOCK].dad_len))
    }

    private func sendTree(tree: Array<CTData>, max_code: UInt32): Unit {
        var max_count: UInt32 = 7
        var min_count: UInt32 = 4
        var curlen: Int64
        var nextlen: Int64 = Int64(tree[0].dad_len)
        var count: UInt32 = 0
        var prevlen: Int64 = -1
        if (nextlen == 0) {
            max_count = 138
            min_count = 3
        }
        var n: Int64 = 0
        while (n <= Int64(max_code)) {
            curlen = nextlen
            nextlen = Int64(tree[n + 1].dad_len)
            n++
            count++
            if (count < max_count && curlen == nextlen) {
                continue
            } else if (count < min_count) {
                do {
                    sendBits(UInt32(bl_tree[curlen].freq_code), UInt32(bl_tree[curlen].dad_len))
                    count--
                } while (count != 0)
            } else if (curlen != 0) {
                if (curlen != prevlen) {
                    sendBits(UInt32(bl_tree[curlen].freq_code), UInt32(bl_tree[curlen].dad_len))
                    count--
                }
                sendBits(UInt32(bl_tree[REP_3_6].freq_code), UInt32(bl_tree[REP_3_6].dad_len))
                sendBits(count - 3, 2)
            } else if (count <= 10) {
                sendBits(UInt32(bl_tree[REPZ_3_10].freq_code), UInt32(bl_tree[REPZ_3_10].dad_len))
                sendBits(count - 3, 3)
            } else {
                sendBits(UInt32(bl_tree[REPZ_11_138].freq_code), UInt32(bl_tree[REPZ_11_138].dad_len))
                sendBits(count - 11, 7)
            }
            count = 0
            prevlen = curlen
            if (nextlen == 0) {
                max_count = 138
                min_count = 3
            } else if (curlen == nextlen) {
                max_count = 6
                min_count = 3
            } else {
                max_count = 7
                min_count = 4
            }
        }
    }

    private func sendAllTrees(lcodes: UInt32, dcodes: UInt32, blcodes: UInt32): Unit {
        sendBits(lcodes - 257, 5)
        sendBits(dcodes - 1, 5)
        sendBits(blcodes - 4, 4)
        var i: Int64 = 0
        while (i < Int64(blcodes)) {
            sendBits(UInt32(bl_tree[bl_order[i]].dad_len), 3)
            i++
        }
        sendTree(dyn_ltree, lcodes - 1)
        sendTree(dyn_dtree, dcodes - 1)
    }

    private func initMatchWrap(wrap: WrapTypeEnum): Unit {
        match (wrap) {
            case _ =>
                adler = adler32(0, Array<UInt8>(), 0, 0)
                status = INIT_STATE
        }
    }

    private func initTryCatchError(): Bool {
        try {
            window = Array<UInt8>(Int64(window_size), repeat: 0)
            prev = Array<UInt16>(Int64(w_size), repeat: 0)
            head = Array<UInt16>(Int64(hash_size), repeat: 0)
            pending_buf = Array<UInt8>(pending_buf_size, repeat: 0)
            bl_count = Array<UInt16>(Int64(MAX_BITS + 1), repeat: 0)
            bl_tree = Array<CTData>(Int64(2 * BL_CODES + 1), {_ => CTData(0, 0)})
            dyn_dtree = Array<CTData>(Int64(2 * D_CODES + 1), {_ => CTData(0, 0)})
            dyn_ltree = Array<CTData>(Int64(HEAP_SIZE), {_ => CTData(0, 0)})
            heap = Array<UInt32>(Int64(HEAP_SIZE), repeat: 0)
            depth = Array<UInt8>(Int64(HEAP_SIZE), repeat: 0)
        } catch (e: Exception) {
            status = FINISH_STATE
            message = error_msg[Int64(Z_MEM_ERROR)]
            deflateEnd()
            return true
        }
        return false
    }

    private func deflateStatusJudgmentStatusFinish(): (Int64, Bool, UInt32) {
        if (status == FINISH_STATE && avail_in != 0) {
            message = error_msg[Int64(Z_BUF_ERROR)]
            return (-1, true, Z_BUF_ERROR)
        }
        return (0, false, 0)
    }

    private func getWrap(wrap: WrapTypeEnum, status: UInt32): UInt32 {
        match (wrap) {
            case DEFLATE_TYPE => return BUSY_STATE
            case _ => return status
        }
    }

    private func deflateStatusJudgmentStatusInit(): (Int64, Bool, UInt32) {
        if (status == INIT_STATE) {
            writeZlibHead()
            adler = adler32(0, Array<UInt8>(), 0, 0)
            status = BUSY_STATE
            flushPending()
            if (pending != 0) {
                last_flush = Z_UNKNOWN_FLUSH
                return (-1, true, Z_OK)
            }
        }
        return (0, false, 0)
    }

    private func deflateStatusJudgment(): (Bool, UInt32) {
        var res1 = deflateStatusJudgmentStatusFinish()
        if (res1[0] == -1) {
            return (res1[1], res1[2])
        }
        if (status == INIT_STATE) {
            status = getWrap(wrap, status)
        }
        var res2 = deflateStatusJudgmentStatusInit()
        if (res2[0] == -1) {
            return (res2[1], res2[2])
        }

        return (false, Z_ERRNO)
    }

    private func deflateMatchWrap(): Bool {
        match (wrap) {
            case DEFLATE_TYPE => return true
            case ZLIB_TYPE =>
                putShortMSB(UInt16(adler >> 16))
                putShortMSB(UInt16(adler & 0xFFFF))
        }
        return false
    }

    private func deflateByLevel(flush: UInt32): UInt32 {
        match (level) {
            case 0 => return deflateStored(flush)
            case 1 | 2 | 3 => return deflateFast(flush)
            case _ => return deflateSlow(flush)
        }
    }

    func deflateInner(flush: UInt32): UInt32 {
        if (flush == Z_FINISH) {
            flushBlock(block_start, Int64(strstart) - block_start, true)
            block_start = Int64(strstart)
            flushPending()
            if (avail_out == 0) {
                return FINISH_STARTED
            }
            return FINISH_DONE
        }
        if (sym_next > lit_bufsize) {
            flushBlock(block_start, Int64(strstart) - block_start, false)
            block_start = Int64(strstart)
            flushPending()
            if (avail_out == 0) {
                return NEED_MORE
            }
        }
        return BLOCK_DONE
    }
}
