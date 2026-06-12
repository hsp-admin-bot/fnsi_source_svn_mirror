package jp.co.nikkiso.ntss.web_api.config;

import java.util.List;

import org.springframework.context.annotation.Configuration;
import org.springframework.http.converter.HttpMessageConverter;
import org.springframework.http.converter.HttpMessageConverters;
import org.springframework.http.converter.StringHttpMessageConverter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfiguration implements WebMvcConfigurer {

  @Override
  public void configureMessageConverters(HttpMessageConverters.ServerBuilder builder) {
    builder.configureMessageConvertersList(converters -> {
      for (int i = 0; i < converters.size(); i++) {
        HttpMessageConverter<?> converter = converters.get(i);
        if (converter instanceof StringHttpMessageConverter) {
          converters.remove(i);
          converters.add(0, converter);
          break;
        }
      }
    });
  }
}
