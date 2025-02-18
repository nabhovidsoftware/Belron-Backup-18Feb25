/** @description : This apex class is used for FOUK-3954.
*  @author: (pruthvising.vanrajsinh.pujara@pwc.com (IN))
*  @Story: FOUK-3954
*/
public Without Sharing class BLN_ExcludeList {
    @AuraEnabled
    public static String saveExcludeList(String recordId, List<String> selectedWorkTypes,List<String> selectedCategory, List<String> selectedProducts){
        
        ServiceTerritory st = new ServiceTerritory();
        st.Id = recordId;
        String selectedValues='';
        for(String str:selectedWorkTypes){
            selectedValues=selectedValues+str+';';
        }
        selectedValues = selectedValues.removeEnd(';');
        st.BLN_ExcludedWorkType__c = selectedValues;
        selectedValues='';
        for(String str:selectedCategory){
            selectedValues=selectedValues+str+';';
        }
        selectedValues = selectedValues.removeEnd(';');
        st.BLN_ExcludedProductCategory__c = selectedValues;
        selectedValues='';
        for(String str:selectedProducts){
            selectedValues=selectedValues+str+';';
        }
        selectedValues = selectedValues.removeEnd(';');
        st.BLN_ExcludedProduct__c = selectedValues;

        try {
            if(Schema.sObjectType.ServiceTerritory.isUpdateable()){
                update st;
                return 'success';
            } else {
                return 'Do not have update permission';
            }
        } catch (Exception e) {
            return 'Error While saving record';
        }
    }
    @AuraEnabled(cacheable=true)
    public static ExcludingListWrapper excludeList(){
        //system.debug('excludeList Entered');
        List<DropDown> excludeWorkTypeList = new List<DropDown>();
        List<DropDown> excludeProductList = new List<DropDown>();
        List<DropDown> excludeProductCategoryList = new List<DropDown>();
        List<WorkType> workTypeList = [select id,Name from WorkType WITH SECURITY_ENFORCED];
        List<Product2> productList = [select id,Name from Product2 WITH SECURITY_ENFORCED LIMIT 50];
        AggregateResult[] productCategoryResults = [select BLN_ProductCategory__c from Product2 where BLN_ProductCategory__c != null  WITH SECURITY_ENFORCED group by BLN_ProductCategory__c ];
        Set<String> productCategoryList = new Set<String>();
        for (AggregateResult result : productCategoryResults) {
            productCategoryList.add((String)result.get('BLN_ProductCategory__c'));
        }
        ExcludingListWrapper exclWrap = new ExcludingListWrapper();
        DropDown ddAll = new DropDown();
        ddAll.label = 'All';
        ddAll.value = 'All';
        //excludeWorkTypeList.add(ddAll);
        
        if(workTypeList.size()>0){
            for(WorkType wt:workTypeList){
                DropDown dd = new DropDown();
                dd.label = wt.Name;
                dd.value = wt.Name;
                excludeWorkTypeList.add(dd);
            }
            exclWrap.workTypeListWrap = excludeWorkTypeList;
            
        }
        if(productList.size()>0){
            excludeProductList.add(ddAll);
            for(Product2 pd:productList){
                DropDown dd = new DropDown();
                dd.label = pd.Name;
                dd.value = pd.Name;
                excludeProductList.add(dd);
            }
            exclWrap.productListWrap = excludeProductList;
        }
        if(productCategoryList.size()>0){
            excludeProductCategoryList.add(ddAll);
            for(String pdcValue:productCategoryList){
                DropDown dd = new DropDown();
                dd.label = pdcValue;
                dd.value = pdcValue;
                excludeProductCategoryList.add(dd);
            }
            exclWrap.productCategoryListWrap = excludeProductCategoryList;
        }
        User ur = [select id,Profile.Name from User where Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
        exclWrap.currentUserProfile = ur.Profile.Name;
        return exclWrap;
    }
    @AuraEnabled(cacheable=true)
    public static ExcludingListWrapper excludeListForProduct(String matchesLike, List<String> savedProductList , Boolean islike){
        //system.debug('excludeListForProduct Entered');
        List<DropDown> excludeProductList = new List<DropDown>();
        //List<Product2> productList = [select Name from Product2 where Name Like :matchesLike WITH SECURITY_ENFORCED  group by Name LIMIT 100];
        AggregateResult[] productResults ;
        if(islike){
            productResults = [select Name from Product2 where Name Like :matchesLike WITH SECURITY_ENFORCED  group by Name ];
        }
        else{
            productResults = [select Name from Product2 where Name IN  :savedProductList WITH SECURITY_ENFORCED  group by Name ];
        }
        Set<String> productList = new Set<String>();
        for (AggregateResult result : productResults) {
            productList.add((String)result.get('Name'));
        }
        //system.debug('excludeListForProduct Size '+productList.size());
        ExcludingListWrapper exclWrap = new ExcludingListWrapper();
        DropDown ddAll = new DropDown();
        ddAll.label = 'All';
        ddAll.value = 'All';     

        if(productList.size()>0){
            //excludeProductList.add(ddAll);
            for(String pd:productList){
                DropDown dd = new DropDown();
                dd.label = pd;
                dd.value = pd;
                excludeProductList.add(dd);
            }
            exclWrap.productListWrap = excludeProductList;
        }
        User ur = [select id,Profile.Name from User where Id =: UserInfo.getUserId() WITH SECURITY_ENFORCED];
        exclWrap.currentUserProfile = ur.Profile.Name;
        return exclWrap;
    }
    public class ExcludingListWrapper{
        @AuraEnabled
        public List<DropDown> workTypeListWrap = new List<DropDown>();
        @AuraEnabled
        public List<DropDown> productListWrap = new List<DropDown>();
        @AuraEnabled
        public List<DropDown> productCategoryListWrap = new List<DropDown>();
        @AuraEnabled
        public String currentUserProfile;
    }
    public class DropDown{
        @AuraEnabled 
        public String label;
        @AuraEnabled 
        public String value;
    }

}