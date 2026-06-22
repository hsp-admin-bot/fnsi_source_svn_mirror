/**
 * 体重計設定画面
 */
<template>
  <div class="main-content-area">
    <div class="ntss-list">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div class="mst-weight-main-content-area" ref="mstWeightMainContentArea">
          <div class="tabs">
            <input
              id="scale"
              type="radio"
              name="tab_item"
              @click="changeTab($event, scaleTabId)"
              checked
            />
            <label class="tab_item" for="scale">{{ isScaleBed ? "スケールベッド設定" : "体重計設定" }}</label>
            <template v-if="isScaleBed">
              <input
                id="scale_bed"
                type="radio"
                name="tab_item"
                @click="changeTab($event, scaleMstTabId)"
                @change="clickScaleMstTab"
              />
              <label class="tab_item" for="scale_bed">スケールベッドマスタ</label>
            </template>
            <input
              id="check"
              type="radio"
              name="tab_item"
              @change="clickCheckTab"
              @click="changeTab($event, checkTabId)"
            />
            <label class="tab_item" for="check">測定チェック</label>
            <input id="print" type="radio" name="tab_item" @click="changeTab($event, printTabId)" @change="clickPrintTab" />
            <label class="tab_item" for="print">印字</label>
            <input id="color" type="radio" name="tab_item" @click="changeTab($event, colorTabId)" />
            <label class="tab_item" for="color">配色</label>
            <template v-if="!isScaleBed">
              <input id="guide" type="radio" name="tab_item" @click="changeTab($event, guideTabId)" />
              <label class="tab_item" for="guide">音声ガイダンス</label>
            </template>

            <!-- 体重計設定タブ -->
            <div class="tab_content" id="scale_content">
              <div class="tab_content_description">
                <mst-weight-setting-item ref="child" />
              </div>
            </div>
            <!-- 測定チェックタブ -->
            <div class="tab_content" id="check_content">
              <div class="tab_content_description">
                <mst-weight-setting-check-item ref="chk" />
              </div>
            </div>

            <!-- 印字タブ -->
            <div class="tab_content" id="print_content">
              <div class="tab_content_description">
                <mst-weight-setting-printing-item ref="print" />
              </div>
            </div>

            <!-- 配色タブ -->
            <div class="tab_content" id="color_content">
              <div class="tab_content_description">
                <mst-weight-setting-color-item ref="color" />
              </div>
            </div>
            <!-- 音声ガイダンスタブ -->
            <div class="tab_content" id="guide_content">
              <div class="tab_content_description">
                <mst-weight-setting-audio-item ref="audio" />
              </div>
            </div>
            <!-- スケールベッドマスタータブ -->
            <div class="tab_content" id="scale_bed_content">
              <div class="tab_content_description">
                <mst-scale-bed-setting-item ref="scaleBed" />
              </div>
            </div>
          </div>
        </div>
      </kendo-grid-toolbar>
      <div id="detail-footer">
        <v-ons-row width="100%">
          <v-ons-col width="50%">
            <v-ons-button style="width:auto" class="btn2-cancel button denial-btn" @click="dispCancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button style="width:auto" class="common-style-select-button button registration-btn" :disabled="whetherToEdit" @click="updSetting">確定</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import MstWeightSettingItem from "@/components/master-maintenance/mst-weight/sub-item/MstWeightTabConfig";
import MstWeightSettingCheckItem from "@/components/master-maintenance/mst-weight/sub-item/MstWeightTabCheck";
import MstWeightSettingAudioItem from "@/components/master-maintenance/mst-weight/sub-item/MstWeightTabAudio";
import MstWeightSettingColorItem from "@/components/master-maintenance/mst-weight/sub-item/MstWeightTabColor";
import MstWeightSettingPrintingItem from "@/components/master-maintenance/mst-weight/sub-item/MstWeightTabPrinting";
import MstScaleBedSettingItem from "@/components/master-maintenance/mst-weight/sub-item/MstScaleBedTabConfig";
import NextTransitionMixin from "@/components/NextTransitionMixin";
//mod マスタ詳細画面がありません破棄メッセージ 张博 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
//mod マスタ詳細画面がありません破棄メッセージ 张博 end
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import isEqualWith from "@/compat/collections/lodash/isEqualWith";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";

import { customComparator } from "@/utils/util.js"

// ストアについて
// testStateストアの実体は/stores/modules/test-store.jsである。
// この名前と実体ファイルの関連付けは/stores.store.jsに定義されている。

