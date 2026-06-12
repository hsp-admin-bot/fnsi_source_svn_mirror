package jp.co.nikkiso.ntss.admin_web.request.notificationMessage;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import jakarta.validation.constraints.NotEmpty;
import java.util.List;

/**
 * 通知メッセージ登録のRequestクラス.
 */
@Data
public class RegistMessageSendMailRequest {

  /**
   * メッセージタイトル.
   */
  @NotEmpty
  private String contentSubject;

  /**
   * メッセージ本文.
   */
  @NotEmpty
  private String contentBody;

  /**
   * 利用者IDのリスト.
   */
  private List<Long> recipients;

  /**
   * 付加情報.
   */
  @JsonProperty("additional_info")
  private String additionalInfo;

}
