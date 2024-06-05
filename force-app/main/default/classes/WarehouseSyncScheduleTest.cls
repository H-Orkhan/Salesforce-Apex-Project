@isTest
public with sharing class WarehouseSyncScheduleTest {

    @isTest
    static void testMockData() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock()); 
        List<String> skuList = new List<String>();

        for(Integer i=100001;i<100023;i++) {
            skuList.add(String.valueOf(i));
        }

        List<Product2> updatedList = [SELECT Id FROM Product2 Where Warehouse_SKU__c in :skuList WITH USER_MODE];
        System.assertEquals(0, updatedList.size());

        Test.startTest();
        String cronjob = '0 0 1 1/1 * ? *';
        String jobId = System.schedule('WarehouseForSyncTest', cronJob, new WarehouseSyncSchedule());
        Test.stopTest();

        System.assert(jobId !=null);


    }


}