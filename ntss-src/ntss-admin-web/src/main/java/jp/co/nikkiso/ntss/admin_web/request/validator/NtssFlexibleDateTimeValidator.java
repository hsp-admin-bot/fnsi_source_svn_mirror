package jp.co.nikkiso.ntss.admin_web.request.validator;

import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;

/**
 * {@link NtssFlexibleDateTime} の実装.
 */
public class NtssFlexibleDateTimeValidator implements ConstraintValidator<NtssFlexibleDateTime, String> {

  private NtssFlexibleDateTimeParseMode mode;
  private boolean allowEmpty;

  @Override
  public void initialize(NtssFlexibleDateTime constraintAnnotation) {
    this.mode = constraintAnnotation.mode();
    this.allowEmpty = constraintAnnotation.allowEmpty();
  }

  @Override
  public boolean isValid(String value, ConstraintValidatorContext context) {
    if (value == null) {
      return allowEmpty;
    }
    if (value.trim().isEmpty()) {
      return allowEmpty;
    }
    return NtssFlexibleDateTimeParseUtil.isValid(value, mode);
  }
}
