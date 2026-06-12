<template>
  <div class="vertical-div">
    <div class="disp-item-area">
      <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start-->
      <!--<div>-->
      <div class="topTitle" style="float: left;width: calc(100% / 4)">
        <!--mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end-->
        <label class="title ntss-pat-event-label">{{ getInputFieldName }}&emsp;</label>
      </div>
      <div v-if="getViewMode || getIsOtherFacilitys">
        <label class="ntss-pat-event-label" style="padding-left: 10px;">{{inputModel.listName}}</label>
      </div>
      <div v-else>
        <!-- mod FNSI-共有を追加 王 20200921 start -->
        <!-- mod #10359 編集権限の動作不正 start -->
        <!-- <v-ons-select
          class="select"
          v-model="inputModel.listName"
          :disabled="getViewMode || !isShared || disabled"
          @change="changeUse"
        >
          <option
            v-for="(item, index) in getInputList"
            :key="index"
            :value="item.name"
            style="color: black"
            :disabled="getViewMode || !isShared || disabled"
          > -->
        <v-ons-select
          class="select"
          v-model="inputModel.listName"
          :disabled="
            getViewMode ||
            !isShared ||
            !getItemAuthorized('PatEvent', 'default_authority') ||
            getIsOtherFacilitys
          "
          @change="changeUse"
        >
          <option
            v-for="(item, index) in getInputList"
            :key="index"
            :value="item.name"
            style="color: black"
            :disabled="
              getViewMode ||
              !isShared ||
              !getItemAuthorized('PatEvent', 'default_authority') ||
              getIsOtherFacilitys
            "
          >{{ item.name }}</option>
            <!-- mod #10359 編集権限の動作不正 end -->
        </v-ons-select>
        <!-- mod FNSI-共有を追加 王 20200921 end -->
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
  name: "PatEventList",
  props: ["propsIndex"],
  data() {
    return {
      inputModel: {
        listName: ""
      }
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
    getInputList() {
      const spcae = [
        {
          name: "",
          socore: 0
        }
      ];
      let lst = this.getPatEventInputParams[this.propsIndex].item_json.values;
      return spcae.concat(lst);
    },
    getResultSelectList() {
      let listName = "";
      const input = this.getPatEventInputParams[this.propsIndex].item_json
        .values;
      const result = this.getPatEventResultParams[this.propsIndex].result_value;
      for (const inrec of input) {
        if (inrec.name === result.name) {
          listName = inrec.name;
          break;
        }
      }
      return listName;
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
    this.inputModel.listName = this.getResultSelectList;
  },
  methods: {
    ...mapActions("pat-event/detail", ["setPatEventResultParamsUpdate"]),
    async changeUse() {
      const result = this.getPatEventResultParams[this.propsIndex];
      const input = this.getPatEventInputParams[this.propsIndex].item_json
        .values;
      let listScore = 0;
      for (const inrec of input) {
        if (inrec.name === this.inputModel.listName) {
          listScore = inrec.score;
          break;
        }
      }
      const value = {
        format_class: result.format_class,
        result_value: {
          name: this.inputModel.listName,
          score: listScore
        }
      };
      await this.setPatEventResultParamsUpdate({
        item: value,
        index: this.propsIndex
      });
    },
    // add #10359 編集権限の動作不正 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 end
  },
};
</script>

<style scoped>
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  /*.vertical-div {
    display: flex;
    flex-direction: column;
    align-content: flex-start;
    font-size: 1em;
  }*/
.vertical-div {
  display: flex;
  align-content: flex-start;
  font-size: 1em;
  border-bottom: #595959 solid 1.5px;
}
  /*mod FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
.disp-item-area {
  width: 100%;
  border-collapse: collapse;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  margin-bottom: 10px;
  display: flex;
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
.select {
  max-width: 20em;
  vertical-align: middle;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
  margin-left: 10px;
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
}
.select :deep(.select-input) {
  opacity: 1;
  font-size: 1em;
  /* color: var(--ntss-base-color); */
}
/*<!-- mod FNSI 患者イベント画面レイアウト調整 吉 start -->*/
/*  .title {*/
/*    margin-left: 10px;*/
/*    margin-top: 10px;*/
/*    font-size: 1em;*/
/*    overflow: hidden;*/
/*    word-spacing: normal;*/
/*    word-break: break-all;*/
/*  }*/
/*  .list-area{*/
/*    padding-top: 10px;*/
/*  }*/
.title {
  margin-left: 10px;
  margin-top: 10px;
  font-size: 1em;
  overflow: hidden;
  word-spacing: normal;
  word-break: break-all;
}
/*<!-- mod FNSI 患者イベント画面レイアウト調整 吉 end -->*/
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 start*/
.topTitle {
  height: 100%;
  /*border-right: #595959 solid 1px;*/
  display: -webkit-box;
  align-items: center;
}
  /*add FNSI-改修内容レイアウト表示と見た目調整。ラベルとデータ項目の区別がつかない。任 end*/
</style>
