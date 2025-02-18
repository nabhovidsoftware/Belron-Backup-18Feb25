public without sharing class lAD_CustomAccManagementController {

    @auraenabled
    public static Id getAccId(string userid){
        try {
            system.debug('userid'+userid);
            Id accountId;
            List<user> accidfromuser = [select id, AccountId  from user where id =:userid  limit 1];
            if (!accidfromuser.isEmpty()) {
                accountId = accidfromuser[0].AccountId;
            }
            system.debug('accountId>>'+accountId);
            return accountId;
        } catch (Exception e) {
            // Handling the exceptions and log an error message
            BLN_ExceptionLogger.captureException(e);
            return null;
        }
       
    } 
    
    @AuraEnabled(cacheable=true)
    public static List<User> getMembers(Id accountId) {
        // Fetching users associated with the specified account
        //return [SELECT Id, Name, Email FROM User WHERE AccountId = :accountId];
        return [SELECT Id,Name,Email, Username, LastName, FirstName, IsActive, Account.Name, contact.Name FROM User where AccountId = :accountId];
    }

    @AuraEnabled
    public static  list< map<string, Object> > getCarts(Id accountId,Id userId) {
        // Fetching active carts associated with the specified account
        List<WebCart> cartData = [SELECT Id, Name, Account.Name, Owner.Name, GrandTotalAmount FROM WebCart WHERE (Status = 'Active' OR Status = 'Checkout') AND AccountId = :accountId AND OwnerId !=: userId ];
        list< map<string, Object> >resultData = new list<map<string, Object>>();
        for(WebCart i: cartData){
            map<string, Object> temp= new map<string, Object>();
            temp.put('Id', i.Id);
            temp.put('AccountName', i.Account.Name);
            temp.put('OwnerName', i.Owner.Name);
            temp.put('GrandTotalAmount', i.GrandTotalAmount);
            resultData.add(temp);
        }

        return resultData ;
    }

    @AuraEnabled
    public static void updateCartOwner(Id cartId, Id newOwnerId) {
        WebCart cart = [SELECT Id, OwnerId FROM WebCart WHERE Id = :cartId LIMIT 1];
        cart.OwnerId = newOwnerId;
        update cart;
    }

    

    @AuraEnabled
    public static List<WebCart> getActiveCartForUser() {
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        return [SELECT Id FROM WebCart WHERE OwnerId = :currentUser.Id AND Status = 'Active' LIMIT 1];
    }


    @AuraEnabled
    public static void updateCartStatus(Id cartId, String status) {
        WebCart cart = [SELECT Id FROM WebCart WHERE Id = :cartId];
        cart.Status = status;
        update cart;
    }

    @AuraEnabled
    public static void updateCartStatusReturn(Id cartId) {
        WebCart c = [SELECT Id, CreatedbyId from WebCart WHERE Id =:cartId];
        Id u = c.createdbyId;
      list<WebCart> c2 =[SELECT Id, Status,OwnerId FROM WebCart where OwnerId=:u and Status='Active'];
        if(c2.size()>0)
        {
            c2[0].Status='PendingDelete';
           
            update c2;
            
        }
        c.OwnerId = u;
        update c;
    }

    @AuraEnabled
    public static webcart getcartCreatedBy(Id cartid) {
        return [SELECT Id, CreatedById,OwnerId FROM WebCart WHERE Id = :cartid];
    }


}