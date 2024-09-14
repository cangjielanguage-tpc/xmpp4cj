// DEPENDENCE: z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main
@Test
public class XmppDateTimeTest {
    @TestCase
    public func parseXep0082Date(): Unit {
        let date = XmppDateTime.parseDate("1971-07-21")
        let cal = date.inUTC()
        Assert.assertEquals(1971, cal.year)
        Assert.assertEquals(6 + 1, cal.monthValue)
        Assert.assertEquals(21, cal.dayOfMonth)
    }

    @TestCase
    public func parseXep0082Time(): Unit {
        let date = XmppDateTime.parseDate("02:56:15")
        let cal = date.inUTC()
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
    }

    @TestCase
    public func parseXep0082TimeUTC(): Unit {
        let date = XmppDateTime.parseDate("02:56:15Z")
        let cal = date.inUTC()
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
    }

    @TestCase
    public func parseXep0082TimeWithZone(): Unit {
        let date = XmppDateTime.parseDate("04:40:15+02:30")
        let cal = date.inTimeZone(TimeZone.UTC)
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(10, cal.minute)
        Assert.assertEquals(15, cal.second)
    }

    @TestCase
    public func parseXep0082TimeWithMillis(): Unit {
        let date = XmppDateTime.parseDate("02:56:15.123")
        let cal = date.inUTC()
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func parseXep0082TimeWithMillisUTC(): Unit {
        let date = XmppDateTime.parseDate("02:56:15.123Z")
        let cal = date.inUTC()
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func parseXep0082TimeWithMillisZone(): Unit {
        let date = XmppDateTime.parseDate("02:56:15.123+01:00")
        let cal = date.inTimeZone(TimeZone.UTC)
        Assert.assertEquals(1, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func parseXep0082DateTimeUTC(): Unit {
        let date = XmppDateTime.parseDate("1971-07-21T02:56:15Z")
        let cal = date.inUTC()
        Assert.assertEquals(1971, cal.year)
        Assert.assertEquals(6, cal.monthValue - 1)
        Assert.assertEquals(21, cal.dayOfMonth)
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
    }

    @TestCase
    public func parseXep0082DateTimeZone(): Unit {
        let date = XmppDateTime.parseDate("1971-07-21T02:56:15-01:00")
        let cal = date.inUTC()
        Assert.assertEquals(1971, cal.year)
        Assert.assertEquals(6, cal.monthValue - 1)
        Assert.assertEquals(21, cal.dayOfMonth)
        Assert.assertEquals(3, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
    }

    @TestCase
    public func parseXep0082DateTimeWithMillisUTC(): Unit {
        let date = XmppDateTime.parseDate("1971-07-21T02:56:15.123Z")
        let cal = date.inUTC()
        Assert.assertEquals(1971, cal.year)
        Assert.assertEquals(6, cal.monthValue - 1)
        Assert.assertEquals(21, cal.dayOfMonth)
        Assert.assertEquals(2, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func parseXep0082DateTimeWithMillisZone(): Unit {
        let date = XmppDateTime.parseDate("1971-07-21T02:56:15.123-01:00")
        let cal = date.inUTC()
        Assert.assertEquals(1971, cal.year)
        Assert.assertEquals(6, cal.monthValue - 1)
        Assert.assertEquals(21, cal.dayOfMonth)
        Assert.assertEquals(3, cal.hour)
        Assert.assertEquals(56, cal.minute)
        Assert.assertEquals(15, cal.second)
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func parseXep0082MissingTzd(): Unit {
        // @AssertThrows[TimeParseException](XmppDateTime.parseXEP0082Date("2017-07-11T18:31:34"))
        @AssertThrows[TimeParseException](XmppDateTime.parseDate("2017-07-11T18:31:34"))
    }

    @TestCase
    public func parseXep0091(): Unit {
        let date = XmppDateTime.parseDate("20020910T23:08:25")
        println(date)
        let cal = date.inUTC()
        Assert.assertEquals(2002, cal.year)
        Assert.assertEquals(8, cal.monthValue - 1)
        Assert.assertEquals(10, cal.dayOfMonth)
        Assert.assertEquals(23, cal.hour)
        Assert.assertEquals(8, cal.minute)
        Assert.assertEquals(25, cal.second)
    }

    @TestCase
    public func parseXep0091NoLeading0(): Unit {
        let date = XmppDateTime.parseDate("200291T23:08:25")
        let cal = date.inUTC()
        Assert.assertEquals(2002, cal.year)
        Assert.assertEquals(8, cal.monthValue - 1)
        Assert.assertEquals(1, cal.dayOfMonth)
        Assert.assertEquals(23, cal.hour)
        Assert.assertEquals(8, cal.minute)
        Assert.assertEquals(25, cal.second)
    }

    @TestCase
    public func parseXep0091AmbiguousMonthDay(): Unit {
        let date = XmppDateTime.parseDate("2002101T23:08:25")
        let cal = date.inUTC()
        Assert.assertEquals(2002, cal.year)
        Assert.assertEquals(9, cal.monthValue - 1)
        Assert.assertEquals(1, cal.dayOfMonth)
        Assert.assertEquals(23, cal.hour)
        Assert.assertEquals(8, cal.minute)
        Assert.assertEquals(25, cal.second)
    }

    @TestCase
    public func parseXep0091SingleDigitMonth(): Unit {
        let date = XmppDateTime.parseDate("2002130T23:08:25")
        let cal = date.inUTC()
        Assert.assertEquals(2002, cal.year)
        Assert.assertEquals(0, cal.monthValue - 1)
        Assert.assertEquals(30, cal.dayOfMonth)
        Assert.assertEquals(23, cal.hour)
        Assert.assertEquals(8, cal.minute)
        Assert.assertEquals(25, cal.second)
    }

    @TestCase
    public func parseNoMonthDay(): Unit {
        @AssertThrows[TimeParseException](XmppDateTime.parseDate("2002T23:08:25"))
    }

    @TestCase
    public func parseNoYear(): Unit {
        @AssertThrows[TimeParseException](XmppDateTime.parseDate("130T23:08:25"))
    }

    @TestCase
    public func testParseMicroseconds(): Unit {
        let date = XmppDateTime.parseDate("2014-09-16T15:14:13.123456Z")
        let cal = date.inUTC()
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func testParseAnySecondFraction(): Unit {
        let date = XmppDateTime.parseDate("2014-09-16T15:14:13.12345678904736Z")
        let cal = date.inUTC()
        Assert.assertEquals(123, cal.nanosecond / 1000000)
    }

    @TestCase
    public func testParseOneSecondFraction(): Unit {
        let date = XmppDateTime.parseDate("2014-09-16T15:14:13.1Z")
        let cal = date.inUTC()
        Assert.assertEquals(100, cal.nanosecond / 1000000)
    }

    @TestCase
    public func testParseTwoSecondFraction(): Unit {
        let date = XmppDateTime.parseDate("2014-09-16T15:14:13.12Z")
        let cal = date.inUTC()
        Assert.assertEquals(120, cal.nanosecond / 1000000)
    }

    @TestCase
    public func testLeapSeconds(): Unit {
        let date = XmppDateTime.parseDate("2015-07-31T23:59:60Z")
        let cal = date.inUTC()
        println(cal)
        Assert.assertEquals(0, cal.second)
    }

    @TestCase
    public func testLeapSeconds3(): Unit {
        let date = XmppDateTime.parseDate("2015-05-31T23:59:63Z")
        let cal = date.inUTC()
        Assert.assertEquals(3, cal.second)
    }

    @TestCase
    public func testArabicLocale(): Unit {
        // Locale.setDefault(Locale("AR"))
        let initialDateString = "2018-09-22T20:09:42.000+00:00"
        let date = XmppDateTime.parseDate(initialDateString)
        let dateString = XmppDateTime.formatXEP0082Date(date)
        Assert.assertEquals(initialDateString, dateString)
    }
}
