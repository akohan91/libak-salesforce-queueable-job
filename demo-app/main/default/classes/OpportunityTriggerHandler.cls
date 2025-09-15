public with sharing class OpportunityTriggerHandler extends TriggerHandler {
	protected override void handleAfterInsert() {
        QueueableJob.instance
            .addJob(new QueueableJobThirdExample().setMaxRetries(1))
            .enqueueJobs();
	}
}