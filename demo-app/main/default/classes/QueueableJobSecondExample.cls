public with sharing class QueueableJobSecondExample extends QueueableJob {
	
	public override void doExecute(QueueableContext context) {
		System.debug('Executing QueueableJobSecondExample... ' + context.getJobId());
	}
}
