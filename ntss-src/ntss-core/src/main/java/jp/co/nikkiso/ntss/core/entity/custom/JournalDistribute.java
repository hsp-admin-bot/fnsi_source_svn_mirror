package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class JournalDistribute extends BaseEntity {
  /** 施設コード */
  private String facilityCd;
  /** 管理番号 */
  private Long ctlNo;
  /** 電文種別 */
  private String coopCd;
  /** IBM向け_電文付帯情報 */
  private String coopCdIndex;
  // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 start
  /** 作成更新区分 */
  private String crud;
  // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 end
  /** オーダ番号 */
  private Long ordNo;
  // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 start
  /** （連携先)オーダ番号 */
  private String coopOrdNo;
  // add 2020-12-14 FNSI-改修 外部連携720(「修正」のデータは複数作られた場合、最新のデータだけ配信する) 夏 end
  /** 患者番号(連携用) */
  private String hospPatId;
  /** 患者番号(システム) */
  private Long patId;
  /** 送信電文パス */
  private String dumpPath;
  /** 送信電文 */
  private byte[] dump;
  /** 変換処理結果 */
  private String anaResult;
  /** 通信結果 */
  private String coopResult;
  /** 配信設定 */
  private String distributeSetting;
  /** 配信処理終了日時 */
  private Timestamp inAnaDate;
  /** 変換処理完了日時 */
  private Timestamp outAnaDate;
  /** 配信処理開始日時 */
  private Timestamp inRegDate;
  /** 変換処理開始日時 */
  private Timestamp outRegDate;
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
  /** 基準日 */
  private String baseDate;
  // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
  // add bug 7351 ope_cd 追加 chen start
  /** 操作番号 */
  private String opeCd;
  // add bug 7351 ope_cd 追加 chen end
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /** 連携版番号 */
  private String coopVersion;
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  /** 再送カウント */
  private int retryCnt;
}
