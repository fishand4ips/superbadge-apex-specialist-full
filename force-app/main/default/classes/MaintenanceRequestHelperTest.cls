@isTest
private class MaintenanceRequestHelperTest {

    @TestSetup
    static void setup() {

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Contact contact = new Contact();
        contact.FirstName = 'test';
        contact.LastName = 'last';
        contact.Email = 'test@test.com';
        contact.AccountId = acc.Id;
        insert contact;
        
        Vehicle__c vehicle = new Vehicle__c(
            Name='test vehicle',
            Air_Conditioner__c=true,
            Model__c='Test'
        );
        insert vehicle;

        Product2 prod = new Product2();
        prod.Cost__c = 50;
        prod.Name = 'Ball Valve 10 cm';
        prod.Lifespan_Months__c = 12;
        prod.Maintenance_Cycle__c = 365;
        prod.Current_Inventory__c = 50;
        prod.Replacement_Part__c = true;
        prod.Warehouse_SKU__c = '100009';
        insert prod;

        Case cs = new Case(
            Status = 'New',
            Type = 'Routine Maintenance',
            Subject = 'New Main Request For Vehicle for Apex Specialist',
            Date_Reported__c = date.today(),
            SuppliedName = 'Test'
        );
        insert cs; 
        
        Equipment_Maintenance_Item__c equipMainList = new Equipment_Maintenance_Item__c(
            Equipment__c = prod.Id,
            Maintenance_Request__c = cs.Id,
            Maintenance_Cycle__c = prod.Maintenance_Cycle__c
        );
        insert equipMainList;

        Map<Equipment_Maintenance_Item__c,Id> EquipMainItemsToProdIds = new Map<Equipment_Maintenance_Item__c,Id>{};

        List<Case> caseList = new List<Case>();
        for(Integer i = 1; i <= 1000; i++) {
            Case maintenanceNew = new Case();
            maintenanceNew.Subject = 'Other';
            maintenanceNew.Product__c = prod.Id;
            maintenanceNew.ContactId = contact.Id;
            maintenanceNew.AccountId = acc.Id;
            maintenanceNew.Vehicle__c = vehicle.Id;
            maintenanceNew.Type = 'Other';
            maintenanceNew.Status = 'New';
            maintenanceNew.ProductId = prod.Id;
            maintenanceNew.Date_Reported__c = Date.today();
            maintenanceNew.Date_Due__c = Date.today();

            if (EquipMainItemsToProdIds.size() > 1) {
                maintenanceNew.Date_Due__c = Date.today().addDays(Integer.valueOf(prod.Maintenance_Cycle__c));
            } else {
                maintenanceNew.Date_Due__c = Date.today();
            }
            
            caseList.add(maintenanceNew);   
        }
        insert caseList;
    }

    @isTest
    static void updateWorkOrdersTest() {
        Vehicle__c v = [SELECT Id, Name FROM Vehicle__c LIMIT 1]; 
        Equipment_Maintenance_Item__c e = [SELECT Id, Equipment__c, Maintenance_Cycle__c FROM Equipment_Maintenance_Item__c LIMIT 1];
        List<Case> caseList = new List<Case>();
        Test.startTest();
        for (Case caseHere : [select Id from Case where SuppliedName = 'Test']) {
            caseHere.Vehicle__c = v.Id;
            caseHere.ProductId = e.Equipment__c;
            caseHere.Type = 'Repair';
            caseHere.Status = 'Closed';
            caseHere.Date_Due__c = Date.today();
            caseList.add(caseHere);
        }
        MaintenanceRequestHelper.updateWorkOrders(caseList);
        System.assertEquals(1, caseList.size());
        List<Case> newCaseList = [
            Select Id, subject, status, Date_Reported__c, Vehicle__c, Date_Due__c
            from Case
            where subject = 'Other'
        ];

        System.assertNotEquals(caseList.size(), newCaseList.size());
        for (Case cs : newCaseList) {
            System.assertEquals(cs.Date_Reported__c, Date.today());
            System.assertEquals(true, cs.Date_Due__c >= Date.today());
        }
        update caseList;
        Test.stopTest();

    }
}
