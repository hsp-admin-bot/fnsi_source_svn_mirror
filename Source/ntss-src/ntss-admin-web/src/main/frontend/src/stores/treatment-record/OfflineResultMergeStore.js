/**
 * 治療記録 オフライン実績情報マージストア
 */
import { sendOfflineTreatResultMerge } from "@/apis/treatment-record";
import { getScopedDocument, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

export default {
  strict: true,
  namespaced: true,
  state: {
  },
  getters: {
  },
  mutation: {
  },
  actions: {
    /**
     * オフライン実績ファイル取得
     */
    selectOfflineResult() {
      // ファイル選択
      return new Promise(resolve =>{
        const input = getScopedDocument()?.createElement("input");
        if (!input) {
          resolve(null);
          return;
        }
        input.type = "file";
        input.accept = ".bptxt";
        input.onchange = event => { resolve(event.target.files[0]);};
        input.click();
      });
    },
    /**
     * オフライン実績ファイル取得してマージ
    */
    async mergeOfflineResult( content, { ordNo, file } ) {
      if( file ) {
        return new Promise( (resolve, reject) =>{
          // オフライン実績ファイル取得
          const scopedWindow = getScopedWindow();
          const FileReaderCtor = scopedWindow?.FileReader || FileReader;
          const reader = new FileReaderCtor();
          reader.readAsText(file);

          // 読み込み完了
          reader.onload = () => {
            const info = reader.result;
            // 情報を登録
            //alert(info);
            sendOfflineTreatResultMerge( ordNo, info ).then(() => {
              // 更新成功
              resolve(true);
            }).catch(error => {
              // 更新失敗
              reject(error);
            });

          };

          // 読み込み失敗
          reader.onerror = error => {
            reject(error);
          }
        });
      }
      return false;
    }
  }
};
