/**
 * マスタメンテナンス マスタ編集モーダルのサンプル（メインコンポーネント）
 * マスタ一覧から「テストマスタ」を選択し、「編集」ボタンを押下すると表示されます。
 */
<template>
  <div class="main-content-area main-content-area-custom">
    <div class="ntss-comsv-modal">
      <div class="label-header">
        <div>
          <label style="white-space: nowrap;">デバイスエッジ</label>
        </div>
        <div>
          <v-ons-select
            class="item-data"
            v-model="inputModel.deviceEdgeNo"
            @change="onChangeDeviceEdgeNo"
          >
            <option
              v-for="(item, index) in mstMachineList"
              :key="index"
              :value="item.value"
            >{{ item.displayValue }}</option>
          </v-ons-select>
        </div>
      </div>
      <kendo-grid-toolbar
        id="comsv-setting-modal-area"
        class="k-grid-toolbar kendo-grid-toolbar-style"
      >
        <div class=" mst-comsv-setting-main-area" style='height: 100%;'>
          <!-- 縦スクロールバーのみ表示する/横スクロールバーはタブ内で表示 -->
          <div class="tabs" style='height: 100%; overflow-x: auto; overflow-y: hidden;'>
            <div id="tab-item-list-area" style="display: flex;">
              <input id="basic" v-model="tabValues" :value="TAB_VALUES.BASIC" type="radio" name="tab_item" checked />
              <label class="tab_item" for="basic">基本設定</label>
              <input id="staff" v-model="tabValues" :value="TAB_VALUES.STAFF" type="radio" name="tab_item" @change="clickStaffTab" />
              <label class="tab_item" for="staff">スタッフ</label>
              <input id="virtual" v-model="tabValues" :value="TAB_VALUES.VIRTUAL" type="radio" name="tab_item" @change="clickMenuTab" />
              <label class="tab_item" for="virtual">仮想端末</label>
              <input id="patient" v-model="tabValues" :value="TAB_VALUES.PATIENT" type="radio" name="tab_item" @change="clickPatientTab" />
              <label class="tab_item" for="patient">患者情報</label>
              <input id="dialysis" v-model="tabValues" :value="TAB_VALUES.DIALYSIS" type="radio" name="tab_item" @change="clickDialysisTab" />
              <label class="tab_item" for="dialysis" id="dialysisTabChange">透析日報</label>
              <input id="graph" v-model="tabValues" :value="TAB_VALUES.GRAPH" type="radio" name="tab_item" />
              <label class="tab_item" for="graph">グラフ表示</label>
            </div>

            <!-- 基本設定タブ -->
            <div class="tab_content" id="basic_content" :class="tabValues === TAB_VALUES.BASIC ? 'displaying-tab' : ''" :style="tabItemListAreaWitth">
              <div class="comsv-setting-main-tab-basic" style="height: 100%; overflow-y: auto;">
                <ComsvSettingMainTab ref="basic" />
              </div>
            </div>

            <!-- スタッフタブ -->
            <div class="tab_content" id="staff_content" :class="tabValues === TAB_VALUES.STAFF ? 'displaying-tab' : ''" :style="tabItemListAreaWitth" @change="changeButton()">
              <div style="height: 100%;">
                <ComsvSettingLcdStaffMainTab ref="sta" />
              </div>
            </div>

            <!-- 仮想端末タブ -->
            <div class="tab_content" id="virtual_content" :class="tabValues === TAB_VALUES.VIRTUAL ? 'displaying-tab' : ''" :style="tabItemListAreaWitth">
              <div style="height: 100%;">
                <ComsvSettingLcdMenuMainTab ref="vir" />
              </div>
            </div>

            <!-- 患者情報タブ -->
            <div class="tab_content" id="patient_content" :class="tabValues === TAB_VALUES.PATIENT ? 'displaying-tab' : ''" :style="tabItemListAreaWitth">
              <div style="height: 100%; overflow-y: auto;">
                <ComsvSettingLcdNpatMainTab ref="pat" />
              </div>
            </div>

            <!-- 透析日報タブ -->
            <div class="tab_content" id="dialysis_content" :class="tabValues === TAB_VALUES.DIALYSIS ? 'displaying-tab' : ''" :style="tabItemListAreaWitth">
              <div style="height: 100%; overflow-y: auto;">
                <ComsvSettingLcdReportMainTab ref="dia" />
              </div>
            </div>

            <!-- 検査グラフ設定タブ -->
            <!-- TODO <div class="tab_content ins-tab-content" id="graph_content" :class="tabValues === TAB_VALUES.GRAPH ? 'displaying-tab' : ''" :style="tabItemListAreaWitth"> -->
            <div class="tab_content" id="graph_content" :class="tabValues === TAB_VALUES.GRAPH ? 'displaying-tab' : ''" :style="tabItemListAreaWitth">
              <div class="ins-tab-content">
                <ComsvSettingCheckGraphMainTab ref="gra" />
              </div>
            </div>
          </div>
        </div>
      </kendo-grid-toolbar>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import ComsvSettingMainTab from "@/components/master-maintenance/mst-comsv-setting/sub-item/ComsvSettingMainItem";
