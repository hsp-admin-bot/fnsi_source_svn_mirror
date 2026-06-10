<template>
  <div class='main-content-area'>
    <div class='weight-input-area' :style="areaHeightStyle">
      <div class="message-label">
        <label>{{ msg }}</label>
        <br>
        <label>{{ msg2 }}</label>
      </div>
      <div class='weight-input'>
        <div class="weight-input-label" style="background-color: darkorange;">
          <label>後体重を入力</label>
        </div>
        <div>
          <v-ons-input class = "weight-input-text" modifier="weight" type = 'text' pattern="^([1-9]\d*|0)(\.\d+)?$" step="0.01" required
            v-model="afterWeight"
          >
          </v-ons-input>
        </div>
        <div class= "weight-kg-text">
          kg
        </div>
      </div>
    </div>

    <div class="bottom-buttons">
      <v-ons-button class="button process-button" @click="prev">戻る</v-ons-button>
      <v-ons-button class="button process-button" @click="next">送信</v-ons-button>
    </div>
    <v-ons-modal :visible="isVisible" :class="fontSizeSet">
      <div>
      <transition name="modal">
        <div class="modal-mask">
          <div class="modal-wrapper">
            <div class="weight-modal-container">
              <div class="modal-header">
                <ons-toolbar style="
                margin: auto; background: #a9a9a9;">
                <div class="left toolbar__title">
                  <span></span>
                </div>
                <div class="right">
                  <ons-toolbar-button class="close-btn print-none">
                    <ons-icon></ons-icon>
                  </ons-toolbar-button>
                </div>
                </ons-toolbar>
              </div>
              <div class="modal-body">
                <label class = "loading-modal">{{checkMsg}}</label>
                <div />
                <label class = "loading-modal">{{checkMsg2}}</label>
              </div>
              <div class="weight-modal-footer">
                <v-ons-button class="button end-button" @click="end" v-if="isButtonVisible">終了</v-ons-button>
              </div>
            </div>
          </div>
        </div>
      </transition>
      </div>
    </v-ons-modal>
    <message-dialog
    v-if="isCheckDialogVisible"
    :visible.sync="isCheckDialogVisible"
    :message-cd="messageCd"
    :string-params="stringParams"
    type="1"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

