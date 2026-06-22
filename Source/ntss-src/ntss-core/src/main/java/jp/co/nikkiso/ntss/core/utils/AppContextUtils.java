package jp.co.nikkiso.ntss.core.utils;

import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

@Component
public class AppContextUtils implements ApplicationContextAware {

  private static ApplicationContext context;

  public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
    context = applicationContext;
  }

  public static <T> T getBean(Class<T> clazz) {
    return context.getBean(clazz);
  }

  public static Object getBean(String clazzName) {
    if (StringUtils.isEmpty(clazzName)) return null;
    return context.getBean(clazzName);
  }
}
