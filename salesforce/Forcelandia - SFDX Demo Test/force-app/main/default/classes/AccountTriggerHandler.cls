public class AccountTriggerHandler{

    /**
    Method Name: updateRelatedCase
    Functionality : When Account Flash field is updated by an user, this code runs and update Flash field on all related
                    Cases with Parent Account Flash field Value.    
    **/
       public static void updateRelatedCase(List<Account> lstAccount, Map<id,Account> mapoldAcc){
       List<case> updatecseList = new List<case>();
       List<Account> acclist=[select id,Flash__c,(select id,status, Flash__c from Cases) from Account where id in:mapoldAcc.keyset()];
       for(Account acc: acclist){
           if(acc.Flash__c <> mapoldAcc.get(acc.id).Flash__c){
               for(case cs: acc.Cases){
                   cs.Flash__c= acc.Flash__c;                   
                   
                   if(acc.Flash__c<>null){
                   cs.ShowFlashImage__c= TRUE;
                   }else{
                   cs.ShowFlashImage__c=False;
                   }
                   updatecseList.add(cs);
               }
           }
       }
       Database.update(updatecseList);
    }
    /**
    Method Name: associateEntitlementToAccount
    Functionality : This method  is used to assocaiate Entitlement On Account Creation    
    **/
     public static void associateEntitlementToAccount(List<Account> lstAccount){
       Map<String, SLAProcess> mapEntitlementProcess = new Map<String, SLAProcess> ();
        List<Entitlement> LstEntitlementRcdsToCreate = new List<Entitlement> ();
        List<TriggerWorkflow__mdt> ObjMetaDataRecord = new List<TriggerWorkflow__mdt>();
        ObjMetaDataRecord = [SELECT IsActive__c,DeveloperName FROM TriggerWorkflow__mdt where DeveloperName = 'AssociateEntitlementToAccount' and IsActive__c = true];
        if(ObjMetaDataRecord.size() > 0 ){
        for (SLAProcess objProcess: [SELECT Id, IsActive, VersionNumber, Name, BusinessHoursId FROM SlaProcess where isActive = true]) {
            if (!mapEntitlementProcess.containsKey(objProcess.Name)) {
                mapEntitlementProcess.put(objProcess.Name, objProcess);
            } else {
                if (objProcess.VersionNumber > mapEntitlementProcess.get(objProcess.Name).VersionNumber) {
                    mapEntitlementProcess.put(objProcess.Name, objProcess);
                }
            }

        }
        for (Account objAccount: lstAccount) {
         if (mapEntitlementProcess.size() > 0) {
                for (SLAProcess objProcess: mapEntitlementProcess.Values()) {
                    Entitlement objEntitlement = new Entitlement();
                    objEntitlement.Name = objAccount.Name + ' ' + objProcess.Name;
                    objEntitlement.AccountId = objAccount.id;
                    objEntitlement.StartDate = Date.newInstance(2019, 10, 6);
                    objEntitlement.EndDate = Date.newInstance(3000, 1, 1);
                    objEntitlement.BusinessHoursId = objProcess.BusinessHoursId;
                    objEntitlement.SlaProcessId = objProcess.id;
                    LstEntitlementRcdsToCreate.add(objEntitlement);
                }
            }
        }
        if (LstEntitlementRcdsToCreate.size() > 0) {
            Database.Insert(LstEntitlementRcdsToCreate);
        }
        }
}
}