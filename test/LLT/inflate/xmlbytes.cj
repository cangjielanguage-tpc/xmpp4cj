// DEPENDENCE: deflate.cj inflate.cj package.cj stream.cj zlib_input_output_stream.cj zutil.cj
// EXEC: cjc %import-path %L %l %f deflate.cj inflate.cj package.cj stream.cj zlib_input_output_stream.cj zutil.cj --test
// EXEC: ./main 

package cangjie_tpc::xmpp4cj.compression1

import std.time.*
import std.net.*
import std.fs.*
import std.io.*
import std.regex.*
import std.sync.SyncCounter
import stdx.encoding.base64.*

let xmlbytes0: Array<Byte> = [120, 218, 140, 82, 97, 111, 155, 48, 16, 253, 43, 200, 223, 193, 100, 105, 218, 206, 2,
    42, 84, 109, 106, 165, 54, 137, 150, 85, 91, 62, 58, 112, 1, 103, 198, 70, 62, 119, 33, 251, 245, 181, 33, 73, 147,
    101, 147, 250, 201, 230, 222, 123, 231, 119, 199, 75, 238, 186, 70, 6, 191, 193, 160, 208, 42, 37, 163, 40, 38, 1,
    168, 66, 151, 66, 85, 41, 121, 249, 254, 53, 188, 37, 119, 89, 130, 214, 0, 111, 216, 112, 4, 78, 162, 112, 255,
    145, 146, 218, 218, 150, 81, 10, 182, 6, 211, 69, 27, 190, 90, 129, 137, 180, 169, 232, 64, 64, 50, 240, 83, 50, 64,
    172, 144, 2, 148, 37, 193, 218, 104, 167, 238, 154, 182, 141, 44, 160, 69, 48, 206, 6, 9, 68, 153, 146, 201, 102,
    242, 235, 51, 112, 222, 77, 122, 49, 147, 220, 187, 249, 83, 135, 247, 83, 114, 110, 246, 104, 109, 13, 220, 190,
    26, 192, 44, 105, 160, 168, 185, 18, 216, 224, 225, 225, 87, 163, 152, 0, 187, 102, 45, 55, 206, 16, 243, 45, 149,
    63, 218, 54, 68, 142, 146, 156, 136, 178, 249, 83, 254, 56, 77, 232, 123, 225, 4, 203, 167, 179, 233, 242, 121, 246,
    178, 248, 15, 190, 184, 255, 150, 63, 135, 139, 135, 60, 28, 157, 49, 222, 239, 206, 159, 243, 127, 106, 204, 187,
    56, 186, 103, 70, 163, 29, 22, 65, 179, 100, 37, 84, 249, 145, 25, 60, 207, 243, 17, 208, 111, 230, 67, 99, 15, 84,
    55, 185, 110, 173, 187, 112, 233, 244, 116, 95, 117, 157, 154, 11, 139, 216, 176, 79, 253, 35, 255, 132, 198, 30,
    42, 80, 92, 96, 174, 198, 226, 30, 60, 64, 251, 188, 156, 4, 165, 53, 218, 234, 66, 75, 90, 240, 214, 197, 165, 230,
    88, 167, 4, 107, 30, 142, 72, 160, 116, 9, 131, 6, 157, 104, 187, 221, 70, 162, 82, 194, 237, 8, 184, 180, 162, 129,
    67, 131, 13, 20, 22, 169, 110, 65, 173, 133, 1, 218, 199, 36, 37, 95, 118, 203, 7, 249, 195, 62, 221, 96, 14, 143,
    213, 56, 223, 84, 63, 231, 243, 221, 50, 86, 179, 171, 212, 155, 146, 162, 17, 22, 47, 7, 234, 51, 21, 14, 40, 243,
    41, 107, 120, 23, 174, 118, 46, 167, 217, 40, 190, 186, 157, 220, 92, 187, 127, 122, 44, 37, 162, 148, 224, 86, 90,
    104, 85, 98, 54, 190, 142, 19, 122, 86, 73, 232, 208, 201, 111, 248, 175, 180, 190, 1, 0, 0, 255, 255, 178, 201, 44,
    84, 40, 169, 44, 0, 122, 17, 200, 43, 205, 41, 129, 164, 127, 11, 115, 215, 112, 67, 144, 239, 75, 242, 49, 114,
    136, 190, 165, 145, 81, 178, 73, 154, 169, 165, 174, 169, 101, 178, 165, 174, 137, 113, 146, 185, 174, 165, 169,
    113, 162, 174, 145, 161, 169, 177, 65, 114, 146, 161, 81, 98, 98, 170, 18, 137, 137, 199, 206, 38, 43, 51, 197, 206,
    208, 200, 129, 28, 203, 108, 244, 65, 154, 109, 244, 65, 38, 1, 169, 204, 66, 59, 0, 0, 0, 0, 255, 255, 178, 73,
    205, 75, 76, 202, 73, 77, 193, 158, 82, 20, 64, 94, 205, 5, 122, 185, 164, 168, 52, 21, 226, 97, 255, 16, 207, 202,
    200, 170, 160, 92, 191, 144, 236, 18, 191, 144, 156, 44, 255, 96, 3, 3, 95, 35, 79, 99, 159, 144, 108, 67, 95, 35,
    215, 18, 223, 44, 87, 67, 223, 42, 167, 172, 200, 44, 96, 140, 134, 187, 229, 56, 186, 132, 21, 250, 133, 23, 155,
    70, 133, 187, 101, 164, 186, 132, 218, 42, 41, 228, 228, 39, 39, 150, 128, 139, 5, 140, 18, 5, 24, 81, 182, 74, 102,
    6, 160, 84, 8, 0, 0, 0, 255, 255, 178, 41, 0, 218, 13, 44, 223, 82, 193, 182, 6, 184, 122, 186, 128, 131, 25, 82,
    20, 145, 233, 125, 72, 44, 145, 171, 89, 223, 14, 0, 0, 0, 255, 255, 66, 117, 83, 160, 175, 135, 153, 167, 174, 145,
    133, 137, 49, 220, 93, 22, 24, 38, 7, 3, 227, 49, 155, 50, 123, 65, 5, 39, 48, 13, 22, 219, 61, 95, 182, 251, 233,
    158, 6, 80, 202, 4, 115, 129, 174, 201, 204, 47, 202, 44, 169, 180, 3, 166, 98, 56, 219, 166, 56, 35, 191, 220, 46,
    177, 60, 177, 18, 168, 16, 196, 164, 78, 118, 198, 151, 149, 139, 115, 19, 147, 179, 161, 217, 56, 60, 36, 63, 191,
    56, 178, 60, 192, 191, 36, 212, 63, 51, 36, 165, 60, 68, 59, 216, 59, 173, 184, 60, 207, 169, 172, 220, 22, 232, 19,
    253, 100, 59, 144, 91, 33, 161, 104, 7, 0, 0, 0, 255, 255, 164, 85, 77, 11, 130, 64, 16, 253, 43, 97, 103, 117, 119,
    83, 34, 49, 17, 42, 186, 118, 136, 138, 46, 178, 166, 133, 91, 182, 226, 106, 208, 191, 111, 118, 220, 236, 96, 135,
    160, 211, 192, 238, 60, 222, 204, 155, 47, 216, 199, 74, 241, 75, 254, 151, 60, 70, 122, 63, 254, 122, 159, 30, 233,
    198, 19, 123, 81, 0, 119, 254, 128, 99, 246, 131, 22, 85, 155, 170, 54, 29, 163, 59, 192, 32, 109, 184, 79, 157, 26,
    170, 145, 53, 196, 27, 164, 82, 94, 75, 40, 172, 50, 255, 72, 117, 106, 235, 186, 131, 24, 183, 55, 215, 55, 20,
    172, 155, 51, 200, 169, 123, 73, 104, 176, 142, 59, 97, 36, 97, 52, 254, 124, 57, 131, 148, 120, 219, 72, 33, 139,
    187, 153, 200, 40, 188, 23, 167, 107, 228, 135, 46, 90, 144, 183, 199, 226, 6, 67, 94, 61, 232, 16, 163, 49, 122,
    181, 97, 106, 81, 152, 229, 55, 254, 28, 12, 62, 190, 90, 35, 104, 178, 178, 154, 91, 140, 48, 207, 166, 204, 38,
    147, 45, 97, 1, 245, 2, 66, 29, 143, 78, 143, 122, 26, 120, 150, 65, 37, 225, 18, 253, 32, 170, 241, 181, 122, 84,
    191, 75, 171, 219, 179, 145, 86, 167, 194, 160, 136, 238, 133, 139, 162, 116, 22, 135, 213, 114, 51, 91, 239, 52,
    171, 219, 211, 226, 181, 198, 6, 138, 94, 0, 0, 0, 255, 255, 204, 154, 199, 142, 131, 108, 150, 64, 95, 101, 52, 91,
    75, 63, 57, 181, 212, 45, 1, 6, 131, 77, 206, 176, 35, 155, 108, 114, 120, 250, 49, 110, 205, 116, 247, 36, 177,
    104, 141, 102, 87, 178, 170, 142, 169, 143, 123, 110, 130, 255, 131, 72, 250, 88, 129, 74, 10, 19, 245, 207, 137,
    164, 116, 254, 99, 44, 194, 120, 252, 227, 123, 199, 206, 54, 233, 151, 17, 199, 63, 194, 173, 171, 187, 169, 254,
    35, 154, 219, 111, 89, 26, 255, 68, 194, 56, 12, 82, 40, 74, 252, 247, 129, 246, 215, 95, 251, 247, 43, 249, 223,
    153, 103, 92, 126, 45, 78, 19, 109, 72, 95, 233, 174, 205, 81, 93, 196, 255, 242, 247, 31, 137, 95, 54, 132, 19, 8,
    142, 146, 8, 68, 254, 235, 95, 24, 99, 36, 26, 82, 174, 83, 136, 198, 122, 198, 141, 82, 6, 41, 7, 102, 101, 21,
    186, 160, 103, 239, 93, 138, 234, 235, 85, 221, 24, 7, 213, 115, 242, 27, 109, 255, 5, 254, 143, 95, 104, 126, 127,
    254, 149, 210, 191, 88, 175, 24, 8, 43, 249, 99, 31, 194, 141, 88, 108, 45, 154, 138, 109, 238, 71, 219, 151, 226,
    207, 22, 49, 218, 56, 244, 106, 122, 67, 14, 186, 137, 15, 64, 137, 77, 171, 118, 138, 66, 127, 190, 141, 189, 184,
    73, 130, 245, 86, 102, 12, 74, 124, 12, 95, 215, 70, 160, 12, 230, 40, 188, 186, 96, 243, 63, 255, 249, 31, 175,
    225, 111, 223, 247, 45, 250, 223, 227, 250, 38, 199, 239, 167, 127, 97, 82, 37, 67, 165, 122, 246, 2, 31, 216, 0,
    140, 153, 196, 110, 72, 130, 12, 228, 64, 108, 18, 100, 84, 90, 63, 137, 243, 120, 63, 197, 93, 99, 204, 179, 57,
    248, 219, 95, 158, 217, 191, 74, 247, 95, 226, 253, 187, 19, 252, 252, 237, 236, 190, 71, 230, 155, 22, 143, 131,
    116, 85, 50, 233, 205, 219, 107, 27, 177, 23, 124, 233, 192, 216, 248, 54, 175, 81, 198, 18, 249, 155, 132, 216, 66,
    10, 138, 206, 254, 37, 194, 191, 59, 172, 255, 129, 10, 127, 169, 9, 170, 55, 199, 253, 37, 199, 66, 236, 29, 137,
    40, 100, 71, 25, 203, 175, 198, 163, 122, 244, 219, 161, 123, 58, 9, 53, 106, 77, 9, 140, 184, 22, 23, 169, 200,
    121, 123, 215, 207, 51, 45, 64, 227, 37, 9, 74, 65, 231, 214, 11, 166, 178, 172, 234, 143, 188, 208, 199, 38, 221,
    193, 123, 75, 38, 174, 63, 100, 142, 147, 92, 164, 162, 95, 106, 4, 243, 7, 107, 179, 32, 250, 76, 124, 217, 197,
    149, 58, 229, 85, 220, 112, 181, 98, 196, 164, 125, 141, 25, 190, 232, 189, 240, 208, 178, 28, 133, 47, 82, 177,
    243, 92, 31, 230, 240, 142, 96, 80, 7, 154, 6, 217, 214, 50, 104, 71, 209, 193, 150, 224, 33, 161, 14, 146, 162,
    152, 158, 110, 72, 217, 185, 60, 249, 153, 47, 82, 241, 243, 92, 33, 24, 72, 1, 135, 67, 30, 97, 195, 170, 181, 177,
    148, 203, 253, 185, 138, 55, 89, 191, 103, 74, 221, 231, 55, 220, 185, 121, 97, 234, 72, 204, 120, 145, 74, 156,
    231, 138, 151, 47, 130, 120, 200, 234, 145, 112, 224, 13, 64, 15, 49, 255, 172, 6, 241, 96, 88, 48, 154, 198, 149,
    14, 159, 225, 206, 75, 149, 203, 5, 245, 69, 234, 41, 99, 68, 137, 80, 195, 96, 32, 112, 0, 98, 219, 171, 14, 125,
    219, 243, 15, 36, 177, 158, 68, 212, 148, 205, 190, 60, 7, 85, 182, 123, 56, 172, 156, 123, 145, 250, 77, 101, 95,
    171, 17, 108, 203, 59, 150, 242, 216, 29, 129, 93, 106, 235, 66, 8, 177, 90, 10, 112, 61, 120, 174, 40, 149, 111,
    196, 173, 131, 91, 228, 206, 236, 23, 169, 208, 183, 9, 103, 236, 49, 69, 124, 81, 84, 55, 62, 125, 190, 179, 45,
    215, 110, 61, 90, 142, 28, 228, 132, 79, 104, 86, 125, 29, 194, 10, 143, 85, 145, 254, 198, 89, 87, 177, 167, 93,
    110, 167, 209, 26, 67, 7, 82, 5, 80, 130, 155, 162, 175, 79, 132, 250, 88, 28, 70, 21, 161, 215, 248, 226, 88, 58,
    36, 190, 52, 67, 78, 141, 171, 81, 0, 157, 122, 249, 150, 137, 227, 159, 78, 68, 210, 221, 198, 185, 119, 60, 211,
    229, 55, 26, 156, 93, 169, 12, 180, 222, 214, 238, 253, 154, 241, 168, 101, 77, 161, 123, 94, 197, 158, 126, 185,
    79, 115, 255, 124, 255, 111, 255, 41, 220, 20, 107, 122, 108, 41, 248, 230, 24, 170, 203, 95, 3, 245, 104, 143, 161,
    123, 190, 110, 147, 169, 107, 34, 19, 92, 197, 158, 130, 5, 83, 170, 184, 180, 144, 85, 169, 30, 177, 106, 115, 216,
    62, 240, 76, 1, 222, 134, 239, 80, 103, 7, 58, 112, 60, 132, 60, 160, 13, 45, 24, 175, 106, 11, 157, 134, 5, 168,
    80, 77, 46, 100, 116, 233, 219, 163, 13, 215, 156, 2, 183, 110, 25, 84, 237, 224, 61, 226, 15, 248, 237, 26, 24, 39,
    61, 193, 232, 241, 145, 175, 98, 79, 197, 252, 119, 133, 180, 208, 22, 205, 121, 222, 204, 143, 1, 130, 133, 165,
    127, 36, 115, 169, 181, 213, 71, 112, 62, 122, 15, 149, 64, 8, 145, 70, 192, 33, 87, 177, 167, 99, 161, 88, 141, 98,
    208, 51, 98, 139, 55, 92, 1, 165, 27, 205, 145, 178, 78, 46, 207, 230, 8, 70, 134, 129, 109, 29, 114, 239, 64, 63,
    183, 220, 229, 91, 118, 74, 102, 131, 72, 212, 186, 12, 232, 222, 151, 135, 250, 216, 238, 187, 22, 230, 61, 53,
    238, 36, 247, 18, 45, 200, 29, 238, 2, 245, 26, 9, 38, 44, 192, 238, 42, 246, 180, 44, 222, 166, 178, 187, 71, 178,
    154, 167, 82, 65, 15, 236, 141, 95, 199, 181, 187, 165, 24, 142, 19, 210, 33, 20, 92, 66, 102, 171, 172, 206, 84,
    34, 93, 173, 10, 167, 101, 102, 251, 4, 171, 24, 233, 203, 145, 237, 159, 177, 192, 12, 107, 191, 69, 175, 56, 88,
    13, 146, 160, 8, 123, 7, 52, 12, 192, 70, 82, 175, 187, 171, 183, 12, 62, 45, 51, 43, 216, 73, 225, 97, 147, 88,
    233, 144, 110, 1, 91, 119, 244, 135, 149, 115, 75, 171, 97, 127, 175, 168, 176, 63, 120, 185, 194, 133, 103, 60,
    198, 87, 177, 240, 175, 155, 0, 10, 45, 33, 228, 24, 21, 125, 177, 112, 228, 144, 102, 237, 23, 141, 123, 12, 21,
    161, 192, 61, 78, 14, 63, 197, 123, 184, 83, 236, 45, 189, 138, 61, 45, 51, 129, 165, 142, 141, 129, 91, 167, 17,
    81, 250, 100, 157, 248, 181, 184, 31, 106, 182, 136, 14, 147, 52, 77, 50, 84, 251, 32, 193, 114, 12, 6, 220, 85,
    236, 105, 153, 137, 162, 155, 127, 27, 32, 54, 91, 138, 69, 13, 155, 193, 12, 124, 222, 97, 249, 32, 142, 167, 169,
    170, 224, 246, 83, 183, 136, 152, 72, 173, 66, 95, 197, 158, 150, 121, 178, 111, 245, 220, 55, 234, 135, 5, 161, 48,
    35, 65, 146, 111, 94, 208, 10, 30, 182, 106, 32, 66, 30, 158, 237, 221, 96, 113, 163, 131, 120, 188, 154, 19, 224,
    211, 50, 215, 167, 18, 112, 126, 248, 43, 211, 225, 80, 128, 149, 32, 31, 109, 118, 57, 108, 134, 22, 219, 25, 131,
    250, 58, 114, 67, 88, 3, 65, 7, 67, 189, 138, 61, 45, 75, 39, 203, 82, 230, 251, 32, 42, 86, 230, 36, 34, 32, 23,
    163, 238, 72, 2, 114, 131, 40, 43, 167, 28, 157, 227, 23, 126, 179, 55, 244, 125, 246, 74, 215, 176, 167, 101, 110,
    18, 76, 117, 75, 211, 205, 83, 221, 209, 232, 229, 150, 27, 101, 162, 75, 214, 141, 211, 12, 185, 44, 57, 161, 242,
    182, 131, 224, 146, 214, 202, 237, 42, 246, 180, 204, 238, 60, 139, 229, 100, 121, 42, 238, 217, 83, 125, 138, 106,
    74, 114, 163, 243, 176, 95, 47, 74, 141, 219, 145, 42, 51, 128, 70, 225, 249, 232, 160, 171, 213, 28, 57, 45, 203,
    210, 122, 179, 224, 193, 178, 91, 178, 155, 49, 133, 81, 129, 142, 52, 41, 84, 164, 64, 136, 224, 231, 4, 161, 124,
    255, 83, 241, 64, 88, 80, 253, 85, 236, 105, 153, 61, 176, 166, 174, 79, 232, 250, 97, 25, 139, 74, 63, 200, 163,
    43, 152, 76, 52, 32, 109, 55, 220, 12, 184, 185, 220, 136, 180, 20, 143, 30, 91, 126, 21, 251, 179, 76, 184, 65,
    114, 161, 12, 232, 124, 43, 71, 239, 53, 138, 88, 9, 168, 207, 67, 195, 110, 253, 186, 61, 33, 82, 163, 234, 33, 67,
    154, 23, 184, 94, 109, 64, 145, 211, 178, 212, 138, 159, 226, 199, 162, 160, 10, 81, 241, 101, 201, 55, 70, 70, 167,
    156, 8, 136, 1, 227, 119, 5, 81, 1, 157, 107, 138, 187, 53, 203, 224, 229, 14, 244, 180, 76, 207, 120, 193, 138,
    209, 216, 179, 209, 72, 9, 187, 0, 192, 224, 64, 179, 31, 76, 126, 187, 163, 11, 247, 29, 110, 84, 23, 248, 108, 67,
    142, 138, 235, 85, 236, 105, 153, 131, 72, 75, 243, 116, 181, 217, 117, 49, 197, 135, 37, 187, 51, 66, 157, 34, 218,
    39, 78, 238, 217, 224, 69, 2, 110, 148, 20, 32, 10, 228, 83, 191, 138, 61, 45, 51, 131, 239, 240, 70, 122, 199, 157,
    101, 157, 50, 133, 248, 231, 27, 170, 61, 173, 163, 25, 130, 204, 55, 207, 114, 188, 151, 40, 48, 200, 202, 68, 198,
    213, 184, 69, 78, 203, 108, 98, 34, 225, 27, 104, 227, 179, 41, 137, 64, 23, 13, 9, 92, 185, 30, 136, 40, 175, 247,
    195, 67, 227, 161, 55, 123, 152, 143, 162, 98, 231, 219, 171, 216, 95, 195, 88, 109, 161, 176, 248, 47, 166, 20,
    202, 251, 132, 38, 46, 26, 96, 29, 95, 26, 208, 48, 211, 251, 224, 239, 176, 70, 119, 224, 61, 137, 203, 55, 117,
    21, 123, 90, 150, 154, 121, 172, 240, 163, 231, 226, 66, 121, 68, 123, 206, 115, 208, 76, 134, 79, 24, 63, 162, 40,
    118, 243, 176, 81, 52, 93, 204, 139, 60, 171, 175, 86, 7, 244, 180, 44, 105, 227, 180, 103, 84, 44, 236, 118, 177,
    84, 60, 160, 74, 246, 122, 128, 70, 180, 147, 239, 123, 45, 127, 147, 177, 249, 166, 139, 133, 104, 16, 241, 234,
    216, 128, 158, 150, 5, 160, 169, 125, 144, 216, 236, 176, 111, 220, 31, 123, 226, 132, 21, 208, 106, 55, 216, 128,
    116, 234, 25, 4, 20, 197, 77, 245, 91, 169, 107, 112, 186, 154, 24, 209, 223, 64, 246, 34, 248, 174, 19, 187, 77,
    28, 107, 4, 92, 107, 61, 33, 227, 74, 228, 123, 150, 194, 204, 77, 66, 251, 76, 30, 30, 252, 187, 58, 0, 251, 106,
    117, 64, 79, 203, 28, 110, 131, 44, 64, 27, 231, 253, 227, 187, 19, 95, 42, 43, 71, 155, 75, 103, 206, 2, 247, 157,
    241, 142, 80, 207, 105, 147, 72, 99, 123, 36, 47, 95, 237, 105, 89, 2, 138, 203, 232, 219, 201, 7, 82, 198, 6, 74,
    113, 185, 23, 115, 22, 57, 10, 19, 37, 136, 249, 237, 246, 126, 76, 140, 247, 102, 213, 146, 21, 191, 138, 197, 126,
    211, 147, 54, 53, 200, 99, 47, 132, 187, 159, 77, 219, 67, 107, 50, 151, 71, 106, 173, 7, 166, 103, 220, 220, 80, 9,
    168, 236, 100, 19, 168, 140, 186, 154, 193, 208, 211, 50, 7, 163, 222, 118, 21, 181, 79, 180, 174, 235, 130, 159,
    197, 37, 226, 54, 250, 5, 196, 247, 7, 62, 241, 22, 250, 118, 108, 171, 243, 152, 167, 38, 95, 142, 132, 211, 50,
    223, 69, 253, 206, 165, 29, 60, 81, 81, 157, 109, 239, 31, 32, 139, 150, 160, 52, 76, 147, 82, 191, 121, 28, 127,
    65, 242, 59, 180, 30, 52, 17, 92, 77, 53, 232, 105, 89, 232, 208, 71, 33, 125, 200, 122, 187, 87, 113, 253, 242, 36,
    188, 85, 116, 139, 171, 204, 80, 86, 19, 155, 152, 31, 221, 163, 142, 220, 136, 227, 130, 203, 87, 123, 90, 230,
    209, 138, 130, 142, 134, 237, 115, 244, 46, 122, 126, 68, 174, 20, 141, 1, 9, 145, 5, 184, 68, 78, 237, 125, 14, 73,
    98, 138, 118, 117, 168, 175, 54, 162, 216, 105, 89, 232, 15, 119, 136, 151, 182, 169, 183, 98, 192, 101, 204, 247,
    212, 83, 8, 3, 169, 163, 32, 155, 239, 185, 204, 82, 217, 228, 170, 154, 37, 103, 242, 234, 33, 96, 167, 101, 22,
    159, 221, 202, 64, 219, 34, 102, 194, 251, 5, 133, 120, 116, 173, 142, 45, 228, 28, 100, 191, 169, 38, 153, 51, 93,
    209, 63, 119, 153, 174, 160, 207, 85, 236, 207, 178, 239, 4, 230, 191, 23, 28, 205, 152, 236, 104, 226, 15, 85, 77,
    0, 64, 14, 142, 143, 221, 204, 166, 67, 74, 100, 69, 211, 117, 49, 241, 25, 107, 174, 98, 127, 181, 44, 113, 17,
    176, 177, 142, 97, 86, 76, 3, 118, 128, 165, 131, 196, 250, 120, 127, 166, 54, 164, 75, 253, 70, 33, 38, 59, 251,
    143, 224, 61, 161, 239, 171, 216, 211, 50, 191, 79, 77, 96, 19, 39, 126, 228, 233, 2, 99, 36, 240, 195, 78, 143,
    111, 132, 121, 96, 61, 30, 82, 67, 111, 254, 94, 54, 171, 21, 25, 235, 213, 153, 23, 59, 45, 51, 105, 118, 120, 137,
    53, 207, 195, 69, 194, 237, 210, 241, 121, 225, 111, 87, 1, 94, 217, 209, 126, 39, 178, 136, 179, 148, 110, 47, 220,
    22, 23, 59, 237, 42, 246, 180, 44, 91, 103, 111, 119, 9, 233, 99, 173, 2, 218, 143, 46, 111, 102, 141, 104, 43, 98,
    160, 59, 201, 77, 253, 196, 15, 35, 67, 165, 106, 80, 76, 231, 106, 137, 196, 126, 115, 153, 207, 106, 65, 13, 204,
    51, 209, 214, 210, 210, 231, 241, 27, 148, 159, 113, 92, 83, 234, 86, 67, 96, 15, 145, 152, 81, 190, 171, 193, 159,
    186, 171, 195, 41, 118, 90, 230, 113, 233, 237, 29, 28, 64, 113, 203, 121, 89, 49, 11, 78, 201, 27, 170, 120, 169,
    82, 164, 128, 114, 241, 42, 31, 208, 202, 217, 157, 134, 183, 212, 213, 229, 7, 118, 90, 230, 75, 185, 230, 231, 58,
    100, 168, 81, 35, 226, 155, 15, 53, 163, 168, 168, 5, 209, 159, 67, 3, 242, 89, 165, 15, 24, 214, 35, 53, 245, 241,
    213, 52, 142, 255, 213, 50, 142, 195, 120, 181, 11, 119, 88, 223, 41, 187, 77, 125, 248, 248, 104, 14, 166, 195, 32,
    236, 213, 218, 176, 224, 21, 77, 196, 161, 212, 6, 206, 85, 236, 105, 89, 130, 32, 121, 138, 198, 117, 154, 122,
    183, 121, 168, 70, 92, 96, 49, 51, 208, 65, 205, 75, 9, 198, 17, 236, 152, 39, 217, 221, 28, 82, 121, 188, 58, 64,
    225, 167, 101, 30, 174, 8, 128, 249, 98, 84, 98, 228, 110, 74, 8, 52, 12, 187, 67, 27, 99, 240, 236, 45, 16, 239,
    119, 232, 112, 42, 171, 153, 214, 21, 157, 174, 174, 128, 240, 159, 101, 101, 22, 53, 108, 228, 86, 123, 237, 225,
    183, 100, 18, 143, 12, 208, 38, 1, 241, 105, 228, 51, 225, 133, 59, 130, 125, 146, 63, 64, 156, 27, 175, 206, 14,
    248, 105, 153, 237, 192, 219, 55, 31, 114, 128, 76, 176, 221, 196, 80, 6, 188, 44, 82, 251, 12, 189, 78, 245, 239,
    250, 139, 30, 168, 133, 27, 114, 161, 170, 252, 171, 3, 20, 254, 155, 203, 216, 144, 103, 221, 185, 3, 111, 143, 82,
    49, 1, 162, 183, 225, 224, 70, 1, 216, 35, 236, 120, 237, 192, 232, 131, 214, 217, 88, 189, 215, 113, 112, 117, 118,
    192, 79, 203, 60, 247, 254, 164, 44, 201, 140, 107, 140, 26, 156, 55, 130, 209, 38, 236, 141, 157, 252, 192, 244,
    37, 238, 30, 159, 110, 87, 5, 218, 244, 55, 92, 55, 174, 98, 79, 203, 178, 60, 56, 100, 55, 25, 181, 21, 236, 66,
    132, 28, 109, 95, 7, 202, 72, 180, 204, 68, 29, 125, 122, 219, 100, 108, 3, 115, 19, 103, 48, 144, 189, 138, 61, 45,
    211, 9, 211, 242, 210, 248, 157, 61, 28, 53, 107, 52, 78, 110, 101, 145, 220, 163, 59, 28, 176, 238, 32, 11, 52,
    158, 166, 3, 79, 137, 102, 25, 92, 93, 170, 224, 167, 101, 250, 67, 71, 30, 146, 71, 74, 101, 190, 55, 69, 33, 221,
    99, 55, 227, 197, 126, 177, 51, 121, 201, 33, 165, 139, 181, 42, 89, 62, 31, 79, 0, 129, 171, 91, 214, 211, 50, 63,
    212, 131, 180, 30, 153, 209, 51, 218, 7, 253, 72, 102, 47, 47, 180, 103, 119, 111, 77, 51, 220, 23, 10, 99, 144,
    166, 46, 155, 28, 47, 235, 215, 85, 236, 175, 150, 105, 48, 3, 121, 90, 45, 186, 13, 185, 64, 52, 163, 28, 84, 100,
    29, 94, 113, 80, 27, 72, 223, 151, 20, 28, 125, 45, 146, 200, 141, 12, 200, 171, 216, 211, 50, 103, 174, 58, 112,
    228, 177, 207, 103, 24, 196, 253, 37, 99, 223, 60, 192, 22, 146, 19, 114, 71, 161, 14, 15, 47, 169, 51, 247, 112, 3,
    20, 131, 174, 118, 227, 196, 105, 153, 165, 62, 107, 8, 170, 76, 249, 118, 227, 106, 85, 20, 107, 178, 50, 185, 222,
    25, 125, 73, 165, 191, 169, 251, 1, 207, 200, 115, 150, 244, 12, 187, 92, 34, 137, 211, 50, 195, 217, 208, 172, 129,
    85, 52, 117, 232, 27, 63, 83, 136, 59, 66, 249, 248, 240, 49, 8, 49, 63, 249, 200, 173, 143, 186, 80, 245, 155, 207,
    78, 87, 71, 18, 226, 180, 204, 18, 38, 67, 102, 49, 80, 232, 119, 228, 6, 26, 80, 220, 13, 82, 111, 196, 159, 101,
    64, 141, 79, 87, 90, 48, 94, 220, 210, 252, 219, 80, 249, 87, 219, 15, 226, 180, 204, 224, 209, 210, 96, 76, 134,
    24, 224, 70, 59, 248, 157, 218, 42, 185, 184, 55, 139, 72, 126, 80, 249, 49, 24, 29, 142, 5, 105, 208, 167, 153, 40,
    92, 197, 158, 150, 89, 118, 249, 164, 16, 25, 8, 189, 23, 148, 19, 216, 234, 84, 245, 3, 52, 65, 20, 219, 121, 200,
    216, 202, 39, 1, 175, 82, 206, 62, 142, 91, 114, 117, 240, 39, 126, 59, 198, 84, 83, 1, 218, 43, 3, 137, 181, 76,
    199, 41, 77, 198, 154, 236, 228, 142, 180, 244, 171, 93, 42, 143, 150, 159, 202, 158, 225, 110, 80, 94, 94, 170, 16,
    191, 29, 227, 139, 38, 208, 155, 177, 16, 132, 87, 196, 139, 9, 110, 188, 95, 114, 35, 28, 125, 252, 137, 28, 158,
    46, 194, 217, 46, 85, 112, 72, 155, 118, 87, 119, 140, 228, 111, 46, 43, 7, 199, 161, 222, 30, 56, 108, 207, 226,
    113, 71, 149, 46, 66, 75, 232, 158, 49, 114, 118, 208, 221, 109, 241, 171, 60, 1, 109, 196, 241, 140, 232, 42, 246,
    180, 44, 236, 12, 226, 158, 76, 232, 10, 170, 57, 254, 222, 21, 163, 6, 214, 29, 147, 227, 89, 199, 19, 193, 134,
    169, 134, 131, 150, 181, 134, 193, 199, 20, 94, 197, 254, 58, 70, 24, 190, 17, 62, 35, 184, 223, 116, 94, 152, 141,
    82, 44, 42, 240, 242, 186, 251, 221, 195, 133, 34, 181, 137, 103, 254, 156, 99, 205, 107, 236, 231, 85, 203, 200,
    211, 178, 128, 134, 250, 237, 217, 81, 226, 70, 231, 130, 250, 98, 145, 134, 251, 94, 168, 216, 220, 133, 113, 128,
    15, 109, 212, 160, 101, 198, 88, 215, 115, 171, 171, 75, 108, 242, 183, 99, 188, 251, 56, 79, 197, 98, 223, 81, 206,
    199, 48, 7, 90, 178, 123, 236, 35, 188, 109, 35, 67, 72, 170, 42, 105, 119, 67, 191, 205, 115, 210, 211, 87, 251, 4,
    242, 180, 204, 80, 29, 205, 44, 173, 144, 211, 153, 88, 7, 142, 103, 27, 188, 210, 7, 52, 138, 145, 170, 246, 14,
    242, 66, 95, 228, 139, 86, 194, 2, 136, 208, 171, 173, 29, 249, 123, 88, 70, 64, 147, 215, 42, 225, 232, 175, 145,
    156, 116, 107, 123, 168, 49, 131, 5, 228, 74, 227, 184, 226, 91, 248, 188, 234, 107, 107, 152, 113, 115, 249, 185,
    3, 249, 179, 76, 131, 160, 137, 213, 85, 35, 16, 212, 133, 127, 244, 181, 240, 166, 164, 87, 223, 43, 69, 104, 121,
    46, 223, 34, 75, 143, 205, 237, 11, 220, 166, 171, 213, 129, 252, 237, 24, 89, 44, 172, 94, 105, 165, 72, 45, 114,
    239, 64, 150, 191, 27, 6, 11, 192, 234, 141, 102, 223, 164, 88, 205, 251, 158, 61, 66, 71, 28, 166, 167, 119, 21,
    251, 219, 126, 80, 31, 206, 129, 30, 116, 146, 145, 140, 15, 196, 226, 118, 123, 248, 210, 235, 163, 175, 165, 121,
    124, 198, 123, 159, 71, 89, 246, 28, 21, 173, 170, 208, 171, 79, 225, 126, 150, 121, 181, 105, 153, 24, 40, 139,
    170, 2, 245, 165, 101, 75, 171, 153, 136, 50, 144, 43, 240, 10, 78, 31, 30, 18, 170, 231, 30, 49, 52, 244, 158, 174,
    98, 127, 155, 252, 39, 202, 151, 163, 164, 245, 66, 75, 163, 19, 62, 46, 203, 74, 68, 108, 183, 251, 186, 131, 129,
    19, 161, 217, 123, 75, 137, 116, 215, 221, 159, 87, 59, 70, 234, 183, 99, 84, 223, 233, 78, 189, 208, 89, 81, 29,
    55, 90, 176, 4, 220, 137, 170, 145, 245, 252, 62, 222, 160, 22, 97, 130, 247, 252, 20, 33, 250, 81, 50, 87, 71, 18,
    234, 180, 44, 178, 4, 23, 15, 108, 62, 15, 158, 122, 182, 175, 99, 83, 115, 209, 109, 65, 228, 180, 45, 243, 165,
    172, 137, 217, 218, 189, 165, 88, 59, 237, 77, 92, 197, 158, 150, 197, 180, 183, 166, 175, 155, 38, 197, 241, 91,
    192, 161, 111, 91, 199, 63, 228, 247, 75, 242, 222, 251, 115, 158, 178, 120, 189, 197, 89, 50, 149, 244, 189, 190,
    58, 238, 81, 191, 90, 182, 96, 20, 16, 59, 26, 144, 251, 238, 192, 244, 90, 57, 190, 122, 46, 138, 8, 165, 137, 148,
    160, 48, 190, 249, 38, 230, 251, 176, 208, 209, 207, 213, 214, 142, 250, 237, 24, 81, 160, 157, 136, 238, 99, 75,
    62, 200, 241, 82, 43, 68, 3, 255, 141, 254, 70, 127, 237, 98, 92, 231, 125, 233, 235, 248, 205, 193, 216, 76, 44,
    175, 98, 79, 203, 188, 133, 104, 159, 14, 103, 98, 166, 220, 25, 12, 106, 132, 86, 116, 207, 56, 144, 99, 141, 201,
    130, 39, 73, 40, 138, 0, 153, 77, 77, 213, 248, 171, 205, 18, 117, 90, 230, 87, 56, 20, 229, 143, 100, 144, 29, 100,
    72, 142, 129, 215, 109, 91, 12, 19, 225, 78, 68, 239, 228, 51, 47, 101, 64, 25, 4, 186, 193, 119, 229, 242, 67, 105,
    234, 151, 111, 45, 141, 51, 215, 251, 3, 86, 37, 208, 139, 230, 118, 105, 85, 179, 219, 66, 238, 77, 56, 134, 10,
    148, 22, 29, 122, 121, 249, 105, 100, 90, 187, 252, 84, 250, 212, 204, 213, 91, 177, 67, 73, 57, 97, 188, 56, 144,
    38, 63, 210, 23, 16, 191, 3, 198, 55, 120, 169, 190, 105, 53, 126, 146, 38, 177, 38, 90, 86, 25, 254, 51, 23, 248,
    143, 183, 63, 128, 191, 190, 117, 243, 79, 124, 173, 10, 196, 254, 4, 131, 127, 96, 8, 249, 255, 237, 181, 170, 127,
    3, 0, 0, 255, 255, 162, 195, 178, 42, 227, 148, 180, 240, 130, 72, 163, 60, 186, 44, 171, 74, 73, 45, 203, 76, 78,
    205, 201, 44, 46, 193, 190, 158, 10, 36, 67, 244, 106, 42, 136, 97, 144, 85, 192, 240, 101, 90, 250, 224, 37, 196,
    197, 37, 84, 79, 29, 22, 6, 131, 46, 117, 0, 0, 0, 0, 255, 255, 178, 129, 173, 142, 87, 71, 89, 53, 172, 174, 160,
    111, 7, 0, 0, 0, 255, 255, 66, 93, 41, 107, 232, 28, 108, 105, 140, 88, 189, 139, 105, 161, 97, 154, 177, 121, 154,
    133, 97, 138, 110, 82, 178, 177, 177, 174, 137, 137, 113, 178, 110, 146, 185, 69, 170, 174, 101, 154, 89, 74, 74,
    106, 74, 146, 129, 145, 101, 18, 174, 69, 180, 64, 231, 1, 0, 0, 0, 255, 255, 194, 182, 86, 216, 72, 9, 234, 217,
    210, 188, 196, 178, 196, 204, 28, 208, 42, 231, 1, 94, 62, 12, 0, 0, 0, 255, 255, 130, 175, 41, 135, 80, 118, 0, 0,
    0, 0, 255, 255, 3, 0, 240, 105, 239, 19]
