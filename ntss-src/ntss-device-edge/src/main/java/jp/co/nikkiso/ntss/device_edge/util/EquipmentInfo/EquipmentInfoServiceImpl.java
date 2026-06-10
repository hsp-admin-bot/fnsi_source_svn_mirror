package jp.co.nikkiso.ntss.device_edge.util.EquipmentInfo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.entity.MstEquipment;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 *  医療材料情報サービスの実装クラス.
 */
@Service
public class EquipmentInfoServiceImpl implements EquipmentInfoService {

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end

  /**
   * 医療材料情報のJSON文字列から医療材料情報クラスに展開します。
   * 【注意】指示の医療材料情報には各項目の名前や単位がないため、
   * 本クラスの各findメソッドを使用してマスタから引き当てて下さい。
   * @param equipmentInfoJsonString
   */
  @Override
  public List<EquipmentInfo> createEquipmentInfoList(String equipmentInfoJsonString) {
    List<EquipmentInfo> equipmentInfoList = new ArrayList<EquipmentInfo>();
    if (equipmentInfoJsonString != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode_parent = mapper.readTree(equipmentInfoJsonString);
        equipmentInfoList = this.setItems(jsonNode_parent);

      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
    }
    return equipmentInfoList;
  }

  /**
   * 格納されている医療材料分類コードをもとに医療材料分類マスタから医療材料分類名を検索し返します。
   * @param equipmentInfo
   * @return 医療材料分類名
   */
  @Autowired
  MstEquipmentClassDao mstEquipmentClassDao;

  @Override
  public String findClassName(EquipmentInfo equipmentInfo) {
    // 医療材料分類コード取得
    int classCd = equipmentInfo.getClassCd();
    // マスタから情報を取得
    MstEquipmentClass mstEquipmentClass = mstEquipmentClassDao.selectByCd(classCd);
    // 名称を返す
    return mstEquipmentClass.getClassName();
  }

  /**
   * 格納されている医療材料分類コードをもとに医療材料分類マスタから医療材料分類名を検索し返します。
   * @param equipmentInfoList
   * @return 医療材料分類名をセットした医療材料情報リスト
   */
  @Override
  public List<EquipmentInfo> findClassName(List<EquipmentInfo> equipmentInfoList) {
    // 戻り値用に引数をディープコピー
    List<EquipmentInfo> rtnList = new ArrayList<EquipmentInfo>(equipmentInfoList);

    // 医療材料分類コードのリストを取得
    List<Integer> classCdList = new ArrayList<Integer>();
    for (int lop = 0; lop < rtnList.size(); lop++) {
      EquipmentInfo equipInfo = rtnList.get(lop);
      int classCd = equipInfo.getClassCd();
      classCdList.add(classCd);
    }

    // マスタから情報を取得
    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectByCdList(classCdList);

    // 名称を引き当てる
    for (int equipLop = 0; equipLop < rtnList.size(); equipLop++) {
      EquipmentInfo buf_equip = rtnList.get(equipLop);
      // 分類コード取得
      int classCd_equip = buf_equip.getClassCd();

      for (int mstLop = 0; mstLop < mstEquipmentClassList.size(); mstLop++) {
        MstEquipmentClass buf_mst = mstEquipmentClassList.get(mstLop);
        int classCd_mst = buf_mst.getClassCd();
        if (classCd_equip == classCd_mst) {
          buf_equip.setClassName(buf_mst.getClassName());
          break;
        }
      }
    }

    return rtnList;
  }

  /**
   * 格納されている医療材料コードをもとに医療材料マスタから医療材料名、省略医療材料名、単位を検索し返します。
   * 戻り値のキー：name, shortName, unit
   * @param equipmentInfo
   * @return 医療材料名、省略医療材料名、単位を格納した連想配列
   */
  @Autowired
  MstEquipmentDao mstEquipmentDao;

  @Override
  public HashMap<String, String> findEquipmentName(EquipmentInfo equipmentInfo) {
    // 医療材料コード取得
    int equipCd = equipmentInfo.getCd();
    // マスタから情報を取得
    MstEquipment mstEquipment = mstEquipmentDao.selectByEquipmentCd(equipCd);
    // 名称を返す
    HashMap<String, String> rtn = new HashMap<String, String>();
    rtn.put("name", mstEquipment.getEquipmentName());
    rtn.put("shortName", mstEquipment.getEquipmentShortName());
    rtn.put("unit", mstEquipment.getUnit());

    return rtn;
  }

  /**
   * 格納されている医療材料コードをもとに医療材料マスタから医療材料名、省略医療材料名、単位を検索し返します。
   * @param equipmentInfoList
   * @return 医療材料名、省略医療材料名、単位ををセットした医療材料情報リスト
   */
  @Override
  public List<EquipmentInfo> findEquipmentName(List<EquipmentInfo> equipmentInfoList) {
    // 戻り値用に引数をディープコピー
    List<EquipmentInfo> rtnList = new ArrayList<EquipmentInfo>(equipmentInfoList);

    // 医療材料コードのリストを取得
    List<Integer> equipCdList = new ArrayList<Integer>();
    for (int lop = 0; lop < rtnList.size(); lop++) {
      EquipmentInfo equipInfo = rtnList.get(lop);
      int equipCd = equipInfo.getCd();
      equipCdList.add(equipCd);
    }

    // マスタから情報を取得
    List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectByCdList(SelectOptions.get(), equipCdList);

    // 名称を引き当てる
    for (int equipLop = 0; equipLop < rtnList.size(); equipLop++) {
      EquipmentInfo buf_equip = rtnList.get(equipLop);
      // コード取得
      int equipCd_equip = buf_equip.getCd();

      for (int mstLop = 0; mstLop < mstEquipmentList.size(); mstLop++) {
        MstEquipment buf_mst = mstEquipmentList.get(mstLop);
        int equipCd_mst = buf_mst.getEquipmentCd();
        if (equipCd_equip == equipCd_mst) {
          buf_equip.setName(buf_mst.getEquipmentName());
          buf_equip.setShortName(buf_mst.getEquipmentShortName());
          buf_equip.setUnit(buf_mst.getUnit());
          break;
        }
      }
    }

    return rtnList;
  }

