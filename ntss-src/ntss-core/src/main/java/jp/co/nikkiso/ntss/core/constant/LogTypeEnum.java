package jp.co.nikkiso.ntss.core.constant;

public enum LogTypeEnum {

  ERROR("エラー"),
  WARNING("警告"),
  INFO("情報"),

  OS_BOOT("OS起動"),
  OS_DOWN("OS停止"),

  TOMCAT_BOOT("Tomcat起動"),
  TOMCAT_DOWN("Tomcat停止"),

  WAR_BOOT("WARアプリケーション起動"),
  WAR_DOWN("WARアプリケーション停止"),

  JAR_BOOT("JARアプリケーション起動"),
  JAR_DOWN("JARアプリケーション停止");

  private final String description;

  LogTypeEnum(String description) {
    this.description = description;
  }

  public String getDescription() {
    return description;
  }
}
