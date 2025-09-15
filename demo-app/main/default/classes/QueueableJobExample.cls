public with sharing class QueueableJobExample extends QueueableJob {
	
	public override void doExecute(QueueableContext context) {
		System.debug('Executing QueueableJobSecondExample... ' + context.getJobId());
		// throw new QueueableJobExampleException('Custom Exeption');
	}

	public class QueueableJobExampleException extends Exception {
		
	}
}