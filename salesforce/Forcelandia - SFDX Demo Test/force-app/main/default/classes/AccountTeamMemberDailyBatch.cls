/*
    This Batch will run on AccountTeamMember records modified yesterday and update their respective Account records.
    Batch will run everyday (Monday-Friday) at 1 am. 
    It will not work on delete of AccountTeamMember records. 
    It will not remove user role from account always enter user role as per accountteammember records
*/
global class AccountTeamMemberDailyBatch implements Database.Batchable<sObject> {
    
    public String query;
    public Set<String> teamFieldsSet     = new Set<String>();
    public Map<String,String> mappingMap =  new Map<String,String>();

    global AccountTeamMemberDailyBatch () {
        mappingMap = AccountTeamMemberDailyBatchHandler.createMapping();
        teamFieldsSet = AccountTeamMemberDailyBatchHandler.createFieldSet(mappingMap);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
 
    global void execute(Database.BatchableContext BC, List<sObject> scope) {  
        AccountTeamMemberDailyBatchHandler.batchExecute(scope,mappingMap,teamFieldsSet);
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    public static void invokeBatch(String q,Integer batchSize) {
        AccountTeamMemberDailyBatch batch = new AccountTeamMemberDailyBatch();    
        if(q != null)
            batch.query = q;
        else
            batch.query = 'Select '+ 'Id,' +'TeamMemberRole,' + 'AccountId,'+'UserId From '+ ' AccountTeamMember where LastModifiedDate = YESTERDAY order by AccountId,TeamMemberRole,LastModifiedDate ASC';          
            Database.executeBatch(batch,batchSize);
        
    }
}