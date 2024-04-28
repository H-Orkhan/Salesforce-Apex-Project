@isTest
public with sharing class MaintenanceRequestHelperTest {


        @isTest
        public static void testWhenIsUpdatedPositive() {

            Vehicle__c vehicle = new Vehicle__c();
            insert vehicle;

            Case testCase = new Case (Type = 'Repair', Status = 'New', Vehicle__c = vehicle.Id);
            insert testCase;

            Product2 equipment = new Product2(Name = 'Equipment for test' ,Maintenance_Cycle__c = 15, Replacement_Part__c = true);
            insert equipment;

            Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c (Equipment__c = equipment.Id, Maintenance_Request__c = testCase.Id);
            insert item;

            Test.startTest();
            testCase.Status = 'Closed';
            Database.SaveResult result = Database.update(testCase, false);
            Test.stopTest();

            List<Case> cases = [Select Id,Type,Subject,Vehicle__c,Date_Reported__c from Case Where Status = 'New'];
            System.assertEquals(cases.size(), 1);
            System.assertEquals(cases[0].Type, 'Repair');
            System.assertEquals(cases[0].Vehicle__c, vehicle.Id);
            System.assertEquals(cases[0].Date_Reported__c, Date.today());

        }

        @isTest
        public static void testWhenIsUpdatedPositiveAndCycleIsNull() {

            Vehicle__c vehicle = new Vehicle__c();
            insert vehicle;

            Case testCase = new Case (Type = 'Repair', Status = 'New', Vehicle__c = vehicle.Id);
            insert testCase;

            Product2 equipment = new Product2(Name = 'Equipment for test' ,Maintenance_Cycle__c = null, Replacement_Part__c = true);
            insert equipment;

            Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c (Equipment__c = equipment.Id, Maintenance_Request__c = testCase.Id);
            insert item;

            Test.startTest();
            testCase.Status = 'Closed';
            Database.SaveResult result = Database.update(testCase, false);
            Test.stopTest();

            List<Case> cases = [Select Id,Type,Subject,Vehicle__c,Date_Reported__c from Case Where Status = 'New'];
            System.assertEquals(cases.size(), 1);
            System.assertEquals(cases[0].Type, 'Repair');
            System.assertEquals(cases[0].Vehicle__c, vehicle.Id);
            System.assertEquals(cases[0].Date_Reported__c, Date.today());

        }

        @isTest
        public static void testWhenIsUpdatedPositiveAndBulk() {
            Integer count = 300;
            List<Vehicle__c> vehicleList = new List<Vehicle__c>();

            for(Integer i = 0;i<count;i++) {
            vehicleList.add(new Vehicle__c (Name = 'Test Name ' + i));
            }
            insert vehicleList;
            
            List<Case> oldCasesList = new List<Case>();
            for(Integer i = 0;i<count;i++) {
                oldCasesList.add(new Case (Type = 'Repair', Status = 'New', Vehicle__c = vehicleList[i].Id, Description = 'Test Case ' + i));
            }
            insert oldCasesList;
            
            List<Product2> productList = new List<Product2>();
            for(Integer i = 0;i<count;i++) {
                productList.add(new Product2(Name = 'Equipment for test ' +i ,Maintenance_Cycle__c = 15, Replacement_Part__c = true));
            }
            insert productList;
            
            List<Equipment_Maintenance_Item__c> itemList = new List<Equipment_Maintenance_Item__c>();
            for(Integer i = 0;i<count;i++) {
                itemList.add(new Equipment_Maintenance_Item__c (Equipment__c = productList[i].Id, Maintenance_Request__c = oldCasesList[i].Id));
            }
            insert itemList;
            
            Test.startTest();
            
            List<Case> newCases = new List<Case>();
            for(Integer i = 0;i<oldCasesList.size();i++) {
                oldCasesList[i].Status = 'Closed';
                newCases.add(oldCasesList[i]);
            }
            
            List<Database.SaveResult> result = Database.update(newCases, false);
            Test.stopTest();
            
            List<Case> cases = [Select Id,Type,Subject from Case Where Status = 'New'];
            System.assertEquals(cases.size(), count);

        }
        @isTest
        public static void testWhenIsUpdatedFalse() {

            Vehicle__c vehicle = new Vehicle__c();
            insert vehicle;

            Case testCase = new Case (Type = 'Test Type', Status = 'Closed', Vehicle__c = vehicle.Id);
            insert testCase;

            Product2 equipment = new Product2(Name = 'Equipment for test' ,Maintenance_Cycle__c = 15, Replacement_Part__c = true);
            insert equipment;

            Equipment_Maintenance_Item__c item = new Equipment_Maintenance_Item__c (Equipment__c = equipment.Id, Maintenance_Request__c = testCase.Id);
            insert item;

            Test.startTest();
            testCase.Status = 'Closed';
            Database.SaveResult result = Database.update(testCase, false);
            Test.stopTest();

            List<Case> cases = [Select Id,Type,Subject from Case Where Status = 'New'];
            System.assertEquals(cases.size(), 0);

        }
}