let xmlstr = ##"<?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" from="xmpp.testserver" id="5j5k9eaax5" xml:lang="zh-CN" version="1.0"><stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>PLAIN</mechanism><mechanism>ANONYMOUS</mechanism><mechanism>SCRAM-SHA-1</mechanism></mechanisms><ver xmlns="urn:xmpp:features:rosterver"/><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/><session xmlns="urn:ietf:params:xml:ns:xmpp-session"><optional/></session><sm xmlns="urn:xmpp:sm:2"/><sm xmlns="urn:xmpp:sm:3"/><csi xmlns="urn:xmpp:csi:0"/><c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="https://www.igniterealtime.org/projects/openfire/" ver="EyYHlWtL7sAeIg3AjgXPPyY0nO4="/><limits xmlns="urn:xmpp:stream-limits:0"><max-bytes>1048576</max-bytes><idle-seconds>360</idle-seconds></limits></stream:features><iq type="result" id="87EW1-1" to="xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae</jid></bind></iq><enabled xmlns="urn:xmpp:sm:3" resume="true" id="OTIyYzRmNTktNTljOS00M2I3LTk1M2EtMjE1MzBjYjEyYWFlADVqNWs5ZWFheDU=" location="xmpp.testserver" max="600"/><presence id="PEID1-1" from="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae" to="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae"/><presence id="QMH6I-28431" from="8@xmpp.testserver/Spark" to="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae"><status>离开</status><priority>0</priority><show>away</show><c xmlns="http://jabber.org/protocol/caps" hash="sha-1" node="https://igniterealtime.org/projects/smack" ver="WToosYwPOtUOiTdwT+SKfswnBvw="></c></presence><message to="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae" from="5@xmpp.testserver" id="vbP4jWji"><event xmlns="http://jabber.org/protocol/pubsub#event"><items node="storage:bookmarks"><item id="current"><storage xmlns="storage:bookmarks"><conference jid="test_20_21@conference.xmpp.testserver" autojoin="true"><nick>5</nick></conference></storage></item></items></event><delay xmlns="urn:xmpp:delay" stamp="2024-12-03T02:14:01.417Z"/><addresses xmlns="http://jabber.org/protocol/address"><address type="replyto" jid="5@xmpp.testserver/gajim.CXEDP9GV"/></addresses></message><message to="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae" from="5@xmpp.testserver" id="pTZO8Ht9"><event xmlns="http://jabber.org/protocol/pubsub#event"><items node="eu.siacs.conversations.axolotl.bundles:826209447"><item id="current"><bundle xmlns="eu.siacs.conversations.axolotl"><signedPreKeyPublic signedPreKeyId="1673648318">BRs7m8Mle1A5qBWbeB3jrBwCNAiAuXhjIOKKk+BV4Qg8</signedPreKeyPublic><signedPreKeySignature>TKc/akMpUzH+7vUPbtixuqsUYLcpxbBPsrqOe+3zAmcz/NcSTlViiQJhRyi+LHThNu51dY56wwmH9RBziXliCg==</signedPreKeySignature><identityKey>BeNf4LluXZY/x/5BtIordZf0E05tHM4LwpdVGhJIyPBS</identityKey><prekeys><preKeyPublic preKeyId="1">BYSTF60AkjBe+XylU3Uv6vo0cRaslbfC7gh81CiLZioU</preKeyPublic><preKeyPublic preKeyId="2">Bd4QmzDKMcHcXzdIHfzjcMKmX9q4ienXQ81mOl9HBIwi</preKeyPublic><preKeyPublic preKeyId="3">BRwpJei0RKLHNiAgTK29ffkqzgiQsmey0Dn8dWYrfVVd</preKeyPublic><preKeyPublic preKeyId="4">Bb2FzCUC04JdYMW6NleFO6RWPis5LywcBFiqXazPfg42</preKeyPublic><preKeyPublic preKeyId="5">BYGSrhb20Q/mm3xwjZnsIV5vZGL4V3e45Qex3joWF8pu</preKeyPublic><preKeyPublic preKeyId="6">Bd12/e/VE3GamCOlRvjvDJwI+MQDfNlqg+6V+XaeVLBs</preKeyPublic><preKeyPublic preKeyId="7">BR6jK77GMOzdE0+/4zIgpwR7GBC0btswAaJayFLkWEZl</preKeyPublic><preKeyPublic preKeyId="8">Bb9I1mB50/z/InqOVA+ygp1LCXL7l9UCKXV4NxDarwEW</preKeyPublic><preKeyPublic preKeyId="9">BWb35xgoC9XCy32W9xoa13Tn9/WX2uk9OFmIxo2n3DBy</preKeyPublic><preKeyPublic preKeyId="10">BUse3YIIOxFeJhfxgP+q4jsE1VaJ1uOYQ15iXCO3q+ET</preKeyPublic><preKeyPublic preKeyId="11">BWoPAPBAZLk/9HWe4Kpb4Y5cabk7Ql6vVTQ1IKPRMeRu</preKeyPublic><preKeyPublic preKeyId="12">BYTS66poI3eyU6EhcuAjCOlVyNkR4lxwohKu6bnCSHoJ</preKeyPublic><preKeyPublic preKeyId="13">BWJSypq4jYJH+NTtGxe0hEB9ogKr9GnzroJK+tSQPIBZ</preKeyPublic><preKeyPublic preKeyId="14">BZteNWAHfkeQbCOmzUY/Je/FU2D1oUZQ/zGHgZARPZsd</preKeyPublic><preKeyPublic preKeyId="15">BZ4HktW1RoehXARWStZWlnB4Oo2ybFz2hWR5ELJ0bGpM</preKeyPublic><preKeyPublic preKeyId="16">BYhk3n1xbuggmuGr12HvqGdujPnkpHVpQq1j/a18RZE3</preKeyPublic><preKeyPublic preKeyId="17">BaIksIZqBIn6mEi1exAE8MQ8vJmzZsBB2UQ1WD/qunEJ</preKeyPublic><preKeyPublic preKeyId="18">BU03bnWB0WDvGOGxDyPagq9sy8EKIT1WrDH9Ks7Bai0o</preKeyPublic><preKeyPublic preKeyId="19">BcxtjoDbMOgeLiArC+Fwswo+e5667LzHiEd8fwMOu9dL</preKeyPublic><preKeyPublic preKeyId="20">BSnJ0kc3qjsCqJcHBrwqxbKcZwR8797Uy/P5/5s8QloM</preKeyPublic><preKeyPublic preKeyId="21">BSk2Ve2rxLCLzL+ZCloApCMgTPl2Yyk9aqzFMk6HJcsc</preKeyPublic><preKeyPublic preKeyId="22">BRs/iPd7Mc4IYIiVMaACUKA6XB9b4/DcdzYe6q2oNUxe</preKeyPublic><preKeyPublic preKeyId="23">BS/vlcRrEwts3NqdwtFwiDzOfvIVBdmmdrkyrL2Mc0ZE</preKeyPublic><preKeyPublic preKeyId="24">BS44xY+r1CfvivOamrSZYFVCFZccttkk2npln3IdLnNA</preKeyPublic><preKeyPublic preKeyId="25">BXMYTqEQq1rv395Rd3dtGxPiF2Tl/b3GXUX+2IxAZcsZ</preKeyPublic><preKeyPublic preKeyId="26">BWY9d0uGYwBo61Z5j0FbxUjrxRPcUfB4YQ3+3CR34rRO</preKeyPublic><preKeyPublic preKeyId="27">BetTTNuDrINTfVdI/MisQVLH3+19Tg9VQEFvFxUx4hBS</preKeyPublic><preKeyPublic preKeyId="28">BWdZtlnAAmJOy4bKWjx9S4vfostu1WC8t4Mxy00velN+</preKeyPublic><preKeyPublic preKeyId="29">BUoXTCEMMtiDfJOJIOe8EsVGUKK9Ocns9jf/A42uzo1s</preKeyPublic><preKeyPublic preKeyId="30">BfelxT2rTUn8ou5NBO/o8S94I9017Fud39YYpkF/ai9q</preKeyPublic><preKeyPublic preKeyId="31">BUrCSQQt4wpCBT9ep3GoiBfIR1PyRWf/+WEs3n9F4zxg</preKeyPublic><preKeyPublic preKeyId="32">BRH+1MiNr4u+jsXKsI5j/OJzP5+qwxJ18P9lrf3mK0wU</preKeyPublic><preKeyPublic preKeyId="33">BeTcJIpT91k3O6vvgxBM4tg7Z7r5FyN3O/QEmiDTuM0i</preKeyPublic><preKeyPublic preKeyId="34">BQfFHTc4cXU4bNaoZ/52ZPUGBg+D4vEndlOW/pxrg4Iw</preKeyPublic><preKeyPublic preKeyId="35">BV3LvmJWPuWW5NY2LUoRaQ97nJ68yfrXbH6Rj9/IH8JQ</preKeyPublic><preKeyPublic preKeyId="36">BSZnod8XzDCCVje1FJh1lXPoAB78gxXTVXKIHB3wBbR+</preKeyPublic><preKeyPublic preKeyId="37">BU7t82+0U6uSLI/obrd2kWX03NKhGX4crqSq2FbbiyFn</preKeyPublic><preKeyPublic preKeyId="38">BbkxaHvYKBjHjDt4dW4Z5oFjR1ruAyrYy2PAo0Ddcjh9</preKeyPublic><preKeyPublic preKeyId="39">BeSgcNFsXW6HjzbygFE1u8aJ26zbbcWgamNPQIgigflc</preKeyPublic><preKeyPublic preKeyId="40">BdnceqBO5aoyIjNX/kdylr1s4oMDylM44xShAiv7m3I2</preKeyPublic><preKeyPublic preKeyId="41">BZ0SPp3cSo59lrzydVak/nP+2R1Q9JZZ99EtlhNll0tO</preKeyPublic><preKeyPublic preKeyId="42">BdK7FooIoxIsl30wlQd8ckIFqC95SxL4qfMrGFhkz/UA</preKeyPublic><preKeyPublic preKeyId="43">BVEx1T/PsuypYWtFjNwEASvoSuHEQ81zaQgAS7ecUs8O</preKeyPublic><preKeyPublic preKeyId="44">Bd0IvsYUdp1Nsm1e6MqIgC3ziS477uhWqYc7sDmwPdw6</preKeyPublic><preKeyPublic preKeyId="45">Bd1Ptm3GyiHDYftxGPmfWF3lPq/tJcm+4L/kUdxH9f9g</preKeyPublic><preKeyPublic preKeyId="46">BV59hUkbnJ4llliFuIvbExAK/cDG6tFT4hVUToXBJPM2</preKeyPublic><preKeyPublic preKeyId="47">BYW4YoWAV6dO4QCnDp/fbvZjRSS9O7Fu6K1MhaTGA7Zw</preKeyPublic><preKeyPublic preKeyId="48">BaVAziLp8lxDkclKXL6nNQTEkSaMOdU7uGoGlbWbEEZ2</preKeyPublic><preKeyPublic preKeyId="49">BXANN4sRUYEAyIXYb8w9A5/d7fZ6L8tnDua87tbyOrlo</preKeyPublic><preKeyPublic preKeyId="50">BaYrD1FLxtqTc/WBShtq93B1OsHMShujfeMSEklC8u8w</preKeyPublic><preKeyPublic preKeyId="51">BTFf+jZPxbBt6qv41F4wkzxaEV3y+OS8gBoiqJyMAk1p</preKeyPublic><preKeyPublic preKeyId="52">BdyNkYhv64fBfzmcp9kt//8rVY5+Smo3j3w4ewvS6u5m</preKeyPublic><preKeyPublic preKeyId="53">BedW30mTzruNSR2V/vo1IlzhptnaAjQ+93SCuYGZht4h</preKeyPublic><preKeyPublic preKeyId="54">BYqeS/xItFsFAi5BL0pCtGvZjX0lszLmAxYyjmwTbRwT</preKeyPublic><preKeyPublic preKeyId="55">BSACrKIlFF2idEyLzpK6hWN/KfznR5EbETNoyiWn6IoP</preKeyPublic><preKeyPublic preKeyId="56">BfwuXyW7LpTwH4qsWFSfmIUNIZQVd+OpcGRf4LkrNSVQ</preKeyPublic><preKeyPublic preKeyId="57">BaYCPZl/uu7nlLvqgch0MJccl9Oxl10q185RjhkrYtod</preKeyPublic><preKeyPublic preKeyId="58">BXEe+hZz/i+gFMNSiENgm9iKOLbN0MiKjG1wEUoP6n9W</preKeyPublic><preKeyPublic preKeyId="59">BYLgPYgQ1RObmI6xY1msINOi7qrkyr3pwLp0als9tqcA</preKeyPublic><preKeyPublic preKeyId="60">BaYEE5FOoay2Qy9UneY2zpPV5Q202XlPrv6kA7caLnZV</preKeyPublic><preKeyPublic preKeyId="61">Bd33ge4cleeX+urks6HC5SZQ0PXe7BVHUcF8CySreMse</preKeyPublic><preKeyPublic preKeyId="62">BX6NH/SKBO7sE+Na/mBCy1xBRFC+ZIDD1zVkTmtww4ty</preKeyPublic><preKeyPublic preKeyId="63">BejfbmCbWkylX6+dtIzf/PtH3YA3pt6iWs0qdgG06EsS</preKeyPublic><preKeyPublic preKeyId="64">BUV2xXYbE/M7CotB9R2vvLnJaXoOYDQKAr9vErgHkkYZ</preKeyPublic><preKeyPublic preKeyId="65">BXCaFCWuo0+GjNS/7qU2Z+9/5GaoFPz5AzAQCcODlcZs</preKeyPublic><preKeyPublic preKeyId="66">BXWDJ9TLScl59rVh35AS2XsoMG5QvcoGpoyOHASYx6QR</preKeyPublic><preKeyPublic preKeyId="67">BfgZzMWdsPw0oa38sUYQ/jbITSdOsYAxxM5x0gS6B50C</preKeyPublic><preKeyPublic preKeyId="68">BQ7STXechfGVOfmPEMnMI8ybD2ZCWrMHA6eerF9ISjZJ</preKeyPublic><preKeyPublic preKeyId="69">BQGQ3GLX8LjgymiiLDcWfFIqvUfMvg1NocPkdvppXH0/</preKeyPublic><preKeyPublic preKeyId="70">BYaQZelsBsXRnGAGduXgiPJoDnSSayv95B3mljmg6jlK</preKeyPublic><preKeyPublic preKeyId="71">BTP2B1XPlIWm8v1ABNz9bTzXiz9x0ADve0sYPbL8x8Z8</preKeyPublic><preKeyPublic preKeyId="72">BVuko0sF5pprrIyKM5lPrCiLVaEziOrGXdlfWzWZ4519</preKeyPublic><preKeyPublic preKeyId="73">BTOJl11kSM++ElOIIl8kSEqVsYLOASVQG2u3JuLQf55m</preKeyPublic><preKeyPublic preKeyId="74">BRVx4fm2O4eVA+Fu93Ws1gsGY513SpgsEwGliOQ+YCtn</preKeyPublic><preKeyPublic preKeyId="75">BTHtRMC50Hqy3+0R1corLqRcpvr4RpojT26i+egAziYw</preKeyPublic><preKeyPublic preKeyId="76">BRF4jRBSB7r2mPzFy9xkMiDmvI8p4MGrRo65ZeZqefIH</preKeyPublic><preKeyPublic preKeyId="77">BTUjJ93M/aXK1g75wVklG0S045yF1RxjJ72wLgCGz+dq</preKeyPublic><preKeyPublic preKeyId="78">BUePO/AXjZLCTSVVjSBTtUdD3nAKnvkXAMJNyf6WZjBS</preKeyPublic><preKeyPublic preKeyId="79">BcKA74+Rv77XicvS0xFYjEs2bpYt8rJW3EUW9iE3neoL</preKeyPublic><preKeyPublic preKeyId="80">BdjrVV9hX0rxJiGD4Nob4j1DfBMfzAo+vYkgd0U3VXRb</preKeyPublic><preKeyPublic preKeyId="81">BaoR7Ddt4w0Og6hyNRl/wy5McuQ6dHU29mE1vwl20Gta</preKeyPublic><preKeyPublic preKeyId="82">Bd22+7YBHWCaFiSmNivO/KXoDDX6HieU7JgJucPXmUJ9</preKeyPublic><preKeyPublic preKeyId="83">BZA1qxJo9IxAgHOKC3mEuQ6ImDHsr2zPsP1vu5CWXWk3</preKeyPublic><preKeyPublic preKeyId="84">BSDY6F9cIqo9VpRSrALUq5pHhURf389kjAWx48gBdqAV</preKeyPublic><preKeyPublic preKeyId="85">BROVPSjTaEQBcQ/zJnZKeG1sIbOOqV3K4K8KANai/b4Q</preKeyPublic><preKeyPublic preKeyId="86">Bd71tXnNasYwbMdownzOcB5Z8wA66NYT6uwQwnRScmsd</preKeyPublic><preKeyPublic preKeyId="87">BTP11tCQORZHOvFGqlHh9LKqqNiaTXWFn3vq5unK0xt/</preKeyPublic><preKeyPublic preKeyId="88">BWC5akKekNLn3Do0CFDRRC/2O+ACh8IkuyyfGaVIrtJX</preKeyPublic><preKeyPublic preKeyId="89">Be9pEV1GAdf8BY/cIx+GYLKpQwjSzpsDqgbffJsNPkk4</preKeyPublic><preKeyPublic preKeyId="90">BdXlSTS50MION1qjTULwSdIM/gN2w0tpF1HkJybBA1ht</preKeyPublic><preKeyPublic preKeyId="91">BSJ4FjsLPqHnA4t6svvw7bCoyYQV50t7PUyn9IAooDJe</preKeyPublic><preKeyPublic preKeyId="92">BROhey9K4uNOVWbv5d0y7kmMQgDs+1n3BZhuJI1AGjBP</preKeyPublic><preKeyPublic preKeyId="93">BbTHW6ZUFgZJQfywsmlEb+v3Menjgvjl7uTyXviwoPh7</preKeyPublic><preKeyPublic preKeyId="94">BcAXweK+PLcchH61Z+9FGMhKLXhyJutfcw+cfdtjADlh</preKeyPublic><preKeyPublic preKeyId="95">BTv59/cVP/gYWrBqPjsKqEbb7NmbNZiR6HicFqaiQ4pR</preKeyPublic><preKeyPublic preKeyId="96">BS4/nt7opULY0EFLnHbrFnK0mQKyIclgqjYQ6+V5CfIj</preKeyPublic><preKeyPublic preKeyId="97">BXv7nJVES5SMoRB4RaTbDfE0ECRtT2tLHiiZ3uSPOPFK</preKeyPublic><preKeyPublic preKeyId="98">BYk61bgGdrMV3rdzrFQUUIadHD7bhdpuvjZ9R74x2DNW</preKeyPublic><preKeyPublic preKeyId="99">BZATPESwDG2OL0XbunvnOSoxaEh7VRO/jTAaXgjpmMAP</preKeyPublic><preKeyPublic preKeyId="100">BWQnIo48MdBXcZLtYbQv06D/RkmM9qmnPFtLtIl7nCNr</preKeyPublic></prekeys></bundle></item></items></event><delay xmlns="urn:xmpp:delay" stamp="2024-12-03T02:05:20.538Z"/><addresses xmlns="http://jabber.org/protocol/address"><address type="replyto" jid="5@xmpp.testserver/gajim.CXEDP9GV"/></addresses></message><message to="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae" from="5@xmpp.testserver" id="3dfWpY2n"><event xmlns="http://jabber.org/protocol/pubsub#event"><items node="eu.siacs.conversations.axolotl.devicelist"><item id="current"><list xmlns="eu.siacs.conversations.axolotl"><device id="826209447"/></list></item></items></event><delay xmlns="urn:xmpp:delay" stamp="2024-12-03T02:05:20.808Z"/><addresses xmlns="http://jabber.org/protocol/address"><address type="replyto" jid="5@xmpp.testserver/gajim.CXEDP9GV"/></addresses></message><r xmlns='urn:xmpp:sm:3' /><presence id="1CS93-1" from="5@xmpp.testserver/1f37f81d-bc33-443c-b78e-9f6ddedb029b" to="12@xmpp.testserver"/><presence id="PEID1-2" type="unavailable" from="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae" to="12@xmpp.testserver/922c4f59-59c9-43b7-953a-21530cb12aae"/></stream:stream>"##

