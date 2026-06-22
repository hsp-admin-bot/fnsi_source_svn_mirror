package web.utils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

public class DateTimeFormatterUtil {

    /**
     * LocalDateTime時間フォーマット（yyy-MM-dd HH：mm：ss）
     *
     * @param localDateTime localDateTimeオブジェクト
     * @param format 日付フォーマット文字列
     * @return フォーマットされた日付文字列
     */
    public static String dateTimeFormatter(LocalDateTime localDateTime, String format) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format);
        return localDateTime.format(formatter);
    }
}
