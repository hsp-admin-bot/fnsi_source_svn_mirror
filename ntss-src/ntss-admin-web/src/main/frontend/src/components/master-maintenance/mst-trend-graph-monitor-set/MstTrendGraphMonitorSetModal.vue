<template>
  <div class="main-area">
    <div class="disp-item-area">
      <div class="wrap-block">
        <label class="item-title">テンプレート名</label>
        <v-ons-input class="item-text custom-input-required" @input="setCss($event.target.value)" v-model="inputModel.name" @change="changeDown"/>
      </div>
      <div class="wrap-block">
        <label class="item-title">装置</label>
        <v-ons-select
          class="selectbox item-dropdown-list"
          v-model="inputModel.model"
          @change="onModelChange()"
        >
          <option v-for="(item, index) in modelList" :key="index" :value="item.code">{{ item.name }}</option>
        </v-ons-select>
      </div>
    </div>
    <div class="disp-item-content-frame print-height-auto" :style="heightStyles">
      <div class="disp-item-content-area">
        <table class="ntss-list graph-list">
          <thead>
            <tr>
              <th class="ntss-list-header-th-sticky graph-list-header graph-list-del" scope="col">表示</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-code"
                scope="col"
              >項目コード</th>
              <th
                class="ntss-list-header-th-sticky graph-list-header graph-list-name"
                scope="col"
              >項目名</th>
            </tr>
          </thead>
          <!-- mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy start -->
          <draggable v-model="inputModel.seriesInfo"
                     element="tbody"
                     @change="changeButton"
                     :options="{ ...dragOptions, handle: '.column-handle' }">
          <!-- mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy end -->
            <template v-for="(item,index) in inputModel.seriesInfo">
            <tr v-if="!item.model_type || item.model_type == inputModel.model" :key="index">
              <td class="ntss-list-body-td graph-list-select">
                <ons-checkbox :checked="item.checked" @change="onSelectRow($event, index)" />
              </td>
              <td class="ntss-list-body-td graph-list-code" style="text-align: right;">
                <label>{{item.code}}</label>
              </td>
              <td class="ntss-list-body-td graph-list-name">
                <!-- mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy start -->
                <v-ons-row>
                  <v-ons-col>
                    <label>{{item.name}}</label>
                  </v-ons-col>
                  <v-ons-col style="max-width:5%; text-align:right;">
                    <v-ons-icon icon="fa-bars" class="column-handle" />
                  </v-ons-col>
                </v-ons-row>
                <!-- mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy end -->
              </td>
            </tr>
            </template>
          </draggable>
        </table>
      </div>
    </div>
  </div>
