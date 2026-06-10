package jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat;

import java.util.List;

import lombok.Data;

/**
 * pat_personal_main検索条件
 */
@Data
public class PatPersonalMainDetailedConditions {
  // 院内ID
  private String hospPatId;
  // 患者名・カナ
  private String patName;
  // カナ頭文字(行)を表す文字列のリスト
  private List<String> nameInitialList;
  // 性別のリスト
  private List<Integer> patSex;
  // 年齢(下限)
  private Integer ageLower;
  // 年齢(上限)
  private Integer ageUpper;
  // 血液型のリスト
  private List<Integer> bloodTypeAboList;
  // 血液型Rhのリスト
  private List<Integer> bloodTypeRhList;
  // 血液型亜型のリスト
  private List<Integer> bloodTypeSerovarList;
  // 入外区分のリスト
  private List<Integer> inOutClassList;
  //add no338 透析困難 start 劉全航
  private String isDialDiff;
  //add no338 透析困難 end 劉全航
  private Integer severityCd;
  //add no338 搬送区分 start 劉全航
  private Integer transportCd;
  //add no338 搬送区分 end 劉全航
  //add no338 連絡先情報 start 張岩
  // 連絡先情報．姓
  private String lastName;
  // 連絡先情報．名
  private String firstName;
  // 連絡先情報．セイ
  private String lastNameKana;
  // 連絡先情報．メイ
  private String firstNameKana;
  // 連絡先情報．続柄コード
  private Integer relationCd;
  // 連絡先情報．続柄名
  private String relationName;
  // 業者連絡先情報.会社名
  private String companyName;
  // 業者連絡先情報.担当者姓
  private String workerLastName;
  // 業者連絡先情報.担当者名
  private String workerFirstName;
  //add no338 連絡先情報 end 張岩
  //mod 患者詳細検索bug修正 start
  private boolean conditionIsEmpty;
  //mod 患者詳細検索bug修正 end
}

