package jp.co.nikkiso.ntss.admin_web.request.validator;

import java.lang.annotation.Documented;
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

/**
 * NTSS で用いる日付・日時文字列を、{@link NtssFlexibleDateTimeParseUtil} のルールで検証する.
 * <p>
 * {@link String} フィールド向け。未入力を許す場合は {@link #allowEmpty()} を true のままにする。
 * </p>
 */
@Documented
@Constraint(validatedBy = NtssFlexibleDateTimeValidator.class)
@Target({ ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER, ElementType.ANNOTATION_TYPE })
@Retention(RetentionPolicy.RUNTIME)
public @interface NtssFlexibleDateTime {

  /**
   * 解釈モード（日付のみ / 日時のみ / いずれか）.
   */
  NtssFlexibleDateTimeParseMode mode() default NtssFlexibleDateTimeParseMode.ANY;

  /**
   * true: null および空・空白のみは検証成功とする.
   */
  boolean allowEmpty() default true;

  String message() default "日付または日時として解釈できません。";

  Class<?>[] groups() default {};

  Class<? extends Payload>[] payload() default {};
}