export default {
  mixins: [MasterMaintenanceMixin],
  components: {
    "message-dialog": messageDialog
  },
  data() {
    return {
      // 表示領域の高さ
      areaHeight: 700,
      // 表示領域の幅
      areaWidth: 550,
      // メインメッセージ
      msg: "後血圧は" ,
      msg2:"測定しましたか？",
      afterWeight: null,
      isCheckDialogVisible: false,
      stringParams: null,
      messageCd: null,
      checkMsg: "",
      checkMsg2: "病院へデータを送っています・・・",
      // タイマー待機モーダルフラグ
      modalFlg: false,
      // タイマー待機モーダルボタン表示制御
      modalButtonFlg : false,
      // タイマーID
      timerId: 0,
      // タイマーカウンター
      timerCount: 0,
      // 治療情報-結果体重JSON
      rstWeightInfo: null,
      // 治療情報-Ord_no
      ordNo: null
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", [ "getStateUserAccountInfo" ]),
    ...mapGetters("pat-info", {
      headerPatId: "selectedPatId"
    }),
    // 表示領域の高さをCSS変数を利用して書き換える
    areaHeightStyle() {
      return { "height": `${this.areaHeight}px` };
    },
    // 表示領域の幅をCSS変数を利用して書き換える
    areaWidthStyle() {
      return { "width": `${this.areaWidth}px` };
    },
    isVisible() {
      return this.modalFlg;
    },
    isButtonVisible(){
      return this.modalButtonFlg;
    },
  },
  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),

    ...mapActions("pat-info", [ "selectPat" ]),
    ...mapMutations("pat-info", {
      setPat: "setSelectedPat",
      setIsLoadingPat: "setIsLoadingPat"
    }),

    // 患者情報ヘッダーに表示する患者を設定する
    async setHeaderPatId(patId) {
      this.setIsLoadingPat(true);
      this.setPat(null);
      await this.selectPat(patId).catch(() => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatHomeDialysisWeightAfterComponent.vue', 'setHeaderPatId', '患者選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // TODO: エラー処理検討
        throw new Error("[PatHomeDialysisStatusComponent.vue]setHeaderPatId(): 患者選択失敗");
      });
      this.setIsLoadingPat(false);
    },

    // ウインドウ変更時の高さ、幅を調整
    calculateSize() {
      // ヘッダーの高さ
      const header = document.getElementsByClassName("header");
      let headerHeight = 0;
      if (header.length !== 0) {
        // フッター分 35px
        headerHeight = header[0].offsetHeight + 35;
      }
      // 下部ボタン部の高さ
      const bottomButtons = document.getElementsByClassName("bottom-buttons");
      // console.log(bottomButtons[0].offsetHeight);
      // 下部ボタン部のmargin：35px
      let bottomButtonsHeight = 35;
      if (bottomButtons.length !== 0) {
        bottomButtonsHeight += bottomButtons[0].offsetHeight;
      }
      // main-content-area の margin：5px
      this.areaHeight = this.windowHeight - headerHeight - bottomButtonsHeight -15;
    },
    prev() {
      this.$router.push({ name: "pat-home-dialysis-status" });
    },
    async next() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 1.入力値有効チェック
      if (!this.isNumericErrCheck()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      //データ送信中ダイアログを表示開始
      this.modalFlg = true;
      this.setLoadingScreenVisible(false);

      // 2.治療情報テーブル 対象データ存在チェック
      if(!await this.orderMainCheck()){
        // 共通：表示終了
        this.modalFlg = false;
        // 日付跨ぎで発生した場合のエラーをどうするか？
        this.isCheckDialogVisible = true;
        this.messageCd = 75000005;
        this.stringParams = [""];
        return;
      }

      // 3.体重情報更新
      try{
        await ApiHelper.post(`/pat_home_dialysis/saveWeightAfter`,
        {
          ordNo: this.ordNo,
          weightAfter: this.afterWeight
        })
      }catch(e){
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatHomeDialysisWeightAfterComponent.vue', 'next', e);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // 共通：表示終了
        this.modalFlg = false;
        console.error(e);
        throw e;
      }

      //4.処理完了:メッセージ変更
      this.modalButtonFlg = true;
      this.checkMsg = "これで終わりです。";
      this.checkMsg2 = "お疲れさまでした。";

    },
    // ダイアログ閉じた場合の処理
    end(){
      this.$router.push({ name: "pat-home-dialysis" });
    },


    /**
     * @description 数値項目有効チェック
     * @summary 各入力項目ごとの数値に有効外の値があればダイアログを表示する
     * @returns {Boolean} true: 有効外なし, false: 有効外あり
    */
    isNumericErrCheck(){
      //1.入力必須チェック
      if(!this.afterWeight){
          this.isCheckDialogVisible = true;
          this.messageCd = 75000001;
          this.stringParams = ["後体重"];
          return false;
      }
      //2.入力値：数値チェック
      if(!this.isNumber(this.afterWeight)){
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["後体重"];
          return false;
      }
      //3.入力値：入力範囲内チェック
      if(0 >= Number(this.afterWeight)){
          //0より小さい値の場合
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["後体重"];
          return false;
      }
      //4.入力値：小数点分解チェック
      let splitResult = this.afterWeight.split('.');
      //文字列の整数部を数値変換して絶対値取得をし、String変換で桁数を取得し、それが整数部制限値以内であること
      if(String(Math.abs(Number(splitResult[0]))).length > 3){
          //整数部の制限エラー
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["後体重"];
          return false;
      }
      if(splitResult[1] && splitResult[1].length > 2){
          //小数部の制限エラー
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["後体重"];
          return false;
      }
      return true;
    },

    // 治療情報テーブルチェック
    async orderMainCheck() {
      let resFlg = false;
      this.rstWeightInfo = null;
      this.ordNo = null;

      await ApiHelper.post(`/pat_home_dialysis/getOrdMainWeightAfter`,{
        patId: this.getStateUserAccountInfo.patId
      })
        .then(response => {
          if(response.data.rst_dialysis_state != null){
            this.rstWeightInfo = response.data.rst_weight_info;
            this.ordNo = response.data.ord_no;
            resFlg = true;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisWeightAfterComponent.vue', 'orderMainCheck', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // console.log(error);
          throw error;
        });

        return resFlg;
    },


    /**
     * 数値チェック関数
     * 入力値が数値 (符号あり小数 (- のみ許容)) であることをチェックする
     * [引数]   numVal: 入力値
     * [返却値] true:  数値
     *          false: 数値以外
     */
    isNumber(numVal){
      // チェック条件パターン
      var pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },


  },
  watch: {
  },
  created() {
    history.pushState(null, null, null);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
  },
  mounted() {
    // 画面リサイズ時のイベントを設定
    window.addEventListener("resize", this.calculateSize);
    this.calculateSize();

    if (this.headerPatId === null && this.getStateUserAccountInfo.patId !== null) {
      this.setHeaderPatId(this.getStateUserAccountInfo.patId);
    }

  },
  updated() {
  },
  beforeDestroy() {
    // 画面を閉じたときにイベントを除去
    window.removeEventListener("resize", this.calculateSize);
  }
};
</script>

