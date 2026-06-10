package jp.co.nikkiso.ntss.device_edge.service.lcdReq;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.api.service.NameConcat.NameConcatService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.custom.lcdReq.LcdReq29;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 仮想端末情報（処置者）サービス
 */
@Service
public class LcdReq29ServiceImpl implements LcdReq29Service {

  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  // #11827 2025.05.14 add 姓名結合用サービス構築 TDC米沢 start
  // 姓名結合用サービス構築
  @Autowired
  NameConcatService nameConcatService;
  // #11827 2025.05.14 add 姓名結合要サービス構築 TDC米沢 end

  @Override
  public List<LcdReq29> selectByFacilityCd(String facilityCd, Integer deviceEdgeNo) {
    // 通信サーバ設定取得
    MstComsvSetting mstComsvSetting = mstComsvSettingDao.selectByCd(facilityCd, deviceEdgeNo);
    // 仮想端末スタッフ一覧取得
    String JsonString = mstComsvSetting.getLcdStaffList();
    ObjectMapper mapper = new ObjectMapper();

    // スタッフ一覧情報のリスト
    List<Staff> staffList = new ArrayList<Staff>();
    // スタッフ一覧にあるユーザーIDのリスト
    List<Long> userIdList = new ArrayList<Long>();

    try {
      JsonNode jsonNode = mapper.readTree(JsonString);
      // スタッフ一覧のJSON配列
      JsonNode staffList_jsonArray = jsonNode.get("staff_list");

      // スタッフ情報取り出し
      for (int lop = 0; lop < staffList_jsonArray.size(); lop++) {
        Staff staff = new Staff();
        JsonNode bufNode = staffList_jsonArray.get(lop);
        staff.no = bufNode.get("no").asInt();
        staff.userId = bufNode.get("user_id").asLong();

        // リストに格納
        staffList.add(staff);
        userIdList.add(staff.userId);
      }
    } catch (IOException e) {
      // TODO 自動生成された catch ブロック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang ende
    }

    // 戻り値格納用リスト
    List<LcdReq29> lcdReq29List = new ArrayList<>();

    // 戻り値作成
    if (staffList.size() != 0 && userIdList.size() != 0) {
      // ユーザー(個人情報あり)一覧取得
      List<MstPersonalUser> userList = mstPersonalUserDao.selectByIdList(userIdList);

      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
      try {
      // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start
      // 施設設定値取得
      nameConcatService.ReadFacilitySettingValue(facilityCd, CoreConstant.FacilitySettingNo.VIRTUAL_TERMINAL_NAME_CONCAT_SETTING);
      // #11827 2025.05.14 add 仮想端末姓名結合設定に準拠 TDC米沢 start

      // スタッフ一覧とユーザー一覧の突合せ
      for (int staffIdx = 0; staffIdx < staffList.size(); staffIdx++) {
        Staff staff = staffList.get(staffIdx);
        // スタッフのユーザーID
        Long userId_staff = staff.userId;

        for (int userIdx = 0; userIdx < userList.size(); userIdx++) {
          MstPersonalUser user = userList.get(userIdx);
          // ユーザーのユーザーID
          Long userId_user = user.getUserId();

          if (Objects.equals(userId_staff, userId_user)) {
            LcdReq29 lcdReq29 = new LcdReq29();
            lcdReq29.setUserId(staff.userId);
            //lcdReq29.setUserLastName(user.getUserLastName());
            //lcdReq29.setUserFirstName(user.getUserFirstName());
            // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
            // lcdReq29.setUserName(user.getUserName());
            // 姓名結合
            lcdReq29.setUserName(nameConcatService.NameConcat(user.getUserFirstName(), user.getUserLastName()));
            // #11827 2025.05.14 mod 仮想端末姓名結合設定に準拠 TDC米沢 start
            lcdReq29.setDispOrder(staff.no);

            // 戻り値用リストに格納
            lcdReq29List.add(lcdReq29);
          }
        }
      }
      } finally {
        nameConcatService.ClearFacilitySettingValue();
      }
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
    }
    return lcdReq29List;
  }

  /**
   * 仮想端末スタッフ一覧構造体
   * @author ntss
   *
   */
  private class Staff {
    int no;
    Long userId;
  }
}
