
/**
* 条件送信簡易画面
*/
<template>
  <div class="sub-content-area ntss-send-condition-text">
    <div style="display: flex; width: 100%; height: 100%;">

      <!-- エリア1: 左側 何も表示しない -->
      <div style="width: 100%;" v-show="!deviceFlg">
      </div>

      <!-- エリア2: 中央 測定値など -->
      <div id="measure-value-row" style="width: 100%;">
        <table id="value-block">
          <!-- 1行目: 測定値 -->
          <tr>
            <td>
              <label class="send-condition-title-label">{{MeasuredValueLabel}}</label>
            </td>
            <td>
              <v-ons-input
                      id="numericID"
                      data-layout="numeric"
                      class="send-condition-measure-value-simple"
                      type="number"
                      :step="numberStep"
                      v-model.number="editMeasuredValue"
                      @blur="changeMeasureVal(editMeasuredValue, $event, false)"
                      @keydown.enter="moveFocus($event)"
                      @keydown="onKeyDown"
                      @input="checkLoop"
                      readonly="readonly"
              ></v-ons-input>
            </td>
            <td>
              <label class="send-condition-unit">
                kg
              </label>
            </td>
          </tr>
          <!-- 2行目: 体重値 -->
          <tr v-show="getPatScaleMode > 0 && !treating">
            <td>
              <label class="send-condition-title-label">体重値</label>
            </td>
            <td>
              <label class="send-condition-simple-weight-value">{{beforeWeightValue}}</label>
            </td>
            <td>
              <label class="send-condition-unit">kg</label>
            </td>
          </tr>
        </table>
      </div>

      <!-- エリア3: 右側 風袋など -->
      <div id="command-button-row" style="width: 100%; display: flex;">
        <!-- エリア3-1: 電卓ボタン -->
        <div style="width: 100%;">
          <table id="value-block" style="font-size: 2em; width: 60px;">
            <!-- 1行目: 測定値行の電卓ボタン -->
            <tr>
              <td>
                <img height="60px" style="margin-top: 0.7em;" :src="image_src" @click="show"/>
              </td>
            </tr>
            <!-- 2行目: 体重値行（定義のみ） -->
            <tr></tr>
          </table>
        </div>
        <!-- エリア3-2: 風袋・除水補正 -->
        <div id="command-button-row-1" style="width: 100%; display: flex;">
          <div id="command-button-block" v-show="getPatScaleMode > 0 && !treating">
            <div class="send-condition-simple-water-command-box send-condition-simple-vertical-div" :style="wheelChairWeightAlign" v-show="getScaleMode === 1">
              <v-ons-button
                      :class="wheelChairButtonClass"
                      ref="wheelChairButton"
                      @click="showWheelChairPopover">
              <span class="weight-mode-mst-weight-button-text">{{getSelectWheelchair.name}}</span>
              </v-ons-button>
              <label class="send-condition-simple-wheel-chair-value">{{getSelectWheelchairWeight}}</label>
            </div>
            <div class="send-condition-simple-water-command-box send-condition-simple-vertical-div">
              <v-ons-button
                class="send-condition-simple-water-command-button btn3-normal"
                @click="showModal(1)"
              >風袋</v-ons-button>
              <label class="send-condition-simple-wheel-chair-value">{{tareValue}}</label>
            </div>
            <div class="send-condition-simple-water-command-box send-condition-simple-vertical-div">
              <v-ons-button
                class="send-condition-simple-water-command-button btn3-normal"
                @click="showModal(0)"
              >除水補正</v-ons-button>
              <label class="send-condition-simple-wheel-chair-value">{{waterValue}}</label>
            </div>
            <div class="send-condition-simple-water-command-box send-condition-simple-vertical-div" v-if="dispPullLeaveAmount">
              <label class="send-condition-simple-wheel-chair-value send-condition-ihdf-pull-leave">I-HDF引き残し</label>
              <label class="send-condition-simple-wheel-chair-value">{{ihdfPullLeaveValue}} kg</label>
            </div>
          </div>
        </div>
      </div>

    </div>

    <!-- 車いすのUIボタン -->
    <pop-over
      v-bind="popoverData"
      :target-position-element="$refs.wheelChairButton"
      :fromSendConditionFlg=true
      @popover-close="closePopover"
      @popover-return="returnPopover"
    />

    <!-- 電卓のUIボタン -->
    <v-ons-popover
      cancelable
      id="numericPopOver"
      :visible.sync="cavisible"
      :target="popoverTarget"
      direction="down"
      class="popoverClass"
      @posthide="tenkeyClose"
    >
      <vue-touch-keyboard :options="options" :layout="layout" :next="next" :cancel="cancel" :accept="accept" :input="input"/>
    </v-ons-popover>
  </div>
