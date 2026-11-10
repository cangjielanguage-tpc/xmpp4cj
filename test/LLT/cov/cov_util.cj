// DEPENDENCE: ../z_test.cj
// DEPENDENCE: ../smack_test_util.cj
// EXEC: cjc %import-path %L %l %f z_test.cj smack_test_util.cj --test
// EXEC: ./main

@Test
public func test_SHA1Util1(): Unit {
    let sha1Util: SHA1Util = SHA1Util()
    let arr: Array<UInt8> = SHA1Util.bytes("0123456789")
    let arr1: Array<UInt8> = [135, 172, 236, 23, 205, 157, 205, 32, 167, 22, 204, 44, 246, 116, 23, 183, 28, 138, 112,
        22]
    @Assert(arr1, arr)
}

@Test
public func test_RandomUtil1(): Unit {
    let randomUtil1: RandomUtil = RandomUtil()
}

@Test
public func test_MAC1(): Unit {
    let mac: MAC = MAC()
}

@Test
public func test_HashCode1(): Unit {
    let hashCode: HashCode = HashCode()
}

@Test
public func test_StringUtils1(): Unit {
    let stringUtils: StringUtils = StringUtils()
    let s1: String = StringUtils.escapeForXmlAttribute("")
    @Assert("", s1)
    let s2: String = StringUtils.escapeForXmlAttribute("0123456789")
    @Assert("0123456789", s2)
    let s3: String = StringUtils.secureOnlineAttackSafeRandomString()
    @Assert(true, s3.size > 0)
    let s4: String = StringUtils.secureUniqueRandomString()
    @Assert(true, s4.size > 0)
    let s5: String = StringUtils.secureOfflineAttackSafeRandomString()
    @Assert(true, s5.size > 0)
    let css1: Array<CharSequence> = ["1", "2"]
    let b1: Bool = StringUtils.isNotEmpty(css1)
    @Assert(true, b1)
    let css2: Array<CharSequence> = []
    let b2: Bool = StringUtils.isNotEmpty(css2)
    @Assert(true, b2)
    let b3: Bool = StringUtils.isNullOrEmpty(css1)
    @Assert(false, b3)
    let b4: Bool = StringUtils.isNullOrEmpty(css2)
    @Assert(true, b4)
    let s6: String = StringUtils.returnIfNotEmptyTrimmed(" 0123456789 ").getOrThrow()
    @Assert("0123456789", s6)
    let e0: IllegalArgumentException = @AssertThrows[IllegalArgumentException](StringUtils.requireNotNullNorEmpty(None, " 0123456789 "))
    @Assert("IllegalArgumentException:  0123456789 ", e0.toString())
    let arr1: ArrayList<String> = StringUtils.splitLinesPortable("0123456789")
    @Assert(true, arr1.size == 1)
    let arr2: ArrayList<String> = StringUtils.toStrings(["0123456789"])
    @Assert(true, arr2.size == 1)
}

@Test
public func test_byteList2String1(): Unit {
    let arr1: ArrayList<Byte> = ArrayList<Byte>([100, 40, 60])
    let s1: String = byteList2String(arr1)
    @Assert("d(<", s1)
}