import ComsvSettingLcdMenuMainTab from "@/components/master-maintenance/mst-comsv-setting/sub-item/ComSvSettingLcdMenuMainItem";
import ComsvSettingLcdNpatMainTab from "@/components/master-maintenance/mst-comsv-setting/sub-item/ComsvSettingLcdNpatMainItem";
import ComsvSettingLcdReportMainTab from "@/components/master-maintenance/mst-comsv-setting/sub-item/ComsvSettingLcdReportMainItem";
import ComsvSettingCheckGraphMainTab from "@/components/master-maintenance/mst-comsv-setting/sub-item/ComsvSettingCheckGraphMainItem";
import ComsvSettingLcdStaffMainTab from "@/components/master-maintenance/mst-comsv-setting/sub-item/ComsvSettingLcdStaffMainItem";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import {EventBus} from "@/eventBus";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
export default {
  name: "mst-comsv-setting",
  components: {
    ComsvSettingMainTab,
    ComsvSettingLcdMenuMainTab,
    ComsvSettingLcdNpatMainTab,
    ComsvSettingLcdReportMainTab,
    ComsvSettingCheckGraphMainTab,
    ComsvSettingLcdStaffMainTab
  },
  data() {
    return {
      show: true,
      toggleA: true,
      toggleB: false,
      inputModel: {
        deviceEdgeNo: ""
      },
      dispDeviceEdgeNo: null,
      mstMachine: [],
      mstMachineList: [],
      tabValues: "basic",
      TAB_VALUES: {
        BASIC: "basic",
        STAFF: "staff",
        VIRTUAL: "virtual",
        PATIENT: "patient",
        DIALYSIS: "dialysis",
        GRAPH: "graph"
      },
      // コンテンツ幅
      conWidth: 0,
      //mod マスタ詳細画面がありません破棄メッセージ
      initDeviceEdgeNo:"",
      // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
      initEditRecord: {}
      // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-com-sv-setting", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList",
      getFacilityList: "getFacilityList",
      getSelectFacility: "getSelectFacility"
    }),
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      fontSize: "getFontSize"
    }),
    // タブ内の幅
    tabItemListAreaWitth() {
      if (this.conWidth !== 0) {
        return { "width": `${this.conWidth}px` };
      } else {
        return {};
      }
    }
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-com-sv-setting", ["setInitEditRecord"]),
    // ...mapActions("ComsvSettingMainTab", [    ]),
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
    validationField(field) {
      return [
        "sortInputTime",
        "operation",
        "allowAddRecord",
        "allowSort",
        "isDel",
        "code",
        "$modalType",
        "sortRank"
      ].some(el => el === field);
    },
    clickPatientTab() {
      const updateWidget = this.$refs.pat.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },
    clickDialysisTab() {
      const updateWidget = this.$refs.dia.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },
    clickStaffTab() {
      const updateWidget = this.$refs.sta.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },
    clickMenuTab() {
      const updateWidget = this.$refs.vir.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },
    onChangeDeviceEdgeNo() {
      this.updateEditRecord("deviceEdgeNo", this.inputModel.deviceEdgeNo + '');
    },
    /**
     * デバイスエッジ一覧の取得
     */
    async getDeviceEdgeNoList() {
      //deviceedgeリストを格納表示
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
      // for (const num in this.getDeviceEdgeList) {
      //   this.mstMachineList.splice(num, 0, {
      //     value: this.getDeviceEdgeList[num].value,
      //     displayValue: this.getDeviceEdgeList[num].text
      //   });
      // }
      this.mstMachineList = (this.getDeviceEdgeList || [])
        .filter(item => {
          const selected = this.inputModel.deviceEdgeNo;
          if (!selected) {
            return item.del !== '1';
          } else {
            return item.del !== '1' || (item.del === '1' && item.value == selected);
          }
        })
        .map(item => ({
          value: item.value,
          displayValue: item.text
        }));
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end

      if (this.inputModel.deviceEdgeNo != 0) {
        const dispStr = this.mstMachineList.find(
          lm => lm.value === this.inputModel.deviceEdgeNo
        );
        if (dispStr) {
          this.dispDeviceEdgeNo = dispStr.displayValue;
        } else {
          this.dispDeviceEdgeNo = "未登録";
        }
      } else {
        this.dispDeviceEdgeNo = "未登録";
      }
    },
    calculateWidth() {
      if (document.getElementById('tab-item-list-area') !== null) {
        this.conWidth = document.getElementById('tab-item-list-area').scrollWidth;
      } else {
        this.conWidth = 0;
      }
    },
    validateData() {
      const lcdReport = JSON.parse(this.editRecord.lcdReport);
      return lcdReport.report_item.length <= 8
    },
    // add 装置通信・仮想端末マスタ 障害対応No219 不正値も保存できます start
    validateDataLcdMenu() {
      const lcdMenu = JSON.parse(this.editRecord.lcdMenu);
      for (const key in lcdMenu) {
        switch (key) {
          case "menu1_title":
          case "menu2_title":
          case "menu3_title":
          case "menu4_title":
            if (lcdMenu[key].length > 6) {
              return 1;
            }
            break;
          case "menu1_item":
          case "menu2_item":
          case "menu3_item":
          case "menu4_item":
            for (const e of lcdMenu[key]) {
              if (e.name.length > 12) {
                return 2;
              }
            }
            break;
        }
      }
      return 0
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
      if (JSON.stringify(this.editRecord).replace(/\s/g, '') !== JSON.stringify(this.initEditRecord).replace(/\s/g, '')) {
        EventBus.$emit("mstHolidayRegistered", false);
      } else {
        EventBus.$emit("mstHolidayRegistered", true);
      }
      // EventBus.$emit("mstHolidayRegistered", false);
      // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
    },
    // add 装置通信・仮想端末マスタ 障害対応No219 不正値も保存できます end
    validateOnRegistration() {
      // add 装置通信・仮想端末マスタ 障害対応No219 不正値も保存できます start
      if (this.validateDataLcdMenu() !== 0) {
        // メッセージ組み立て
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // let title = 'チェックエラー';
        let title = DIALOG_MESSAGES[12000008].title;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        let message = '';
        // add 全マスタメッセージ調整 王 start
        switch (this.validateDataLcdMenu()) {
          case 1:
            // message = 'メニュー文字列が6文字を超えています。';
            message = DIALOG_MESSAGES[12000008].message;
            break;
          case 2:
            // message = 'メニュー項目文字列が12文字を超えています。';
            message = DIALOG_MESSAGES[12000009].message;
        }
        // add 全マスタメッセージ調整 王 start
        // ダイアログ表示
        this.$ons.notification.alert({
          title: title,
          message: message
        });
        return false;
      }
      // add 装置通信・仮想端末マスタ 障害対応No219 不正値も保存できます end

      if (this.validateData()) {
        return true;
      }
      this.tabValues = this.TAB_VALUES.DIALYSIS;
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = '仮想端末の透析日報は最大8項目まで表示可能です。';
      // const message ='表示対象を8項目以下にしてください。';
      const title = DIALOG_MESSAGES[12000321].title;
      const message = messageFormat(DIALOG_MESSAGES[12000321].message);
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    }
  },
  watch: {
    windowWidth() {
      this.calculateWidth();
    },
    fontSize() {
      setTimeout(() => {
        this.calculateWidth();
      }, 200);
    },
    // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
    editRecord: {
      handler() {
        this.changeButton();
      },
      deep: true
    }
    // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
  },
  mounted() {
    // 描画系の処理がすべて完了した後に実行される処理
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "deviceEdgeNo") {
        this.inputModel.deviceEdgeNo = this.getValueByField(
          this.columnDefinition[num].field
        );
        this.getDeviceEdgeNoList();
      }
    }
    this.$nextTick(() => {
      this.calculateWidth();
    });
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
    //mod マスタ詳細画面がありません破棄メッセージ
    this.initDeviceEdgeNo = this.inputModel.deviceEdgeNo;
    // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc start
    this.initEditRecord = JSON.parse(JSON.stringify(this.editRecord));
    // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（装置通信・仮想端末マスタ画面）20231108 ztc end
    
    // 編集前のレコード退避
    this.setInitEditRecord(this.initEditRecord);
  }
};
</script>

