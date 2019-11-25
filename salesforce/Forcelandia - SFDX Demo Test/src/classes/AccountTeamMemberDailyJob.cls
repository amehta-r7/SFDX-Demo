/**
 * This schedulable class exists to kick off AccountTeamMemberDailyJob,
 * which is responsible for updating AccountTeamMember records in Account object.
 */
global class AccountTeamMemberDailyJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        AccountTeamMemberDailyBatch.invokeBatch(null,200);
    }
}