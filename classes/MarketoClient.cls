public class MarketoClient {
	/**
		Change this endpoint if required, as per your WSDL
	*/
	public static String API_ENDPOINT = 'https://na-c.marketo.com/soap/mktows/1_6';
	
	// DATE format for calculating request timestamp
	private static final String W3C_DATE_TIME_FORMAT =  'yyyy-MM-dd\'T\'HH:mm:ssZ';

	private String mktowsUserId, encKey;
	
	public MarketoClient(String userId, String encKey) {
		this.mktowsUserId = userId;
		this.encKey = encKey;
	}
	
	/**
		Use this port for making other web service calls.
		This port is ready and authenticated
	*/
	public Mktows.MktowsApiSoapPort prepareSoapPort() {
		Mktows.MktowsApiSoapPort port = new Mktows.MktowsApiSoapPort();
        port.endpoint_x = API_ENDPOINT;
		port.authentication = createAuthenticationHeader();
		return port;
	}
	
	Mktows.AuthenticationHeaderInfo createAuthenticationHeader() {
		Mktows.AuthenticationHeaderInfo authHeader = null;
		String requestTimestamp = calcRequestTimestamp();
		String requestSignature = calcRequestSignature(requestTimestamp, mktowsUserId, encKey);
		authHeader = new Mktows.AuthenticationHeaderInfo();
 		authHeader.mktowsUserId = mktowsUserId;
		authHeader.requestSignature = requestSignature;
		authHeader.requestTimestamp = requestTimestamp;
		return authHeader;
	}
	  
	String calcRequestTimestamp() {
		Datetime dt = System.now();
		String text = dt.formatGMT(W3C_DATE_TIME_FORMAT);
		String w3cValue = text.substring(0, 22) + ':' + text.substring(22);
		return w3cValue;
	}
	
	
	String calcRequestSignature(String requestTimestamp, String mktowsUserId, String encryptionKey){
		String encryptString = requestTimestamp + mktowsUserId;
		return calculateHMAC(encryptString, encryptionKey);
	}			
	
	String calculateHMAC(String encryptString, String encryptionKey) {
      String algorithmName = 'HMacSHA1';
      Blob mac = Crypto.generateMac(algorithmName,  Blob.valueOf(encryptString), 
                                                    Blob.valueOf(encryptionKey));
      return Encodingutil.convertToHex(mac);		
	}	
}