trigger ContactTrigger on Contact (before insert, before update, after insert, after update, after delete, after undelete) {
    new ContactTriggerHandler().handleTrigger();
}