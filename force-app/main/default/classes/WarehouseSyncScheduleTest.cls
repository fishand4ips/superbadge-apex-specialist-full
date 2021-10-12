@isTest
private with sharing class WarehouseSyncScheduleTest {
    @TestSetup
    static void init() {
        for (AsyncApexJob aJob : [Select id, Status, ApexClass.Name from AsyncApexJob where Status != 'Aborted' and Status != 'Completed']) {  
            System.abortJob(aJob.Id);
        }
    }

    @isTest
    static void scheduleTest() {
        final String CRON_EXP = '0 7 1 11,16 4-11 ? 2020,2021,2022,2023';
        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleJobTest', CRON_EXP, new WarehouseSyncSchedule());
        Test.stopTest();
        
        CronTrigger ct = [
            SELECT Id, CronExpression, TimesTriggered
            FROM CronTrigger 
            WHERE Id = :jobId
        ];
        
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}