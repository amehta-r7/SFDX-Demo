/*
    This Batch will run on all account and accountteammember records,compare user roles between both objects and
    later update only specific accounts where some changes are present in accountteammember records(update/insert/delete)
    Batch will run weekly on Saturday at 1 am. 
    It will work on update/insert/delete of accountteammember.
*/
/*
Log 1 : Modified by : Nidhi Gupta/Ankita Mehta
        Ticket Number : APPS-2869
*/
global class AccountTeamMemberBatch implements Database.Batchable<sObject> {
    
    public String query;
    public Set<String> teamFieldsSet     = new Set<String>();
    public Map<String,String> mappingMap =  new Map<String,String>();

    global AccountTeamMemberBatch() {
        mappingMap = AccountTeamMemberBatchHandler.createMapping();
        teamFieldsSet = AccountTeamMemberBatchHandler.createFieldSet(mappingMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<sObject> scope) {  
        AccountTeamMemberBatchHandler.batchExecute(scope,mappingMap,teamFieldsSet);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public static void invokeBatch(String q,Integer batchSize) {
        AccountTeamMemberBatch batch = new AccountTeamMemberBatch();    
        if(q != null)
            batch.query = q;
        /* Log 1 Starts*/
        else {
        List<String> fields = getAllFields();
        batch.query = 'select Id,' + String.join(fields, ',') + ' from Account';
        System.debug('batch.query........'+batch.query);
            /*batch.query = 'Select '+ 'Id,' +'AccountExecutiveAE__c,' + 'BusinessDevelopmentRepBDR__c,'+'ChannelAccountManagerCAM__c,'+'CustomerSuccessEngineerCSE__c,'+
                'CustomerSuccessManagerCSM__c,'+'ExecutiveSponsor__c ,'+'IDRAE__c,'+'OnboardingSpecialist__c,'+'SalesDevelopmentRepSDR__c,'+'ServicesLeadGen__c,'+
                'SolutionsEngineerSE__c,'+'TEMAE__c,'+'AutomationAE__c,'+'ServicesSpecialist__c From '+ ' Account'; */  
        }  
        /*Log 1 Ends*/     
            Database.executeBatch(batch,batchSize);
        
    }
    
    /* Log 1 Starts*/
    public static List<String> getAllFields() {
        List<String> fields = new List<String>();
        Map<String, AccountTeamMemberSetting__c> accountSetting = AccountTeamMemberSetting__c.getAll();
        System.debug('accountSetting........'+accountSetting);
        
        for(String setting : accountSetting.keyset()) {
            fields.add(accountSetting.get(setting).AccountField__c);
        }
        return fields;
    }
    /*Log 1 Ends*/
}