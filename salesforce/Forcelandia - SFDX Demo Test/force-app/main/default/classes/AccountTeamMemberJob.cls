/**
 * This schedulable class exists to kick off AccountTeamMemberJob,
 * which is responsible for updating AccountTeamMember records in Account object.
 */
global class AccountTeamMemberJob implements Schedulable {
    global void execute(SchedulableContext sc) {
        AccountTeamMemberBatch.invokeBatch(null,200);
    }
}