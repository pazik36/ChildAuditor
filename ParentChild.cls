public with sharing class ChildAuditorCtrl {
	
    @AuraEnabled
    public static List<ChildInfo> takeChildInfo(String recordId) {
        
        Id objectId = recordId; 
        List<Schema.ChildRelationship> aChildRelationshipList = Schema.getGlobalDescribe()
            				   .get(objectId.getSobjectType() + '').getDescribe().getChildRelationships();
        
	Set<String> notQueryable = new Set<String>(); //some objects in salesforce can not be queried.
        for (Schema.SObjectType objectApiName :Schema.getGlobalDescribe().values()) {
            Schema.DescribeSObjectResult objResult = objectApiName.getDescribe();
            if (objResult.isQueryable() == false) {
				notQueryable.add(String.valueOf(objResult.getSobjectType()));
            }
        }

        String childApiName;
        String lookupToParent;
        String childQuery;
        Map<String,String> childToQuery = new Map<String,String>();
        for (Schema.ChildRelationship relationshipInfo :aChildRelationshipList) {
            
            childApiName = String.valueOf(relationshipInfo.ChildSobject);
            if (notQueryable.contains(childApiName) || childApiName == 'RecordActionHistory') {
                continue;
            }
            lookupToParent = String.valueOf(relationshipInfo.field);
            childQuery = 'SELECT count() FROM ' + childApiName + ' WHERE ' + lookupToParent + ' = :recordId';
            childToQuery.put(childApiName, childQuery);
        }

	List<ChildInfo> childInfos = new List<ChildInfo>();
        if (childToQuery.keySet().size() > (Limits.getLimitQueries() - 20)) { // remain 20 soqls for the rest of the code.
            return childInfos;
        }
	    
        ChildInfo aChildInfo;
        Integer count;
        for (String childNameApi :childToQuery.keySet()) {
            try {
                count = Database.countQuery(childToQuery.get(childNameApi));
                //* we can manage soql limit by doing it in asynchronous way when we have more than X number of soqls
                // we can check necessary number of soql limits and make soqls in asynchronous way. 
                // It is just another task.
            } catch (Exception e) {
                System.debug('123qwe ='+'STACK='+e.getStackTraceString()+'---123qwe-MESSAGE='+e.getMessage());
				System.debug('123qwe  cause' + e.getCause());
				System.debug('123qwe  line' + e.getLineNumber());
            }
           
            aChildInfo = new ChildInfo();
            aChildInfo.name = childNameApi;
            aChildInfo.numberOfRecords = String.valueOf(count);
            childInfos.add(aChildInfo);
        }
        return childInfos;
    }
    
    public class ChildInfo {
        
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String numberOfRecords {get;set;}
    }
    
}
