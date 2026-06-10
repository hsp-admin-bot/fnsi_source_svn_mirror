package jp.co.nikkiso.ntss.admin_web.response.ordMain;

import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.MultiValueMap;

import java.util.List;

@Data
public class JournalCreatecallNextPatIdRequestResponse {
  /*
   * @param headers the entity headers
   */
  MultiValueMap<String, String> headers;

  /*
   * @param body the entity body
   */
  String body;

  /*
   * @param status the status code
   */
  HttpStatus status;

  /*
   * @param ctlNoList
   */
  List<JournalCreateRequestPayload> ctlNoList;

  //mod #10412 次患者更新関連全体見直し対応 朴 start
  /*
   * @param callNextPatList
   */
  List<OrdMain> callNextPatList;
  //mod #10412 次患者更新関連全体見直し対応 朴 end

  /*
   * @param response
   */
  ResponseEntity<String> response;

}
