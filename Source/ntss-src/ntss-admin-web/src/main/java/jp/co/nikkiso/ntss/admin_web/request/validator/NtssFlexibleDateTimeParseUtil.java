package jp.co.nikkiso.ntss.admin_web.request.validator;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.time.ZonedDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeFormatterBuilder;
import java.time.format.DateTimeParseException;
import java.time.format.ResolverStyle;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

/**
 * NTSS 系で用いられる日付・日時文字列を解釈するユーティリティ.
 * <p>
 * 日付のみ: {@code yyyyMMdd}, {@code yyyy-MM-dd}, {@code yyyy/MM/dd}, {@code yyyy/M/d} 等。<br>
 * 日時: スペース区切り、{@code T} 区切り、コンパクト {@code yyyyMMddHHmm} / {@code yyyyMMddHHmmss}、
 * ISO オフセット・ゾーン付き、{@code yyyy-MM-dd'T'HH:mm:ss.SSSXXX} 等。
 * </p>
 */
public final class NtssFlexibleDateTimeParseUtil {

  private static final List<DateTimeFormatter> DATE_ONLY_FORMATTERS;
  /** {@link LocalDateTime#parse(CharSequence, DateTimeFormatter)} に渡せるもののみ */
  private static final List<DateTimeFormatter> LOCAL_DATE_TIME_FORMATTERS;

  static {
    List<DateTimeFormatter> d = new ArrayList<>();
    d.add(DateTimeFormatter.BASIC_ISO_DATE);
    d.add(DateTimeFormatter.ISO_LOCAL_DATE);
    d.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyy/MM/dd")
      .toFormatter(Locale.ROOT));
    d.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyy/M/d")
      .toFormatter(Locale.ROOT));
    DATE_ONLY_FORMATTERS = Collections.unmodifiableList(d);

    List<DateTimeFormatter> dt = new ArrayList<>();
    dt.add(DateTimeFormatter.ISO_LOCAL_DATE_TIME);
    dt.add(new DateTimeFormatterBuilder()
      .append(DateTimeFormatter.ISO_LOCAL_DATE)
      .appendLiteral(' ')
      .appendPattern("HH:mm:ss")
      .optionalStart()
      .appendFraction(java.time.temporal.ChronoField.NANO_OF_SECOND, 0, 9, true)
      .optionalEnd()
      .toFormatter(Locale.ROOT));
    dt.add(new DateTimeFormatterBuilder()
      .append(DateTimeFormatter.ISO_LOCAL_DATE)
      .appendLiteral(' ')
      .appendPattern("HH:mm")
      .toFormatter(Locale.ROOT));
    dt.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyy/MM/dd HH:mm:ss")
      .toFormatter(Locale.ROOT));
    dt.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyy/MM/dd HH:mm")
      .toFormatter(Locale.ROOT));
    dt.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyyMMddHHmm")
      .toFormatter(Locale.ROOT));
    dt.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyyMMddHHmmss")
      .toFormatter(Locale.ROOT));
    dt.add(new DateTimeFormatterBuilder()
      .appendPattern("yyyy-MM-dd'T'HH:mm:ss.SSSXXX")
      .toFormatter(Locale.ROOT));
    dt.add(DateTimeFormatter.ISO_DATE_TIME);
    LOCAL_DATE_TIME_FORMATTERS = Collections.unmodifiableList(dt);
  }

  private NtssFlexibleDateTimeParseUtil() {
  }

  /**
   * 日付のみとして解釈できるか.
   */
  public static boolean isValidDateOnly(String raw) {
    return parseAsLocalDate(raw).isPresent();
  }

  /**
   * 日時として解釈できるか（純粋な日付のみの文字列は false）.
   */
  public static boolean isValidDateTimeOnly(String raw) {
    if (raw == null) {
      return false;
    }
    if (raw.trim().isEmpty()) {
      return false;
    }
    if (parseAsLocalDate(raw).isPresent()) {
      return false;
    }
    return parseAsLocalDateTime(raw).isPresent();
  }

  /**
   * モードに応じて解釈可能か（空・null は false）.
   */
  public static boolean isValid(String raw, NtssFlexibleDateTimeParseMode mode) {
    if (raw == null || raw.trim().isEmpty()) {
      return false;
    }
    switch (mode) {
      case DATE_ONLY:
        return isValidDateOnly(raw);
      case DATE_TIME:
        return isValidDateTimeOnly(raw);
      case ANY:
      default:
        return parseAsLocalDate(raw).isPresent() || parseAsLocalDateTime(raw).isPresent();
    }
  }

  /**
   * 日付として解釈を試みる.
   */
  public static Optional<LocalDate> parseAsLocalDate(String raw) {
    if (raw == null) {
      return Optional.empty();
    }
    String s = raw.trim();
    if (s.isEmpty()) {
      return Optional.empty();
    }
    for (DateTimeFormatter f : DATE_ONLY_FORMATTERS) {
      try {
        return Optional.of(LocalDate.parse(s, f));
      } catch (DateTimeParseException ignored) {
        // next
      }
    }
    return Optional.empty();
  }

  /**
   * 日時として解釈し、システム既定タイムゾーン上の {@link LocalDateTime} に正規化する.
   */
  public static Optional<LocalDateTime> parseAsLocalDateTime(String raw) {
    if (raw == null) {
      return Optional.empty();
    }
    String s = raw.trim();
    if (s.isEmpty()) {
      return Optional.empty();
    }
    for (DateTimeFormatter f : LOCAL_DATE_TIME_FORMATTERS) {
      try {
        return Optional.of(LocalDateTime.parse(s, f));
      } catch (DateTimeParseException ignored) {
        // next
      }
    }
    try {
      return Optional.of(OffsetDateTime.parse(s).toLocalDateTime());
    } catch (DateTimeParseException ignored) {
      // next
    }
    try {
      return Optional.of(ZonedDateTime.parse(s).toLocalDateTime());
    } catch (DateTimeParseException ignored) {
      // next
    }
    return Optional.empty();
  }

}
