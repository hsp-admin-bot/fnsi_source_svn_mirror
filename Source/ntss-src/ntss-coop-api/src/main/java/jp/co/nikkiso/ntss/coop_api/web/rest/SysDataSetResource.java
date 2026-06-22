package jp.co.nikkiso.ntss.coop_api.web.rest;

import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.coop_api.request.SysDataSetRequest;
import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.response.SysDataSetCntResult;
import jp.co.nikkiso.ntss.coop_api.service.IfEdgeService;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import java.util.Map;

@RestController
@Slf4j
public class SysDataSetResource {

  @Autowired
  IfEdgeService ifEdgeService;

  @Autowired
  SysDataSetService sysDataSetService;

  /**
   * 連携エッジ処理実行指示(/ifedge/maintenance)
   * @param request : {@link SysDataSetRequest}
   * @return {@link ResponseEntity}
   */
  @PostMapping("/runDataSet")
  public ResponseEntity<?> execute(@RequestBody SysDataSetRequest request) {
    SysDataSetCntResult result = new SysDataSetCntResult();
    try {
      Map<String, Object> resultMap = sysDataSetService.getResultCnt(request.getSqlCode(), request.getDataKey());
      if (!"正常終了".equals(resultMap.get("message"))) {
        ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, String.valueOf(resultMap.get("message"))
        );
        return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
      } else{
        result.setExcuteResultsCount(Integer.valueOf(resultMap.get("excuteResultsCount").toString()));
        result.setMessage("正常終了");
        result.setStatus(200);
      }
    }catch (Exception e){
      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "Sql_CD:["  + request.getSqlCode() + "],実行でエラーが発生しました。"
      );
      return new ResponseEntity<>(error, HttpStatus.INTERNAL_SERVER_ERROR);
    }
    return new ResponseEntity<>(result, HttpStatus.OK);
  }
}

