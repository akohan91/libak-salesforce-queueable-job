public with sharing class ContactTriggerHandler extends TriggerHandler{
	protected override void handleAfterInsert() {
        QueueableJob.instance
            .addJob(new QueueableJobSecondExample().setMaxRetries(1))
            .enqueueJobs();
        insert new Opportunity(
            Name = 'Test',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(2)
        );
        QueueableJob.instance
            .addJob(new QueueableJobSecondExample().setMaxRetries(1))
            .enqueueJobs();
	}
}