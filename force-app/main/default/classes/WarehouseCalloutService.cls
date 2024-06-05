global with sharing class WarehouseCalloutService implements  Queueable ,Database.AllowsCallouts{

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';
    
    global void execute (QueueableContext context) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');

        HttpResponse response = http.send(request);

    
        if(response.getStatusCode() == 200) {
            List<EquipmentMap> equipmentMap = EquipmentMap.parse(response.getBody());
            List<Product2> newEquipmentList = new List<Product2>();
            Map<String,Id> skuToIdMap = new Map<String,Id>();
        
            //I added it after refactoring (line 19-22)
            for(Product2 product : [SELECT Warehouse_SKU__c, Id FROM Product2 WITH USER_MODE]) {
                skuToIdMap.put(product.Warehouse_SKU__c, product.Id);
            }

            for(EquipmentMap eq : equipmentMap) {
                Product2 pr = new Product2();
                //I added it after refactoring (line 27-29)
                if(skuToIdMap.containsKey(eq.sku)) {
                    pr.Id = skuToIdMap.get(eq.sku);
                }
                pr.Name = eq.name;
                pr.Replacement_Part__c = true;
                pr.Cost__c = eq.cost;
                pr.Current_Inventory__c = eq.quantity;
                pr.Lifespan_Months__c = eq.lifespan;
                pr.Maintenance_Cycle__c = eq.maintenanceperiod;
                pr.Warehouse_SKU__c = eq.sku;
                newEquipmentList.add(pr);
            }
            upsert as user newEquipmentList;
        }
    }

}