package com.fnsi.cloudconverter.logging;

import ch.qos.logback.core.PropertyDefinerBase;

/**
 * logback-spring.xml から参照するパス展開用 PropertyDefiner。
 *
 * sourceProperty に設定された値の token を replacement に置換して返す。
 * 末尾にディレクトリ区切りが無い場合は自動で付与する。
 */
public class TemplateTokenReplacingPropertyDefiner extends PropertyDefinerBase {

    private String sourceProperty;
    private String token;
    private String replacement;
    private String defaultValue;

    @Override
    public String getPropertyValue() {
        String template = null;
        if (sourceProperty != null && !sourceProperty.isBlank() && getContext() != null) {
            template = getContext().getProperty(sourceProperty);
        }
        if (template == null || template.isBlank()) {
            template = defaultValue;
        }
        if (template == null || template.isBlank()) {
            return "";
        }

        String resolved = template;
        if (token != null && replacement != null) {
            resolved = resolved.replace(token, replacement);
        }

        if (!resolved.endsWith("/") && !resolved.endsWith("\\")) {
            resolved = resolved + "/";
        }
        return resolved;
    }

    public void setSourceProperty(String sourceProperty) {
        this.sourceProperty = sourceProperty;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public void setReplacement(String replacement) {
        this.replacement = replacement;
    }

    public void setDefaultValue(String defaultValue) {
        this.defaultValue = defaultValue;
    }
}
