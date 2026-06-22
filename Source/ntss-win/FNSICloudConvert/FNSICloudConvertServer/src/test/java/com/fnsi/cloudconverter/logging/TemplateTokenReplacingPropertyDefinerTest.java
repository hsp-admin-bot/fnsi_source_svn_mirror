package com.fnsi.cloudconverter.logging;

import ch.qos.logback.core.ContextBase;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class TemplateTokenReplacingPropertyDefinerTest {

    @Test
    void shouldReplaceDateTokenAndAppendTrailingSlash() {
        ContextBase context = new ContextBase();
        context.putProperty("SERVER_LOG_PATH_TEMPLATE", "/efs/system/{1}/オンプレクラウドコンバートサーバ");

        TemplateTokenReplacingPropertyDefiner definer = new TemplateTokenReplacingPropertyDefiner();
        definer.setContext(context);
        definer.setSourceProperty("SERVER_LOG_PATH_TEMPLATE");
        definer.setToken("{1}");
        definer.setReplacement("today");

        assertEquals(
                "/efs/system/today/オンプレクラウドコンバートサーバ/",
                definer.getPropertyValue()
        );
    }

    @Test
    void shouldUseDefaultValueWhenContextPropertyIsMissing() {
        TemplateTokenReplacingPropertyDefiner definer = new TemplateTokenReplacingPropertyDefiner();
        definer.setContext(new ContextBase());
        definer.setSourceProperty("MISSING_PROPERTY");
        definer.setToken("{1}");
        definer.setReplacement("%d{yyyyMMdd}");
        definer.setDefaultValue("/efs/system/{1}/オンプレクラウドコンバートサーバ/");

        assertEquals(
                "/efs/system/%d{yyyyMMdd}/オンプレクラウドコンバートサーバ/",
                definer.getPropertyValue()
        );
    }
}
