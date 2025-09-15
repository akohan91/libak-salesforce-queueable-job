public with sharing class QueueableJobThirdExample extends QueueableJob {
	
	public override void doExecute(QueueableContext context) {
		System.debug('Executing QueueableJobSecondExample... ' + context.getJobId());
		// throw new QueueableJobExampleException('Custom Exeption');
	}
}