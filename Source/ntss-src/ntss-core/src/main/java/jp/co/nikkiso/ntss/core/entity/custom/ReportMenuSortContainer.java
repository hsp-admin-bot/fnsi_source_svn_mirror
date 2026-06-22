package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.DevMenteMainDto;
import lombok.Data;
import org.springframework.util.CollectionUtils;

import java.util.List;
import java.util.Map;

/**
 * 帳票メニュー
 */
@Data
public class ReportMenuSortContainer {

  /**
   * 患者IDのリスト
   */
  private List<Long> patIds;

  /**
   * 期間指定の場合の開始日
   * {@link ReportMenuSortContainer#isDialysisDate}によって設定される日付の意味が異なる.
   * <code>true</code>の場合、治療日を表す.
   * <code>false</code>の場合、検査日/処方日/紹介日を表す.
   */
  private String fromDate;

  /**
   * 期間指定の場合の終了日
   * {@link ReportMenuSortContainer#isDialysisDate}によって設定される日付の意味が異なる.
   * <code>true</code>の場合、治療日を表す.
   * <code>false</code>の場合、検査日/処方日/紹介日を表す.
   */
  private String toDate;

  /**
   * 特定日（治療日 or 検査日/処方日/紹介日）
   * {@link ReportMenuSortContainer#isDialysisDate}によって設定される日付の意味が異なる.
   * <code>true</code>の場合、治療日を表す.
   * <code>false</code>の場合、検査日/処方日/紹介日を表す.
   */
  private String specifyDate;

  /**
   * 治療日か否か.
   * - 紹介日/すべて：対象患者ID検索時はfalse、帳票生成処理呼出し時はtrue
   * true : 治療日 ／ false : 検査日/処方日
   */
  private Boolean isDialysisDate;

  // add #11226 患者情報系historyの取得条件見直し② limingzhe start
  public String dateKind;
  // add #11226 患者情報系historyの取得条件見直し② limingzhe end

  // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
  /**
   * 基準日（印刷情報用）
   */
  public String dateKindPrint;
  // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 帳票コード
   */
  private Long reportCd;

  /**
   * 帳票種別
   */
  private Integer reportClass;

  /**
   * 検査区分
   */
  private List<String> regOrderClassList;

  // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方区分」を追加 高 start
  /**
   * 処方区分
   * */
  private List<String> prescriptionClassList;
  // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方区分」を追加 高 end

  /**
   * 紹介区分
   * */
  private List<String> letterCategoryList;

  /**
   * 薬剤コードのリスト
   */
  private List<Integer> medicineCdList;

  /**
   * 医療材料コードのリスト
   */
  private List<Integer> equipmentCdList;

  // add #11603 検査予定のラベル出力とフィルタ機能 高 start
  /**
   * 検査セットコードのリスト
   */
  private List<Integer> examSetCdList;
  // add #11603 検査予定のラベル出力とフィルタ機能 高 end

  /**
   * 出力順
   */
  private List<Map<String, String>> sortCondition;

  /**
   * 帳票名
   */
  private String reportName;

  /**
   * プリンタコード
   */
  private Long printerCd;

  /**
   * ラベル開始位置
   */
  private Integer stPos;

  /*add FNSI-改修内容装置帳票の対応 任 start*/
  private List<DevMenteMainDto> machines;
  /*add FNSI-改修内容装置帳票の対応 任 end*/
  /**
   * 医療材料コードリストにダイアライザが含まれているか否か
   * @return true : 含まれている、false : 含まれていない
   */
  public Boolean isDialyzer() {
    // 医療材料コードリストがnullまたは空の場合
    return CollectionUtils.isEmpty(equipmentCdList) ? false : equipmentCdList.contains(0);
  }
  //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
  /**
   * フリーワード
   */
  private String freeWord;
  /**
   * 治療日
   */
  private String treatDate;
  /**
   * クール
   */
  private String kurCdList;
  /**
   *ベッド
   */
  private String bedCdListString;

  private List<String> expressCondCd;
  //add 6502 装置帳票：定期・日常が分離されていない 吉 start
  private String reportType;
  //add 6502 装置帳票：定期・日常が分離されていない 吉 end
  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 start
  private boolean reportFromFlag;
  // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 end
  //add 項目別(印刷情報一覧)の項目が実装されない  吉 end

  //add IES因島）sql性能試験 後で削除 liuc start
  // タイムスタンプstr
  private String sqlTestTimeStr;
  //add IES因島）sql性能試験 後で削除 liuc end

  // add #9323 donghao start
  private int pageIndex;
  // add #9323 donghao end

  // add 11010 スケジュール表出力時の処理が不足している gjn start
  private List<Long> kurList;

  private List<Long> bedCdList;
  // add 11010 スケジュール表出力時の処理が不足している gjn end

  // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
  public List<Integer> inspectionCdList;
  // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end

  // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
  /**
   * 開始日～終了日
   */
  private String period;

  /**
   * 週数　n週目、で出力
   */
  private String weeks;

  /**
   * 種別 出力条件でいずれか選択されていたら「医療材料・薬剤」
   */
  private String kind;

  /**
   * 医療材料分類　すべて、または明細を「・」で連結
   */
  private String equipmentType;

  /**
   * 薬剤分類　すべて、または明細を「・」で連結
   */
  private String medicineType;

  // add #11603 検査予定のラベル出力とフィルタ機能 高 start
  /**
   * 検査セット分類
   */
  private String examSetType;
  // add #11603 検査予定のラベル出力とフィルタ機能 高 end

  /**
   * 検査分類
   */
  private String inspectionType;

  /**
   * 検査日数指定基準日
   */
  private String inspectionDate;

  /**
   * 検査出力方向
   */
  private String inspectionDirection;

  /**
   * 検査出力日数
   */
  private String inspectionDays;

  /**
   * 検査区分
   */
  private String inspectionKbn;

  // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
  /**
   * 処方区分
   */
  private String prescriptionKbn;

  /**
   * 処方区分
   */
  private String introductionKbn;
  // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
  /**
   * 患者グループ
   */
  private String patGroups;

  /**
   * 第1優先情報
   */
  private String sortColumn1;

  /**
   * 第1優先昇順/降順
   */
  private String sortOrder1;

  /**
   * 第2優先情報
   */
  private String sortColumn2;

  /**
   * 第2優先昇順/降順
   */
  private String sortOrder2;

  /**
   * 第3優先情報
   */
  private String sortColumn3;

  /**
   * 第3優先昇順/降順
   */
  private String sortOrder3;

  /**
   * 選択を連結「予定・実績」
   */
  private String expressCondCdStr;

  /**
   * すべて、または選択クールを「・」で連結
   */
  private String kurNames;

  /**
   * ログイン者
   */
  private String login;
  // add 11009 カテゴリ「印刷情報」の仕様調整 房 end


}
