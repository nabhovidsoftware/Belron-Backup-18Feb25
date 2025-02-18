public class LAD_FetchOctaBearer implements queueable,Database.allowscallouts {

     string orderId;
    
    public LAD_FetchOctaBearer(string orderId){
        this.orderId=orderId;
       
    }
    public void execute(queueableContext context){
        fetchBearerTokens(orderId);
    }
    
    public static void fetchBearerTokens(string orderId){
     
		String octaEndpoint = 'https://belron-qa.oktapreview.com/oauth2/aus3y4d618foXQcFa0x7/v1/token?grant_type=client_credentials&scope=read';

		Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(octaEndpoint);
        request.setHeader('Content-Type','application/x-www-form-urlencoded');
        String username = '0oa7aj1weyriv995x0x7';
        String password = 'Tq8CqPYi1BhQ_qbU0Ok5x77r3dzC6l0_nzkewKR4MnBcg0u8HvDY5nNDczaZwbH0';
        request.setMethod('POST');

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic '+
        EncodingUtil.base64Encode(headerValue);
		system.debug('authorizationHeader>>'+authorizationHeader);
        request.setHeader('Authorization', authorizationHeader);
		HTTPResponse response = http.send(request);
        Map<string,object> parseJson=(Map<string,object>)json.deserializeuntyped(response.getbody());
		string bearer=(string)parseJson.get('access_token');
        if(!Test.isRunningTest()){
		system.enqueueJob(new LAD_fetchTaxDetailsOrder(orderId,bearer));
        }
    }
}