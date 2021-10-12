global with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {
    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    global void execute(QueueableContext context) {
        makeGetCallout();
    }
    
    public static void makeGetCallout() {
        HttpResponse response = getResponse();
        if (response.getStatusCode() == 200) {
            List<Object> jsonResponse = (List<Object>) JSON.deserializeUntyped(response.getBody());
            List<Product2> products = new List<Product2>();
            for (Object item : jsonResponse) {
                Map<String, Object> jsonMap = (Map<String,Object>) item;
                Product2 product = new Product2();
                product.Name = (String) jsonMap.get('name');
                product.Replacement_Part__c = (Boolean) jsonMap.get('replacement');
                product.Cost__c = (Decimal) jsonMap.get('cost');
                product.Current_Inventory__c = (Double) jsonMap.get('quantity');
                product.Lifespan_Months__c = (Integer) jsonMap.get('lifespan');
                product.Maintenance_Cycle__c = (Integer) jsonMap.get('maintenanceperiod');
                product.Warehouse_SKU__c = (String) jsonMap.get('sku');
                products.add(product);
            }
            if (products.size() > 0) {
                System.debug('>>>>>>products>>>>>> ' + products);
                upsert products;
            }
        }
    }

    private static HttpResponse getResponse() {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(WAREHOUSE_URL);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        return response;
    }
}