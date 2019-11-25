/*
Log 1 : Modified by : Nidhi Gupta/Ankita Mehta
        Ticket Number : APPS-2869
*/
global class AccountTeamMemberDailyBatchHandler {

    public static Map<String,Map<String,String>> accMemberMap = new Map<String,Map<String,String>>();
    public static Map<Id,sobject> accObjMap                   = new Map<Id,sobject>();     
    public static List<sobject> updateAccList                 = new List<sobject>();
    
    
    global AccountTeamMemberDailyBatchHandler () {}
     
    public static void batchExecute(List<sObject> scope,Map<String,String> mappingMap,Set<String> teamFieldsSet) {
        createAccountTeamMemberMaps(scope,mappingMap);
        if(!accMemberMap.isempty()) {
            createAccountMap(accMemberMap);
        }
          
        for(String accId : accObjMap.keyset()) {
            sObject accObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
            Boolean isChange = createUpdateAccountList(accObj,accId,accObjMap,mappingMap,teamFieldsSet);
            if(isChange == true) {
                updateAccList.add(accObj);
            }
        }
        System.debug('updateAccList...Final Account Update Size....'+updateAccList.size());
        if(!updateAccList.isempty()) {
            //update updateAccList;
            Database.SaveResult[] srList = Database.update(updateAccList, false);
        }
    }
    
    public static void createAccountMap(Map<String,Map<String,String>> accMemberMap) {
        /*Log 1 Starts*/
        List<String> fields = AccountTeamMemberBatch.getAllFields();
        Set<String> accountIdSet = new Set<String>();
        accountIdSet.addAll(accMemberMap.keyset());
        String soqlQuery = 'select Id,' + String.join(fields, ',') + ' from Account where Id IN : accountIdSet';
        System.debug('soqlQuery......'+soqlQuery);
        List<Account> accList = database.query(soqlQuery);
        System.debug('accList......'+accList);
        for(sObject acc : accList) {
            accObjMap.put(acc.Id,acc);
        }
        /*for(sobject acc : [Select Id,AccountExecutiveAE__c,BusinessDevelopmentRepBDR__c,ChannelAccountManagerCAM__c,
                CustomerSuccessEngineerCSE__c,CustomerSuccessManagerCSM__c,ExecutiveSponsor__c ,IDRAE__c,
                OnboardingSpecialist__c,SalesDevelopmentRepSDR__c,ServicesLeadGen__c,SolutionsEngineerSE__c,TEMAE__c,AutomationAE__c 
                from Account where Id IN : accMemberMap.keyset()]) {
            accObjMap.put(acc.Id,acc);
        }*/
        /*Log 1 Ends*/
    }
    
    public static void createAccountTeamMemberMaps(List<sobject> memberList,Map<String,String> mappingMap) {
        for(sobject accTeamMemObj : memberList) {
            String roleFieldApi = '';
            if(mappingMap.containskey(String.Valueof(accTeamMemObj.get('TeamMemberRole')))) {
                roleFieldApi = (String) mappingMap.get(String.valueof(accTeamMemObj.get('TeamMemberRole')));
            }
            String accId = (String) accTeamMemObj.get('AccountId');
            if(accMemberMap.containskey(accId)) {
                accMemberMap.get(accId).put(roleFieldApi,String.valueof(accTeamMemObj.get('UserId')));
            }
            else {
                Map<String,String> accRoleUserMap = new Map<String,String>();
                accRoleUserMap.put(roleFieldApi,String.valueof(accTeamMemObj.get('UserId')));
                if(!accRoleUserMap.isempty()) {
                    /*accMemberMap stores AccountId and its related AccountTeamMember's 
                            with role field api*/
                    accMemberMap.put(accId,accRoleUserMap);  
                }
            }                   
        }
    }
    
    /*Create a Map to update Account if there is any change in AccountTeamMember records */
    public static boolean createUpdateAccountList(sObject accObj,String accId,Map<Id,sobject> accObjMap,
                Map<String,String> mappingMap,Set<String> teamFieldsSet) {
        Boolean isChange = false;
        for(String s : teamFieldsSet) {
            if((accMemberMap.get(accId)).containskey(s) && (accMemberMap.get(accId)).get(s) == (String) accObjMap.get(accId).get(s)) {
                //System.debug('No update required. Same AccountTeamMember role users present in Account');
            }
            if((accMemberMap.get(accId)).containskey(s) && (accMemberMap.get(accId)).get(s) != (String) accObjMap.get(accId).get(s)) {
                //System.debug('update to new values.....As there are new AccountTeamMember records under Account......');
                accObj.put(s,accMemberMap.get(accId).get(s));
                accObj.put('Id',accId);
                isChange = true;
            }
        }
        return isChange;
    }
    
    /*Create a map of Role Name and Account User Role field API*/
    public static Map<String,String> createMapping() {
        Map<String,String> mappingMap =  new Map<String,String>();
        List<AccountTeamMemberSetting__c> teamSettingList = AccountTeamMemberSetting__c.getall().values();
        for(AccountTeamMemberSetting__c teamSetting : teamSettingList) {
            mappingMap.put(teamSetting.Name,teamSetting.AccountField__c);
        }
        return mappingMap;
    }
    
    /*Create a set of Account User Role Field API's*/
    public static Set<String> createFieldSet(Map<String,String> mappingMap) {
        Set<String> teamFieldsSet = new Set<String>();
        teamFieldsSet.addall(mappingMap.values());
        return teamFieldsSet;
    }
}