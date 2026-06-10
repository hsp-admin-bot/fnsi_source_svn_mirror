<template>
  <div>
    <v-ons-button class="open-button btn3-normal pat-btn-margin-right" @click="openAllContents()">OPEN</v-ons-button>
    <v-ons-button class="close-button btn3-normal" @click="closeAllContents()">CLOSE</v-ons-button>
    <div v-for="(json, index) in editRecord.pat_memo_info" :key="index">
      <table :class="{ 'card-table': memoDisplayList[index + 1] }">
        <!-- タイトル部分 -->
        <tr v-show="memoDisplayList[index + 1]">
          <td class="number-area">{{ index + 1 }}</td>
          <td>
            <custom-simple-textarea-a
              :value="getPatDataJsonArray(json, 'title')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              @focus="toggleContent(index + 1, true)"
              style="width: 100%;"
            />
          </td>
          <td class="button-area">
            <!--
              :class="{ 'button-color': memoContentList[index + 1] }"
              modify by maxueqiang bug:4728
               -->
            <button
              class="content-button"
              :class="{ 'btn3-normal': memoContentList[index + 1] }"
              @click="toggleContent(index + 1, !memoVisibleList[index + 1])"
            >
              {{ memoVisibleList[index + 1] ? "▲" : "▼" }}
            </button>
          </td>
        </tr>
        <!-- 内容部分 -->
        <tr v-if="memoVisibleList[index + 1]">
          <td colspan="3">
            <com-textarea
              class="comTextarea"
              :content="getPatDataJsonArray(json, 'content')"
              :disabled="!getItemAuthorized('PatInfo', 'default_authority') || getIsOtherFacility"
              :idTextarea="'patMemo'+index"
              cssClass="textarea-custom-text-font textarea-resize-vertical"
              @set-content-data="setContentData($event, index)"
            />
          </td>
        </tr>
      </table>
    </div>
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { ApiHelper } from "@/apis/AxiosHelper";
import baseCardContent from "@/components/pat-info/base-components/BaseCardContent.vue";
import { mapGetters, mapActions } from "vuex";
// del #10359 編集権限の動作不正 dengshen start
// import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// import {AUTHORITY_CODES} from "@/constants/userAuthority"; //施設コード取得のために追加
// del #10359 編集権限の動作不正 dengshen end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end

