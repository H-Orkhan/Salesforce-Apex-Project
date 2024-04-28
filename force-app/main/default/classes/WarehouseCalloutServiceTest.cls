@IsTest
private class WarehouseCalloutServiceTest {

    @IsTest
    public static void testMockData() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        WarehouseCalloutService service = new WarehouseCalloutService();
        Test.startTest();
        System.enqueueJob(service);
        Test.stopTest();
        List<String> skuList = new List<String>();
        for(Integer i=100001;i<100023;i++) {
            skuList.add(String.valueOf(i));

        }
        List<Product2> updatedList = [SELECT Id FROM Product2 Where Warehouse_SKU__c in :skuList];
        System.assertEquals(22, updatedList.size());
    
    }
}