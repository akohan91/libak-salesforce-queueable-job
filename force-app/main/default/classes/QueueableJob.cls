/**
 * @description Base class for implementing chainable queueable jobs with retry capabilities.
 * Implements both Queueable and Finalizer interfaces to handle job execution and failure scenarios.
 */
public virtual with sharing class QueueableJob implements Queueable, Finalizer {
	
	/**
	 * @description Singleton instance of the QueueableJob
	 */
	public static QueueableJob instance {
		get {
			if (instance == null) {
				instance = new QueueableJob();
			}
			return instance;
		}
		private set;
	}

	/**
	 * @description List of jobs pending execution in the chain
	 */
	private List<QueueableJob> pendingJobs = new List<QueueableJob>();

	/**
	 * @description Tracks the depth of the trigger chain
	 */
	private Integer triggerChainDepth = 0;

	/**
	 * @description Number of remaining retry attempts for the current job
	 */
	private Integer remainingRetries = 0;

	/**
	 * @description Virtual method to be implemented by concrete classes for job execution logic
	 * @param jobContext The context of the queueable job
	 */
	protected virtual void doExecute(QueueableContext jobContext) {}

	/**
	 * @description Implementation of the Queueable interface execute method
	 * @param jobContext The context of the queueable job
	 */
	public void execute(QueueableContext jobContext) {
		System.attachFinalizer(this);
		QueueableJob.instance = this;
		this.doExecute(jobContext);
	}

	/**
	 * @description Implementation of the Finalizer interface execute method
	 * Handles retry logic and chain continuation on job completion or failure
	 * @param finalizerContext The context of the finalizer
	 */
	public void execute(FinalizerContext finalizerContext) {
		if (System.ParentJobResult.UNHANDLED_EXCEPTION.equals(finalizerContext.getResult())) {
			// Log exception
			if (this.remainingRetries > 0) {
				this.remainingRetries--;
				System.enqueueJob(this);
			} else {
				this.enqueueNextJob();
			}
		} else {
			this.enqueueNextJob();
		}
		
	}

	/**
	 * @description Initiates the execution of the job chain
	 * @return Id The ID of the enqueued job, or null if already in a queueable context
	 */
	public Id enqueueJobs() {
		System.debug('TRIGGER CHAIN DEPTH: ' + this.triggerChainDepth);
		if (System.isQueueable() || this.triggerChainDepth > 0) {
			return null;
		}
		return this.enqueueNextJob();
	}

	/**
	 * @description Adds a single job to the chain
	 * @param job The job to add to the chain
	 * @return QueueableJob The current instance for method chaining
	 * @throws QueueableJobException if the job parameter is null
	 */
	public QueueableJob addJob(QueueableJob job) {
		if (job == null) {
			throw new QueueableJobException('Cannot add null job');
		}
		this.pendingJobs.add(job);
		return this;
	}

	/**
	 * @description Adds multiple jobs to the chain
	 * @param jobs List of jobs to add to the chain
	 * @return QueueableJob The current instance for method chaining
	 */
	public QueueableJob addJobs(List<QueueableJob> jobs) {
		this.pendingJobs.addAll(jobs);
		return this;
	}

	/**
	 * @description Sets the maximum number of retry attempts for the job
	 * @param maxRetries The number of times to retry the job on failure
	 * @return QueueableJob The current instance for method chaining
	 * @throws QueueableJobException if maxRetries is negative
	 */
	public QueueableJob setMaxRetries(Integer maxRetries) {
		if (maxRetries < 0) {
			throw new QueueableJobException('Retry attempts cannot be negative');
		}
		this.remainingRetries = maxRetries;
		return this;
	}

	/**
	 * @description Increments the trigger chain depth counter
	 * @return QueueableJob The current instance for method chaining
	 */
	public QueueableJob incrementTriggerChainDepth() {
		this.triggerChainDepth++;
		return this;
	}

	/**
	 * @description Decrements the trigger chain depth counter
	 * @return QueueableJob The current instance for method chaining
	 */
	public QueueableJob decrementTriggerChainDepth() {
		this.triggerChainDepth--;
		return this;
	}

	/**
	 * @description Enqueues the next job in the chain
	 * @return Id The ID of the enqueued job, or null if no jobs remain
	 */
	private Id enqueueNextJob() {
		if (this.pendingJobs.size() > 0) {
			System.debug('===>>> ENQUEUED JOB. JOBS IN THE QUEUE ' + this.pendingJobs.size());
			QueueableJob job = this.pendingJobs.remove(0);
			job.addJobs(this.pendingJobs);
			this.resetInstance();
			return System.enqueueJob(job);
		}
		return null;
	}

	/**
	 * @description Resets the singleton instance
	 */
	private void resetInstance() {
		QueueableJob.instance = null;
	}

	/**
	 * @description Custom exception class for QueueableJob related errors
	 */
	public class QueueableJobException extends Exception {}
}