/**
 * よく使う施設マスタ 全施設マスタ検索用コンポーネント
 */
<template>
  <v-card>
    <div class='dialog-header-item'>
      <v-ons-row>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                    :visible.sync='popoverVisible'
                    :target='popoverTarget'
                    :direction='popoverDirection'
                    :cover-target=false
                    :class="['master-search', fontSizeSet]"
                    @keyup.enter.native="closeDialog">
       <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%'>
            <label class="search-label-font">都道府県</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <kendo-dropdownlist
              v-model="condition.inProgress.prefCd"
              :data-source="getPrefectures"
              :data-text-field="'prefName'"
              :data-value-field="'prefCd'"
              style="width: 9em; height: 2em; margin-right: 5px;">
            </kendo-dropdownlist>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <!-- mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start -->
          <v-ons-col width='40%'>
            <label class="search-label-font">フリーワード</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <!-- mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end -->
            <v-ons-input
              input-id='freeWord'
              type='text'
              float
              v-model='condition.inProgress.freeWord'
              placeholder="フリーワード検索"
            ></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class="condition-row button-row">
          <div class="left">
            <v-ons-button class='btn2-cancel clear' @click='clearCondition(); closeDialog()'>クリア</v-ons-button>
          </div>
          <div class="right">
            <v-ons-button class='btn3-normal ok' @click='closeDialog'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { prefectures } from "@/components/master-maintenance/mst-device-edge/Prefectures.js";
import commonSearchArea from "@/components/common/CommonSearchArea";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [MasterMaintenanceMixin],
  name: "SysFaciitySearchComponent",
  data() {
    const defaultCondition = {
      prefCd:"",
      freeWord: ""
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      condition: {
        inProgress: {
          ...defaultCondition
        },
        inUsed: {
          ...defaultCondition
        }
      },
      dispPrefName: "",
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("mst-favorite-facility", { storeCondition:"condition" }),
    getPrefectures() {
      const zenkoku = { prefCd: "", prefName: "全国" };
      let prefecturesList = new Array();
      prefecturesList.push(zenkoku);
      prefectures.map(prefecture => {
        prefecturesList.push(prefecture)
      })
      return prefecturesList;
    }
  },
  methods: {
    ...mapActions("mst-favorite-facility", [
      "setConditionFreeWord",
      "setConditionPrefCd",
      "conditionsClear",
      "getMstFacilityByCd"
    ]),
    showPopover(event) {
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    clearCondition() {
      // 検索条件クリアして画面を更新
      this.clearConditionInUsedAndInProgress();
      this.conditionsClear();
    },
    closeDialog() {
      this.copyConditionInProgressToInUsed();
      // 画面を閉じる
      this.popoverVisible = false;
      this.commitCondFreeWord();
      this.commitCondPrefCd();
      this.showDispPrefName();
      this.setConditionList();
      EventBus.$emit("setFacilityList");
      //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
      this.$emit('GetFilterData',this.condition)
      //add #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    },
    commitCondFreeWord() {
      this.setConditionFreeWord(this.condition.inUsed.freeWord);
    },
    //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    async commitCondPrefCd() {
      await this.setConditionPrefCd(this.condition.inUsed.prefCd);
    },
    //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.freeWord = this.condition.inProgress.freeWord;
      this.condition.inUsed.prefCd = this.condition.inProgress.prefCd;
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.freeWord = this.condition.inUsed.freeWord;
      this.condition.inProgress.prefCd = this.condition.inUsed.prefCd;
    },
    clearConditionInUsedAndInProgress() {
      this.condition.inUsed.freeWord = this.defaultCondition.freeWord;
      this.condition.inUsed.prefCd = this.defaultCondition.prefCd;
      this.condition.inProgress.freeWord = this.defaultCondition.freeWord;
      this.condition.inProgress.prefCd = this.defaultCondition.prefCd;
    },
    showDispPrefName() {
      const _prefCd = this.condition.inProgress.prefCd
      let prefecturesCopy = prefectures.slice();
      const result = prefecturesCopy.filter(function(pref){
        if (pref.prefCd === _prefCd) return true;
      });
      this.dispPrefName = result.length > 0 ? result[0].prefName : "";
    },
    // 共通検索エリア部品に表示するデータのリストを作成
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // 都道府県
      if (condObj.prefCd != "") {
        condList.push({ name:"都道府県", text:this.dispPrefName });
      }
      // フリーワード
      if (condObj.freeWord != "") {
        condList.push({ name:"フリーワード", text:condObj.freeWord });
      }
      this.conditionList = condList;
    }
  },
  async created() {
    await this.getMstFacilityByCd(this.facilityCd).then(response => {
      this.condition.inProgress.prefCd = response.data.prefecturesCd !== null && response.data.prefecturesCd.trim() ?
                                          response.data.prefecturesCd : "";
    })
    // add redmine #4533対応 孔 start
    if (this.storeCondition.prefCd !== "") this.condition.inProgress.prefCd = this.storeCondition.prefCd
    // add redmine #4533対応 孔 end
    this.copyConditionInProgressToInUsed()
    this.commitCondPrefCd();
    this.showDispPrefName();
    //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 start
    await this.setConditionList();
    //mod #8372 よく使うマスタの施設選択表示までが遅い。フリーズする。ローダーも表示しない。 付 end
    EventBus.$emit("setFacilityList");
  }
};
</script>

<style scoped>
.dialog-header-item {
  /* 文字色：黒テーマ字に灰色になってしまう為、黒で上書きする */
  color:#333333;
  font-size: .667em;
  height: 4.7em;
  margin-bottom: 0.5em;
}
.search-label-font {
  font-size: 1.7em;
}
.condition-row >>> .text-input {
  font-size: 1.7em;
}
.button-row {
  height: 30px;
  margin: 5px 0;
}
.button-row > .left {
  float: left;
}
.button-row > .right {
  float: right;
}
.button-row >>> .button {
  font-size: 1.7em;
  width: auto;
  min-width: 80px;
}
.master-search >>> .popover__content {
  min-width: 320px;
}
</style>
