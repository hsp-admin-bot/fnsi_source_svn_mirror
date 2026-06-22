package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;
import java.net.URLEncoder;
import java.security.SecureRandom;
import java.util.Base64;

import org.apache.commons.codec.binary.Base32;
import org.apache.commons.codec.binary.Hex;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

public class TwoFactAuth {
	/* Create A Constructor to call */
	public String TwoFactAuth(String secCode, String email, String companyName) throws Exception {
		String str = a2z(secCode, email, companyName);
		return str;
	}

	/* function to generate the secret key */
	public static String createSecretKey() {
		SecureRandom random = new SecureRandom();
		byte[] bytes = new byte[20];
		random.nextBytes(bytes);
		Base32 base32 = new Base32();
		return base32.encodeToString(bytes);
	}

	/* convert OTP code to secret key */
	public static String getOTPCode(String secretKey) {
		Base32 base32 = new Base32();
		byte[] bytes = base32.decode(secretKey);
		String hexKey = Hex.encodeHexString(bytes);
		return TOTP.getOTPCode(hexKey);
	}

	/* return a barcode url string */
	public static String googleAuthBarcode(String secretKey, String account, String issuer) {
		try {
			return "otpauth://totp/" + URLEncoder.encode(issuer + ":" + account, "UTF-8").replace("+", "%20")
					+ "?secret=" + URLEncoder.encode(secretKey, "UTF-8").replace("+", "%20") + "&issuer="
					+ URLEncoder.encode(issuer, "UTF-8").replace("+", "%20");
		} catch (UnsupportedEncodingException e) {
			throw new IllegalStateException(e);
		}
	}

	// from the barcodeURL convert it into base64 byte array.
	private static byte[] getQRImg(String text, int width, int height) throws Exception {
		QRCodeWriter qrCodeWriter = new QRCodeWriter();
		BitMatrix bitMatrix = qrCodeWriter.encode(text, BarcodeFormat.QR_CODE, width, height);

		ByteArrayOutputStream pngOutputStream = new ByteArrayOutputStream();
		MatrixToImageWriter.writeToStream(bitMatrix, "PNG", pngOutputStream);
		byte[] pngData = pngOutputStream.toByteArray();
		return pngData;
	}

	// convert QRbyte array into a string
	private static String QR2Str(byte[] QR) {
		String outString = Base64.getEncoder().encodeToString(QR);
		return outString;
	}

	/* all is here */
	private static String a2z(String secCode, String email, String comName) throws Exception {
		String barCodeUrl = googleAuthBarcode(secCode, email, comName);
		String str = QR2Str(getQRImg(barCodeUrl, 200, 200));
		return str;
	}

}
