<template>
  <div class="vertical-div">
    <div class="disp-item-area">
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
      <!--<div>-->
      <div class="lineRight">
        <div class="topTitle" style="float: left;width: calc(100% / 4)">
          <label class="title ntss-pat-event-label changeRow">{{getInputFieldName}}&emsp;</label>
          <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
        </div>
      <div v-for="(item, index) in getPatEventInputResultCheck" :key="index">
        <div class="title2" v-if="index % 2 === 0">
          <label class="title ntss-pat-event-label">
            <!-- mod FNSI-共有を追加 王 20200921 start -->
        <!-- mod #10359 編集権限の動作不正 start -->
            <!-- <ons-checkbox
              :input-id="'check-' + index"
              :checked="item.checked"
              :disabled="getViewMode || !isShared"
              @click="changeUse(item, $event)"
            /> -->
            <ons-checkbox
              :input-id="'check-' + index"
              :checked="item.checked"
              :disabled="getViewMode || !isShared ||
              !getItemAuthorized('PatEvent', 'default_authority') ||
              getIsOtherFacilitys"
              @click="changeUse(item, $event)"
            />
        <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            {{ item.name }}
          </label>
        </div>
        <div v-else class="title">
          <label class="title2 ntss-pat-event-label">
            <!-- mod FNSI-共有を追加 王 20200921 start -->
        <!-- mod #10359 編集権限の動作不正 start -->
            <!-- <ons-checkbox
              :input-id="'check-' + index"
              :checked="item.checked"
              :disabled="getViewMode || !isShared"
              @click="changeUse(item, $event)"
            /> -->
            <ons-checkbox
              :input-id="'check-' + index"
              :checked="item.checked"
              :disabled="getViewMode || !isShared ||
              !getItemAuthorized('PatEvent', 'default_authority') ||
              getIsOtherFacilitys"
              @click="changeUse(item, $event)"
            />
        <!-- mod #10359 編集権限の動作不正 end -->
            <!-- mod FNSI-共有を追加 王 20200921 end -->
            {{ item.name }}
          </label>
        </div>
      </div>
        <!--add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
      </div>
      <!--add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
// add #10359 編集権限の動作不正 start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 end

  export default {
  name: "PatEventCheck",
  props: ["propsIndex"],

  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("account-edit", ["getStateUserAccountInfo"]),
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
    getPatEventInputResultCheck() {
      let hoge = [];
      const input = this.getPatEventInputParams[this.propsIndex].item_json
        .values;
      const result = this.getPatEventResultParams[this.propsIndex].result_value;
      for (const inrec of input) {
        let flagFound = false;
        for (const resrec of result) {
          if (inrec.name === resrec.name) {
            hoge.push({
              name: inrec.name,
              score: inrec.score,
              checked: true
            });
            flagFound = true;
          }
        }
        if (!flagFound) {
          hoge.push({
            name: inrec.name,
            score: inrec.score,
            checked: false
          });
        }
      }
      return hoge;
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

  methods: {
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    getIndex(value, arr, prop) {
      for (var i = 0; i < arr.length; i++) {
        if (arr[i][prop] === value) {
          return i;
        }
      }
      return -1; //値が存在しなかったとき
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
    async changeUse(item, ev) {
      const result = this.getPatEventResultParams[this.propsIndex];
      if (ev.target.checked) {
        //チェックＯＮで既存データに、無の場合は追加、有の場合はスルー
        let flagFound = false;
        for (const dt of result.result_value) {
          if (dt.name === item.name) {
            flagFound = true;
            break;
          }
        }
        if (!flagFound) {
          //追加処理
          result.result_value.push({ name: item.name, score: item.score });
        }
      } else {
        //チェックＯＦＦで既存データに、無の場合はスルー、有の場合は削除
        for (const dt of result.result_value) {
          if (dt.name === item.name) {
            //削除処理
            let idx = this.getIndex(item.name, result.result_value, "name");
            result.result_value.splice(idx, 1);
            break;
          }
        }
      }
      const value = {
        format_class: result.format_class,
        result_value: result.result_value
      };
      await this.setPatEventResultParamsUpdate({
        item: value,
        index: this.propsIndex
      });
    }
  }
};
</script>

<style scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
  font-size: 1em;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  border-bottom: #595959 solid 1.5px;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
}
.disp-item-area {
  width: 100%;
  border-collapse: collapse;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  display: flex;
/*  align-items: center;
  padding-bottom: 10px;*/
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
}
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
  float: left;
}
.title2 {
  padding-bottom: 10px;
  padding-left: 10px;
  padding-right: 10px;
  float: left;
}
.checkbox :deep(.checkbox__checkmark) {
  opacity: 1;
}
/*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
.lineRight {
  /*height: 100%;*/
  width: 100%;
  margin-bottom: 10px;
}
.topTitle {
  height: 100%;
  display: flex;
  align-items: center;
  /*border-right: #595959 solid 1px;*/
}
.changeRow {
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
/*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
</style>