<style scoped>
.main-content-area {
  min-width: 200px;
}

.weight-input-area {
  align-items: stretch;
  overflow-x: auto;
}

/* メインメッセージ部 設定クラス */
.message-label {
  padding-top: 5px;
  padding-bottom: 20px;
  padding-left: 40px;
  font-size: 4em;
  font-weight: bolder;
}


/* 体重入力構成クラス */
.weight-input {
  display: flex;
  justify-content: center;
  position: relative;

}


/* 前体重ラベル */
.weight-input-label {
  color: white;
  font-size: 3em;
  font-weight: bolder;
  width: 15rem;
  line-height: 4.5rem;
  text-align: center;
  border-radius: 8px;
  border: 2.5px solid slategray;
  margin-right: 15px;
}

.weight-input-text{
  width: 10.5rem;
}

ons-input >>> .text-input {
  font-size: 5em;
  height: 5rem;
}

.weight-kg-text{
  font-size: 5em;
  position: relative;
  top: 20px;
  padding-left: 5px;
}

/* 遷移系ボタン構成クラス */
.bottom-buttons {
  display: flex;
  justify-content: space-evenly;
  margin-top: 15px;
}

.process-button {
  font-size: 2.5em;
  font-weight: bolder;
  text-shadow: 2px 2px 1px dimgrey;
  width: 12.5rem;
  line-height: 4rem;
  border-radius: 8px;
  padding-top: 10px;
  padding-bottom: 10px;
}

.end-button {
  font-size: 2.5em;
  font-weight: bolder;
  text-shadow: 2px 2px 1px dimgrey;
  width: 12.5rem;
  line-height: 3rem;
  border-radius: 8px;
  padding-top: 5px;
  padding-bottom: 5px;
}


.weight-modal-container {
  width: 65%;
  height: 30%;
  min-height: 250px;
  margin: auto;
  -webkit-transform: scale(1);
  transform: scale(1);
  background: #fafafa;
}
.weight-modal-footer {
  position: absolute;
  width: 100%;
  height: 7em;
  bottom: 0px;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
  color:#000000;
}

@import "../../assets/styles/modal.css";

/* 横幅550xp を下回ったらスタイル変更 */
@media screen and (max-width: 550px), screen and (max-height: 470px) {
  .main-content-area {
    min-width: 100px;
  }

  .message-label {
    padding-top: 5px;
    padding-bottom: 10px;
    padding-left: 20px;
    font-size: 2em;
  }

  .weight-input-label {
    font-size: 2em;
    font-weight: bolder;
    width: 9rem;
    line-height: 3.5rem;
    border: 1.5px solid slategray;
    margin-right: 5px;
  }

  .weight-input-text{
    width: 7.5rem;
  }

  ons-input >>> .text-input {
    font-size: 3.5em;
    height: 3.5rem;
  }

  .weight-kg-text{
    font-size: 3em;
    position: relative;
    top: 15px;
    padding-left: 1px;
  }


  .process-button {
    font-size: 2em;
    font-weight: unset;
    width: 10rem;
    line-height: 2.5rem;
  }
}

/* 縦幅が340px以下 ならスタイル変更 */
@media screen and (max-height: 340px) {
  .main-content-area {
    min-width: 100px;
  }

  .message-label {
    padding-top: 1px;
    padding-bottom: 5px;
    padding-left: 10px;
    font-size: 1.5em;
  }

  .weight-input-label {
    font-size: 1.4em;
    font-weight: bolder;
    width: 8rem;
    line-height: 2rem;
    border: 1.25px solid slategray;
    margin-right: 5px;
  }

  .weight-input-text{
    width: 7rem;
  }

  ons-input >>> .text-input {
    font-size: 2em;
    height: 2.25rem;
  }

  .weight-kg-text{
    font-size: 2em;
    position: relative;
    top: 12px;
    padding-left: 1px;
  }

  .bottom-buttons {
    display: flex;
    justify-content: space-evenly;
    margin-top: 5px;
    height: 1rem;
  }

  .process-button {
    font-size: 1.4em;
    font-weight: unset;
    width: 7rem;
    line-height: 1.2rem;
  }
}

</style>
