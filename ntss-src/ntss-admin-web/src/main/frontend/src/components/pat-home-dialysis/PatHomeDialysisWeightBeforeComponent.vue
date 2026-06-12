<!-- 前体重入力画面 -->
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
          <label>前体重を入力</label>
        </div>
        <div>
          <v-ons-input class = "weight-input-text" modifier="weight" type ='text' pattern="^([1-9]\d*|0)(\.\d+)?$" inputmode="decimal" step="0.01" required
            v-model="beforeWeight"
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
      <v-ons-button class="button process-button" @click="next">次へ</v-ons-button>
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
                  <span>受信待機</span>
                </div>
                <div class="right">
                  <ons-toolbar-button class="close-btn print-none">
                    <ons-icon icon="fa-times"  @click="end" v-if="isButtonVisible"></ons-icon>
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
                <v-ons-button class="button end-button" @click="end" v-if="isButtonVisible">待機解除</v-ons-button>
              </div>
            </div>
          </div>
        </div>
      </transition>
      </div>
    </v-ons-modal>
    <message-dialog
    v-if="isCheckDialogVisible"
    v-model:visible="isCheckDialogVisible"
    :message-cd="messageCd"
    :string-params="stringParams"
    type="1"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { getLatestHeaderElement, getHeaderHeight, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

export default {
  mixins: [MasterMaintenanceMixin],
  components: {
    "message-dialog": messageDialog
  },
  data() {
    return {
      urlBase : "/pat_home_dialysis",
      // 表示領域の高さ
      areaHeight: 700,
      // 表示領域の幅
      areaWidth: 550,
      // メインメッセージ
      msg: "プライミングは" ,
      msg2: "完了していますか？",
      beforeWeight: null,
      isCheckDialogVisible: false,
      stringParams: null,
      messageCd: null,
      ordMainInterval: null,
      // タイマー待機message
      checkMsg: "装置データ受信待機中",
      checkMsg2: "しばらくお待ちください。",
      // タイマー待機モーダルフラグ
      modalFlg: false,
      // タイマー待機モーダルボタン表示制御
      modalButtonFlg : true,
      // タイマーID
      timerId: 0,
      // タイマーカウンター
      timerCount: 0,
      // 治療情報-結果体重JSON
      rstWeightInfo: null,
      // 治療情報-Ord_no
      ordNo: null,
      // リトライ間隔
      intervalSecond: null
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
      // 画面からデータを取得
      return this.modalFlg;
    },
    isButtonVisible(){
      // 画面からデータを取得
      return this.modalButtonFlg;
    }
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
        getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'setHeaderPatId', '患者選択失敗');
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // TODO: エラー処理検討
        throw new Error("[PatHomeDialysisStatusComponent.vue]setHeaderPatId(): 患者選択失敗");
      });
      this.setIsLoadingPat(false);
    },

    // ウインドウ変更時の高さ、幅を調整
    calculateSize() {
      // ヘッダーの高さ
      const latestHeader = getLatestHeaderElement(this.$el || document);
      const headerHeight = latestHeader ? getHeaderHeight(latestHeader, 0) + 35 : 0;
      // 下部ボタン部の高さ
      const bottomButtons = getScopedElementsByClassName("bottom-buttons", this.$el || document);
      // 下部ボタン部のmargin：35px
      let bottomButtonsHeight = 35;
      if (bottomButtons.length !== 0) {
        bottomButtonsHeight += bottomButtons[0].offsetHeight;
      }
      // main-content-area の margin：5px
      this.areaHeight = this.windowHeight - headerHeight - bottomButtonsHeight -15;
    },
    prev() {
      this.$router.push({ name: "pat-home-dialysis" });
    },

    async next() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // 1. 入力値有効チェック
      if (!await this.isNumericErrCheck()) {
        //共通：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 2.在宅透析パターン取得
      if(!await this.getPatHhdPattern()){
        //共通：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 3.治療情報テーブル存在チェック（一定期間ループ）
      if(!await this.orderMainCheck()){
        //共通：表示終了
        this.setLoadingScreenVisible(false);
        this.modalFlg = true;
        this.startBeforePolling();
        return;
      }

      // 後続処理呼び出し(ポーリング終了時呼び出しもあるため別method化)
      this.beforeWeightUpd();

    },

    // ダイアログ閉じた場合の処理
    end(){
      clearInterval(this.timerId);
      this.modalFlg = false;
      this.timerCount = 0;
    },

    /**
     * @description 前体重情報更新処理
     * @summary 入力項目の情報で前体重情報を更新し、更新が成功した後、対象の治療情報のステータスが1以降になった時、次画面へ遷移する
    */
    async beforeWeightUpd(){
      // 4.体重情報更新
      try{
        await ApiHelper.post(`/pat_home_dialysis/saveWeightBefore`,
        {
          ordNo: this.ordNo,
          weightBefore: this.beforeWeight
        })
      }catch(e){
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'beforeWeightUpd', e);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        console.error(e);
        throw e;
      }
      // 5.対象ord_noのrst_dialysis_stateの更新待機
      if(!await this.dialysisStateCheck()){
        //共通：表示終了
        this.setLoadingScreenVisible(false);
        this.modalFlg = true;
        this.startAfterPolling();
        return;
      }
      // 画面遷移機能呼出
      await this.screenPush();
    },

    async screenPush(){
      // 6.次画面 共通：表示終了
      this.setLoadingScreenVisible(false);
      this.$router.push({ name: "pat-home-dialysis-status" });
    },

    /**
     * @description 数値項目有効チェック
     * @summary 各入力項目ごとの数値に有効外の値があればダイアログを表示する
     * @returns {Boolean} true: 有効外なし, false: 有効外あり
    */
    isNumericErrCheck(){
      //1.入力必須チェック
      if(!this.beforeWeight){
          this.isCheckDialogVisible = true;
          this.messageCd = 75000001;
          this.stringParams = ["前体重"];
          return false;
      }
      //2.入力値：数値チェック
      if(!this.isNumber(this.beforeWeight)){
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["前体重"];
          return false;
      }
      //3.入力値：入力範囲内チェック
      if(0 >= Number(this.beforeWeight)){
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["前体重"];
          return false;
      }
      //4.入力値：小数点分解チェック
      let splitResult = this.beforeWeight.split('.');
      if(String(Math.abs(Number(splitResult[0]))).length > 3){
          //整数部の制限エラー
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["前体重"];
          return false;
      }
      if(splitResult[1] && splitResult[1].length > 2){
          //小数部の制限エラー
          this.isCheckDialogVisible = true;
          this.messageCd = 75000002;
          this.stringParams = ["前体重"];
          return false;
      }
      return true;
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

    // 患者在宅治療パターン取得
    async getPatHhdPattern() {
      let resFlg = false;

      await ApiHelper.post(`/pat_home_dialysis/getPatHhdPatternList`,{
        patId: this.getStateUserAccountInfo.patId
      })
        .then(response => {
          if(response.data.length === 0){
            //対象データ0件エラー
            this.isCheckDialogVisible = true;
            this.messageCd = 75000003;
            this.stringParams = [""];
          }else{
            resFlg = true;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'getPatHhdPattern', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          //API自体がエラー：共通エラー処理へ
          // console.log(error);
          throw error;
        });

    return resFlg;
    },

    // 治療情報テーブルチェック
    async orderMainCheck() {
      let resFlg = false;
      this.timerCount = 0;
      this.rstWeightInfo = null;
      this.ordNo = null;

      await ApiHelper.post(`/pat_home_dialysis/getOrdMainWeightBefore`,{
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
          getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'orderMainCheck', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // console.log(error);
          throw error;
        });

        return resFlg;
    },

    // 治療情報取得ループ
    async orderMainInterval() {
      await ApiHelper.post(`/pat_home_dialysis/getOrdMainWeightBefore`,{
        patId: this.getStateUserAccountInfo.patId
      })
        .then(response => {
          if(response.data.rst_dialysis_state != null){
            this.rstWeightInfo = response.data.rst_weight_info;
            this.ordNo = response.data.ord_no;
            // 対象データ有:
            this.endBeforePolling();
          }else{
            // 対象データ無:
            this.timerCount = this.timerCount + 1;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'orderMainInterval', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          //取得エラー:
          clearInterval(this.timerId);
          this.modalFlg = false;
          this.timerCount = 0;
          // console.log(error);
        });

    },
        // 治療情報テーブルチェック
    async dialysisStateCheck() {
      let resFlg = false;
      this.timerCount = 0;
      await ApiHelper.get(`/pat_home_dialysis/getOrdMainWeight/${this.ordNo}`)
        .then(response => {
          // 先ほど体重を更新した治療情報テーブルの状態が変化したか確認
          if(Number(response.data.rst_dialysis_state) >= 1){
            // 透析Stateが1以降
            resFlg = true;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'dialysisStateCheck', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // console.log(error);
          throw error;
        });
        return resFlg;
    },

    // 治療情報取得ループ
    async dialysisStateInterval() {
      await ApiHelper.get(`/pat_home_dialysis/getOrdMainWeight/${this.ordNo}`)
        .then(response => {
          if(Number(response.data.rst_dialysis_state) >= 1){
            // 対象データ有:
            this.endAfterPolling();
          }else{
            // 対象データ無:
            this.timerCount = this.timerCount + 1;
          }
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'dialysisStateInterval', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          //取得エラー:
          // console.log(error);
          clearInterval(this.timerId);
          this.modalFlg = false;
          this.timerCount = 0;
        });
    },

    // 更新前ポーリングを開始
    startBeforePolling() {
      this.modalButtonFlg = true;
      this.checkMsg = "治療情報データ作成待機中",
      this.checkMsg2 = "しばらくお待ちください。",
      this.timerId = setInterval(this.orderMainInterval, this.intervalSecond * 1000);
    },
    // 更新前ポーリングが正常終了
    endBeforePolling() {
      clearInterval(this.timerId);
      this.modalFlg = false;
      this.timerCount = 0;
      this.setLoadingScreenVisible(true);
      this.beforeWeightUpd();
    },

    // 更新後ポーリングを開始
    startAfterPolling() {
      this.modalButtonFlg = false;
      this.checkMsg = "体重データ反映待機中",
      this.checkMsg2 = "しばらくお待ちください。",
      this.timerId = setInterval(this.dialysisStateInterval, this.intervalSecond * 1000);
    },
    // 更新後ポーリングが正常終了
    endAfterPolling() {
      clearInterval(this.timerId);
      this.modalButtonFlg = true;
      this.modalFlg = false;
      this.timerCount = 0;
      this.setLoadingScreenVisible(true);
      this.screenPush();
    },

  },
  created() {
    history.pushState(null, null, null);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
  },
  mounted() {
    // 画面リサイズ時のイベントを設定
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("resize", this.calculateSize);
    this.calculateSize();

    // 患者情報ヘッダーの設定
    if (this.headerPatId === null && this.getStateUserAccountInfo.patId !== null) {
      this.setHeaderPatId(this.getStateUserAccountInfo.patId);
    }

    //ord_main取得間隔秒をセット
    ApiHelper.get("/mstInfo/sysSystemDefine/10")
      .then(response => {
        this.intervalSecond = JSON.parse(response.data[0].value).interval_second;
      })
      .catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatHomeDialysisWeightBeforeComponent.vue', 'mounted', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // エラーログ
        // console.log(error);
        // 取得できない場合：10秒セット
        this.intervalSecond = 10;
      });

  },

  beforeUnmount() {
    // 画面を閉じたときにイベントを除去
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("resize", this.calculateSize);
  }
};
</script>

<style scoped>
@import "../../assets/styles/modal.css";

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

ons-input :deep(.text-input) {
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
  font-size: 2.0em;
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

/* 横幅550px以下 または縦幅が341px以上、470px以下 ならスタイル変更 */
@media screen and (max-width: 550px), screen and (min-height:341px) and (max-height: 470px) {
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

  ons-input :deep(.text-input) {
    font-size: 3.5em;
    height: 3.5rem;
  }

  .weight-kg-text{
    font-size: 3em;
    position: relative;
    top: 15px;
    padding-left: 1px;
  }

  /* 遷移系ボタン構成クラス */
  .bottom-buttons {
    display: flex;
    justify-content: space-evenly;
    margin-top: 15px;
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

  ons-input :deep(.text-input) {
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
