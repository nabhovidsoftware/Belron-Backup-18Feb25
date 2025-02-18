/**
 * Created by gciesielsk001 on 28.03.2024.
 */

public virtual class BLN_TriggerHandler {

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // constructor
    public BLN_TriggerHandler() {
        this.setTriggerContext();
    }

    public void run() {
        if(BLN_FSLUtility.isTriggerDisabled(UserInfo.getUserId())){
            return;
        } else {
            switch on this.context {

                when BEFORE_INSERT {
                    this.beforeInsert();
                }
                when BEFORE_UPDATE {
                    this.beforeUpdate();
                }
                when BEFORE_DELETE {
                    this.beforeDelete();
                }
                when AFTER_INSERT {
                    this.afterInsert();
                }
                when AFTER_UPDATE {
                    this.afterUpdate();
                }
                when AFTER_DELETE {
                    this.afterDelete();
                }
                when AFTER_UNDELETE {
                    this.afterUndelete();
                }
            }
        }
    }

    @TestVisible
    protected virtual void beforeInsert() {
        string result = '';
         result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }

    @TestVisible
    protected virtual void beforeUpdate() {
        string result = '';
        result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }

    @TestVisible
    protected virtual void beforeDelete() {
        string result = '';
        result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }

    @TestVisible
    protected virtual void afterInsert() {
        string result = '';
        result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }

    @TestVisible
    protected virtual void afterUpdate() {
        string result = '';
        result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }

    @TestVisible
    protected virtual void afterDelete() {
        string result = '';
        result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }

    @TestVisible
    protected virtual void afterUnDelete() {
        string result = '';
        result = 'Finish'; //Before Adding your logic here please remove string result = 'Finish' as we have added this for PMD
    }


    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {
        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        } else {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')) {
            this.context = TriggerContext.BEFORE_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        } else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

}