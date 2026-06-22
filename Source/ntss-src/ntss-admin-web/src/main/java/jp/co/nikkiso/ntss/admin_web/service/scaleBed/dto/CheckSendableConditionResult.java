package jp.co.nikkiso.ntss.admin_web.service.scaleBed.dto;

import jp.co.nikkiso.ntss.admin_web.request.weight.SendConditionRequest;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class CheckSendableConditionResult {

  private boolean success;

  private String message;

  private SendConditionRequest sendConditionRequest;
}
