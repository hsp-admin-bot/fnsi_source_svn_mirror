package jp.co.nikkiso.ntss.coop_api.service.externalCoopOper;

import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendRequest;
import org.springframework.http.ResponseEntity;

// add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 start
public interface CoopSendService {
  ResponseEntity<?> sendLogic(JournalConvertSendRequest request);
}
// add #9406  外部連携稼働ビューア API呼び出しに失敗する 20231016 孟堅 end
