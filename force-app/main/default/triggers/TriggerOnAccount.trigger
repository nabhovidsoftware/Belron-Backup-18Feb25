trigger TriggerOnAccount on Account (before insert ) {
    if(trigger.isInsert){
       if(trigger.isBefore){
           BLN_PopulateCommunityURLHandler.updateUrlonInsertion(trigger.New);
       }
    }
}