export default {
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null
  },
  mixins: [NextTransitionMixin],
  components: {
    "mst-weight-setting-item": MstWeightSettingItem,
    "mst-weight-setting-check-item": MstWeightSettingCheckItem,
    "mst-weight-setting-audio-item": MstWeightSettingAudioItem,
    "mst-weight-setting-color-item": MstWeightSettingColorItem,
    "mst-weight-setting-printing-item": MstWeightSettingPrintingItem,
    "mst-scale-bed-setting-item": MstScaleBedSettingItem
  },
  data() {
    return {
      mainAreaHeight: 500,
      mstWeightHeight: 300,
      tabSelectedId: 0,
      whetherToEdit: true,
      editRecordClone: {}
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd"
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      masterPhysicalName: "getMasterName",
      editRecord: "getEditRecord"
    }),
    ...mapGetters("mst-weight", {
      getIsGridEditing: "getIsGridEditing"
    }),
    const() {
      return {
        scaleTabId: 0,
        checkTabId: 1,
        printTabId: 2,
        colorTabId: 3,
        guideTabId: 4,
        scaleMstTabId: 5
      };
    },
    scaleMstTabId() {
      return this.const.scaleMstTabId;
    },
    scaleTabId() {
      return this.const.scaleTabId;
    },
    checkTabId() {
      return this.const.checkTabId;
    },
    printTabId() {
      return this.const.printTabId;
    },
    colorTabId() {
      return this.const.colorTabId;
    },
    guideTabId() {
      return this.const.guideTabId;
    },
    // 高さ調整
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.mainAreaHeight}px` };
    },
    isScaleBed() {
      return this.editRecordClone?.weightType === "1";
    }
  },
  methods: {
    ...mapActions("master-maintenance", [
      "setEditRecord",
      "setMasterRecordList",
      "editRecordBeEmpty"
    ]),
    ...mapActions("send-condition/scale/audio", ["initAudio"]),
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start   
    ...mapActions("mst-weight",["setIsChangedMstWeight"]),
    // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
    changeTab(ev, selectedId) {
      const currentId = this.tabSelectedId;
      this.selectedSelection = [];
      // 選択中のタブがクリックされた場合は処理しない
      if (selectedId != currentId && currentId === this.printTabId) {
        const onRegistration = this.$refs.print.validateOnRegistration;
        if (onRegistration) {
          const validationResult = onRegistration();
          if (!validationResult) {
            ev.preventDefault();
            return;
          }
        }
      }
      this.tabSelectedId = selectedId;
    },
    clickCheckTab() {
      const updateWidget = this.$refs.chk.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },
    clickPrintTab() {
      const updateWidget = this.$refs.print.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },
    clickScaleMstTab() {
      const updateWidget = this.$refs.scaleBed?.updateWidget;
      if (updateWidget) {
        updateWidget();
      }
    },

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.getIsGridEditing) {
        const wh = this.windowHeight;
        const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
        const fmh =
          this.isDispMenu === 1
            ? getFooterMenuClientHeight(this.$el || null)
            : 0;
        // main部の高さ設定(ウィンドウ高さ－ヘッダー高さ－メニューバー高さ)
        this.mainAreaHeight = wh - hh - fmh;

        const gfh = getScopedElementById("detail-footer", this.$el || this).offsetHeight;
        // 体重計マスタmainコンテンツ高さ設定(親要素(main部)の高さ－確定/キャンセルボタンエリア高さ)
        this.$refs.mstWeightMainContentArea.style.height = `calc(100% - ${gfh}px)`;
      }
    },
    syncChildEditRecords() {
      // 確定ボタン押下時にフォーカスアウトしていない入力値もeditRecordへ反映する。
      [
        this.$refs.child,
        this.$refs.chk,
        this.$refs.print,
        this.$refs.color,
        this.$refs.audio,
        this.$refs.scaleBed
      ].forEach(ref => {
        if (typeof ref?.syncEditRecord === "function") {
          ref.syncEditRecord();
        }
      });
    },
    // キャンセルボタン
    dispCancel() {
      //mod マスタ詳細画面がありません破棄メッセージ 张博 start
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start     
      // const item1 = this.$refs["child"].passFather();
      // const item2 = this.$refs["audio"].passFather();
      // const item3 = this.$refs["color"].passFather();
      // const item4 = this.$refs["print"].passFather();
      // del #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start   
      // if (item1||item2||item3||item4) {
      if (!this.whetherToEdit) {
      // mod #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: async answer => {
            if (answer === 1) {
                    // state.editRecordを空にする
                    this.editRecordBeEmpty();
                    // 体重計設定画面表示
                    this.$emit("close");
            }
          }
        })
      }else{
                    // state.editRecordを空にする
                    this.editRecordBeEmpty();
                    // 体重計設定画面表示
                    this.$emit("close");
      }
      //mod マスタ詳細画面がありません破棄メッセージ 张博 end
    },
    // 確定ボタン
    updSetting() {
      // フォーカスアウト前の入力値も確定対象にする。
      this.syncChildEditRecords();
      // 体重計設定情報登録
      const onRegistrationList = [
        this.$refs.child?.validateOnRegistration,
        this.$refs.chk?.validateOnRegistration,
        this.$refs.print?.validateOnRegistration,
        this.$refs.color?.validateOnRegistration,
        this.$refs.audio?.validateOnRegistration,
        this.$refs.scaleBed?.validateOnRegistration
      ];
      for (const onRegistration of onRegistrationList) {
        if (onRegistration) {
          const validationResult = onRegistration();
          if (!validationResult) return;
        }
      }

      const masterRecordList = this.getMasterRecordList;

      // state.editRecordを取得
      const editRecord = this.editRecord;
      // operationがないときは編集とみなす
      if (!editRecord.operation) {
        editRecord.operation = 2;
      } else if (editRecord.operation === 1) {
        // "追加"の場合は、"編集済"フラグを立てる
        editRecord.edited = true;
      }

      // state.masterRecordListにマージ
      const index = masterRecordList.data.findIndex(
        masterRecord => masterRecord.code === editRecord.code
      );
      masterRecordList.data[index] = editRecord;

      // TODO: 共通マスメン側で修正するかも？
      this.setMasterRecordList(undefined);
      this.setMasterRecordList(masterRecordList);

      // state.editRecordを空にする
      this.editRecordBeEmpty();

      // 体重計設定画面表示
      this.$emit("close");
    },
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240108 mrx start
    editRecord: {
      handler (val) {
        const cloneTemp = cloneDeep(val);
        const cloneTemp2 = cloneDeep(this.editRecordClone);
        const parseArr = ['audioSetting', 'checkContent', 'colorSetting', 'printSetting', 'telegramFormat', 'scaleBedSetting']
        parseArr.forEach((item) => {
          cloneTemp[item] = cloneTemp[item] ? JSON.parse(cloneTemp[item]) : [];
          cloneTemp2[item] = cloneTemp2[item] ? JSON.parse(cloneTemp2[item]) : [];
        });
        this.whetherToEdit = isEqualWith(cloneTemp, cloneTemp2, customComparator);
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 start      
        this.setIsChangedMstWeight(this.whetherToEdit)
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240125 張玲 end
      },
      deep: true
    }
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_体重計マスタ 20240108 mrx end
  },
  created() {
    this.initAudio();
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    this.whetherToEdit = true;
    this.editRecordClone = cloneDeep(this.editRecord);
  },
};
</script>
<style scoped>
.mst-weight-main-content-area {
  overflow: hidden;
  overflow-y: auto;
  padding: 0 5px; /* 確定／キャンセルボタンと左右位置合わせ */
}

/* [メイン] タブ切り替え全体のスタイル*/
.tabs {
  margin-top: 40px;
  /* background-color: #fff; */
  width: auto;
  margin: 0 auto;
}
/* [メイン] タブのスタイル*/
.tab_item {
  width: calc(100% / 5);
  height: 50px;
  border-bottom: 3px solid #5ab4bd;
  background-color: #d9d9d9;
  line-height: 50px;
  text-align: center;
  color: #565656;
  display: block;
  float: left;
  text-align: center;
  font-weight: bold;
  transition: all 0.2s ease;
  text-overflow: ellipsis;
  white-space: nowrap;
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
  padding: 10px 10px 0;
  clear: both;
  overflow-y: auto;
}
/* [メイン] 選択されているタブのコンテンツのみを表示*/
#scale:checked ~ #scale_content,
#check:checked ~ #check_content,
#print:checked ~ #print_content,
#color:checked ~ #color_content,
#scale_bed:checked ~ #scale_bed_content,
#guide:checked ~ #guide_content {
  display: block;
}
/* 測定チェック・印字はGrid表示域をできる限り多く確保する為、余計な余白除去 */
#check:checked ~ #check_content,
#print:checked ~ #print_content {
  padding: 0;
}
/* [メイン] 選択されているタブのスタイルを変える*/
.tabs input:checked + .tab_item {
  background-color: #2a8bc4;
  color: #fff;
}

.main-content-area {
  display: flex;
  flex-direction: column;
  margin: 0; /* 親コンポーネント側との二重マージンを抑制 */
}

.hidden-item {
  display: none;
}

.tab_content_description {
  overflow-y: auto;
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

.kendo-grid-toolbar-style {
  padding: 0; /* ライブラリのスタイル打消し */
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}

#detail-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.right {
  text-align: right;
}

.tab_content_description .text-area .text-input {
  font-size: 100% !important;
}
</style>