<style scoped>
table {
  border-collapse: collapse;
}
table th,
table td {
  border: solid 1px black;
}

/* [メイン] タブ切り替え全体のスタイル*/
.tabs {
  margin-top: 40px;
  /* background-color: #fff; */
  width: auto;
  height: auto;
  margin: 0 auto;
}
/* [メイン] タブのスタイル*/
.tab_item {
  width: calc(100% / 6);
  min-width: 6em;
  height: 50px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 50px;
  text-overflow: ellipsis;
  white-space: nowrap;
  text-align: center;
  color: #565656;
  display: block;
  text-align: center;
  font-weight: bold;
  transition: all 0.2s ease;
}
.tab_item:hover {
  opacity: 0.75;
}
/* [メイン] ラジオボタンを全て消す*/
input[name="tab_item"] {
  display: none;
}
/* [メイン] タブ切り替えの中身のスタイル*/
.tab_content {
  display: none;
  clear: both;
  height: calc(100% - 54px);
}
/* [メイン] 選択されているタブのコンテンツのみを表示*/
#basic:checked ~ #basic_content,
#staff:checked ~ #staff_content,
#virtual:checked ~ #virtual_content,
#patient:checked ~ #patient_content,
#dialysis:checked ~ #dialysis_content,
#graph:checked ~ #graph_content {
  display: block;
  padding: 20px 20px 0px 20px;
}
.displaying-tab {
  display: block;
}
/* [メイン] 選択されているタブのスタイルを変える*/
.tabs input:checked + .tab_item {
  background-color: #2a8bc4;
  color: #fff;
}

.main-content-area-menu {
  display: flex;
  flex-direction: column;
}

.hidden-item {
  display: none;
}

.ins-tab-content {
  height: calc(100% - 15px);
  margin-top: 15px;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}
.nowrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: nowrap;
}
.btn-area {
  /* position: absolute; */
  display: flex;
  justify-content: space-between;
  left: 8px;
  bottom: 3px;
  flex-basis: 80%;
}
.item-data {
  margin-left: 0.5em;
  min-width: 7em;
}
.k-grid-toolbar {
  padding: 0.3em 0 0 0;
  background-color: var(--ntss-base-background-color);
  color: var(--ntss-base-color);
}
.kendo-grid-toolbar-style {
  height: calc(100% - 2.5em);
  border-bottom: none;
}
.ntss-comsv-modal {
  background-color: var(--ntss-base-background-color);
  height: 100%;
}
.label-header {
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
  height: 2.1em;
}
.main-content-area-custom {
  height: 100%;
  margin-left: 10px;
  margin-bottom: 0;
}
</style>
