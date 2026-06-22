package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord.mergeHandler;

import jp.co.nikkiso.ntss.core.entity.OrdMain;

/**
 * 実績マージチェーン処理
 *
 * @author Tao.zhou
 * @since 2024-04-03
 */
public abstract class TreatmentRecordMergeChainHandler {

  /** 実績マージのベースデータ */
  protected OrdMain baseOrdMainData;

  protected int chgBaseRdsCons = 0;

  /** 実績マージのマージデータ */
  protected OrdMain mergeOrdMainData;

  protected int chgMergeRdsCons = 0;

  /** 各継承オブジェクトが保持する参照 */
  protected TreatmentRecordMergeChainHandler successor;

  /** 継承オブジェクト設定する */
  public TreatmentRecordMergeChainHandler setSuccessor(TreatmentRecordMergeChainHandler successor) {
    this.successor = successor;
    // Data needs to be passed on.
    this.successor.setBaseOrdMainData(this.getBaseOrdMainData())
      .setMergeOrdMainData(this.getMergeOrdMainData());
    this.successor.setChgBaseRdsCons(this.getChgBaseRdsCons());
    this.successor.setChgMergeRdsCons(this.getChgMergeRdsCons());
    // For chain
    return this.successor;
  }

  /** 継承オブジェクトを取得 */
  public TreatmentRecordMergeChainHandler getSuccessor() {
    return this.successor;
  }

  /** ベースデータを取得 */
  public OrdMain getBaseOrdMainData() {
    return baseOrdMainData;
  }

  /** マージデータを取得 */
  public OrdMain getMergeOrdMainData() {
    return mergeOrdMainData;
  }

  /** ベースデータを設定する */
  public TreatmentRecordMergeChainHandler setBaseOrdMainData(OrdMain baseOrdMainData) {
    this.baseOrdMainData = baseOrdMainData;
    return this;
  }

  /** マージデータを設定する */
  public TreatmentRecordMergeChainHandler setMergeOrdMainData(OrdMain mergeOrdMainData) {
    this.mergeOrdMainData = mergeOrdMainData;
    return this;
  }

  public int getChgBaseRdsCons() {
    return chgBaseRdsCons;
  }

  public void setChgBaseRdsCons(int chgBaseRdsCons) {
    this.chgBaseRdsCons = chgBaseRdsCons;
  }

  public int getChgMergeRdsCons() {
    return chgMergeRdsCons;
  }

  public void setChgMergeRdsCons(int chgMergeRdsCons) {
    this.chgMergeRdsCons = chgMergeRdsCons;
  }

  /** 最終チェーン構造の組み立て後の実行方法 */
  public abstract void execute();
}
