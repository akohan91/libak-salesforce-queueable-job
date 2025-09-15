public with sharing class AccountTriggerHandler extends TriggerHandler{
	protected override void handleAfterInsert() {
		insert new Contact(
			FirstName = 'Andrei',
			LastName = 'Kakhanouski'
		);
		QueueableJob.instance
			.addJob(new QueueableJobExample().setMaxRetries(3))
			.enqueueJobs();
	}
}