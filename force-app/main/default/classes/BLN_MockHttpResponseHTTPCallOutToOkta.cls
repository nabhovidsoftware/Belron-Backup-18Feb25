// Mock HTTP response generator
public class BLN_MockHttpResponseHTTPCallOutToOkta implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody('{"access_token": "00D7a00000057BE!AR0AQL3GDzbly30diuDf7bL3MhSCjAcmRPrrKcG1hdWZpO8JU2yUytrpaiXfkQ50vab4vSOygl8.b9NIwnSCsCZHQk_xt18n", "expires_in": 3600}');
        return res;
    }
}