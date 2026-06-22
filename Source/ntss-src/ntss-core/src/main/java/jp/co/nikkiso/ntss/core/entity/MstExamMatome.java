package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;

/**
 * mst_exam_item(検査項目マスタ)のエンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_exam_matome")
@Getter
@Setter
public class MstExamMatome extends BaseEntity{
  /**
   * JLAC10ｺｰﾄﾞ（１７桁）
   */
  private String examMatomeCd;

  /**
   * 変更区分
   */
  private BigDecimal updateType;

  /**
   * JLAC10ｺｰﾄﾞ（１5/17桁）
   */
  private String examMatomeEarlyCd;

  /**
   * 分析物（拡張）
   */
  private String analyticalMaterial;

  /**
   * 分析物（コード）
   */
  private String analyticalMaterialCd;

  /**
   * 分析物（名称）
   */
  private String analyticalMaterialName;

  /**
   * 識別（拡張）
   */
  private String identify;

  /**
   * 識別（コード）
   */
  private BigDecimal identifyCd;

  /**
   * 識別（名称）
   */
  private String identifyName;

  /**
   * 材料（拡張）
   */
  private String material;

  /**
   * 材料（コード）
   */
  private BigDecimal materialCd;

  /**
   * 材料（名称）
   */
  private String materialName;

  /**
   * 測定法（拡張）
   */
  private String assay;

  /**
   * 測定法（コード）
   */
  private BigDecimal assayCd;

  /**
   * 測定法（名称）
   */
  private String assayName;

  /**
   * 結果識別（共通）（拡張）
   */
  private String resultRecognitionCommon;

  /**
   * 結果識別（共通）（コード）
   */
  private BigDecimal resultRecognitionCommonCd;

  /**
   * 結果識別（共通）（名称）
   */
  private String resultRecognitionCommonName;

  /**
   * 結果識別（固有）（拡張）
   */
  private String resultRecognitionInherent;

  /**
   * 結果識別（固有）（名称）
   */
  private String resultRecognitionInherentName;

  /**
   * 結果識別検索子（分析物＋識別＋結果）
   */
  private String resultIdentificationSearcher;

  /**
   * 標準検査名称
   */
  private String standardInspectionName;

  /**
   * 参考（結果識別コード）
   */
  private BigDecimal referenceResultIdentificationCd;

  /**
   * 参考（単位）
   */
  private String referenceUnit;

  /**
   * 保険内
   */
  private String insured;

  /**
   * 診療行為コード
   */
  private BigDecimal medicalPracticeCd;

  /**
   * 診療行為名称１（旧名称）
   */
  private String medicalPracticeName1;

  /**
   * 診療行為名称２
   */
  private String medicalPracticeName2;

  /**
   * 点数
   */
  private BigDecimal points;

  /**
   * 章
   */
  private String chapter;

  /**
   * 区分番号
   */
  private BigDecimal categoryNumber;

  /**
   * 項番
   */
  private BigDecimal itemNumber;

  /**
   * 更新年月日
   */
  private BigDecimal updateDate;
}