</template>
<script>
import { mapGetters, mapActions } from "vuex";
import { MACHINE_MODEL, NX_MACHINE_ID } from "@/constants/machineModel";
import { ApiHelper } from "@/apis/AxiosHelper.js";
import { deepCopy } from "@/functions/common/CommonFunctions";
import vuedraggable from "vuedraggable";
import {EventBus} from "@/eventBus";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  name: "MstTrendGraphTemplateModal",
  components: {
    draggable: vuedraggable
  },
  data() {
    return {
      modelList: [
        {
          code: MACHINE_MODEL.DRO,
          name: "ＤＲＯ"
        },
        {
          code: MACHINE_MODEL.DAB,
          name: "ＤＡＢ"
        },
        {
          code: MACHINE_MODEL.DAD,
          name: "ＤＡＤ"
        },
        {
          code: MACHINE_MODEL.DRY_A,
          name: "ＤＲＹ－Ａ"
        },
        {
          code: MACHINE_MODEL.DRY_B,
          name: "ＤＲＹ－Ｂ"
        }
      ],
      inputModel: {
        code: 0,
        name: "",
        model: "",
        seriesInfo: [],
        facilityCd: "",
        isDisp: "",
        isDel: ""
      },
      //mod マスタ詳細画面がありません破棄メッセージ
      initName:"",
      initModel:"",
      initSeriesInfo:[],
      contentsAreaHeight: 200,
      monitorItemList: [],
      temporaryItemList: [],
      //add 端末判別 5103 鞠 start
      androidFlg: false,
      iosFlg: false,
      //add 端末判別 5103 鞠 end
      // add redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy start
      // ドラッグ時の詳細設定
      dragOptions: {
        animation: 250, //drag時の速度
        forceFallback: true, //trueにすると、draggable用のDnDが作動するようになる
        dragClass: "drag", //ドラッグ時のクラス名
        ghostClass: "ghost" //ドロップ時のクラス名
      }
      // add redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy end
    };
  },

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    // 端末判別 鞠 5103 start
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    // 端末判別 鞠 5103 end
    /**
     * コンテンツの高さをCSS変数を利用して書き換える
     */
    heightStyles() {
      return { height: `${this.contentsAreaHeight}px` };
    },
    /**
     * モニタ項目のフィルタリング
     */
    filteredMonitorList() {
      let filteredList = this.monitorItemList;
      if (this.inputModel.model !== null && this.inputModel.model !== "") {
        filteredList = filteredList.filter(
          item => item.model === this.inputModel.model
        );
      } else {
        return [];
      }
      return filteredList;
    }
  },
  watch: {
    /**
     * ウィンドウサイズが変更された時の処理.
     */
    windowHeight() {
      this.calculateGridHeight();
    },
    // 端末判別 鞠 5103 start
    getFontSize() {
      this.calculateGridHeight();
    },
    // 端末判別 鞠 5103 end
  },
  async mounted() {
    // モニタ項目
    const sysMonitorItemRequestParamDab = {
      moniDataType: NX_MACHINE_ID.DAB,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDad = {
      moniDataType: NX_MACHINE_ID.DAD,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDro = {
      moniDataType: NX_MACHINE_ID.DRO,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDryA = {
      moniDataType: NX_MACHINE_ID.DRY_A,
      vitalMonitorClass: null
    };
    const sysMonitorItemRequestParamDryB = {
      moniDataType: NX_MACHINE_ID.DRY_B,
      vitalMonitorClass: null
    };
    const that = this;
    await Promise.all([
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDab
      ),
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDad
      ),
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDro
      ),
      ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDryA
      ),
       ApiHelper.get(
        "/treatment-record/sys_monitor_item",
        sysMonitorItemRequestParamDryB
      )
    ]).then(response => {
      /* ================= #9312  Modified Start ================= */
      // モニタ項目：DAB
      const sysMonitorItemDab = response[0].data
        ? response[0].data.filter(item => item.moni_data_no !== 'A99') : [];
      // モニタ項目：DAD
      const sysMonitorItemDad = response[1].data
        ? response[1].data.filter(item => item.moni_data_no !== 'D99') : [];
      // モニタ項目：DRO
      const sysMonitorItemDro = response[2].data
        ? response[2].data.filter(item => item.moni_data_no !== 'R99') : [];
      // モニタ項目：DRY_A
      const sysMonitorItemDryA = response[3].data ? response[3].data : [];
      // モニタ項目：DRY_B
      const sysMonitorItemDryB = response[4].data ? response[4].data : [];
      /* ================= #9312  Modified End ================= */

      // モニタ項目の結合
      const sysMonitorItem = sysMonitorItemDab.concat(
        sysMonitorItemDad,
        sysMonitorItemDro,
        sysMonitorItemDryA,
        sysMonitorItemDryB
      );
      // 表示用モニタ項目作成
      that.monitorItemList = sysMonitorItem
        .filter(s => s.is_disp === "1")
        .map(s => {
          let model = null;
          let code = 0;
          switch (s.moni_data_type) {
            case NX_MACHINE_ID.DAB:
              //DAB
              model = MACHINE_MODEL.DAB;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DAB, "");
              break;
            case NX_MACHINE_ID.DAD:
              //DAD
              model = MACHINE_MODEL.DAD;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DAD, "");
              break;
            case NX_MACHINE_ID.DRO:
              //DRO
              model = MACHINE_MODEL.DRO;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DRO, "");
              break;
            case NX_MACHINE_ID.DRY_A:
              //DRY_A
              model = MACHINE_MODEL.DRY_A;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DRY_A, "");
              break;
            case NX_MACHINE_ID.DRY_B:
              //DRY_B
              model = MACHINE_MODEL.DRY_B;
              code = s.moni_data_no.replace(NX_MACHINE_ID.DRY_B, "");
              break;
            default:
              break;
          }
          const upperLength = parseInt(s.upper).toString(10).length;
          const lowerLength = parseInt(s.lower).toString(10).length;
          let length = 0;
          if (upperLength > lowerLength) {
            length = upperLength;
          } else {
            length = lowerLength;
          }
          return {
            model: model,
            code: parseInt(code, 10),
            name: s.moni_data_name,
            intPoint: length,
            decPoint: s.decimal_figure,
            maxValue: s.upper,
            minValue: s.lower
          };
        });
    });
    this.monitorItemList = that.monitorItemList;

    for (const num in this.columnDefinition) {
      // テンプレートコード
      if (this.columnDefinition[num].field === "code") {
        this.inputModel.code = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // テンプレート名
      if (this.columnDefinition[num].field === "name") {
        this.inputModel.name = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 装置種別
      if (this.columnDefinition[num].field === "model") {
        this.inputModel.model = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // モニタ項目一覧セット
      if (this.columnDefinition[num].field === "seriesInfo") {
        const seriesInfo = this.getValueByField(
          this.columnDefinition[num].field
        );
        const dataList = this.filteredMonitorList;
        this.inputModel.seriesInfo = [];
        if (seriesInfo !== null && seriesInfo && seriesInfo.length !== 0) {
          const contact = JSON.parse(seriesInfo);
          // mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy start
          if (contact !== null && contact.length === dataList.length) {
            for (let idx = 0; idx < contact.length; idx++) {
              let checkValue = false;
                for (let jdx = 0; jdx < dataList.length; jdx++) {
                  if (contact[idx].code === dataList[jdx].code) {
                    checkValue = contact[idx].checked === undefined ? true:contact[idx].checked;
                    break;
                  }
                }
              this.inputModel.seriesInfo.push({
                checked: checkValue,
                code: contact[idx].code,
                name: contact[idx].name,
                model_type: this.inputModel.model
              });
            }
          } else {
            for (let idx = 0; idx < dataList.length; idx++) {
              let checkValue = false;
                for (let jdx = 0; jdx < contact.length; jdx++) {
                  if (dataList[idx].code === contact[jdx].code) {
                    checkValue = true;
                    break;
                  }
                }
              this.inputModel.seriesInfo.push({
                checked: checkValue,
                code: dataList[idx].code,
                name: dataList[idx].name,
                model_type: this.inputModel.model
              });
            }
          }
          // mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy end
        } else {
          for (let idx = 0; idx < dataList.length; idx++) {
            let checkValue = false;
            this.inputModel.seriesInfo.push({
              checked: checkValue,
              code: dataList[idx].code,
              name: dataList[idx].name,
              model_type: this.inputModel.model
            });
          }
        }
      }
      // 施設コード
      if (this.columnDefinition[num].field === "facilityCd") {
        this.inputModel.facilityCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 表示フラグ
      if (this.columnDefinition[num].field === "isDisp") {
        this.inputModel.isDisp = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      // 削除フラグ
      if (this.columnDefinition[num].field === "isDel") {
        this.inputModel.isDel = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
    }
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
    //mod マスタ詳細画面がありません破棄メッセージ
    this.initName = this.inputModel.name;
    this.initModel = this.inputModel.model;
    this.initSeriesInfo = JSON.parse(JSON.stringify(this.inputModel.seriesInfo));
  },
  created() {
    this.setLoadingScreenVisible(true);
    // 端末判別 鞠 5103 start
    const ua = navigator.userAgent;
    if (ua.match(/Android/)) {
      this.androidFlg = true;
    } else if (ua.match(/iPhone|iPad/)) {
      this.iosFlg = true;
    }
    // 端末判別 鞠 5103 end
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    getValueByField(field) {
      return this.editRecord[field];
    },
    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },
    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    /**
     * Gridの高さを調整する
     */
    calculateGridHeight() {
      const modal = document.getElementsByClassName("modal-container")[0];
      const modalHeight = modal.clientHeight;
      const modalHeaderHeight = document.getElementsByClassName("toolbar")[0].clientHeight;
      const modalFooterHeight = modal.lastElementChild.clientHeight;
      const contentsHeight1 = document.getElementsByClassName(
        "disp-item-area"
      )[0].clientHeight;
      this.contentsAreaHeight =
        modalHeight -
        modalHeaderHeight -
        modalFooterHeight -
        contentsHeight1 -
        30;
      // add 鞠 5103 スマホ詳細画面の項目名が横に長すぎる start
      if(this.androidFlg === true) {
        document.getElementsByClassName("ntss-list-header-th-sticky graph-list-header graph-list-name")[0].style.minWidth = "14em"
      }else{
        document.getElementsByClassName("ntss-list-header-th-sticky graph-list-header graph-list-name")[0].style.minWidth = "40em"
      }
      // add 鞠 5103 スマホ詳細画面の項目名が横に長すぎる end
    },
    /**
     * 表示項目
     */
    onMoniItemChange(value, index) {
      this.inputModel.seriesInfo[index].moni_cd = parseInt(value, 10);
    },
    /**
     * モデルの選択
     */
    onModelChange() {
      //mod マスタ詳細画面がありません破棄メッセージ
      if (this.initModel!==this.inputModel.model) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }
      const dataList = this.filteredMonitorList;
      // add 障害票一覧_マスタ No.44 宋qy start
      if (this.inputModel.seriesInfo.filter(e=>e.model_type == this.inputModel.model).length > 0) {
        return;
      }
      // add 障害票一覧_マスタ No.44 宋qy end
      for (let idx = 0; idx < dataList.length; idx++) {
        this.inputModel.seriesInfo.push({
          checked: false,
          code: dataList[idx].code,
          name: dataList[idx].name,
          model_type: this.inputModel.model
        });
      }
    },
    //mod マスタ詳細画面がありません破棄メッセージ
    changeDown(){
    if (this.inputModel.name!==this.initName) {
      this.changeButton();
    }else{
      EventBus.$emit("mstHolidayRegistered", true);
    }
    },
    setCss(value) {
      if(value && document.getElementsByClassName("custom-input-invalid")[0])
      document.getElementsByClassName("custom-input-invalid")[0].classList.remove("custom-input-invalid");
    },
    /**
     * 表示項目の選択
     */
    onSelectRow(ev, index) {
      this.inputModel.seriesInfo[index].checked = ev.target.checked;
      if (JSON.stringify(this.inputModel.seriesInfo)!==JSON.stringify(this.initSeriesInfo)) {
        this.changeButton();
      }else{
        EventBus.$emit("mstHolidayRegistered", true);
      }

    },
    /**
     * 文字入力
     */
    validateRequired(value) {
      const val = value.toString();
      if (val.length === 0 || val.trim().length === 0) {
        return false;
      }
      return true;
    },
    /**
     * 入力データの検証
     */
    validateData() {
      let seriesInfoList = [];
      this.temporaryItemList = deepCopy(this.inputModel.seriesInfo);
      this.inputModel.seriesInfo.forEach(e=>{
        if (e.model_type == this.inputModel.model) {
          delete e.model_type;
          seriesInfoList.push(e);
        }
      });
      this.inputModel.seriesInfo = seriesInfoList;
      return {
        nameValid: this.validateRequired(this.inputModel.name),
        nameLengthValid: this.inputModel.name.length <= 50,
        modelValid: this.validateRequired(this.inputModel.model)
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        this.updateEditRecord("name", this.inputModel.name);
        this.updateEditRecord("model", this.inputModel.model);
        let saveInfo = [];
        for (const item of this.inputModel.seriesInfo) {
          // mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy start
          // if (item.checked) {
            saveInfo.push({
              code: item.code,
              name: item.name,
              checked: item.checked
            });
          // }
          // mod redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy end
        }
        this.updateEditRecord("seriesInfo", JSON.stringify(saveInfo));
        return true;
      }
      if (!validationResult.nameValid) {
        document.getElementsByClassName("custom-input-required")[0]?.classList?.add("custom-input-invalid");
      }
      // メッセージ組み立て
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // const title = "チェックエラー";
      const title = DIALOG_MESSAGES['00200100'].title;
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            !validationResult.nameValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "テンプレート名を入力する必要があります。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200100'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.nameLengthValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "テンプレート名が長すぎます。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200101'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            !validationResult.modelValid
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // ? "装置を選択して下さい。<br>"
              ? messageFormat(DIALOG_MESSAGES['00200102'].message)
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              : ""
          }

        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      this.inputModel.seriesInfo = this.temporaryItemList;
      return false;
    },
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    }
  }
};
</script>

