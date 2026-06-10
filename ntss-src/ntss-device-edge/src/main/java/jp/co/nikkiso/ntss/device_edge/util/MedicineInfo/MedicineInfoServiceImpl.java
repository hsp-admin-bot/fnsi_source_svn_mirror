package jp.co.nikkiso.ntss.device_edge.util.MedicineInfo;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Objects;

import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.device_edge.util.Utilities;

/**
 *  薬剤情報サービスの実装クラス.
 */
@Service
public class MedicineInfoServiceImpl implements MedicineInfoService {

  /**
   * 薬剤情報のJSON文字列から薬剤情報クラスに展開します。
   * 【注意】指示の薬剤情報には各項目の名前や単位がないため、
   * 本クラスの各findメソッドを使用してマスタから引き当てて下さい。
   * @param medicineInfoJsonString
   */
  @Override
  public List<MedicineInfo> createMedicineInfoList(String medicineInfoJsonString) {
    List<MedicineInfo> medicineInfoList = new ArrayList<MedicineInfo>();
    if (medicineInfoJsonString != null) {
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode jsonNode_parent = mapper.readTree(medicineInfoJsonString);
        medicineInfoList = this.setItems(jsonNode_parent);

      } catch (IOException e) {
      }
    }
    return medicineInfoList;
  }

  @Autowired
  MstMedicineClassDao mstMedicineClassDao;

  /**
   * 格納されている薬剤分類コードをもとに薬剤分類マスタから薬剤分類名を検索し返します。
   * @param medicineInfo
   * @return 薬剤分類名
   */
  @Override
  public String findClassName(MedicineInfo medicineInfo) {
    // 薬剤分類コード取得
    int classCd = medicineInfo.getClassCd();
    // マスタから情報を取得
    MstMedicineClass mstMedicineClass = mstMedicineClassDao.selectByCd(classCd);
    // 名称を返す
    return mstMedicineClass.getClassName();
  }

  /**
   * 格納されている薬剤分類コードをもとに薬剤分類マスタから薬剤分類名を検索し返します。
   * @param medicineInfoList
   * @return 薬剤分類名をセットした薬剤情報リスト
   */
  @Override
  public List<MedicineInfo> findClassName(List<MedicineInfo> medicineInfoList) {
    // 戻り値用に引数をディープコピー
    List<MedicineInfo> rtnList = new ArrayList<MedicineInfo>(medicineInfoList);

    // 薬剤分類コードのリストを取得
    List<Integer> classCdList = new ArrayList<Integer>();
    for (int lop = 0; lop < rtnList.size(); lop++) {
      MedicineInfo mediInfo = rtnList.get(lop);
      int classCd = mediInfo.getClassCd();
      classCdList.add(classCd);
    }

    // マスタから情報を取得
    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectByCdList(classCdList);

    // 名称を引き当てる
    for (int mediLop = 0; mediLop < rtnList.size(); mediLop++) {
      MedicineInfo buf_medi = rtnList.get(mediLop);
      // 分類コード取得
      int classCd_medi = buf_medi.getClassCd();

      for (int mstLop = 0; mstLop < mstMedicineClassList.size(); mstLop++) {
        MstMedicineClass buf_mst = mstMedicineClassList.get(mstLop);
        int classCd_mst = buf_mst.getClassCd();
        if (classCd_medi == classCd_mst) {
          buf_medi.setClassName(buf_mst.getClassName());
          break;
        }
      }
    }

    return rtnList;
  }

  @Autowired
  MstMedicineDao mstMedicineDao;

  /**
   * 格納されている薬剤コードをもとに薬剤マスタから薬剤名、省略薬剤名、単位を検索し返します。
   * 戻り値のキー：name, shortName, unit
   * @param medicineInfo
   * @return 薬剤名、省略薬剤名、単位を格納した連想配列
   */
  @Override
  public HashMap<String, String> findMedicineName(MedicineInfo medicineInfo) {
    // 薬剤コード取得
    int medicineCd = medicineInfo.getCd();
    // マスタから情報を取得
    MstMedicine mstMedicine = mstMedicineDao.selectByMediCd(medicineCd);
    // 名称を返す
    HashMap<String, String> rtn = new HashMap<String, String>();
    rtn.put("name", mstMedicine.getMedicineName());
    rtn.put("shortName", mstMedicine.getMedicineShortName());
    rtn.put("unit", mstMedicine.getUnit());

    return rtn;
  }

  /**
   * 格納されている薬剤コードをもとに薬剤マスタから薬剤名、省略薬剤名、単位を検索し返します。
   * @param medicineInfoList
   * @return 薬剤名、省略薬剤名、単位ををセットした薬剤情報リスト
   */
  @Override
  public List<MedicineInfo> findMedicineName(List<MedicineInfo> medicineInfoList) {
    // 戻り値用に引数をディープコピー
    List<MedicineInfo> rtnList = new ArrayList<MedicineInfo>(medicineInfoList);

    // 薬剤コードのリストを取得
    List<Integer> mediCdList = new ArrayList<Integer>();
    for (int lop = 0; lop < rtnList.size(); lop++) {
      MedicineInfo mediInfo = rtnList.get(lop);
      int equipCd = mediInfo.getCd();
      mediCdList.add(equipCd);
    }

    // マスタから情報を取得
    List<MstMedicine> mstMedicineList = mstMedicineDao.selectAllByCdList(SelectOptions.get(), mediCdList);

    // 名称を引き当てる
    for (int mediLop = 0; mediLop < rtnList.size(); mediLop++) {
      MedicineInfo buf_medi = rtnList.get(mediLop);
      // コード取得
      int mediCd_medi = buf_medi.getCd();

      for (int mstLop = 0; mstLop < mstMedicineList.size(); mstLop++) {
        MstMedicine buf_mst = mstMedicineList.get(mstLop);
        int mediCd_mst = buf_mst.getMedicineCd();
        if (mediCd_medi == mediCd_mst) {
          buf_medi.setName(buf_mst.getMedicineName());
          buf_medi.setShortName(buf_mst.getMedicineShortName());
          buf_medi.setUnit(buf_mst.getUnit());
          break;
        }
      }
    }

    return rtnList;
  }

  /**
   * 格納されている指示者コードをもとに利用者マスタから姓・名を検索し返します。
   * 戻り値のキー：lastName, firstName
   * @param medicineInfo
   * @return 指示者姓名を格納した連想配列
   */
  @Override
  public HashMap<String, String> findIndUserName(MedicineInfo medicineInfo) {
    // TODO 指示者姓名を返すメソッドを実装する
    return null;
  }

  /**
   * 格納されている指示者コードをもとに利用者マスタから姓・名を検索し返します。
   * @param medicineInfoList
   * @return 指示者姓名をセットした薬剤情報リスト
   */
  @Override
  public List<MedicineInfo> findIndUserName(List<MedicineInfo> medicineInfoList) {
    // TODO 指示者姓名を返すメソッドを実装する
    return null;
  }

  /**
   * 格納されている更新者コードをもとに利用者マスタから姓・名を検索し返します。
   * 戻り値のキー：lastName, firstName
   * @param medicineInfo
   * @return 更新者姓名を格納した連想配列
   */
  @Override
  public HashMap<String, String> findUpdUserName(MedicineInfo medicineInfo) {
    // TODO 更新者姓名を返すメソッドを実装する
    return null;
  }

  /**
   * 格納されている更新者コードをもとに利用者マスタから姓・名を検索し返します。
   * @param medicineInfoList
   * @return 更新者姓名をセットした薬剤情報リスト
   */
  @Override
  public List<MedicineInfo> findUpdUserName(List<MedicineInfo> medicineInfoList) {
    // TODO 更新者姓名を返すメソッドを実装する
    return null;
  }

  /****** プライベートメソッド *********/

  /**
   * JSONノードからMedicineInfoクラスに展開して返します。
   * @param jsonNodeArray
   * @return
   */
  private List<MedicineInfo> setItems(JsonNode jsonNodeArray) {
    List<MedicineInfo> medicineInfoList = new ArrayList<MedicineInfo>();

    for (int lop = 0; lop < jsonNodeArray.size(); lop++) {
      MedicineInfo equipInfo = new MedicineInfo();

      JsonNode jsonNode = jsonNodeArray.get(lop);

      // 各キーのノードを取得
      JsonNode classCdNode = jsonNode.get("class_cd");
      JsonNode classNameNode = jsonNode.get("class_name");
      JsonNode classTypeNode = jsonNode.get("class_type");
      JsonNode cdNode = jsonNode.get("cd");
      JsonNode nameNode = jsonNode.get("name");
      JsonNode shortNameNode = jsonNode.get("shot_name");
      JsonNode amountNode = jsonNode.get("amount");
      JsonNode unitNode = jsonNode.get("unit");
      JsonNode timingCdNode = jsonNode.get("timing_cd");
      JsonNode timingNameNode = jsonNode.get("timing_name");
      JsonNode procedureCdNode = jsonNode.get("procedure_cd");
      JsonNode procedureNameNode = jsonNode.get("procedure_name");
      JsonNode commentNode = jsonNode.get("comment");
      // del #11160 【総合検証NG】投与薬剤ありで条件送信すると装置で透析日報が表示されない zkm start
//      JsonNode indUserIdNode = jsonNode.get("ind_user_id");
//      JsonNode indUserLastNameNode = jsonNode.get("ind_user_last_name");
//      JsonNode indUserFirstNameNode = jsonNode.get("ind_user_first_name");
//      JsonNode updUserIdNode = jsonNode.get("upd_user_id");
//      JsonNode updUserLastNameNode = jsonNode.get("upd_user_last_name");
//      JsonNode updUserFirstNameNode = jsonNode.get("upd_user_first_name");
      // del #11160 【総合検証NG】投与薬剤ありで条件送信すると装置で透析日報が表示されない zkm end
      JsonNode inputClassNode = jsonNode.get("input_class");
      JsonNode isEditableNode = jsonNode.get("is_editable");
      JsonNode copOrderNoNode = jsonNode.get("cop_order_no");
      JsonNode effectFlgNode = jsonNode.get("effect_flg");
      JsonNode effectDateNode = jsonNode.get("effect_date");
      JsonNode effectUserIdNode = jsonNode.get("effect_user_id");
      JsonNode effectUserLastNameNode = jsonNode.get("effect_user_last_name");
      JsonNode effectUserFirstNameNode = jsonNode.get("effect_user_first_name");

      // 薬剤クラスにセット
      equipInfo.setClassCd(Utilities.getIntJsonNode(classCdNode, null));
      equipInfo.setClassName(Utilities.getTextJsonNode(classNameNode, ""));
      equipInfo.setClassType(Utilities.getTextJsonNode(classTypeNode, ""));
      equipInfo.setCd(Utilities.getIntJsonNode(cdNode, null));
      equipInfo.setName(Utilities.getTextJsonNode(nameNode, ""));
      equipInfo.setShortName(Utilities.getTextJsonNode(shortNameNode, null));
      equipInfo.setAmount(Utilities.getTextJsonNode(amountNode, ""));
      equipInfo.setUnit(Utilities.getTextJsonNode(unitNode, ""));
      equipInfo.setTimingCd(Utilities.getIntJsonNode(timingCdNode, null));
      equipInfo.setTimingName(Utilities.getTextJsonNode(timingNameNode, ""));
      equipInfo.setProcedureCd(Utilities.getIntJsonNode(procedureCdNode, null));
      equipInfo.setProcedureName(Utilities.getTextJsonNode(procedureNameNode, ""));
      equipInfo.setComment(Utilities.getTextJsonNode(commentNode, ""));
      // del #11160 【総合検証NG】投与薬剤ありで条件送信すると装置で透析日報が表示されない zkm start
//      equipInfo.setIndUserId(Utilities.getIntJsonNode(indUserIdNode, null));
//      equipInfo.setIndUserLastName(Utilities.getTextJsonNode(indUserLastNameNode, ""));
//      equipInfo.setIndUserFirstName(Utilities.getTextJsonNode(indUserFirstNameNode, ""));
//      equipInfo.setUpdUserId(Utilities.getIntJsonNode(updUserIdNode, null));
//      equipInfo.setUpdUserLastName(Utilities.getTextJsonNode(updUserLastNameNode, ""));
//      equipInfo.setUpdUserFirstName(Utilities.getTextJsonNode(updUserFirstNameNode, ""));
      // del #11160 【総合検証NG】投与薬剤ありで条件送信すると装置で透析日報が表示されない zkm end
      equipInfo.setInputClass(Utilities.getIntJsonNode(inputClassNode, null));
      equipInfo.setIsEditable(Utilities.getIntJsonNode(isEditableNode, null));
      equipInfo.setCopOrderNo(Objects.isNull(copOrderNoNode) ? null : copOrderNoNode.asLong());
      equipInfo.setEffectFlg(Utilities.getIntJsonNode(effectFlgNode, null));
      equipInfo.setEffectDate(Utilities.dateStringToDate_iso8601(effectDateNode.asText()));
      equipInfo.setEffectUserId(Utilities.getIntJsonNode(effectUserIdNode, null));
      equipInfo.setEffectUserLastName(Utilities.getTextJsonNode(effectUserLastNameNode, ""));
      equipInfo.setEffectUserFirstName(Utilities.getTextJsonNode(effectUserFirstNameNode, ""));

      // 戻り値リストに追加
      medicineInfoList.add(equipInfo);
    }

    return medicineInfoList;
  }

}
