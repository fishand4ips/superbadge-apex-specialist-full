@IsTest
private class WarehouseCalloutServiceTest {
    @isTest
    static void makeGetCalloutTest() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();
        System.assertEquals(3, [SELECT count() FROM Product2]);
    }
}