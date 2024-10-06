/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights resvered.
 */
package xmpp4cj.jid

/**
 * XMPP 中用于日期和时间处理的工具类
 *
 * @see XEP-82: XMPP DateTime and Time Profiles
 */
public class XmppDateTime {
    private static let dateFormatter = DateFormatType("yyyy-MM-dd") // XEP_0082_DATE_PROFILE

    private static let datePattern = Regex(#"^\d+-\d+-\d+$"#)

    private static let timeFormatter = DateFormatType("hh:mm:ss.SSSOOOO") // XEP_0082_TIME_MILLIS_ZONE_PROFILE

    private static let timePattern = Regex(#"^(\d+:){2}\d+.\d+(Z|([+-](\d+:\d+)))$"#)

    private static let timeNoZoneFormatter = DateFormatType("hh:mm:ss.SSS") // XEP_0082_TIME_MILLIS_PROFILE

    private static let timeNoZonePattern = Regex(#"^(\d+:){2}\d+.\d+$"#)

    private static let timeNoMillisFormatter = DateFormatType("hh:mm:ssOOOO") // XEP_0082_TIME_ZONE_PROFILE

    private static let timeNoMillisPattern = Regex(#"^(\d+:){2}\d+(Z|([+-](\d+:\d+)))$"#)

    private static let timeNoMillisNoZoneFormatter = DateFormatType("hh:mm:ss") // XEP_0082_TIME_PROFILE

    private static let timeNoMillisNoZonePattern = Regex(#"^(\d+:){2}\d+$"#)

    private static let dateTimeFormatter = DateFormatType("yyyy-MM-ddTHH:mm:ss.SSSOOOO") // XEP_0082_DATETIME_MILLIS_PROFILE

    private static let dateTimePattern = Regex(#"^\d+(-\d+){2}+T(\d+:){2}\d+.\d+(Z|([+-](\d+:\d+)))$"#)

    private static let dateTimeNoMillisFormatter = DateFormatType("yyyy-MM-ddTHH:mm:ssOOOO") // XEP_0082_DATETIME_PROFILE

    private static let dateTimeNoMillisPattern = Regex(#"^\d+(-\d+){2}+T(\d+:){2}\d+(Z|([+-](\d+:\d+)))$"#)

    private static let TIME_ZONE_UTC = TimeZone.UTC

    static func constructUtcDateFormat(format: String): DateFormatType {
        return DateFormatType(format)
    }

    private static let xep0091Formatter = constructUtcDateFormat("yyyyMMddTHH:mm:ss")

    private static let xep0091Date6DigitFormatter = constructUtcDateFormat("yyyyMdTHH:mm:ss")

    private static let xep0091Date7Digit1MonthFormatter = constructUtcDateFormat("yyyyMddTHH:mm:ss")

    private static let xep0091Date7Digit2MonthFormatter = constructUtcDateFormat("yyyyMMdTHH:mm:ss")

    private static let xep0091Pattern = Regex(#"^\d+T\d+:\d+:\d+$"#)
    private static let extraDurationReg = Regex(#".*(\d{2}):(\d{2}):(\d{2}).*"#)

    private static let couplings = ArrayList<PatternCouplings>(
        [
            PatternCouplings(datePattern, dateFormatter),
            PatternCouplings(dateTimePattern, dateTimeFormatter),
            PatternCouplings(dateTimeNoMillisPattern, dateTimeNoMillisFormatter),
            PatternCouplings(timePattern, timeFormatter),
            PatternCouplings(timeNoZonePattern, timeNoZoneFormatter),
            PatternCouplings(timeNoMillisPattern, timeNoMillisFormatter),
            PatternCouplings(timeNoMillisNoZonePattern, timeNoMillisNoZoneFormatter)
        ]
    )

    /**
     * 解析给定的日期字符串，遵循 XEP-0082 - XMPP 日期时间和时间配置文件。
     *
     * @param dateString 要解析的日期字符串。
     * @return 解析后的 DateTime。
     * @throws ParseException 如果指定的字符串无法解析。
     */
    public static func parseXEP0082Date(dateString: String): DateTime {
        for (coupling in couplings) {
            let matcher = coupling.pattern.matcher(dateString)
            if (matcher.find().isSome()) {
                return coupling.formatter.parse(dateString)
            }
        }
        return dateTimeNoMillisFormatter.parse(dateString)
    }

    /**
     * 解析给定的日期字符串，可以是 XEP-0082 - XMPP 日期时间和时间配置文件的三种配置之一，或者是 XEP-0091 - 传统延迟交付格式。此方法使用内部日期格式化器，因此是线程安全的。
     *
     * @param dateString 要解析的日期字符串。
     * @return 解析后的 DateTime。
     * @throws ParseException 如果指定的字符串无法解析。
     */
    public static func parseDate(dateString: String): DateTime {
        let matcher = xep0091Pattern.matcher(dateString)
        if (matcher.find().isSome()) {
            let length = dateString.split("T")[0].size
            if (length < 8) {
                let date = handleDateWithMissingLeadingZeros(dateString, length)
                if (let Some(date) <- date) {
                    return date
                }
            } else {
                return xep0091Formatter.parse(dateString)
            }
        }
        if (let Some(data) <- extraDurationReg.matcher(dateString).find()) {
            var str = dateString
            var extraDuration = Duration.Zero
            for ((group, maxnum, timeUnit) in [(1, 23, Duration.hour), (2, 59, Duration.minute), (3, 59, Duration.second)]) {
                let pos = data.matchPosition(group)
                let num = Int64.parse(str[pos.start..pos.end])
                if (num > maxnum) {
                    extraDuration += (timeUnit * (num - maxnum))
                    str = "${str[0..pos.start]}${maxnum}${str[pos.end..]}"
                }
            }
            return parseXEP0082Date(str) + extraDuration
        }
        return parseXEP0082Date(dateString)
    }

    private static let XEP_0082_DATETIME_MILLIS_PROFILE = DateFormatType("yyyy-MM-ddTHH:mm:ss.SOO") // XEP_0082_DATETIME_MILLIS_PROFILE

    /**
     * 将 DateTime 格式化为 XEP-0082 - XMPP 日期时间和时间配置文件的字符串。
     *
     * @param date 要格式化为时间字符串的时间值。
     * @return 以 XEP-0082 格式格式化后的时间字符串。
     */
    public static func formatXEP0082Date(date: DateTime): String {
        return XEP_0082_DATETIME_MILLIS_PROFILE.format(date)
    }

    /**
     * 将 XEP-0082 日期字符串的时区定义转换为 RFC822 时区定义。主要区别在于 XEP-0082 在小时和分钟之间使用分号，而 RFC822 则不使用。
     *
     * @param dateString 日期字符串。
     * @return 具有转换后的时区的字符串。
     */
    static func convertXep82TimezoneToRfc822(dateString: String): String {
        if (dateString[dateString.size - 1] == b'Z') {
            dateString.replace("Z", "+00:00")
        } else {
            dateString
        }
    }

    /**
     * 将 RFC 822 时区转换为 XEP-82 中使用的时区格式。
     *
     * @param dateString 输入日期字符串。
     * @return 输入字符串，其时区转换为 XEP-82。
     */
    static func convertRfc822TimezoneToXep82(dateString: String): String {
        let length = dateString.size
        var res: String = dateString[0..(length - 2)]
        res += ':'.toString()
        res += dateString[(length - 2)..(length)]
        return res
    }

    /**
     * 以不同方式解析给定的日期字符串，并返回位于过去和/或最接近当前日期时间的日期。
     *
     * @param stampString 字符串表示的日期。
     * @param dateLength stampString 中日期前缀的长度。
     * @return 解析后的日期。
     * @throws ParseException 日期字符串格式未知。
     */
    private static func handleDateWithMissingLeadingZeros(stampString: String, dateLength: Int64): ?DateTime {
        if (dateLength == 6 || (b'2' <= stampString[4] && stampString[5] <= b'9') || (stampString[4] == b'1' &&
            stampString[5] >= b'3')) {
            let fixMonth = stampString[..4] + "0" + stampString[4..]
            return xep0091Date6DigitFormatter.parse(fixMonth)
        }
        let now = DateTime.now()
        let oneDigitMonth = parseXEP91Date(stampString, xep0091Date7Digit1MonthFormatter)
        let twoDigitMonth = parseXEP91Date(stampString, xep0091Date7Digit2MonthFormatter)
        let dates = filterDatesBefore(now, [oneDigitMonth, twoDigitMonth])
        if (!dates.isEmpty()) {
            return determineNearestDate(now, dates)
        }
        return None
    }

    private static func parseXEP91Date(stampString: String, dateFormat: DateFormatType): ?DateTime {
        try {
            return dateFormat.parse(stampString)
        } catch (_: TimeParseException | IllegalArgumentException) {
            return None
        }
    }

    private static func filterDatesBefore(now: DateTime, dates: Array<?DateTime>): ArrayList<DateTime> {
        let result = ArrayList<DateTime>()
        for (date in dates) {
            if (let Some(date) <- date) {
                if (date < now) {
                    result.append(date)
                }
            }
        }
        return result
    }

    /**
     * 一个有3个捕获组的图案，第二个捕获组在“点”后至少有1位数字。最后一个是时区定义，可以是“Z”、“+1234”或“-1234”。
     */
    private static let SECOND_FRACTION = Regex(#".*\.(\d+)"#)

    static func handleMilliseconds(dateString: String): String {
        let matcher = SECOND_FRACTION.matcher(dateString)
        if (matcher.allCount() == 0) {
            return dateString
        }
        let pos = matcher.find()().matchPosition(1)
        let millsize = pos.end - pos.start
        return if (millsize < 9) {
            let zeros = "0" * (9 - millsize)
            dateString[0..pos.end] + zeros + dateString[pos.end..]
        } else {
            let posend = pos.end - (millsize - 9)
            dateString[0..posend] + dateString[pos.end..]
        }
    }

    private static func determineNearestDate(now: DateTime, dates: ArrayList<DateTime>): DateTime {
        var closest = dates[0]
        var closestDur = now - dates[0]
        for (i in 1..dates.size) {
            let dt = dates[i]
            let dur = now - dt
            if (dur < closestDur) {
                closest = dt
                closestDur = dur
            }
        }
        return closest
    }
}

class DateFormatType {
    let FORMAT_STRING: String
    private let FORMATTER: DateTimeFormat
    private let CONVERT_TIMEZONE: Bool
    private let HANDLE_MILLIS: Bool
    private let needDate: Bool // 需要日期补全
    private let needZone: Bool // 需要时区补全

    init(dateFormat: String) {
        needDate = dateFormat[0] == b'h'
        var format = dateFormat
        if (needDate) {
            format = "yyyy-MM-ddT" + format
        }
        needZone = dateFormat[dateFormat.size - 1] != b'O'
        if (needZone) {
            format = format + "OOOO"
        }
        FORMATTER = DateTimeFormat.of(format)

        FORMAT_STRING = dateFormat
        CONVERT_TIMEZONE = dateFormat[dateFormat.size - 1] == b'Z'
        HANDLE_MILLIS = dateFormat.contains("SSS")
    }

    public func format(date: DateTime): String {
        var res: String = date.toString(FORMATTER)
        if (CONVERT_TIMEZONE) {
            res = XmppDateTime.convertRfc822TimezoneToXep82(res)
        }
        return res
    }

    public func parse(dateString: String): DateTime {
        var tempdateString = dateString
        if (CONVERT_TIMEZONE) {
            tempdateString = XmppDateTime.convertXep82TimezoneToRfc822(tempdateString)
        }
        if (HANDLE_MILLIS) {
            tempdateString = XmppDateTime.handleMilliseconds(tempdateString)
        }
        if (needDate) {
            tempdateString = "1970-01-01T" + tempdateString
        }
        if (needZone) {
            tempdateString = tempdateString + "+00:00"
        }
        return DateTime.parse(tempdateString, FORMATTER)
    }
}

class PatternCouplings {
    let pattern: Regex

    let formatter: DateFormatType

    init(datePattern: Regex, dateFormat: DateFormatType) {
        pattern = datePattern
        formatter = dateFormat
    }
}
