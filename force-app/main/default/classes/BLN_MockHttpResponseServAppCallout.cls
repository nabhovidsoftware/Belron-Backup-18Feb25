public class BLN_MockHttpResponseServAppCallout implements HttpCalloutMock {
   public HTTPResponse respond(HTTPRequest req) {
       HTTPResponse res = new HTTPResponse();
       res.setHeader('Content-Type', 'application/json');
       res.setBody('{"status": "success", "message": "Mock response"}');
       res.setStatusCode(200);
       return res;
   }
}