public with sharing class MaintenanceRequestHelper {
    
    public static void updateWorkOrders(List<Case> newList) {
        List<Case> CreateMaintReqLst = new List<Case>();
        Set<Id> caseIdsSet = new Set<Id>();
        List<Equipment_Maintenance_Item__c> newEMI = new List<Equipment_Maintenance_Item__c>();
        for (Case caseRec : newList) {
            if (caseRec.Status == 'Closed' && (caseRec.Type.contains('Repair') || caseRec.Type.contains('Routine Maintenance'))) {
                caseIdsSet.add(caseRec.Id);    
            }
        }
        List<Case> CaseList = [
            SELECT Id, Type,Status, Vehicle__c, Subject, Date_Reported__c, Date_Due__c, ProductId, Product__c,
            (select Id, Maintenance_Cycle__c, Equipment__c, Quantity__c from Equipment_Maintenance_Items__r)
            FROM Case
            WHERE Id in:caseIdsSet
        ];        
        
        for (Case caseRec : CaseList) {
            Integer minMaintCycle = 0;
            List<Equipment_Maintenance_Item__c> EqpMaintList = caseRec.Equipment_Maintenance_Items__r;
            if (EqpMaintList.size() > 0) {
                for (Equipment_Maintenance_Item__c EquipMaint : EqpMaintList) {
                    newEMI.add(new Equipment_Maintenance_Item__c(
                        Equipment__c = EquipMaint.Equipment__c,
                        Maintenance_Request__c = caseRec.Id,
                        Quantity__c = EquipMaint.Quantity__c)
                    );

                    if (Integer.valueOf(EquipMaint.Maintenance_Cycle__c) < minMaintCycle || minMaintCycle == 0) {
                        minMaintCycle = Integer.valueOf(EquipMaint.Maintenance_Cycle__c);
                    }       
                }
            }
            Case newCase = new Case();
            newCase.Type = 'Routine Maintenance';
            newCase.Status = 'New';
            newCase.Vehicle__c = caseRec.Vehicle__c;
            newCase.Subject =  String.isBlank(caseRec.Subject) ? 'Routine Maintenance Request' : caseRec.Subject;
            newCase.Date_Reported__c = Date.today();
            newCase.Date_Due__c = Date.today().addDays((Integer)minMaintCycle);
            newCase.ProductId = caseRec.ProductId;
            newCase.Product__c = caseRec.Product__c;
            newCase.Cloned_Closed_Case_Id__c = caseRec.Id;
            CreateMaintReqLst.add(newCase);
        }
        
        if (CreateMaintReqLst.size() > 0){
            insert CreateMaintReqLst;    
        }
        
        for (Case c2: CreateMaintReqLst) {
            for (Equipment_Maintenance_Item__c emi2 : newEmi){
                if (c2.Cloned_Closed_Case_Id__c == emi2.Maintenance_Request__c) {
                    emi2.Maintenance_Request__c = c2.id;    
                }
            }
        }
        
        if (newEmi.size() > 0) {
            insert newEmi;    
        }     
    }        
}
 