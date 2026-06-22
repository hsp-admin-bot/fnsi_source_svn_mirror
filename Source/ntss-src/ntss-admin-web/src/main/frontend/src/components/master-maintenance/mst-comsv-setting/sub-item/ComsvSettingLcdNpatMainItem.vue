
<template>
  <div class="disp-item-list custom-disp-item-list">
    <table style="padding-left: 2.4em;">
      <thead>
        <tr>
          <th class="th-font-weight" style="width: 2em;">No</th>
          <th align="center" style="width: 4em;" class="th-font-weight">表示/<br>非表示</th>
          <th class="th-font-weight" style="padding-left:6px;">項目名 ((＊)：2段組可能項目)</th>
        </tr>
      </thead>
    </table>
    <draggable
      v-model="localEditDataSource"
      animation="250"
      handle=".drag-handle"
      :forceFallback="true"
      @change="onSave"
    >
      <div v-for="(item, index) in localEditDataSource" :index="index" :key="item.code">
        <div class="drag-item">
          <div align="center" class="drag-handle">
            <ons-toolbar-button>
              <ons-icon icon="fa-sort"></ons-icon>
            </ons-toolbar-button>
          </div>
          <div class="no-width"><label>{{ item.no }}</label></div>
          <div align="center" class="drag-item-button-area">
            <v-ons-switch
              v-model="item.dispflag"
              @change="onSave($event, item.code)"
              @mousedown.stop @touchstart.stop>
            </v-ons-switch>
          </div>
          <div class="drag-item-label">
            {{ `${item.name}${item.isSplit === "1" ? "(＊)" : ''}` }}
          </div>
        </div>
      </div>
    </draggable>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { VueDraggable } from "@/compat/drag/VueDraggable";
// #10161 2023.12.27 del 未使用importに気づいたので削除(※#10161内容は直接の関係なし) TDC山崎 start
// import {EventBus} from "@/compat/vue/event-bus.js";
// // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
// import { messageFormat } from '@/functions/common/MessageFormat';
// import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
// #10161 2023.12.27 del 未使用importに気づいたので削除(※#10161内容は直接の関係なし) TDC山崎 end
// #10161 2023.12.27 del 未使用importに気づいたので削除(※#10161内容は直接の関係なし) TDC山崎 end

