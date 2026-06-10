package jp.co.nikkiso.ntss.alive_moni_auto.service;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.alive_moni_auto.constant.SysSystemDefineCtlNo;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;


/**
 * システム設定情報のService実装クラス.
 */
@Service
public class SysSystemDefineServiceImpl implements SysSystemDefineService {

  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;

  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean IsProcServer(SysSystemDefineCtlNo ctlNo, String ipAddress) {

    // 確認対象のIPアドレスが空の場合
    if (true == StringUtils.isEmpty(ipAddress)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：処理実施対象サーバーか確認するためのローカルIPアドレスが null または空文字");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    List<SysSystemDefine> lstSysSystemDefine = this.getSysSystemDefine(ctlNo);
    if (null == lstSysSystemDefine) {
      // エラー(false を返す)
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：システム設定情報の取得に失敗　管理番号[" + ctlNo.getNo() + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

      return false;
    } else if (0 == lstSysSystemDefine.size()) {
      // 指定管理番号のデータが存在しない
      // エラー(false を返す)

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：システム設定情報の取得件数が0件　管理番号[" + ctlNo.getNo() + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);

      return false;
    }

    // JsonからMapへ変換
    Map<String, String> map = new LinkedHashMap<>();
    ObjectMapper mapper = new ObjectMapper();
    try {
      map = mapper.readValue(lstSysSystemDefine.get(0).getValue(), new TypeReference<LinkedHashMap<String, String>>(){});
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：システム設定情報のJsonデータ展開処理に失敗　Jsonデータ[" + lstSysSystemDefine.get(0).getValue() + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    if (false == ipAddress.equals(map.get("ip_address"))) {
      // 処理実施サーバーではないので false を返す. ログは出力しない(頻繁に呼ばれるため)
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("死活監視：処理対象外サーバー　システム設定[" + map.get("ip_address") + "]、確認サーバー[" + ipAddress + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    // データが取得できているので、処理実施サーバーとして true を返す
    return true;
  }

  /**
   * システム設定の情報の取得.
   *
   * @param ctlNo システム設定の管理番号
   * @return システム設定情報
   */
  private List<SysSystemDefine> getSysSystemDefine(SysSystemDefineCtlNo ctlNo) {

    List<SysSystemDefine> data;
    try {
      data = this.sysSystemDefineDao.selectByCtlNo(ctlNo.getNo());
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
    }

    return data;
  }
}
