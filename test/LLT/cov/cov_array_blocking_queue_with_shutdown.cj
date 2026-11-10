// DEPENDENCE: ../z_test.cj
// EXEC: cjc %import-path %L %l %f z_test.cj --test
// EXEC: ./main

@Test
public func test_ArrayBlockingQueueWithShutdown1(): Unit {
    let arrayBlockingQueueWithShutdownTryTakeResultCode1 = ArrayBlockingQueueWithShutdownTryTakeResultCode.couldNotLock
    let arrayBlockingQueueWithShutdownTryTakeResultCode2 = ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasShutDown
    let arrayBlockingQueueWithShutdownTryTakeResultCode3 = ArrayBlockingQueueWithShutdownTryTakeResultCode.queueWasEmpty
    let arrayBlockingQueueWithShutdownTryTakeResultCode4 = ArrayBlockingQueueWithShutdownTryTakeResultCode.takeSuccessful
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode1 == arrayBlockingQueueWithShutdownTryTakeResultCode1)
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode2 == arrayBlockingQueueWithShutdownTryTakeResultCode2)
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode3 == arrayBlockingQueueWithShutdownTryTakeResultCode3)
    @Assert(true, arrayBlockingQueueWithShutdownTryTakeResultCode4 == arrayBlockingQueueWithShutdownTryTakeResultCode4)
    @Assert("couldNotLock", arrayBlockingQueueWithShutdownTryTakeResultCode1.toString())
    @Assert("queueWasShutDown", arrayBlockingQueueWithShutdownTryTakeResultCode2.toString())
    @Assert("queueWasEmpty", arrayBlockingQueueWithShutdownTryTakeResultCode3.toString())
    @Assert("takeSuccessful", arrayBlockingQueueWithShutdownTryTakeResultCode4.toString())
    @Assert(false, arrayBlockingQueueWithShutdownTryTakeResultCode2 == arrayBlockingQueueWithShutdownTryTakeResultCode3)
}

@Test
public func test_ArrayBlockingQueueWithShutdown2(): Unit {
    let arrayBlockingQueueWithShutdownTryPutResult1 = ArrayBlockingQueueWithShutdownTryPutResult.couldNotLock
    let arrayBlockingQueueWithShutdownTryPutResult2 = ArrayBlockingQueueWithShutdownTryPutResult.queueWasShutDown
    let arrayBlockingQueueWithShutdownTryPutResult3 = ArrayBlockingQueueWithShutdownTryPutResult.queueWasFull
    let arrayBlockingQueueWithShutdownTryPutResult4 = ArrayBlockingQueueWithShutdownTryPutResult.putSuccessful
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult1 == arrayBlockingQueueWithShutdownTryPutResult1)
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult2 == arrayBlockingQueueWithShutdownTryPutResult2)
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult3 == arrayBlockingQueueWithShutdownTryPutResult3)
    @Assert(true, arrayBlockingQueueWithShutdownTryPutResult4 == arrayBlockingQueueWithShutdownTryPutResult4)
    @Assert("couldNotLock", arrayBlockingQueueWithShutdownTryPutResult1.toString())
    @Assert("queueWasShutDown", arrayBlockingQueueWithShutdownTryPutResult2.toString())
    @Assert("queueWasFull", arrayBlockingQueueWithShutdownTryPutResult3.toString())
    @Assert("putSuccessful", arrayBlockingQueueWithShutdownTryPutResult4.toString())
    @Assert(false, arrayBlockingQueueWithShutdownTryPutResult4 == arrayBlockingQueueWithShutdownTryPutResult3)
}
