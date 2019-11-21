@isTest(seealldata = false)
private class AccountTeamMemberBatchTest {
    private static List<Account> accountList = new List<Account>();
    private static List<AccountTeamMember> accountTeamMemberList = new List<AccountTeamMember>();

    static void init() {
        //create user 
        User paul= new User(
                FirstName = 'Paul',
                LastName = 'Adams (TEST)',
                Alias = 'cadam',
                Email = 'paul_adams@test.rapid7.com',
                Username = 'paul_adams@test.rapid7.com',
                CommunityNickname = 'paul.adams.test',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/New_York',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = UserInfo.getProfileId());
        insert paul;
        User chris = new User(
                FirstName = 'Chris',
                LastName = 'Adams (TEST)',
                Alias = 'cadam',
                Email = 'chris_adams@test.rapid7.com',
                Username = 'chris_adams@test.rapid7.com',
                CommunityNickname = 'chris.adams.test',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/New_York',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = UserInfo.getProfileId());
        insert chris;
        User david = new User(
                FirstName = 'david',
                LastName = 'Adams (TEST)',
                Alias = 'dadam',
                Email = 'david@test.rapid7.com',
                Username = 'david@test.rapid7.com',
                CommunityNickname = 'david.adams.test',
                EmailEncodingKey = 'UTF-8',
                TimeZoneSidKey = 'America/New_York',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                ProfileId = UserInfo.getProfileId());
        insert david;
        System.assertEquals(david.ProfileId,UserInfo.getProfileId());
        //createCustom Setting
        AccountTeamMemberSetting__c setting1 = new AccountTeamMemberSetting__c(
                Name = 'IDR AE',
                AccountField__c ='IDRAE__c');
        insert setting1;
        AccountTeamMemberSetting__c setting2 = new AccountTeamMemberSetting__c(
                Name = 'TEM AE',
                AccountField__c = 'TEMAE__c');
        insert setting2;
        AccountTeamMemberSetting__c setting3 = new AccountTeamMemberSetting__c(
                Name = 'Business Development Rep (BDR)',
                AccountField__c = 'BusinessDevelopmentRepBDR__c');
        insert setting3;
        //create Account 
        for(Integer i=0;i<=10;i++) {
            Account dotalore = new Account(
                    Name = 'Test'+i,
                    Type = 'Customer',
                    BillingCountry = 'United States',
                    IDRAE__c = paul.Id);
            accountList.add(dotalore);
        }
        if(!accountList.isEmpty()) {
            insert accountList;

            //create AccountTeamMember
            for(integer i=0;i<accountList.size()-1;i++) {
               
                AccountTeamMember teammember = new AccountTeamMember (
                        TeamMemberRole = 'IDR AE',
                        AccountId =accountList[i].Id,UserId=chris.Id);
                AccountTeamMember teammember1 = new AccountTeamMember (
                        TeamMemberRole = 'TEM AE',
                        AccountId =accountList[i].Id,UserId=david.Id);
                AccountTeamMember teammember2 = new AccountTeamMember (
                        TeamMemberRole = 'Business Development Rep (BDR)',
                        AccountId =accountList[i].Id,UserId=chris.Id);
                accountTeamMemberList.add(teammember);
                accountTeamMemberList.add(teammember1);
                accountTeamMemberList.add(teammember2);
            }
            if(!accountTeamMemberList.isEmpty()) {
                insert accountTeamMemberList;
            }
        }
    }
    
    @isTest static void test_AccountTeamMemberWeeklyJob() {
        init();
        Test.startTest();

        AccountTeamMemberJob sched = new AccountTeamMemberJob();
        sched.execute(null);

        Test.stopTest();
    }
    
    @isTest static void test_AccountTeamMemberDailyJob0() {
        init();
        Test.startTest();
        
        AccountTeamMemberDailyBatch.invokeBatch('Select '+ 'Id,' +'TeamMemberRole,' + 'AccountId,'+'UserId From '+ ' AccountTeamMember where LastModifiedDate = TODAY order by AccountId,TeamMemberRole,LastModifiedDate ASC',200);
        
        Test.stopTest();
    }
    
    @isTest static void test_AccountTeamMemberDailyJob() {
        init();
        Test.startTest();

        AccountTeamMemberDailyJob sched = new AccountTeamMemberDailyJob();
        sched.execute(null);

        Test.stopTest();
    }
}