<template>
  <div class="disp-item-list custom-disp-item-list">
    <table style="padding-left: 2.4em;">
      <thead>
        <tr>
          <th class="th-font-weight" style="width: 2em;">No</th>
          <th align="center" class="th-font-weight" style="width: 4em;">表示/<br>非表示</th>
          <th class="th-font-weight" style="padding-left:6px;">項目名</th>
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
            {{ item.name }}
          </div>
        </div>
      </div>
    </draggable>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import { deepCopy } from "@/functions/common/CommonFunctions";
import vuedraggable from "vuedraggable"
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {messageFormat} from "@/functions/common/MessageFormat";

export default {
  name: "comsvSettingLcdReport",
  components: {
    "draggable": vuedraggable
  },
  data() {
    return {
      lcdReportList: [
        {
          code: 1,
          name: "透析開始時刻",
          dispflag: 0
        },
        {
          code: 2,
          name: "透析終了時刻",
          dispflag: 0
        },
        {
          code: 3,
          name: "目標体重",
          dispflag: 0
        },
        {
          code: 4,
          name: "前体重",
          dispflag: 0
        },
        {
          code: 5,
          name: "前最高血圧",
          dispflag: 0
        },
        {
          code: 6,
          name: "前最低血圧",
          dispflag: 0
        },
        {
          code: 7,
          name: "前平均血圧",
          dispflag: 0
        },
        {
          code: 8,
          name: "前脈拍",
          dispflag: 0
        },
        {
          code: 9,
          name: "後体重",
          dispflag: 0
        },
        {
          code: 10,
          name: "後最高血圧",
          dispflag: 0
        },
        {
          code: 11,
          name: "後最低血圧",
          dispflag: 0
        },
        {
          code: 12,
          name: "後平均血圧",
          dispflag: 0
        },
        {
          code: 13,
          name: "後脈拍",
          dispflag: 0
        },
        {
          code: 14,
          name: "除水速度制限",
          dispflag: 0
        },
        {
          code: 15,
          name: "除水量制限",
          dispflag: 0
        },
        {
          code: 16,
          name: "透析時間",
          dispflag: 0
        },
        {
          code: 17,
          name: "目標除水量",
          dispflag: 0
        },
        {
          code: 18,
          name: "血流量",
          dispflag: 0
        },
        {
          code: 19,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "ＩＰ速度",
          name: "IP速度",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 20,
          name: "透析回数",
          dispflag: 0
        },
        {
          code: 21,
          name: "実績除水量",
          dispflag: 0
        },
        {
          code: 22,
          name: "実績血液循環量",
          dispflag: 0
        },
        {
          code: 23,
          name: "治療法",
          dispflag: 0
        },
        {
          code: 24,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "ＤＷ",
          name: "DW",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 25,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "ＣＴＲ",
          name: "CTR",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 26,
          name: "血液型",
          dispflag: 0
        },
        {
          code: 27,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "ＲＨ",
          name: "RH",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 28,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "ＶＡ",
          name: "VA",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 29,
          name: "ダイアライザ",
          dispflag: 0
        },
        {
          code: 30,
          name: "透析液",
          dispflag: 0
        },
        {
          code: 31,
          name: "抗凝固剤",
          dispflag: 0
        },
        {
          code: 32,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "（凝）初回注入量",
          name: "(凝)初回注入量",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 33,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "（凝）持続注入量",
          name: "(凝)持続注入量",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 34,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "（凝）持続総量",
          name: "(凝)持続総量",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 35,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "（凝）合計注入量",
          name: "(凝)合計注入量",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 36,
          name: "前回後体重",
          dispflag: 0
        },
        {
          code: 37,
          name: "除水速度",
          dispflag: 0
        },
        {
          code: 38,
          name: "補液速度",
          dispflag: 0
        },
        {
          code: 39,
          name: "補液温度設定値",
          dispflag: 0
        },
        {
          code: 40,
          name: "補液量設定値",
          dispflag: 0
        },
        {
          code: 41,
          name: "補液速度限界値",
          dispflag: 0
        },
        {
          code: 42,
          name: "補液量設定値制限",
          dispflag: 0
        },
        {
          code: 43,
          name: "入外区分",
          dispflag: 0
        },
        {
          code: 44,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "前体重－ＤＷ",
          name: "前体重-DW",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 45,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "前体重－前回後体",
          name: "前体重-前回後体",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 46,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "前回後体重－前体",
          name: "前回後体重-前体",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 47,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "前体重－後体重",
          name: "前体重-後体重",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 48,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "後体重－前体重",
          name: "後体重-前体重",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 49,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "除水補正値合計ｇ",
          name: "除水補正値合計g",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 50,
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // name: "除水補正値合計Ｌ",
          name: "除水補正値合計L",
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          dispflag: 0
        },
        {
          code: 51,
          name: "クール名",
          dispflag: 0
        },
        {
          code: 52,
          name: "ベッド名",
          dispflag: 0
        },
        {
          code: 53,
          name: "穿刺者",
          dispflag: 0
        },
        {
          code: 54,
          name: "返血者",
          dispflag: 0
        },
        {
          code: 55,
          name: "病棟名",
          dispflag: 0
        },
        {
          code: 56,
          name: "ﾀﾞｲｱﾗｲｻﾞ膜面積",
          dispflag: 0
        },
        // add bug 8009 修正 chen start
        {
          code: 87,
          name: "血液回路",
          dispflag: 0
        },
        {
          code: 88,
          name: "吸着カラム",
          dispflag: 0
        },
        {
          code: 89,
          name: "補液",
          dispflag: 0
        },
        // add bug 8009 修正 chen end
        {
          code: 57,
          name: "消耗品０１",
          dispflag: 0
        },
        {
          code: 58,
          name: "消耗品０２",
          dispflag: 0
        },
        {
          code: 59,
          name: "消耗品０３",
          dispflag: 0
        },
        {
          code: 60,
          name: "消耗品０４",
          dispflag: 0
        },
        {
          code: 61,
          name: "消耗品０５",
          dispflag: 0
        },
        {
          code: 62,
          name: "消耗品０６",
          dispflag: 0
        },
        {
          code: 63,
          name: "消耗品０７",
          dispflag: 0
        },
        {
          code: 64,
          name: "消耗品０８",
          dispflag: 0
        },
        {
          code: 65,
          name: "消耗品０９",
          dispflag: 0
        },
        {
          code: 66,
          name: "消耗品１０",
          dispflag: 0
        },
        {
          code: 67,
          name: "薬剤０１",
          dispflag: 0
        },
        {
          code: 68,
          name: "薬剤０２",
          dispflag: 0
        },
        {
          code: 69,
          name: "薬剤０３",
          dispflag: 0
        },
        {
          code: 70,
          name: "薬剤０４",
          dispflag: 0
        },
        {
          code: 71,
          name: "薬剤０５",
          dispflag: 0
        },
        {
          code: 72,
          name: "薬剤０６",
          dispflag: 0
        },
        {
          code: 73,
          name: "薬剤０７",
          dispflag: 0
        },
        {
          code: 74,
          name: "薬剤０８",
          dispflag: 0
        },
        {
          code: 75,
          name: "薬剤０９",
          dispflag: 0
        },
        {
          code: 76,
          name: "薬剤１０",
          dispflag: 0
        },
        {
          code: 77,
          name: "薬剤１１",
          dispflag: 0
        },
        {
          code: 78,
          name: "薬剤１２",
          dispflag: 0
        },
        {
          code: 79,
          name: "薬剤１３",
          dispflag: 0
        },
        {
          code: 80,
          name: "薬剤１４",
          dispflag: 0
        },
        {
          code: 81,
          name: "薬剤１５",
          dispflag: 0
        },
        {
          code: 82,
          name: "薬剤１６",
          dispflag: 0
        },
        {
          code: 83,
          name: "薬剤１７",
          dispflag: 0
        },
        {
          code: 84,
          name: "薬剤１８",
          dispflag: 0
        },
        {
          code: 85,
          name: "薬剤１９",
          dispflag: 0
        },
        {
          code: 86,
          name: "薬剤２０",
          dispflag: 0
        }
      ],
      localDataSource: [],
      localEditDataSource: [],
      inputModel: {
        comsvCd: "",
        facilityCd: "",
        deviceEdgeNo: "",
        lcdReport: ""
      },
      initLocalEditDataSource:{},
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord"
    })
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),

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
     * バリデーションチェック.
     */
    validate() {
      // 8までチェック可能
      this.$store.commit("comsvSetting/setIsOver", {
        itemName: "lcdReport",
        result:
          this.localDataSource.filter(dat => dat.checked === true).length > 8
      });
    },
    onSave(ev, editCode) {
      this.$nextTick(() => {
      //add 6749 仮想端末の透析日報は最大8項目まで表示可能です。 ljg start
        if (this.localEditDataSource.filter(dat => dat.dispflag === true).length > 8) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['12000321'].title,
            message: messageFormat(DIALOG_MESSAGES['12000321'].message),
          });
          // トグルとデータは既に編集されてしまっているので戻す
          if (typeof(editCode) === "number") {
            this.localEditDataSource.forEach(data => {
              if (data.code === editCode) {
                data.dispflag = false;
              }
            });
            ev.target.children[0].checked = false;
          }
        }
      //add 6749 仮想端末の透析日報は最大8項目まで表示可能です。 ljg end
         //番号の振り直し
        let idx = 0;
        let tmpData = deepCopy(this.localEditDataSource);
        tmpData.forEach(data => {
          data.no = ++idx;
        });
        this.localEditDataSource = tmpData;
        // 表示状態のデータのリストを取得
        const registlcdReport = this.localEditDataSource
          .filter(dat => dat.dispflag === true)
          .map((dat, idx) => ({
            no: idx + 1,
            code: dat.code,
            name: dat.name
          }));
        let jsondata = { report_item: registlcdReport };
        this.updateEditRecord("lcdReport", JSON.stringify(jsondata));
      });
    }
  },
  watch: {
  },
  updated() {
  },
  created() {
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
      if (this.columnDefinition[num].field === "lcdReport") {
        this.inputModel.lcdReport = this.getValueByField(
          this.columnDefinition[num].field
        );
      }
    }
    // 次患者表示情報とチェック対象の項目をマージして入れる
    if (!this.inputModel.lcdReport) {
      this.inputModel.lcdReport = '{"report_item": []}';
    }
    const lcdReport = JSON.parse(this.inputModel.lcdReport);
    if (lcdReport !== null) {
      // 保存データがある場合は展開する
      this.localDataSource = lcdReport.report_item.map((dat, idx) => ({
        code: dat.code,
        name: dat.name,
        dispflag: 1,
        viewOrder: String.toString(idx),
        backColor: ""
      }));
      // 足りないデータ(非表示データ)を追加
      const undispflagData = this.lcdReportList.filter(
        dat =>
          this.localDataSource.findIndex(
            dispflag => dispflag.code === dat.code
          ) < 0
      );
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
      this.localDataSource = this.lcdReportList.map((dat, idx) => ({
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
.right {
  text-align: right;
}
.header-btn-area {
  height: 2em;
  padding: 0.1em 0.1em 0.1em 0.1em;
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
