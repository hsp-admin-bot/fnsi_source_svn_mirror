package jp.co.nikkiso.ntss.admin_web.service.utils;

import jp.co.nikkiso.ntss.admin_web.web.rest.util.TwoFactAuth;

public class QRCodeUtils {

	public static String getSecretKey() {
	    TwoFactAuth tFA = new TwoFactAuth();
	    String secretKey = tFA.createSecretKey();
	    return secretKey;
	  }
}