</template>

<script>
  import { mapGetters, mapActions } from "vuex";
  import {
    weightScaleClass,
    weightScaleMode,
    dialysisState
  } from "@/constants/weightDefine";
  import { EventBus } from "@/eventBus.js";
  import MasterSelector from "@/components/common/master-selector/MasterSelector";
  //           mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang start
  import VueTouchKeyboard from "vue-touch-keyboard/dist/vue-touch-keyboard";
  import "./../../../public/css/vue-touch-keyboard.css";
  //           mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang end
  // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
  import { messageFormat } from '@/functions/common/MessageFormat';
  // mod #6107 2023/03/23 メッセージボックス全調整 張博 end

  export default {
    props: {
      // 後体重用車いす測定モードかどうか
      treating: false
    },
    components: {
      "pop-over": MasterSelector,
                  // mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang start
      "vue-touch-keyboard":VueTouchKeyboard.component
                  // mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang end
    },
    data() {
      return {
        popoverData: {
          popoverVisible: false,
          popoverDisplayDirection: "left",
          popoverTitleHeader: "",
          popoverFilterLabel: "",
          popoverFilterDataset: [],
          popoverContentLabel: "",
          popoverContentDataset: []
        },
        measureValue: "",
        cavisible: false,
                  // mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang start
        layout: null,
        input: null,
        options: {
          useKbEvents: false,
          preventClickEvent: false
        },
                  // mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang end
        // add FNSI-体重計モードテンキーの追加 徐 start
        image_src: require("@/../public/img/keyboard/keyboard.png"),
        popoverTarget: null,
        // add FNSI-体重計モードテンキーの追加 徐 end
        // add FNSI-田中衡機の追加 徐 start
        deviceFlg: false,
        // add FNSI-田中衡機の追加 徐 end
        // mod FNSI-体重計画面 徐 start
        breadMode: true,
        // mod FNSI-体重計画面 徐 end
        numberStep: 0.01,
        numberMax: 300.00,
        numberMin: 0.00,
        doClearTwice: false,
        isAndroid: false,
        isIOS: false,
      };
    },
    computed: {
      ...mapGetters("send-condition/scale", [
        "getIsInitialized",
        "getScaleMode",
        "getMeasuredValue",
        "getBodyWeightValue",
        "getBodyWeightInfo",
        "getSelectWheelchair",
        "getSelectWheelchairWeight",
        "getScaleClass",
        "getTareWeight",
        "getOffWaterWeight",
        "getIsCurrentDialysisStateEqualDialysisState",
        "getPullLeaveAmount",
        "getMachineState",
        "getTreatmentMode"
      ]),
      ...mapGetters("send-condition/scale/setting",
      ["getWheelChairList",
      // add FNSI-田中衡機の追加 徐 start
      "getWeightConfigInfo"
      // add FNSI-田中衡機の追加 徐 end
      ]),
      // mod FNSI-体重計画面 徐 start
      ...mapGetters("app", ["getQueryParameters"]),
      // mod FNSI-体重計画面 徐 end
      ...mapGetters("user", {
        facilityCd: "getFacilityCd"
      }),
      ...mapGetters("pat-info", ["selectedPatId", "selectedPatName"]),
      ...mapGetters("send-condition/weight", ["getWeightMode"]),
      // 体重測定:0 スケジュールなし患者: 1 それ以外: 2
      getPatScaleMode() {
        if (this.getScaleClass === weightScaleClass.noSchedule) {
          return 1;
        } else if (this.getScaleClass === weightScaleClass.scale) {
          return 0;
        }
        return 2;
      },
      isWheelChairMode: {
        //   mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang start
        // get() {
        //     return this.getScaleMode === weightScaleMode.wheelChair;
        //   }
        //    mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang end

          get() {
              // eslint-disable-next-line vue/no-side-effects-in-computed-properties
              this.cavisible = false;
              return this.getScaleMode === weightScaleMode.wheelChair;
          }
      },
      MeasuredValueLabel: {
        get() {
          return this.isWheelChairMode ? "車いす" : "測定値";
        }
      },
      // 測定値
      editMeasuredValue: {
        get() {
          let retval = this.adjustDigits();
          if (this.doClearTwice) {
            // クリア処理の2回目を時間差で行う
            setTimeout(() => {
              this.clearValue();
              this.moveCursor();
            }, 10);
            this.doClearTwice = false;
          }
          return retval;
        },
        set(val) {
          if(this.cavisible) {
            return;
          }
          this.measureValue = val;

        }
      },
      // 前体重
      beforeWeightValue: {
        get() {
          let value = Number(this.getBodyWeightInfo.value);
          if (value < 0) {
            return `－${(value * -1).toFixed(2)}`;
          } else {
            return `${value.toFixed(2)}`;
          }
        }
      },
      // 風袋
      tareValue: {
        get() {
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return this.getTareWeight;
          if (
            this.getTareWeight !== null
          ) {
            let value = Number(this.getTareWeight);
            if (value < 0) {
              return `－${(value * -1).toFixed(2)} kg`;
            } else {
              return `${value.toFixed(2)} kg`;
            }
          } else {
            return "";
          }
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        }
      },
      // 除水補正
      waterValue: {
        get() {
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 start
          // return this.getOffWaterWeight;
          if (
            this.getOffWaterWeight !== null
          ) {
            let value = Number(this.getOffWaterWeight);
            if (value < 0) {
              return `－${(value * -1).toFixed(2)} kg`;
            } else {
              return `${value.toFixed(2)} kg`;
            }
          } else {
            return "";
          }
          // FNSI-add 画面も単位が㎏になるの全ての項目はX.XXに修正 徐 end
        }
      },
      // I-HDF引き残し
      ihdfPullLeaveValue: {
        get() {
          return Number(this.getPullLeaveAmount.value).toFixed(2);
        }
      },
      // 治療中、または条件確認後の状態であるならばtrue
      isDialysisNow: {
        get() {
          return this.getIsCurrentDialysisStateEqualDialysisState(
                  dialysisState.dialysis
          );
        }
      },
      // 車いす重量が未測定のときのみ中央揃え
      wheelChairWeightAlign() {
        if (this.getSelectWheelchairWeight === "未測定") {
          return "align-items: center;";
        } else {
          return "";
        }
      },
      // I-HDF引き残しの表示フラグ
      dispPullLeaveAmount() {
        // 1.I-HDFの装置モード
        const isIhdf = this.getTreatmentMode[0].deviceMode === 10;
        if (!isIhdf) {
          return false;
        }
        // 2.後体重測定時
        const isAfter = this.getScaleClass === weightScaleClass.after;
        if (!isAfter) {
          return false;
        }
        // 3.引き残しのデータがある場合
        const isShow = this.getPullLeaveAmount.show;
        return isIhdf && isAfter && isShow;
      },
      wheelChairButtonClass() {
        const calibrationCheck = this.getSelectWheelchair.calibrationCheck;

        if (calibrationCheck) {
          return [
            "send-condition-simple-wheelchair-button",
            "btn3-normal"
          ];
        } else {
          return [
            "send-condition-simple-wheelchair-button",
            "btn4-alert"
          ];
        }
      },
    },
    methods: {
      ...mapActions("multi-modal", ["showTareWaterEdit"]),
      ...mapActions("send-condition/scale", [
        "setMeasuredValue",
        "setWeightValue",
        "setEditModalData",
        "calcWeightValue",
        "setSelectWheelChair",
        "changeWheelChairWeightValue",
        "setMeasuring",
        "preSaveCheckDBChanged"
      ]),
      // 車いす選択ポップアップ
      showWheelChairPopover() {
        //
        this.popoverData.popoverTitleHeader = "車いす選択";
        this.popoverData.popoverContentLabel = "車いす";
        this.popoverData.popoverContentDataset = this.createPopoverContentData(
                this.getWheelChairList.filter(elm => elm.wheelChairWeight !== null),
                "wheelChairCd",
                "wheelChairName",
                "calibrationCheck"
        );
        this.popoverData.popoverVisible = true;
        console.log("this.$refs.wheelChairButton: %o", this.$refs.wheelChairButton);
      },
      createPopoverContentData(mstData, objCd, objName, calibrationCheck) {
        const retArr = [];
        for (let i = 0; i < mstData.length; i++) {
          if (
                  this.selectedPatId === mstData[i].patId ||
                  mstData[i].isPersonal === "0"
          ) {
            retArr.push({
              value: mstData[i][objCd],
              text: mstData[i][objName],
              calibrationCheck: mstData[i][calibrationCheck],
            });
          }
        }
        return retArr;
      },

      closePopover() {
        this.popoverData.popoverVisible = false;
      },
      returnPopover(selectData) {
        this.setSelectWheelChair(selectData.value);
      },
      // 測定値変更時
      changeMeasureVal(oldVal, e, isPostHide) {
        if (this.cavisible && !isPostHide) {
          return;
        }

        // 入力制限
        // add FNSI-測定値スタイルの修正  徐 start
        // const re = new RegExp(e.target.pattern);
        // const result = re.exec(e.target.value);
        // e.target.value = result ? result.input : oldVal;
        let pattern = "^([0-9][0-9]{0,2}|0)(.[0-9]{1,2})?$";
        const re = new RegExp(pattern);
        const result = re.exec(e.target.value);
        if (result) {
          if (result.input > this.numberMax) {
            e.target.value = Number(oldVal).toFixed(2);
          } else {
            e.target.value = Number(result.input).toFixed(2);
          }
        } else {
          if (this.getWeightMode.isWeightMode) {
            if (e.target.value === null || e.target.value === "") {
              e.target.value = "";
            } else {
              let valueSplit = String(e.target.value).split(".");
              if (valueSplit.length === 2) {
                if (valueSplit[0].length > 3) {
                  e.target.value = Number(oldVal).toFixed(2);
                } else if (valueSplit[1].length > 2) {
                  e.target.value = Number(oldVal).toFixed(2);
                } else if (valueSplit[0].length === 0 && valueSplit[1].length === 0) {
                  e.target.value = null;
                }
              }
            }
          } else {
            e.target.value = Number(oldVal).toFixed(2);
          }
        }
        // add FNSI-測定値スタイルの修正  徐 end

        if (this.isWheelChairMode) {
          this.changeWheelChairWeightValue(e.target.value).then(() => {
            // 体重値計算
            this.calcWeightValue();
          });
        } else {
          this.setMeasuredValue(e.target.value).then(() => {
            // 体重値計算
            this.calcWeightValue();
          });
        }
        //add FNSI-修正 keyboard 房 start
        setTimeout( () => {
          let b = true;
          let str = this.editMeasuredValue.replaceAll(".","");
          if (str.length >= this.editMeasuredValue.length - 1) {
            let regex = /^[0-9]*$/;
            b = regex.test(str);
          } else {
            b = false;
          }

          if ( b === false ) {
            document.getElementById("numericID").value = null;
            this.editMeasuredValue = null;
          }
        }, 300 );
        //add FNSI-修正 keyboard 房 end
      },
      showTareAndWaterEditModal(mode) {
        // 編集対象データセット
        this.setEditModalData(mode);

        // 除水補正の場合
        let title = "除水補正";

        // 風袋の場合
        if (mode === 1) {
          title = "風袋";
        }

        // 風袋・除水補正モーダル表示
        this.showTareWaterEdit(title);
      },
      // 風袋・除水補正モーダル表示
      showModal(mode) {
        // 指示が外部で変更されていないかどうかチェック
        this.preSaveCheckDBChanged(0).then(
                /** @param {boolean} r*/
                r => {
                  if (r) {
                    // ボタンに対応するアクションを実行
                    this.showTareAndWaterEditModal(mode);
                  } else {
                    this.$ons.notification.confirm({
                    // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                    // title: "外部変更あり",
                    title: DIALOG_MESSAGES[13000123].title,
                    // message: "治療情報の変更がありました。再取得します。",
                    message: messageFormat(DIALOG_MESSAGES[13000123].message),
                    // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                      callback: answer => {
                        if (answer == 1) {
                          //OK
                          EventBus.$emit("refresh");
                        }
                      }
                    });
                  }
                }
        );
      },

      // 入力欄の桁数自動調整
      adjustDigits() {
        if (this.isWheelChairMode) {
          return Number(this.getSelectWheelchair.weight).toFixed(2);
        } else {
          return Number(this.getMeasuredValue).toFixed(2);
        }
      },

      // 入力欄のフォーカス移動
      moveFocus(event) {
        event.target.blur();
      },

      // テンキー表示時にキー入力無効化
      onKeyDown(event) {
        if (this.cavisible) {
          event.preventDefault();
        }
      },

      // 数値範囲内ループチェック
      checkLoop(event) {
        // テキスト入力の場合は除外
        if (event.inputType && event.inputType === "insertText") {
          return;
        }

        // テンキー入力の場合は除外
        if (this.cavisible) {
          return;
        }

        // 数値範囲内かどうかの確認
        if (event.target.value > this.numberMax) {
          event.target.value = this.numberMin;
        } else if (event.target.value < this.numberMin) {
          event.target.value = this.numberMax;
        }
      },

      show() {
          //mod FNSI-修正 keyboard 房 start
          // mod FNSI-体重計画面 徐 start
          // if (this.getWeightMode.isWeightMode) {
          // mod FNSI-体重計画面 徐 end
          // add FNSI-テンキー順番の変更 徐 start
          // // add FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang start
          // if(e.target.firstElementChild.value === "0"){
          //     e.target.firstElementChild.value = "";
          // }
          // // add FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang end
          // this.input = e.target.firstElementChild;
          let numericIDElem = document.getElementById("numericID");
          numericIDElem.setAttribute("type", "text");
          this.input = numericIDElem.firstElementChild;
          this.input.setAttribute("readonly", "readonly");

          this.selectAllInput(this.input);

          // this.layout = e.target.dataset.layout;
          let name = ["{reverse} {clr} {backspace}", "7 8 9", "4 5 6", "1 2 3", "{zero} . {cancel}"];
          let meta = {
            "reverse": { func: "next", text: "＋/－"},
            "clr": { func: "accept", text: "CLR", classes: "control"},
            "backspace": { func: "backspace", classes: "control"},
            "zero": { key: "0"},
            "cancel": { func: "cancel", text: "確定", classes: "featured"}
          };
          let layoutparam = {default: name, _meta: meta};
          this.layout = layoutparam;

          // if (!this.cavisible)
          //   this.cavisible = true
          this.popoverTarget = this.input;
          this.cavisible = !this.cavisible;
          // add FNSI-テンキー順番の変更 徐 end
          //mod FNSI-修正 keyboard 房 end
        },
        // mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang start

      // テンキー用関数 accept: 全文字クリア
      accept() {
        // add FNSI-テンキー順番の変更 徐 start
        // let str = this.editMeasuredValue;
        // let regex = /(^[0-9][0-9]*(.[0-9]+)?)$/;
        // let b;
        // if(str.indexOf("_") > 0 || str.indexOf("-") > 0){
        //     b = false;
        // }else {
        //     b = regex.test(str);
        // }
        // if ( b === false ) {
        //   document.getElementById("numericID").value = null;
        // }
        // this.cavisible = false;
        // 入力前の値が"0.00"以外の場合、全文字クリア処理を2回行う
        if (document.getElementById("numericID").value !== "0.00") this.doClearTwice = true;

        this.clearValue();
        this.moveCursor();
        // add FNSI-テンキー順番の変更 徐 end
      },
        // mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし liang end

      // テンキー用関数 cancel: 画面テンキーを閉じる
      cancel() {
        document.getElementById("numericPopOver").hide();
        this.cavisible = false;
      },

      // テンキー用関数 next: 正負反転
      next() {

        const reverseVal = Number(document.getElementById("numericID").value) * (-1);

        document.getElementById("numericID").value = reverseVal.toFixed(2);
        this.editMeasuredValue = reverseVal.toFixed(2);
        this.moveCursor();
      },

      // テンキー用関数 tenkeyClose: 画面テンキーを閉じた際の内部処理
      tenkeyClose() {
        const isPostHide = true;
        // 入力を番号に戻す
        document.getElementById("numericID").setAttribute("type", "number");
        // 異常データの場合の初期化
        this.changeMeasureVal(this.editMeasuredValue, {target: document.getElementById("numericID")}, isPostHide);

        this.input = null;
      },

      // テンキー用内部関数 moveCursor: カーソル位置を右端にセットする
      moveCursor() {
        this.input.focus();
        this.input.setSelectionRange(10, 10);
      },
      // テンキー用内部関数 selectAllInput: 入力内容を全選択状態にする
      selectAllInput(inputElement) {
        inputElement.focus();
        inputElement.setSelectionRange(0, inputElement.value.length);
      },

      // テンキー用内部関数 clearValue: 測定値をクリアする
      clearValue() {
        this.input.value = null;
        this.editMeasuredValue = 0.00;
        if (this.isWheelChairMode) {
          this.changeWheelChairWeightValue(null).then(() => {
            // 体重値計算
            this.calcWeightValue();
          });
        } else {
          this.setMeasuredValue(null).then(() => {
            // 体重値計算
            this.calcWeightValue();
          });
        }
      },
    },
    watch: {},
    created() {
      // del FNSI-テンキー順番の変更 徐 start
      // this.hide();
      // del FNSI-テンキー順番の変更 徐 end
      // add FNSI-田中衡機の追加 徐 start
      let deviceClass = null;
      if (this.getWeightConfigInfo !== undefined && this.getWeightConfigInfo !== null) {
          deviceClass = this.getWeightConfigInfo.deviceClass;
      }
      if (String(deviceClass) === "1") {
        this.deviceFlg = true;
      }
      // add FNSI-田中衡機の追加 徐 end
      // mod FNSI-体重計画面 徐 start
      const queryParameters = this.getQueryParameters;
      if (Number(queryParameters.WEIGHTNO) > 0) {
        if (Number(queryParameters.MODE) == 1) {
          this.breadMode = false;
        }
      }
      // mod FNSI-体重計画面 徐 end

      // 端末判別
      const ua = navigator.userAgent;
      if (ua.match(/Android/)) {
        this.isAndroid = true;
      } else if (ua.match(/iPhone|iPad/)) {
        this.isIOS = true;
      }
    },
    mounted() {
      // 体重値セット
      this.calcWeightValue();

      setTimeout(() => {
        let numericIdElem = document.getElementById("numericID");
        if (numericIdElem) {
          // 数値入力欄に'wheel'のイベントリスナーを設定することで
          // ホイールを使ったマウスホイールによる数値変更が可能。
          // 関数の内容は問わないため何もしない関数を指定。
          numericIdElem.addEventListener('wheel', () => {});
          // スマホ表示時、右側に余白をつけるクラスを追加
          if (this.isIOS || this.isAndroid) {
            numericIdElem?.classList?.add('input-mobile');
          }
        }
      }, 1000);
    },
    beforeDestroy() {
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },
    destroyed() {

    }
  };
</script>
<style scoped>
  .sub-content-area {
    display: flex;
    flex-direction: column;
    width: 100%;
    margin: auto;
  }

  /* 車いす */
  .wheelchair-command-box {
    text-align: center;
  }
  .hidden-item {
    display: none;
  }

  .display-flex-css {
    display: flex;
    justify-content: center;
  }
           /*mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし。 liang start*/
  ons-input >>> .text-input {
    text-align: right;
    color: var(--send-cond-font-color) !important;
    background-color: var(--ntss-base-background-color) !important;
    opacity: 1 !important;
    height: 1.6em !important;
  }
  ons-input >>> input[type="text"] {
    padding-right: 15px;
  }
  .input-mobile >>> input[type="number"] {
    padding-right: 15px;
  }
           /*mod FNSI-改修内容体重計モードの場合体重計表示機はキーボードなし。 liang end*/
  /* add FNSI-体重計モードテンキーの追加 徐 start */
  .popoverClass >>> .popover--top {
    width: auto;
  }
  /* add FNSI-体重計モードテンキーの追加 徐 end */
  /* add FNSI-体重計画面 徐 start */
  .send-title-label {
    font-size: 4em;
  }
  /* add FNSI-体重計画面 徐 end */
</style>