  @Override
  public HashMap<String, String> findIndUserName(EquipmentInfo equipmentInfo) {
    // TODO 指示者姓名を返すメソッドを実装する
    return null;
  }

  @Override
  public List<EquipmentInfo> findIndUserName(List<EquipmentInfo> equipmentInfoList) {
    // TODO 指示者姓名を返すメソッドを実装する
    return null;
  }

  @Override
  public HashMap<String, String> findUpdUserName(EquipmentInfo equipmentInfo) {
    // TODO 更新者姓名を返すメソッドを実装する
    return null;
  }

  @Override
  public List<EquipmentInfo> findUpdUserName(List<EquipmentInfo> equipmentInfoList) {
    // TODO 更新者姓名を返すメソッドを実装する
    return null;
  }

  /****** プライベートメソッド *********/

  /**
   * JSONノードからEquipmentInfoクラスに展開して返します。
   * @param jsonNodeArray
   * @return
   */
  private List<EquipmentInfo> setItems(JsonNode jsonNodeArray) {
    List<EquipmentInfo> equipmentInfoList = new ArrayList<EquipmentInfo>();

    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
      EquipmentInfo equipInfo = new EquipmentInfo();

      JsonNode jsonNode = jsonNodeArray.get(lop);

      // 各キーのノードを取得
      JsonNode classCdNode = jsonNode.get("class_cd");
      JsonNode classNameNode = jsonNode.get("class_name");
      JsonNode classTypeNode = jsonNode.get("class_type");
      JsonNode cdNode = jsonNode.get("cd");
      JsonNode nameNode = jsonNode.get("name");
      JsonNode shortNameNode = jsonNode.get("shot_name");
      // del 10310 needle _ typeの使用を削除するには gjn start
      //JsonNode needleTypeNode = jsonNode.get("needle_type");
      // del 10310 needle _ typeの使用を削除するには gjn end
      JsonNode amountNode = jsonNode.get("amount");
      JsonNode unitNode = jsonNode.get("unit");
      JsonNode indUserIdNode = jsonNode.get("ind_user_id");
      JsonNode indUserLastNameNode = jsonNode.get("ind_user_last_name");
      JsonNode indUserFirstNameNode = jsonNode.get("ind_user_first_name");
      JsonNode updUserIdNode = jsonNode.get("upd_user_id");
      JsonNode updUserLastNameNode = jsonNode.get("upd_user_last_name");
      JsonNode updUserFirstNameNode = jsonNode.get("upd_user_first_name");
      JsonNode inputClassNode = jsonNode.get("input_class");
      JsonNode isEditableNode = jsonNode.get("is_editable");
      JsonNode copOrderNoNode = jsonNode.get("cop_order_no");

      // 医療材料クラスにセット
      equipInfo.setClassCd(Utilities.getIntJsonNode(classCdNode, null));
      equipInfo.setClassName(Utilities.getTextJsonNode(classNameNode, ""));
      equipInfo.setClassType(Utilities.getTextJsonNode(classTypeNode, ""));
      equipInfo.setCd(Utilities.getIntJsonNode(cdNode, null));
      equipInfo.setName(Utilities.getTextJsonNode(nameNode, ""));
      equipInfo.setShortName(Utilities.getTextJsonNode(shortNameNode, null));
      // del 10310 needle _ typeの使用を削除するには gjn start
      //equipInfo.setNeedleType(Utilities.getTextJsonNode(needleTypeNode, ""));
      // del 10310 needle _ typeの使用を削除するには gjn end
      equipInfo.setAmount(Utilities.getTextJsonNode(amountNode, ""));
      equipInfo.setUnit(Utilities.getTextJsonNode(unitNode, ""));
      equipInfo.setIndUserId(Utilities.getIntJsonNode(indUserIdNode, null));
      equipInfo.setIndUserLastName(Utilities.getTextJsonNode(indUserLastNameNode, ""));
      equipInfo.setIndUserFirstName(Utilities.getTextJsonNode(indUserFirstNameNode, ""));
      equipInfo.setUpdUserId(Utilities.getIntJsonNode(updUserIdNode, null));
      equipInfo.setUpdUserLastName(Utilities.getTextJsonNode(updUserLastNameNode, ""));
      equipInfo.setUpdUserFirstName(Utilities.getTextJsonNode(updUserFirstNameNode, ""));
      equipInfo.setInputClass(Utilities.getIntJsonNode(inputClassNode, null));
      equipInfo.setIsEditable(Utilities.getIntJsonNode(isEditableNode, null));
      equipInfo.setCopOrderNo(Objects.isNull(copOrderNoNode) ? null : copOrderNoNode.asLong());

      // 戻り値リストに追加
      equipmentInfoList.add(equipInfo);
    }

    return equipmentInfoList;
  }

}
