@IsTest
private class WarehouseCalloutServiceTest {

    @IsTest
    public static void testMockData() {

        List<Product2> oldProducts = new List<Product2>();
        for(Integer i = 0;i<5;i++) {
            Product2 pr = new Product2();
            pr.Current_Inventory__c = i;
            pr.Name = 'Test Name = ' + i;
            pr.Maintenance_Cycle__c = i*156;
            pr.Lifespan_Months__c = (i+10)*78;
            pr.Cost__c = (i+500)*3;
            //I added sku id from 100015 from 100019 in old list for check both of cases with exists sku id (when external url will be in old list range) and when external sku will not be in old list range
            pr.Warehouse_SKU__c = String.valueOf(100015+ i);
            oldProducts.add(pr);
        }

        insert oldProducts;
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