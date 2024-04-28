public with sharing class MaintenanceRequestHelper {

    //My version
    public static void updateWorkOrders(List<Case> newCaseList,List<Case> oldCaseList) {
        List<Case> workCases = new List<Case> ();

        for (Integer i = 0; i< newCaseList.size(); i++) {
            if((newCaseList[i].Type == 'Repair'  ||  newCaseList[i].Type == 'Routine Maintenance')  && !oldCaseList[i].Status.equals('Closed') && newCaseList[i].Status.equals('Closed')) {
                workCases.add(newCaseList[i]);
            }
        }

        List<Equipment_Maintenance_Item__c> equipmentItemsList = [SELECT Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :newCaseList];
       
        List<Id> equipments = new List<Id>();
        for(Equipment_Maintenance_Item__c item : equipmentItemsList) {
            equipments.add(item.Equipment__c);
        }

        List<AggregateResult> listOfAggregateResult = [SELECT MIN(Maintenance_Cycle__c) minCycle FROM Product2 where Id in :equipments];
        
        Integer minCycleCount;

        if(listOfAggregateResult[0].get('minCycle') == null) {
            minCycleCount = 0;
        }

        else {
            minCycleCount = Integer.valueOf(listOfAggregateResult[0].get('minCycle'));
        }

        List<Case> filledCaseList = fillData(workCases, minCycleCount,equipmentItemsList);
}

public static List<Case> fillData (List<Case> cases,Integer minCycle,List<Equipment_Maintenance_Item__c> equipmentItemsList) {
    List<Case> caseList = new List<Case> ();
    List<Equipment_Maintenance_Item__c> updatedList = new List<Equipment_Maintenance_Item__c>();
    for(Case c : cases) {
        Case newCase = new Case();
        newCase.Type = c.Type;
        newCase.Status = 'New';
        newCase.Subject = c.Id.toString();
        newCase.Vehicle__c = c.Vehicle__c;
        newCase.Date_Reported__c = Date.today();
        newCase.Date_Due__c = Date.today().addDays(minCycle);
        caseList.add(newCase);
    }
    
    insert caseList;
     
    Map<Id,Id> oldNew = new Map<Id,Id>();

    for(Integer i=0;i <caseList.size();i++) {
        oldNew.put((Id) caseList[i].Subject, caseList[i].Id);
    }

    for(Equipment_Maintenance_Item__c item : [SELECT Equipment__c,Maintenance_Request__c FROM Equipment_Maintenance_Item__c WHERE Maintenance_Request__c IN :cases]) {

        Equipment_Maintenance_Item__c newItem = new Equipment_Maintenance_Item__c(Equipment__c = item.Equipment__c, Maintenance_Request__c = oldNew.get(item.Maintenance_Request__c));
        updatedList.add(newItem);
    }


    if(updatedList.size() > 0) {
        insert updatedList;
    }

    return caseList;
}


    //Your version, eith some refactoring
    public static void updateWorkOrdersOptimized(List<Case> newCaseList, List<Case> oldCaseList) {
        List<Case> workCases = new List<Case> ();

        for (Integer i = 0; i< newCaseList.size(); i++) {
            if((newCaseList[i].Type == 'Repair'  ||  newCaseList[i].Type == 'Routine Maintenance')  && !oldCaseList[i].Status.equals('Closed') && newCaseList[i].Status.equals('Closed')) {
                workCases.add(newCaseList[i]);
            }
        }
        List<Case> cases = [SELECT Id, 
                                       (SELECT Equipment__r.Maintenance_Cycle__c FROM Equipment_Maintenance_Items__r) 
                                FROM Case WHERE Id in :workCases];

        Map<Id, Decimal> newCaseWithCycle = new Map<Id, Decimal>();

            for(Case c : cases) {
                for(Equipment_Maintenance_Item__c emi : c.Equipment_Maintenance_Items__r) {
                    if(newCaseWithCycle.get(c.Id) == null) {
                        newCaseWithCycle.put(c.Id, emi.Equipment__r.Maintenance_Cycle__c);
                    } else if (newCaseWithCycle.get(c.Id) > emi.Equipment__r.Maintenance_Cycle__c) {
                        newCaseWithCycle.put(c.Id, emi.Equipment__r.Maintenance_Cycle__c);
                    }
                }
            }

             fillDataOptimized(workCases,newCaseWithCycle);
        }

    public static void fillDataOptimized (List<Case> cases,Map<Id, Decimal> newCaseWithCycle) {
        
                 Map<Id, Case> oldToNewCaseMap = new Map<Id, Case>();

                List<Case> caseList = new List<Case> ();
                List<Equipment_Maintenance_Item__c> updatedList = new List<Equipment_Maintenance_Item__c>();
                for(Case c : cases) {
                    Case newCase = new Case();
                    newCase.Type = c.Type;
                    newCase.Status = 'New';
                    newCase.ParentId = c.Id;
                    newCase.Vehicle__c = c.Vehicle__c;
                    oldToNewCaseMap.put(c.Id, newCase);
                }

                insert oldToNewCaseMap.values();

                List<Equipment_Maintenance_Item__c> items = new List<Equipment_Maintenance_Item__c>();
                for(Case c : cases) {
                    for(Equipment_Maintenance_Item__c emi: c.Equipment_Maintenance_Items__r) {
                        Equipment_Maintenance_Item__c newItem = emi.clone(false, true, false, false);
                        newItem.Maintenance_Request__c = oldToNewCaseMap.get(c.Id).Id;
                        items.add(emi);
                    }
                }
                insert items;
    }
}