<style scoped>
@media print{
  .disp-item-content-frame{
    height: auto !important;
  }
}
.disp-item-name-area {
  vertical-align: middle;
  padding-left: 5px;
}

.disp-item-content-area {
  overflow: auto;
  height: 100%;
}

.disp-item-area {
  width: 100%;
  border-collapse: collapse;
}

.disp-item-area tr {
  height: 30px;
}
.custom-input-required {
  color: black;
  background-color: #ffff99;
}
.custom-input-invalid {
  color: black;
  background-color: rgba(255, 0, 0, 1);
}
.disp-item-area tr th {
  text-align: left;
}

.disp-item-area tr th:first-child,
.disp-item-area tr th:nth-child(2) {
  width: 30%;
}

.disp-item-area tr td:first-child,
.disp-item-area tr td:nth-child(2),
.disp-item-area tr td:nth-child(3) {
  text-align: left;
}

.disp-item-content-frame {
  width: 100%;
  border: 1px solid;
  box-sizing: border-box;
  position: relative;
}
/* ラベル */
.item-title {
  position: relative;
  top: 5px;
  padding-left: 5px;
  width: 150px;
  min-width: 50px;
}
/* テキスト */
.item-text {
  position: relative;
  margin-left: 5px;
  width: 10%;
  min-width: 125px;
}
/* ドロップダウン */
.item-dropdown-list {
  position: relative;
  margin-left: 5px;
}
/* 横並び */
.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
  margin-bottom: 5px;
}

.graph-list {
  display: block;
  position: relative;
  background-color: inherit;
}

table.graph-list {
  border-collapse: collapse;
}

table.graph-list th,
table.graph-list td {
  border: solid 1px var(--ntss-list-border-color);
  background-color: var(--ntss-base-background-color);
}

table.graph-list {
  width: 100%;
}

table.graph-list thead {
  color: white;
  background-color: var(--ntss-list-header-background-color);
}

table.graph-list thead tr {
  height: 30px;
}

table.graph-list thead tr th.graph-list-header {
  z-index: 1;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
}

table.graph-list .graph-list-del {
  min-width: 3em;
}
/*del 鞠 5103*/
/*table.graph-list .graph-list-name {*/
/*  min-width: 40em;*/
/*}*/

table.graph-list .graph-list-code {
  min-width: 5em;
}

table.graph-list tbody tr {
  height: 1.2rem;
  background-color: white;
}
/* add redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy start */
.column-handle {
  cursor: move;
}
.ghost {
  opacity: 0.5;
}
.drag {
  display: none;
}
/* add redmine 5375 治療状況透析液調製装置トレンドレイアウトマスタ詳細の並び順変更ができない 宋qy end */
</style>
