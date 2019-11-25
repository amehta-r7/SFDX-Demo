global class AccountTeamMemberBatchHandler {

    public static Map<String,Map<String,String>> accMemberMap = new Map<String,Map<String,String>>();
    public static Map<Id,sobject> accObjMap                   = new Map<Id,sobject>();     
    public static List<sobject> updateAccList                 = new List<sobject>();
    
    global AccountTeamMemberBatchHandler() {}
     
    public static void batchExecute(List<sObject> scope,Map<String,String> mappingMap,Set<String> teamFieldsSet) {
        accObjMap= new Map<Id,sobject>(scope);  
        createAccountTeamMemberMaps(mappingMap,teamFieldsSet);
        
        for(String accId : accObjMap.keyset()) {
            sObject accObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
            Boolean isChange = createUpdateAccountList(accObj,accId,accObjMap,mappingMap,teamFieldsSet);
            if(isChange == true) {
                updateAccList.add(accObj);
            }
        }
        System.debug('updateAccList...Final Account Update Size....'+updateAccList.size());
        if(!updateAccList.isempty()) {
            Database.SaveResult[] srList = Database.update(updateAccList, false);

        }
    }
    public static void createAccountTeamMemberMaps(Map<String,String> mappingMap,Set<String> teamFieldsSet) {
        for(sobject accTeamMemObj : [Select Id,TeamMemberRole,AccountId,UserId from AccountTeamMember where 
            AccountId In  : accObjMap.keyset() order by AccountId,TeamMemberRole,LastModifiedDate ASC]) {
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
    
    /*Create a List to update Account if there is any change in AccountTeamMember records */
    public static boolean createUpdateAccountList(sObject accObj,String accId,Map<Id,sobject> accObjMap,
                Map<String,String> mappingMap,Set<String> teamFieldsSet) {
        Boolean isChange = false;
        for(String s : teamFieldsSet) {
            if(accMemberMap.isempty()) {
                if((String) accObjMap.get(accId).get(s) == null) {
                    /*
                     System.debug('No update as accMemberMap is empty(no members under accounts)
                                and even Account Role fields are null.');
                    */
                }
                else if((String) accObjMap.get(accId).get(s) != null) {
                    /*
                     System.debug('Update to blank as accMemberMap is empty(no members under accounts)
                                and but Account Role fields are not null.');
                    */
                    accObj.put(s,'');   //s is role fields.
                    accObj.put('Id',accId);
                    isChange = true;
                }
            
            }
            else {
                if(!(accMemberMap.containskey(accId)) ) {
                    if((String) accObjMap.get(accId).get(s) != null) {
                        /*
                          System.debug('update to blank...As accMemberMap is not empty 
                          but it does not contain any AccountTeamMember related to that Account.
                          if already account has some values in role fields then update to null....');
                        */
                        accObj.put(s,'');
                        accObj.put('Id',accId);
                        isChange = true;
                    }
                }
                else {
                    
                    if((accMemberMap.get(accId)).containskey(s) && (accMemberMap.get(accId)).get(s) == (String) accObjMap.get(accId).get(s)) {
                        //System.debug('No update required. Same AccountTeamMember role users present in Account');
                    }
                    if((accMemberMap.get(accId)).containskey(s) && (accMemberMap.get(accId)).get(s) != (String) accObjMap.get(accId).get(s)) {
                        //System.debug('update to new values.....As there are new AccountTeamMember records under Account......');
                        accObj.put(s,accMemberMap.get(accId).get(s));
                        accObj.put('Id',accId);
                        isChange = true;
                    }
                    if(!((accMemberMap.get(accId)).containskey(s)) && (String) accObjMap.get(accId).get(s) != null) {
                        //System.debug('update to blank.......as same role not present in Account.');
                        accObj.put(s,accMemberMap.get(accId).get(s));
                        accObj.put('Id',accId);
                        isChange = true;
                    }
                    if(!((accMemberMap.get(accId)).containskey(s)) && (String) accObjMap.get(accId).get(s) == null) {
                        //System.debug('No Update... as rolefeilds are null in Account');
                    }
                }
            
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