export default {
  name: "comsvSettingLcdNpat",
  components: {
    "draggable": VueDraggable
  },
  data() {
    return {
      lcdNpatList: [
        // #10161 2023.12.27 chg 装置通信・仮想端末マスタの次患者データの設定の新規追加直後のデフォルト表示順を修正 TDC山崎 start
        /*
        {
          code: 1,
          name: "患者ID",
          dispflag: 0
        },
        {
          code: 2,
          name: "患者名フリガナ",
          dispflag: 0
        },
        {
          code: 3,
          name: "性別・年齢",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 4,
          name: "状態",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 5,
          name: "病棟",
          dispflag: 0
        },
        {
          code: 6,
          name: "診療科",
          dispflag: 0
        },
        {
          code: 7,
          name: "主治医",
          dispflag: 0
        },
        {
          code: 8,
          name: "DW",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 9,
          name: "VA",
          dispflag: 0
        },
        {
          code: 10,
          name: "治療方法",
          dispflag: 0
        },
        {
          code: 11,
          name: "治療開始予定時刻",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 12,
          name: "治療時間",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 13,
          name: "治療モード",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 14,
          name: "ダイアライザ名",
          dispflag: 0
        },
        {
          code: 15,
          name: "A針名",
          dispflag: 0
        },
        {
          code: 16,
          name: "V針名",
          dispflag: 0
        },
        {
          code: 17,
          name: "抗凝固剤名",
          dispflag: 0
        },
        {
          code: 18,
          name: "抗凝固剤ワンショット量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 19,
          name: "抗凝固剤持続注入量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 20,
          name: "抗凝固剤持続総量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 21,
          name: "抗凝固剤総量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          dispflag: 0
        },
        {
          code: 22,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 23,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 24,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 25,
          name: "医療材料1",
          dispflag: 0
        },
        {
          code: 26,
          name: "医療材料2",
          dispflag: 0
        },
        {
          code: 27,
          name: "医療材料3",
          dispflag: 0
        },
        {
          code: 28,
          name: "医療材料4",
          dispflag: 0
        },
        {
          code: 29,
          name: "医療材料5",
          dispflag: 0
        },
        {
          code: 30,
          name: "医療材料6",
          dispflag: 0
        },
        {
          code: 31,
          name: "医療材料7",
          dispflag: 0
        },
        {
          code: 32,
          name: "医療材料8",
          dispflag: 0
        },
        {
          code: 33,
          name: "医療材料9",
          dispflag: 0
        },
        {
          code: 34,
          name: "医療材料10",
          dispflag: 0
        },
        {
          code: 35,
          name: "透析液",
          dispflag: 0
        },
        {
          code: 36,
          name: "投与薬剤1",
          dispflag: 0
        },
        {
          code: 37,
          name: "投与薬剤2",
          dispflag: 0
        },
        {
          code: 38,
          name: "投与薬剤3",
          dispflag: 0
        },
        {
          code: 39,
          name: "投与薬剤4",
          dispflag: 0
        },
        {
          code: 40,
          name: "投与薬剤5",
          dispflag: 0
        },
        {
          code: 41,
          name: "投与薬剤6",
          dispflag: 0
        },
        {
          code: 42,
          name: "投与薬剤7",
          dispflag: 0
        },
        {
          code: 43,
          name: "投与薬剤8",
          dispflag: 0
        },
        {
          code: 44,
          name: "投与薬剤9",
          dispflag: 0
        },
        {
          code: 45,
          name: "投与薬剤10",
          dispflag: 0
        },
        {
          code: 46,
          name: "投与薬剤11",
          dispflag: 0
        },
        {
          code: 47,
          name: "投与薬剤12",
          dispflag: 0
        },
        {
          code: 48,
          name: "投与薬剤13",
          dispflag: 0
        },
        {
          code: 49,
          name: "投与薬剤14",
          dispflag: 0
        },
        {
          code: 50,
          name: "投与薬剤15",
          dispflag: 0
        },
        {
          code: 51,
          name: "投与薬剤16",
          dispflag: 0
        },
        {
          code: 52,
          name: "投与薬剤17",
          dispflag: 0
        },
        {
          code: 53,
          name: "投与薬剤18",
          dispflag: 0
        },
        {
          code: 54,
          name: "投与薬剤19",
          dispflag: 0
        },
        {
          code: 55,
          name: "投与薬剤20",
          dispflag: 0
        },
        // add bug 8009 修正 chen start
        {
          code: 56,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "目標体重(＊)",
          name: "目標体重",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 57,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "血流量(＊)",
          name: "血流量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 58,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "IP速度(＊)",
          name: "IP速度",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 59,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "IPワンショット量(＊)",
          name: "IPワンショット量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 60,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "IP自動切時間(＊)",
          name: "IP自動切時間",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 61,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "補液選択(＊)",
          name: "補液選択",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 62,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "補液量(＊)",
          name: "補液量",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 63,
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen start
          // name: "補液速度(＊)",
          name: "補液速度",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
          isSplit: "1",
          // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
          // mod #8009 「通信サーバ仮想端末マスタで不足している項目がある」について、対応する。 dengshen end
          dispflag: 0
        },
        {
          code: 64,
          name: "一次膜",
          dispflag: 0
        },
        // add bug 8009 修正 chen end
        {
          code: 91,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 92,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 93,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 94,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 95,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 96,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 97,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 98,
          name: "(空行)",
          dispflag: 0
        },
        {
          code: 99,
          name: "(空行)",
          dispflag: 0
        }
        */

        { code: 1, name: "患者ID", dispflag: 0 },
        { code: 2, name: "患者名フリガナ", dispflag: 0 },
        { code: 3, name: "性別・年齢", isSplit: "1", dispflag: 0 },
        { code: 4, name: "入外", isSplit: "1", dispflag: 0 },
        { code: 5, name: "病棟", dispflag: 0 },
        { code: 6, name: "診療科", dispflag: 0 },
        { code: 7, name: "主治医", dispflag: 0 },
        { code: 10, name: "治療方法", dispflag: 0 },
        { code: 13, name: "治療モード", isSplit: "1", dispflag: 0 },
        { code: 11, name: "治療開始予定時刻", isSplit: "1", dispflag: 0 },
        { code: 12, name: "治療時間", isSplit: "1", dispflag: 0 },
        { code: 8, name: "DW", isSplit: "1", dispflag: 0 },
        { code: 56, name: "目標体重", isSplit: "1", dispflag: 0 },
        { code: 14, name: "ダイアライザ名", dispflag: 0 },
        { code: 64, name: "一次膜", dispflag: 0 },
        { code: 57, name: "血流量", isSplit: "1", dispflag: 0 },
        { code: 9, name: "VA", dispflag: 0 },
        { code: 15, name: "A針名", dispflag: 0 },
        { code: 16, name: "V針名", dispflag: 0 },
        { code: 35, name: "透析液", dispflag: 0 },
        { code: 61, name: "補液選択", isSplit: "1", dispflag: 0 },
        { code: 62, name: "補液量", isSplit: "1", dispflag: 0 },
        { code: 63, name: "補液速度", isSplit: "1", dispflag: 0 },
        { code: 17, name: "抗凝固剤名", dispflag: 0 },
        { code: 18, name: "抗凝固剤ワンショット量", isSplit: "1", dispflag: 0 },
        { code: 19, name: "抗凝固剤持続注入量", isSplit: "1", dispflag: 0 },
        { code: 20, name: "抗凝固剤持続総量", isSplit: "1", dispflag: 0 },
        { code: 21, name: "抗凝固剤総量", isSplit: "1", dispflag: 0 },
        { code: 59, name: "IPワンショット量", isSplit: "1", dispflag: 0 },
        { code: 58, name: "IP速度", isSplit: "1", dispflag: 0 },
        { code: 60, name: "IP電源自動切り・時間", isSplit: "1", dispflag: 0 }, // #9147 2024.01.24 chg [IP自動切時間]→[IP電源自動切り・時間] TDC山崎
        { code: 36, name: "投与薬剤1", dispflag: 0 },
        { code: 37, name: "投与薬剤2", dispflag: 0 },
        { code: 38, name: "投与薬剤3", dispflag: 0 },
        { code: 39, name: "投与薬剤4", dispflag: 0 },
        { code: 40, name: "投与薬剤5", dispflag: 0 },
        { code: 41, name: "投与薬剤6", dispflag: 0 },
        { code: 42, name: "投与薬剤7", dispflag: 0 },
        { code: 43, name: "投与薬剤8", dispflag: 0 },
        { code: 44, name: "投与薬剤9", dispflag: 0 },
        { code: 45, name: "投与薬剤10", dispflag: 0 },
        { code: 46, name: "投与薬剤11", dispflag: 0 },
        { code: 47, name: "投与薬剤12", dispflag: 0 },
        { code: 48, name: "投与薬剤13", dispflag: 0 },
        { code: 49, name: "投与薬剤14", dispflag: 0 },
        { code: 50, name: "投与薬剤15", dispflag: 0 },
        { code: 51, name: "投与薬剤16", dispflag: 0 },
        { code: 52, name: "投与薬剤17", dispflag: 0 },
        { code: 53, name: "投与薬剤18", dispflag: 0 },
        { code: 54, name: "投与薬剤19", dispflag: 0 },
        { code: 55, name: "投与薬剤20", dispflag: 0 },
        { code: 25, name: "医療材料1", dispflag: 0 },
        { code: 26, name: "医療材料2", dispflag: 0 },
        { code: 27, name: "医療材料3", dispflag: 0 },
        { code: 28, name: "医療材料4", dispflag: 0 },
        { code: 29, name: "医療材料5", dispflag: 0 },
        { code: 30, name: "医療材料6", dispflag: 0 },
        { code: 31, name: "医療材料7", dispflag: 0 },
        { code: 32, name: "医療材料8", dispflag: 0 },
        { code: 33, name: "医療材料9", dispflag: 0 },
        { code: 34, name: "医療材料10", dispflag: 0 },
        { code: 22, name: "(空行)", dispflag: 0 },
        { code: 23, name: "(空行)", dispflag: 0 },
        { code: 24, name: "(空行)", dispflag: 0 },
        { code: 91, name: "(空行)", dispflag: 0 },
        { code: 92, name: "(空行)", dispflag: 0 },
        { code: 93, name: "(空行)", dispflag: 0 },
        { code: 94, name: "(空行)", dispflag: 0 },
        { code: 95, name: "(空行)", dispflag: 0 },
        { code: 96, name: "(空行)", dispflag: 0 },
        { code: 97, name: "(空行)", dispflag: 0 },
        { code: 98, name: "(空行)", dispflag: 0 },
        { code: 99, name: "(空行)", dispflag: 0 }
        // #10161 2023.12.27 chg 装置通信・仮想端末マスタの次患者データの設定の新規追加直後のデフォルト表示順を修正 TDC山崎 end
      ],
      localDataSource: [
        {
          code: 1,
          name: "患者ＩＤ",
          dispflag: 0,
          viewOrder: 0,
          backColor: ""
        },
        {
          code: 2,
          name: "患者名フリガナ",
          dispflag: 0,
          viewOrder: 1,
          backColor: ""
        },
        {
          code: 9,
          name: "ＶＡ",
          dispflag: 0,
          viewOrder: 2,
          backColor: ""
        }
      ],
      localEditDataSource: [],
      inputModel: {
        comsvCd: "",
        facilityCd: "",
        deviceEdgeNo: "",
        lcdNpat: ""
      },
      initLocalEditDataSource:{},
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    })
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

    getValueByField(field) {
      return this.editRecord[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    // #9147 2023.12.22 chg 装置通信・仮想端末マスタの患者情報で表示項目の10件制限を廃止 TDC山崎 start
    //onSave(ev, editCode){
    onSave() {
    // #9147 2023.12.22 chg 装置通信・仮想端末マスタの患者情報で表示項目の10件制限を廃止 TDC山崎 end
      this.$nextTick(() => {
        // #9147 2023.12.22 del 装置通信・仮想端末マスタの患者情報で表示項目の10件制限を廃止 TDC山崎 start
        // // バリデーションチェック.
        // if (this.localEditDataSource.filter(dat => dat.dispflag === true).length > 10) {
        //   this.$ons.notification.alert({
        //     // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        //     // title: "更新失敗",
        //     // message: "表示の件数を10件以上にすることは出来ません。"
        //     title: DIALOG_MESSAGES['00200046'].title,
        //     message: messageFormat(DIALOG_MESSAGES['00200046'].message),
        //     // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
        //   });
        //   // トグルとデータは既に編集されてしまっているので戻す
        //   if (typeof(editCode) === "number") {
        //     this.localEditDataSource.forEach(data => {
        //       if (data.code === editCode) {
        //         data.dispflag = false;
        //       }
        //     });
        //     ev.target.children[0].checked = false;
        //   }
        //   return;
        // }
        // #9147 2023.12.22 del 装置通信・仮想端末マスタの患者情報で表示項目の10件制限を廃止 TDC山崎 end

        //番号の振り直し
        let idx = 0;
        let tmpData = deepCopy(this.localEditDataSource);
        tmpData.forEach(data => {
          data.no = ++idx;
        });
        this.localEditDataSource = tmpData;

        const registlcdNpat = this.localEditDataSource
          .filter(dat => dat.dispflag === true)
          .map((dat, idx) => ({
            no: idx + 1,
            code: dat.code,
            name: dat.name
          }));

        // データ登録
        let jsonData = { npat_item: registlcdNpat };
        this.updateEditRecord("lcdNpat", JSON.stringify(jsonData));
      });
    }
  },


  mounted() {
    // 描画系の処理がすべて完了した後に実行される処理
    for (const num in this.columnDefinition) {
      if (this.columnDefinition[num].field === "comsvCd") {
        this.inputModel.comsvCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      if (this.columnDefinition[num].field === "facilityCd") {
        this.inputModel.facilityCd = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      if (this.columnDefinition[num].field === "deviceEdgeNo") {
        this.inputModel.deviceEdgeNo = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
      if (this.columnDefinition[num].field === "lcdNpat") {
        this.inputModel.lcdNpat = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
    }
    // 次患者表示情報とチェック対象の項目をマージして入れる
    if (!this.inputModel.lcdNpat) {
      this.inputModel.lcdNpat = '{"npat_item": []}';
    }
    const lcdNpat = JSON.parse(this.inputModel.lcdNpat);
    if (lcdNpat !== null) {
      // 保存データがある場合は展開する
      this.localDataSource = lcdNpat.npat_item.map((dat, idx) => ({
        code: dat.code,
        name: dat.name,
        dispflag: 1,
        viewOrder: String.toString(idx),
        backColor: ""
      }));
      const undispflagData = this.lcdNpatList.filter(
        dat =>
          this.localDataSource.findIndex(
            dispflag => dispflag.code === dat.code
          ) < 0
      );
      // 足りないデータ(非表示データ)を追加
      this.localDataSource = this.localDataSource.concat(
        undispflagData.map((dat, idx) => ({
          code: dat.code,
          name: dat.name,
          dispflag: 0,
          viewOrder: this.localDataSource.length + idx,
          backColor: ""
        }))
      );
    } else {
      // 保存データが存在しない場合は、内部定義データで初期化する
      this.localDataSource = this.lcdNpatList.map((dat, idx) => ({
        code: dat.code,
        name: dat.name,
        dispflag: 0,
        viewOrder: 1 + idx,
        backColor: ""
      }));
    }
    let idx = 0;
    this.localDataSource.forEach(data => {
      data.no = ++idx;
      // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 start
      const target = this.lcdNpatList.find(x => x.code === data.code);
      if (target?.isSplit === "1") {
        data.isSplit = "1";
      }
      // #9147 2023.11.21 add 次患者情報2段組設定の追加 TDC片口 end
    });
    // 編集用にデータを補正(初期表示時にdispflagが型違いでエラーになる為、一時データで編集してから適用する)
    let tmpData = this.localDataSource;
    tmpData.forEach(data => {
      data.dispflag = !!data.dispflag;
    });
    this.localEditDataSource = tmpData;
    this.initLocalEditDataSource = JSON.parse(JSON.stringify(this.localEditDataSource));
  }
};
</script>

<style scoped>
/* グリッドのスタイル */
.disp-item-list {
  border-collapse: collapse;
  margin: 0 auto;
  margin-top: 0.5em;
  top: 100px;
  width: calc(100% - 40px - 0.3em);
  background-color: var(--ntss-list-header-backgroud-color);
}
.kendo-grid-toolbar-style {
  --height: 100%;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.no-width {
  width: 2em;
  text-align: right;
  margin-right: 0.5em;
}
.disp-item-list table th {
  background-image: none !important;
}
.drag-item {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  flex-wrap: nowrap;
  width: max-content;
}
.drag-item-button-area {
  width: 5em;
  padding-bottom: 3px;
  min-width: max-content;
}
.th-font-weight {
  font-weight: unset;
}
</style>
