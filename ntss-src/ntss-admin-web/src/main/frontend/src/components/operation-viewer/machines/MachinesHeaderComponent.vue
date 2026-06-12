/**
 * 稼働ビューアページ用ヘッダ
 */
<template>
  <div>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col vertical-align='center'>
          <div class='ntss-button-group'>
            <input type="radio" class="identification" name="identification" value="1" id="input-bed-name" @click='changeDisplayName(true);' checked='checked'>
            <label for="input-bed-name" class="label first-of-type">ベッド名</label>
            <input type="radio" class="identification" name="identification" value="2" id="input-machine-name" @click='changeDisplayName(false);'>
            <label for="input-machine-name" class="label last-of-type">装置名</label>
          </div>
        </v-ons-col>
        <v-ons-col style="margin-top: 0.4em;">
          <div class="filter-area" id="filter">
            <div class="filter-button">
              <input type="checkbox" class="emergency" id="machineEmergency" @click='checkedCheckbox($event);' v-bind:checked='condition.machineEmergency'>
              <label for="machineEmergency" class="filterLabel">{{ emergencyCount }}</label>
            </div>
            <!-- 予防保全対応不完全のため非表示とする -->
            <div class="filter-button" v-if=false>
              <input type="checkbox" class="prophylaxis" id="machineProphylaxis" @click='checkedCheckbox($event);' v-bind:checked='condition.machineProphylaxis'>
              <label for="machineProphylaxis" class="filterLabel">{{ prophylaxisCount }}</label>
            </div>
            <div class="filter-button">
              <input type="checkbox" class="defect" id="machineDefect" @click='checkedCheckbox($event);' v-bind:checked='condition.machineDefect'>
              <label for="machineDefect" class="filterLabel">{{ defectCount }}</label>
            </div>
          </div>
          <div class="filter-area">
            <div class="filter-button">
              <input type="radio" class="all" id="machineAll" @click='checkedRadio($event);' v-bind:checked='condition.machineAll'>
              <label for="machineAll" class="filterLabel filterLabelWidth">ALL</label>
            </div>
          </div>
        </v-ons-col>
      </v-ons-row>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";

export default {
  data() {
    return {
      condition: {
        machineEmergency: false,
        machineProphylaxis: false,
        machineDefect: false,
        machineAll: true
      }
    };
  },
  computed: {
    ...mapGetters("operation-viewer/machine", [
      "getDisplayNameFlag",
      "getCondition",
      "getEmergencyCount",
      "getProphylaxisCount",
      "getDefectCount",
      "getServiceSupportCount"
    ]),
    ...mapGetters("account-edit", [
      "isNkkFacility"
    ]),
    /**
     * 表示名称を取得する.
     *
     * @returns 表示名称
     */
    displayNameFlag() {
      return this.getDisplayNameFlag;
    },
    /**
     * 緊急発報件数若しくはサービス対応件数を取得する.
     * サインイン者が日機装施設に属している場合は、サービス対応件数を返却する.
     * それ以外の場合は、緊急発報件数を返却する.
     *
     * @returns 緊急発報件数 or サービス対応件数
     */
    emergencyCount() {
      // 日機装施設に属している場合
      if (this.isNkkFacility) {
        return this.getServiceSupportCount;
      }
      // それ以外
      return this.getEmergencyCount;
    },
    // 予防保守件数取得
    prophylaxisCount() {
      return this.getProphylaxisCount;
    },
    // 通信不良件数取得
    defectCount() {
      return this.getDefectCount;
    }
  },
  methods: {
    ...mapActions("operation-viewer/machine", [
      "setCondition",
      "changeDisplayNameFlag"
    ]),
    // ------------------------------------------------------------------
    // 処理：各チェックボックスクリック時のイベント
    //       TODO:全選択のラジオボタンをOFFにし、施設一覧のstateのconditionを更新する
    // 引数：event : マウスクリックイベント
    // ------------------------------------------------------------------
    checkedCheckbox(event) {
      // 選択された要素の属性:idをイベントから取得
      const checkId = event.currentTarget.id;
      if (checkId === "machineEmergency") {
        this.condition.machineEmergency = event.currentTarget.checked;
      } else if (checkId === "machineProphylaxis") {
        this.condition.machineProphylaxis = event.currentTarget.checked;
      } else if (checkId === "machineDefect") {
        this.condition.machineDefect = event.currentTarget.checked;
      }
      // 全選択のラジオボタンを未選択に設定
      this.condition.machineAll = false;
      // チェックボックスが全てOFFになった場合の対応
      if (
        !this.condition.machineEmergency &&
        !this.condition.machineProphylaxis &&
        !this.condition.machineDefect
      ) {
        // 全選択のラジオボタンをONに設定
        this.condition.machineAll = true;
      }
      // storeに条件を登録
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：全選択のラジオボタンクリック時のイベント
    //       TODO:緊急発報、予防保守、通信異常のチェックボックスを全てOFFにし、
    //       TODO:施設一覧のstateのconditionを更新する
    // 引数：event : マウスクリックイベント
    // ------------------------------------------------------------------
    checkedRadio(event) {
      this.condition.machineEmergency = false;
      this.condition.machineProphylaxis = false;
      this.condition.machineDefect = false;
      this.condition.machineAll = event.currentTarget.checked;
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    // ベッド名/装置名の表示切替を変更
    changeDisplayName(displayNameFlag) {
      this.changeDisplayNameFlag(displayNameFlag);
    },
    // 抽出条件を元にした検索イベント
    search() {
      this.setCondition(this.condition);
    },
    fetchCondition() {
      const condition = this.getCondition;
      this.condition.machineEmergency = condition.machineEmergency;
      this.condition.machineProphylaxis = condition.machineProphylaxis;
      this.condition.machineDefect = condition.machineDefect;
      this.condition.machineAll = condition.machineAll;
    }
  },
  created() {
    this.changeDisplayNameFlag(true);
    this.fetchCondition();
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}

/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 100%;
  font-size: 1.5em;
}

.label {
  display: block; /* ブロックレベル要素化する */
  float: left; /* 要素の左寄せ・回り込を指定する */
  width: 30%; /* ボックスの横幅を指定する */
  height: 2em; /* ボックスの高さを指定する */
  padding-left: 5px; /* ボックス内左側の余白を指定する */
  padding-right: 5px; /* ボックス内御右側の余白を指定する */
  color: #ffffff; /* フォントの色を指定する */
  text-align: center; /* テキストのセンタリングを指定する */
  line-height: 2em; /* 行の高さを指定する */
  cursor: pointer; /* マウスカーソルの形（リンクカーソル）を指定する */
  margin: 15px 0px;
  white-space: nowrap;
}
.first-of-type {
  border-radius: 10px 0 0 10px;
  margin-left: 4px;
}
.last-of-type {
  border-radius: 0 10px 10px 0;
  margin-right: 10px;
}
.filterLabelWidth {
  width: 4.6em;
}
</style>
