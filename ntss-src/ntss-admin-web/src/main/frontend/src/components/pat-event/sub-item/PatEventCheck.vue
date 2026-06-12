<template>
  <div class="vertical-div">
    <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
    <!--<div class="disp-item-area">
      <div>
        <label class="title ntss-pat-event-label">{{getInputFieldName}}&emsp;</label>
      </div>
      <div v-for="(item, index) in getInputRadio" :key="index">
        <div class="title2" v-if="index % 2 === 0">
          <label class="title ntss-pat-event-label">
            &lt;!&ndash;mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 start&ndash;&gt;
            &lt;!&ndash;<v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              v-model="inputModel.radioName"
              :disabled="getViewMode"
              @click="changeUse($event.target,item,index)"
            />&ndash;&gt;
            &lt;!&ndash; mod FNSI-共有を追加 王 20200921 start &ndash;&gt;
            <v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              modifier="round"
              v-model="inputModel.radioName"
              :disabled="getViewMode || !isShared"
              @click="changeUse($event.target,item,index)"
            />
            &lt;!&ndash; mod FNSI-共有を追加 王 20200921 end &ndash;&gt;
            &lt;!&ndash;mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 end&ndash;&gt;
            {{item.name}}
          </label>
        </div>
        <div v-else class="title">
          <label class="title ntss-pat-event-label">
            &lt;!&ndash;mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 start&ndash;&gt;
            &lt;!&ndash;<v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              v-model="inputModel.radioName"
              :disabled="getViewMode"
              @click="changeUse($event.target,item,index)"
            />&ndash;&gt;
            &lt;!&ndash; mod FNSI-共有を追加 王 20200921 start &ndash;&gt;
            <v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              modifier="round"
              v-model="inputModel.radioName"
              :disabled="getViewMode || !isShared"
              @click="changeUse($event.target,item,index)"
            />
            &lt;!&ndash; mod FNSI-共有を追加 王 20200921 end &ndash;&gt;
            &lt;!&ndash;mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 end&ndash;&gt;
            {{item.name}}
          </label>-->
    <div class="buttomLine" style="width: calc(100% / 4)">
      <div class="disp-item-area topTitle" style="float: left;">
        <div class="borderRight">
          <label class="title ntss-pat-event-label changeRow" >{{getInputFieldName}}&emsp;</label>
        </div>
      </div>
    </div>
    <div style="width: 75%;">
      <div v-for="(item, index) in getInputRadio" :key="index">
      <div class="title2" v-if="index % 2 === 0">
        <label class="title ntss-pat-event-label">
          <!--mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 start-->
          <!--<v-ons-radio
            :input-id="'radio-' + index"
            :value="item.name"
            v-model="inputModel.radioName"
            :disabled="getViewMode"
            @click="changeUse($event.target,item,index)"
          />-->
          <!-- mod FNSI-共有を追加 王 20200921 start -->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!-- <v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              modifier="round"
              v-model="inputModel.radioName"
              :disabled="getViewMode || !isShared || disabled"
              @click="changeUse($event.target, item, index)"
            /> -->
            <v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              modifier="round"
              v-model="inputModel.radioName"
              :disabled="
                getViewMode ||
                !isShared ||
                !getItemAuthorized('PatEvent', 'default_authority') ||
                getIsOtherFacilitys
              "
              @click="changeUse($event.target, item, index)"
            />
            <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            <!--mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 end-->
            {{ item.name }}
          </label>
        </div>
        <div v-else class="title">
          <label class="title ntss-pat-event-label">
            <!--mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 start-->
            <!--<v-ons-radio
            :input-id="'radio-' + index"
            :value="item.name"
            v-model="inputModel.radioName"
            :disabled="getViewMode"
            @click="changeUse($event.target,item,index)"
          />-->
          <!-- mod FNSI-共有を追加 王 20200921 start -->
            <!-- mod #10359 編集権限の動作不正 start -->
            <!-- <v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              modifier="round"
              v-model="inputModel.radioName"
              :disabled="getViewMode || !isShared"
              @click="changeUse($event.target, item, index)"
            /> -->
            <v-ons-radio
              :input-id="'radio-' + index"
              :value="item.name"
              modifier="round"
              v-model="inputModel.radioName"
              :disabled="
                getViewMode ||
                !isShared ||
                !getItemAuthorized('PatEvent', 'default_authority') ||
                getIsOtherFacilitys
              "
              @click="changeUse($event.target, item, index)"
            />
            <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            <!--mod FNSI-改修内容イベント作成画面ラジオボタン改修 任 end-->
            {{ item.name }}
          </label>
        </div>
        <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
      </div>
    </div>
    </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