// @Test
public func t1(): Unit {
    let input = ByteBuffer()
    input.write(xmlbytes0)
    let de = DeCompressInWrapper(input)

    let arr = Array<Byte>(1024, repeat: 0)
    let res = StringBuilder()
    while (true) {
        let len = de.read(arr)
        if (len <= 0) {
            break
        }
        println(len)
        res.append(String.fromUtf8(arr[..len]))
    }
    @Assert(res.toString(), xmlstr)
}

// @Test
public func t2(): Unit {
    let inflate: Inflate = Inflate()
    inflate.inflateInit(wrap: ZLIB_TYPE)

    inflate.setInBuf(xmlbytes0)

    let buffer = Array<Byte>(1024, repeat: 0)

    let res = StringBuilder()
    for (i in 0..20) {
        let l0 = inflate.isHaveOutData()
        inflate.setOutBuf(buffer)
        inflate.inflate(Z_FULL_FLUSH)
        println("${i}: ${l0} ${inflate.isHaveOutData()} ${inflate.getOutDataLength()}")
        res.append(String.fromUtf8(buffer[..inflate.getOutDataLength()]))
    }
    @Assert(res.toString(), xmlstr)
}

@Test
public func t3(): Unit {
    let input = ByteBuffer()
    spawn {
        let src = ByteBuffer()
        src.write(xmlbytes0)
        let arr = Array<Byte>(500, repeat: 0)
        while (true) {
            sleep(Duration.millisecond / 500)
            let len = src.read(arr)
            if (len == 0) {
                break
            }
            input.write(arr[..len])
        }
    }

    let de = DeCompressInWrapper(input)

    let arr = Array<Byte>(1024, repeat: 0)
    let res = StringBuilder()
    while (true) {
        sleep(Duration.second)
        let len = de.read(arr)
        if (len <= 0) {
            break
        }
        println(len)
        res.append(String.fromUtf8(arr[..len]))
    }
    @Assert(res.toString(), xmlstr)
}
