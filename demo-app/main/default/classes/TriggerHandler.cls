public virtual class TriggerHandler {
	
	// static map of handlername, times run() was invoked
	private static Set<String> bypassedHandlers;
	
	@TestVisible
	private static List<SObjectType> TRIGGER_CHAIN = new List<SObjectType>();
	
	// static initialization
	static {
		bypassedHandlers = new Set<String>();
	}
	
	/***************************************
	* public instance methods
	***************************************/
	
	// main method that will be called during execution
	public void handleTrigger() {
		registerSobjectInChain();
		QueueableJob.instance.incrementTriggerChainDepth();
		switch on Trigger.operationType {
			when BEFORE_INSERT {
				handleBeforeInsert();
				onValidateBefore();
			}
			when BEFORE_UPDATE {
				handleBeforeUpdate();
				onValidateBefore();
			}
			when BEFORE_DELETE {
				handleBeforeDelete();
			}
			when AFTER_INSERT {
				onValidateAfter();
				handleAfterInsert();
			}
			when AFTER_UPDATE {
				onValidateAfter();
				handleAfterUpdate();
			}
			when AFTER_DELETE {
				handleAfterDelete();
			}
			when AFTER_UNDELETE {
				handleAfterUndelete();
			}
		}
		QueueableJob.instance.decrementTriggerChainDepth();
		QueueableJob.instance.enqueueJobs();
	}
	
	/***************************************
	* public static methods
	***************************************/
	
	public static void bypass(String handlerName) {
		TriggerHandler.bypassedHandlers.add(handlerName);
	}
	
	public static void clearBypass(String handlerName) {
		TriggerHandler.bypassedHandlers.remove(handlerName);
	}
	
	/***************************************
	* context methods
	***************************************/
	
	private void onValidateBefore() {
		validateBefore();
	}
	// Override this to apply general validation to be performed during insert or update, called after the handleBeforeInsert and handleBeforeUpdate methods
	protected virtual void validateBefore() {
	}

	private void onValidateAfter() {
		validateAfter();
	}
	// Override this to apply general validation to be performed during insert or update, called before the handleAfterInsert and handleAfterUpdate methods
	protected virtual void validateAfter() {
	}

	// context-specific methods for override
	@TestVisible
	protected virtual void handleBeforeInsert() {
	}
	@TestVisible
	protected virtual void handleAfterInsert() {
	}
	@TestVisible
	protected virtual void handleBeforeUpdate() {
	}
	@TestVisible
	protected virtual void handleAfterUpdate() {
	}
	@TestVisible
	protected virtual void handleBeforeDelete() {
	}
	@TestVisible
	protected virtual void handleAfterDelete() {
	}
	@TestVisible
	protected virtual void handleAfterUndelete() {
	}
	
	private static void registerSobjectInChain() {
		SObjectType sot = getTriggerSobjectType();
		if (sot != null) {
			TRIGGER_CHAIN.add(sot);
		}
	}
	
	private static SObjectType getTriggerSobjectType() {
		if (!Trigger.isExecuting) {
			return null;
		}
		return Trigger.new != null ? Trigger.new.getSObjectType() : Trigger.old.getSObjectType();
	}
	
	public static Boolean isTriggerChainRoot() {
		SObjectType rootType = TRIGGER_CHAIN.isEmpty() ? null : TRIGGER_CHAIN.get(0);
		SObjectType currentType = getTriggerSobjectType();
		return rootType != null
			&& currentType != null
			&& rootType.getDescribe().getName() == currentType.getDescribe().getName()
			&& getNumberOfSobjectsHoopsOnTriggerChain() == 0;
	}
	
	@TestVisible
	private static void resetTriggerChain() {
		TRIGGER_CHAIN = new List<SObjectType>();
	}
	
	public static List<SObjectType> getTriggerChain() {
		return TRIGGER_CHAIN;
	}
	
	public static void initTriggerChain(List<SObjectType> triggerChain) {
		TRIGGER_CHAIN = new List<SObjectType>(triggerChain);
	}
	
	public static SObjectType getTriggerChainRootObjectType() {
		return TRIGGER_CHAIN.isEmpty() ? null : TRIGGER_CHAIN.get(0);
	}
	
	private static Integer getNumberOfSobjectsHoopsOnTriggerChain() {
		Integer counter = 0;
		String rootObject = TRIGGER_CHAIN.get(0).getDescribe().getName();
		for (SObjectType sType : TRIGGER_CHAIN) {
			if (rootObject != sType.getDescribe().getName()) {
				counter++;
			}
			rootObject = sType.getDescribe().getName();
		}
		return counter;
	}
}