export default {
  name: "PatMemoCard",
  mixins: [baseCardContent],

  data() {
    return {
      // メモごとの開閉フラグリスト
      memoVisibleList: {
        "1": false,
        "2": false,
        "3": false,
        "4": false,
        "5": false,
        "6": false,
        "7": false,
        "8": false,
        "9": false,
        "10": false,
        "11": false,
        "12": false,
        "13": false,
        "14": false,
        "15": false,
        "16": false,
        "17": false,
        "18": false,
        "19": false,
        "20": false
      },

      // メモごとの内容フラグリスト
      memoContentList: {
        "1": false,
        "2": false,
        "3": false,
        "4": false,
        "5": false,
        "6": false,
        "7": false,
        "8": false,
        "9": false,
        "10": false,
        "11": false,
        "12": false,
        "13": false,
        "14": false,
        "15": false,
        "16": false,
        "17": false,
        "18": false,
        "19": false,
        "20": false
      },

      // メモごとの表示フラグリスト
      memoDisplayList: {
        "1": false,
        "2": false,
        "3": false,
        "4": false,
        "5": false,
        "6": false,
        "7": false,
        "8": false,
        "9": false,
        "10": false,
        "11": false,
        "12": false,
        "13": false,
        "14": false,
        "15": false,
        "16": false,
        "17": false,
        "18": false,
        "19": false,
        "20": false
      },
      selectedIndex: null, //選択された患者メモ番号
      // del #10359 編集権限の動作不正 dengshen start
      // // add 編集権限の適用 liang start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // editFlag: null,
      // // add 編集権限の適用 liang end
      // del #10359 編集権限の動作不正 dengshen end

    };
  },
  // add  編集権限の適用 liang start
  props: {
    // 新規登録フラグ
    isCreationPat: {
      type: Boolean,
      default: false
    },
  },
  // add 編集権限の適用 liang  end
  computed: {
    // add 編集権限の適用 liang start
    // mod #10359、#10331 編集権限について、対応する。 dengshen start
    // ...mapGetters("account-edit", ["getStateUserAccountInfo", "getUseFunctions"]),
    ...mapGetters("account-edit", ["getStateUserAccountInfo", "getAuthorizedFunctions"]),
    // mod #10359、#10331 編集権限について、対応する。 dengshen end
    // add 編集権限の適用 liang  end
    //施設コード取得用
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId", "getIsOtherFacility", "getOtherFacilityCd"]),
  },
  watch: {
    selectedPatId() {
      this.openContentsWithData();
      // del FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 start
      // add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 関春麗 start
      //this.patMemoInfo();
      // add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 関春麗 end
      // del FNSI7519-profile連携（XML）で受信した詳細情報（患者フリーコメント） 周 end
      this.contentChk();
    },
    // add #12462 患者情報共有 Ji start
    editRecord: {
      handler() {
        this.contentChk();
      },
      deep: true
    }
    // add #12462 患者情報共有 Ji end
  },
  created() {
    this.refreshData();
    // del #10359 編集権限の動作不正 dengshen start
    // // add 編集権限の適用 liang start
    // if ( this.isCreationPat ) {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isCreatePatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen start
    //   // this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatViewAuthorized = this.getAuthorizedFunctions.includes(FUNC_PAT_INFO);
    //   // mod #10359、#10331 編集権限について、対応する。 dengshen end
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    // // add 編集権限の適用 liang end
    // del #10359 編集権限の動作不正 dengshen end
  },

  methods: {
    ...mapActions("loading-screen", ["setLoadingScreenMessage", "setLoadingScreenVisible"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    replaceStr (str) {
      let val;
      if (str == null) {
        val = null;
      } else {
        val = str.replaceAll("@#@",'"').replaceAll("&apos;","'").replaceAll("&lt;","<").replaceAll("&gt;",">")
      }
      return val;
    },

    // add bug #7125 修正 chen start
    async refreshData() {
      this.setLoadingScreenVisible(true);
      try {
        const requestParam = {
          facilityCd: this.getFacilityCd
        };
        // 患者メモマスタの取得
        const mstPatMemo = await ApiHelper.get(
          "/mstInfo/mstPatMemo",
          requestParam
        ).catch(error => {
          getErrorMessage('PatMemoCardContent.vue', 'created', error);
          throw error;
        });

        // 表示フラグリスト作成
        for (let data of mstPatMemo.data) {
          this.memoDisplayList[data.patMemoNo] = data.isDisp === "1";
        }
        this.openContentsWithData();
        this.patMemoInfo();
        this.contentChk();
      } finally {
        this.setLoadingScreenVisible(false);
      }
      // this.initRecord = deepCopy(this.editRecord);
    },
    // add bug #7125 修正 chen end
    /**
     * @description 指定インデックスの表示フラグ切り替え
     */
    toggleContent(index, visible) {
      // console.log("toggleContent.index is : ",index);
      const visibleFlag = this.memoDisplayList[index] && visible;
      this.memoVisibleList[index] = visibleFlag;
    },

    /**
     * @description 全メモ内容オープン
     */
    openAllContents() {
      for (const index in this.memoVisibleList) {
        this.toggleContent(index, true);
      }
    },

    /**
     * @description 全メモ内容オープン
     * add by maxueqiang 【1006】最新の改修対象一覧
     */
    openContentsWithData() {
      if ( !this.isCreationPat && Array.isArray(this.editRecord.pat_memo_info)) {
        this.closeAllContents();
        let filterArray = this.editRecord.pat_memo_info.filter(item =>{
          return item.content.initValue != null;
        });
        filterArray.forEach(element => {
          this.toggleContent(element.ctl_no.initValue.toString(), true);
        });
      }
    },
    // add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 関春麗 start
     /**
     * @description 受信XMLエスケープ文字の置換
     */
    patMemoInfo() {
     for (const val of this.editRecord.pat_memo_info) {
      const contentValue = this.replaceStr(val.content.initValue);
      const titleValue = this.replaceStr(val.title.initValue);
      val.content.editValue = contentValue;
      val.content.initValue = contentValue;
      val.title.editValue = titleValue;
      val.title.initValue = titleValue;
      }
    },
    // add 7519 profile連携（XML）で受信した詳細情報（患者フリーコメント） 関春麗 end
    /**
     * @description 全メモ内容クローズ
     */
    closeAllContents() {
      for (const index in this.memoVisibleList) {
        this.toggleContent(index, false);
      }
    },

    /**
     * @description メモ内容の存在チェック(初期表示)
     */
    contentChk() {
      for (const index in this.memoContentList) {
        const memoInfo = this.editRecord.pat_memo_info[index - 1];
        const strMemo = memoInfo && memoInfo.content.initValue;
        // strMemo が undefined,null,"" であれば
        // （memoInfo が有効なObjectではない場合も含む）
        // 対応する memoContentList は false にする
        // ※この処理を行う時点では content.initValue と content.editValue は
        // 　どちらでも同じ値になっている想定
        this.memoContentList[index] = !!strMemo;
      }
    },

    /**
     * @description メモ内容の存在チェック(編集後)
     */
    contentChkOnBlur(index) {
      this.selectedIndex = index;
      const strMemo = document.getElementById(`patMemo${this.selectedIndex}`)
        .value;
      if (strMemo === null || strMemo === "") {
        this.memoContentList[index + 1] = false;
      } else {
        this.memoContentList[index + 1] = true;
      }
    },

    setContentData(newValue, index) {
      this.editRecord.pat_memo_info[index].content.editValue = newValue;
      this.contentChkOnBlur(index);
    }
  }
};
</script>

<style scoped>
/* カード内のtableタグ */
.card-table {
  width: 100%;
  border-bottom: 1px solid;
}

/* 横に広げる */
.custom-input {
  display: inline-block;
  width: 100%;
  box-sizing: border-box;
  font-size: inherit;
}

/* 横に広げる */
.comTextarea {
  resize: both;
  display: inline-block;
  width: 100%;
  box-sizing: border-box;
  font-size: inherit;
}
/* カード内の番号 */
.number-area,
.button-area {
  width: 6%;
}

.content-button,
.open-button,
.close-button {
  font-size: 1em;
}

.content-button {
  border-style: outset;
  border-image-repeat: stretch;
  border-color: unset;
}

/* ボタンの色を変更する */
.button-color {
  background-image: linear-gradient(#B1CBD8 0%,#3D82A5 50%,#3D82A5 50%,#377B9E 100%);
  color: #fff;
}
.card-table >>> textarea.custom-textarea {
  color: black !important;
}
</style>
