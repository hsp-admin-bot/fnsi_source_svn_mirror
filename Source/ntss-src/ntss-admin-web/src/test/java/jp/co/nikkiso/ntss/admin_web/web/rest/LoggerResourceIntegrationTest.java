package jp.co.nikkiso.ntss.admin_web.web.rest;

import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.restdocs.mockmvc.RestDocumentationRequestBuilders;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import jakarta.servlet.http.HttpServletRequest;

import static org.hamcrest.Matchers.is;
import static org.hamcrest.Matchers.nullValue;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.csrf;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * {@link LoggerResource} の結合テストクラス.
 */
@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
public class LoggerResourceIntegrationTest extends AbstractResourceIntegrationTest {

  /**
   * ObjectMapper.
   */
  @Autowired
  private ObjectMapper mapper;

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: なし
   * 結果: 成功レスポンスが返却される事.
   */
  @Test
  @NtssMockUser(facilityCd = "test")
  public void test_outputLog_成功() throws Exception {
    // 事前準備
    String strLogClass = "app";
    String strLogLevel = "info";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", strLogClass, strLogLevel)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.isSuccess", is(true)))
      .andExpect(jsonPath("$.errorMessage", nullValue()));
  }

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: 想定外のログレベルが指定されている事.
   * 結果: {@link org.springframework.http.HttpStatus#BAD_REQUEST}が返却される事.
   */
  @Test
  @NtssMockUser
  public void test_outputLog_失敗_想定外のログレベルが指定されている場合() throws Exception {
    // 事前準備
    String strLogClass = "app";
    String strLogLevel = "test";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", strLogClass, strLogLevel)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(String.format("ログ出力に失敗しました.ログ区分:[%s] ログレベル:[%s]", strLogClass ,strLogLevel))));
  }

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: ログレベルにnullが指定されている事.
   * 結果: {@link org.springframework.http.HttpStatus#NOT_FOUND}が返却される事.
   */
  @Test
  @NtssMockUser
  public void test_outputLog_失敗_ログレベルにnullが指定されている場合() throws Exception {
    // 事前準備
    String strLogClass = "app";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", strLogClass, null)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isNotFound());
  }

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: ログレベルに空文字が指定されている事.
   * 結果: {@link org.springframework.http.HttpStatus#NOT_FOUND}が返却される事.
   */
  @Test
  @NtssMockUser
  public void test_outputLog_失敗_ログレベルに空文字が指定されている場合() throws Exception {
    // 事前準備
    String strLogClass = "app";
    String strLogLevel = "";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", strLogClass, strLogLevel)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isNotFound());
  }

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: 想定外のログ区分が指定されている事.
   * 結果: {@link org.springframework.http.HttpStatus#BAD_REQUEST}が返却される事.
   */
  @Test
  @NtssMockUser
  public void test_outputLog_失敗_想定外のログ区分が指定されている場合() throws Exception {
    // 事前準備
    String strLogClass = "test";
    String strLogLevel = "info";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", strLogClass, strLogLevel)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isBadRequest())
      .andExpect(jsonPath("$.isSuccess", is(false)))
      .andExpect(jsonPath("$.errorMessage", is(String.format("ログ出力に失敗しました.ログ区分:[%s] ログレベル:[%s]", strLogClass ,strLogLevel))));
  }

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: ログ区分にnullが指定されている事.
   * 結果: {@link org.springframework.http.HttpStatus#NOT_FOUND}が返却される事.
   */
  @Test
  @NtssMockUser
  public void test_outputLog_失敗_ログ区分にnullが指定されている場合() throws Exception {
    // 事前準備
    String strLogLevel = "info";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", null, strLogLevel)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isNotFound());
  }

  /**
   * {@link LoggerResource#outputLog(HttpServletRequest, String, String, EventLogMessage, NtssUser)}の検証.
   *
   * 条件: ログ区分に空文字が指定されている事.
   * 結果: {@link org.springframework.http.HttpStatus#NOT_FOUND}が返却される事.
   */
  @Test
  @NtssMockUser
  public void test_outputLog_失敗_ログ区分に空文字が指定されている場合() throws Exception {
    // 事前準備
    String strLogClass = "";
    String strLogLevel = "info";
    EventLogMessage request = new EventLogMessage();
    request.setLogMessage("テストのログメッセージ");
    String requestBody = mapper.writeValueAsString(request);
    // 実行
    ResultActions result = mockMvc.perform(RestDocumentationRequestBuilders
      .put("/api/logging/{logClass}/{logLevel}", strLogClass, strLogLevel)
      .contentType(MediaType.APPLICATION_JSON)
      .with(new RequestPostProcessor() {
        @Override
        public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
          return request;
        }
      })
      .content(requestBody).with(csrf()));

    result
      .andExpect(status().isNotFound());
  }
}