export default {
  name: "PatEventRadio",
  props: ["propsIndex"],
  data() {
    return {
      inputModel: {
        radioName: ""
      },
      remove: -1
    };
  },

  computed: {
    // mod FNSI-共有を追加 王 20200921 start
    ...mapGetters("pat-event/detail", [
      "getPatEventInputParams",
      "getPatEventResultParams",
      "getPatEventRecord",
      "getViewMode"
    ]),
    // mod FNSI-共有を追加 王 20200921 end
    // add FNSI-共有を追加 王 20200921 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("pat-event/list", ["getIsOtherFacility"]),
    ...mapGetters("observe-record/list", ["getIsOtherFacilitys"]),
    isShared() {
      if(this.getPatEventRecord.isComRec){
        return this.getFacilityCd === this.getSharedFacilityCd;
      }
      return true;
    },
    // add FNSI-共有を追加 王 20200921 end
    getInputRadio() {
      return this.getPatEventInputParams[this.propsIndex].item_json.values;
    },
    getResultSelectRadio() {
      let radioName = "";
      const input = this.getPatEventInputParams[this.propsIndex].item_json
        .values;
      const result = this.getPatEventResultParams[this.propsIndex].result_value;
      for (const inrec of input) {
        if (inrec.name === result.name) {
          radioName = inrec.name;
          break;
        }
      }
      return radioName;
    },
    getInputFieldName() {
      const flag = this.getPatEventInputParams[this.propsIndex]
        .is_field_display;
      if (flag === "1") {
        return this.getPatEventInputParams[this.propsIndex].field_name;
      } else {
        return "";
      }
    }
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  mounted() {
    this.inputModel.radioName = this.getResultSelectRadio;
  },
  methods: {
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end

    /**
     * ラジオボタン選択時
     */
    async changeUse(ev, item, index) {
      if (this.remove == index) {
        ev.checked = false;
        this.remove = -1;
      } else {
        this.remove = index;
      }
      const result = this.getPatEventResultParams[this.propsIndex];
      this.inputModel.initialFunction = item.name;
      let value = null;
      if (ev.checked === true) {
        value = {
          format_class: result.format_class,
          result_value: {
            name: item.name,
            score: item.score
          }
        };
      } else {
        value = {
          format_class: result.format_class,
          result_value: {
            name: "",
            score: 0
          }
        };
      }
      await this.setPatEventResultParamsUpdate({
        item: value,
        index: this.propsIndex
      });
    }
  }
};
</script>

<style scoped>
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.vertical-div {
    display: flex;
    flex-direction: column;
    align-content: flex-start;
    font-size: 1em;
  }
  .disp-item-area {
    width: 100%;
    border-collapse: collapse;
  }*/
.vertical-div {
  display: flex;
  align-content: flex-start;
  font-size: 1em;
  border-bottom: #595959 solid 1.5px;
}
.disp-item-area {
  height: 100%;
  width: 100%;
  border-collapse: collapse;
  display: flex;
  align-items: center;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.disp-item-area tr {
  height: 50px;
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
.onscol {
  padding-top: 10px;
}
.title {
  padding: 10px;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
.topTitle {
  height: 100%;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.title2 {
  padding: 10px;
  float: left;
}
.radio-button :deep(.radio-button__checkmark) {
  opacity: 1;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
.buttomLine {
  margin-bottom: 10px;
}
.borderRight {
  height: 100%;
  /*border-right: #595959 solid 1px;*/
  display: flex;
  align-items: center;
}
.changeRow {
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
</style>
