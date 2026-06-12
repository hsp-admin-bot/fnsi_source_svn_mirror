package jp.co.nikkiso.ntss.core.utils;

import java.util.HexFormat;

/**
 * Hex encoding utilities backed by the Java 17 standard library.
 */
public final class HexCodecUtils {

  private static final HexFormat HEX_PARSER = HexFormat.of();
  private static final HexFormat UPPERCASE_HEX_FORMATTER = HexFormat.of().withUpperCase();

  private HexCodecUtils() {
  }

  public static String printHexBinary(byte[] bytes) {
    return UPPERCASE_HEX_FORMATTER.formatHex(bytes);
  }

  public static byte[] parseHexBinary(String value) {
    return HEX_PARSER.parseHex(value);
  }
}
