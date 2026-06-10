package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import java.lang.reflect.UndeclaredThrowableException;
import java.math.BigInteger;
import java.security.GeneralSecurityException;
import java.security.SecureRandom;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import org.apache.commons.codec.binary.Base32;
import org.apache.commons.codec.binary.Hex;

public final class TOTP {

	private TOTP() {
		// private utility class constructor
	}

	public static String getOTPCode(String key) {
		return TOTP.getOTPCode(TOTP.stepCounter(), key);
	}

	public static boolean validKwO(final String key, final String otp) {
		return TOTP.validKwO(TOTP.stepCounter(), key, otp);
	}

	public static boolean validKwO(final long step, final String key, final String otp) {
		return TOTP.getOTPCode(step, key).equals(otp) || TOTP.getOTPCode(step - 1, key).equals(otp)
				|| TOTP.getOTPCode(step + 1, key).equals(otp);
	}

	public static long stepCounter() {
		return System.currentTimeMillis() / 30000;
	}

	/* convert secret key with declare time to the OTP code */
	private static String getOTPCode(final long step, final String key) {
		String steps = Long.toHexString(step).toUpperCase();
		while (steps.length() < 16) {
			steps = "0" + steps;
		}

		// get the time in UNIX and the secret key to convert into hash byte array.
		final byte[] msg = TOTP.hexStr2Bytes(steps);
		final byte[] k = TOTP.hexStr2Bytes(key);
		final byte[] hash = TOTP.hmac_sha1(k, msg);

		// put selected bytes into result int
		final int offset = hash[hash.length - 1] & 0xf;
		final int binary = ((hash[offset] & 0x7f) << 24) | ((hash[offset + 1] & 0xff) << 16)
				| ((hash[offset + 2] & 0xff) << 8) | (hash[offset + 3] & 0xff);
		final int otp = binary % 1000000;
		String result = Integer.toString(otp);
		while (result.length() < 6) {
			result = "0" + result;
		}
		return result;
	}

	/* convert a hex string into a byte */
	private static byte[] hexStr2Bytes(final String hex) {
		// Adding one byte to get the right conversion
		// values starting with "0" can be converted
		final byte[] bArray = new BigInteger("10" + hex, 16).toByteArray();
		final byte[] ret = new byte[bArray.length - 1];

		// Copy all the REAL bytes, not the "first"
		System.arraycopy(bArray, 1, ret, 0, ret.length);
		return ret;
	}

	/* encrypt with hmac_sha1 algorithm */
	private static byte[] hmac_sha1(final byte[] keyBytes, final byte[] text) {
		try {
			final Mac hmac = Mac.getInstance("HmacSHA1");
			final SecretKeySpec macKey = new SecretKeySpec(keyBytes, "RAW");
			hmac.init(macKey);
			return hmac.doFinal(text);
		} catch (final GeneralSecurityException gse) {
			throw new UndeclaredThrowableException(gse);
		}
	}

	/* generate secrect key in base32 encode */
	public static String generateSecretKey() {
		SecureRandom random = new SecureRandom();
		byte[] bytes = new byte[20];
		random.nextBytes(bytes);
		Base32 base32 = new Base32();
		return base32.encodeToString(bytes);
	}

	/* generate OTP code from secrect key */
	public static String getTOTPCode(String secretKey) {
		Base32 base32 = new Base32();
		byte[] bytes = base32.decode(secretKey);
		String hexKey = Hex.encodeHexString(bytes);
		return TOTP.getOTPCode(hexKey);
	}

}
