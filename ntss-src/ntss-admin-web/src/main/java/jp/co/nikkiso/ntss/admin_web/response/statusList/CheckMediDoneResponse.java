package jp.co.nikkiso.ntss.admin_web.response.statusList;

import java.io.IOException;
import java.util.Objects;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@Getter
@Setter
public class CheckMediDoneResponse extends FlagAndMessageBaseResponse {
  /**
   * オーダー番号.
   */
  public Long ordNo;
  /**
   * 投薬実施フラグ
   */
  public boolean isMediDone;

  //add 実績確定修正 房 start
  public String rstMediInfo;
  //add 実績確定修正 房 end

  //add 実績確定修正 徐 start
  public String rstKurName;
  //add 実績確定修正 徐 end

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public CheckMediDoneResponse(String errorMessage) {
    super(errorMessage);
  }

  // Setter
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
  public void setIsMediDone(String mediInfo) throws IOException {
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
    if (!Objects.equals(mediInfo, "") && mediInfo != null) {
      // JSON配列パース
      boolean isDone = true;
      ObjectMapper mapper = new ObjectMapper();
      try {
        JsonNode nodeArray = mapper.readTree(mediInfo);
        // 各薬剤の実施状況を確認
        for (int lop = 0; lop < nodeArray.size(); lop++) {
          JsonNode mediNode = nodeArray.get(lop);
          JsonNode effectFlg_node = mediNode.get("effect_flg");
          int effectFlg = 0;
          if(effectFlg_node!=null){
            effectFlg = effectFlg_node.asInt();
          }
          // 未実施が1件でもある場合はフィールド値をFalseにし、ループを抜ける
          if (effectFlg == 0) {
            isDone = false;
            break;
          }
        }
      } catch (IOException e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
        throw e;
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
      }

      this.isMediDone = isDone;
    }
  }


  /**
   * 実績：治療方法コード
   */
  public Integer rstTreatmentCd;
}
