package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

import org.springframework.security.test.context.support.WithSecurityContext;

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.METHOD, ElementType.TYPE})
@WithSecurityContext(factory=NtssMockUserFactory.class)
public @interface NtssMockUser {
    String facilityCd() default "000001";
    long userId() default 1L;
    int userType() default 0;
    int administrator() default 0;
    String authority() default "";
}
