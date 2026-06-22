/**
 * リリース情報ページ
 */
<template>
  <modal-base @onClose="cancel">
    <template #body>
      <div class="maker-notice" v-show="displayMode == 1">
      <div class="release-base" v-show="dispFlg == 1">
        <div>
          <div class="maker-notice-input">
            <label class="release-check" v-show="getSystemUseSetting == 1">ReMS</label>
            <label class="release-check" v-show="getSystemUseSetting == 2">FutureNetWeb⁺Si</label>
            <label class="release-check" v-show="getSystemUseSetting == 3" @change ="onRefresh()">
              <v-ons-checkbox
                :input-id="'checkfnSi'"
                v-model="fnSiFlg"
              ></v-ons-checkbox>FutureNetWeb⁺Si
            </label>
            <label class="release-check" v-show="getSystemUseSetting == 3" @change ="onRefresh()">
              <v-ons-checkbox
                :input-id="'checkReMS'"
                v-model="remsFlg"
              ></v-ons-checkbox>ReMS
            </label>
          </div>
        </div>
        <div class="release-body" id="release-body">
        <table class="release-list">
      <tbody>
          <tr v-for='master in filterItems'
            :key='master.ctlNo'
            :class="'release-list-body-tr'"
            >
            <td class='release-list-date body-col' @click="detailOpen(master)">{{ displayDateValue(master.releaseDate) }}</td>
            <td class='release-list-title body-col' @click="detailOpen(master)">{{ master.title }}</td>
          </tr>
        
      </tbody></table>
        </div>
      </div>
        <div class="pagination">
          <a href="#" class="prev" @click="onPrev" v-if="page > 1" >&lt; 前へ</a>
          <a class="prev" v-if="page == 1" >&emsp;&emsp;&emsp;</a>
          <div class="total">ページ {{page}}/{{totalPage}}</div>
          <a href="#" class="next" @click="onNext" v-if="page < totalPage">次へ &gt;</a>
          <a class="next"  v-if="page == totalPage" >&emsp;&emsp;&emsp;</a>
        </div>
      </div>

      <div class="maker-notice" v-show="displayMode == 2">
      <div class="release-base">
        <div class="scroll-area">
          <table class="release-list">
      <tbody>
              <tr>
              <td width="2.0em"><ons-icon icon="fa-arrow-left" size="1.5em" class="title" @click="headerOpen"></ons-icon></td>
              <td class='release-detail-date body-col'>{{displayDateValue(detailData.releaseDate)}}</td>
              <td class='release-detail-title body-col'>{{detailData.title}}</td>
            </tr>
            
      </tbody></table>
        </div>
        <div class="release-detail" id="release-detail">
          <span v-safe-html="detailHtml"></span>
        </div>
      </div>
      </div>
    </template>

    <template #footer>
      <div class="flex-container">
      <div class="denial-btn-area" style="background:none">
      </div>
      <div class="denial-btn-area" style="background:none">
        <button
          class="button btn2-cancel denial-btn" @click="cancel"
        >閉じる</button>
      </div>
      </div>
    </template>
  </modal-base>
</template>

<script>
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";

import ModalBase from "@/components/modals/ModalBase";
import MultiModalMixin from "@/components/modals/MultiModalMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";

export default {
  name: "ReleaseInfo",
  mixins: [MultiModalMixin],
  components: {
    "modal-base": ModalBase
  },
  data() {
    return {
      page: 1, //現在のページ番号
      perPage: 10, //1ページ毎の表示件数
      totalPage: 1, //総ページ数
      count: 0, //データの総数
      displayMode: 1, //画面表示モード(1:一覧／2:明細)
      dispFlg: false, //画面表示フラグ(初期表示用)
      fnSiFlg: false,
      remsFlg: false,
      detailData: {
        title:null,
        releaseDate:""
      }//明細表示data
    };
  },
  computed: {
    ...mapGetters("user", ["getSystemUseSetting"]),
    ...mapGetters("release-info",["getReleaseInfosAll","getDetail"]),

    // ReMSの表示有無を返す
    isReMS(){
      return this.getSystemUseSetting === "1" || this.getSystemUseSetting === "3";
    },
    // FNSiの表示有無を返す
    isFNSi(){
      return this.getSystemUseSetting === "2" || this.getSystemUseSetting === "3";
    },
    detailHtml() {
      return this.getDetail;
    },
    // 検索条件が変更されたら表示内容を更新
    filteredReleaseInfos() {
      let res;
      if(this.fnSiFlg && !this.remsFlg){
        res = this.getReleaseInfosAll.filter( e => e.systemType === "2");
      }else if(!this.fnSiFlg && this.remsFlg){
        res = this.getReleaseInfosAll.filter( e => e.systemType === "1");
      }else{
        res = this.getReleaseInfosAll.filter( e => e.systemType === "1" || e.systemType === "2");
      }
      return res;
    },
    filterItems() {
      return this.filteredReleaseInfos.slice((this.page - 1) * this.perPage, this.page * this.perPage);
    }
  },
  methods: {
    ...mapActions("release-info", [
      "getSystemReleaseInfosAll",
      "getReleaseDetail"
    ]),

    onPrev() {
      this.page = Math.max(this.page - 1, 1);
    },
    onNext() {
      this.page = Math.min(this.page + 1, this.totalPage);
    },
    async onRefresh(){
      this.page = 1;
      this.totalPage = Math.ceil(this.filteredReleaseInfos.length / this.perPage);
      var modal = getScopedElementById("release-body", this.$el || this);
      modal.scrollTop = 0;
    },
    
    /**
     * キャンセル処理
     */
    cancel() {
      this.hideModal();
    },

    async detailOpen(detailData){
      await this.getReleaseDetail(detailData.ctlNo);
      this.detailData = detailData;
      this.displayMode = 2;
    },

    headerOpen(){
      var modal = getScopedElementById("release-detail", this.$el || this);
      modal.scrollTop = 0;
      this.displayMode = 1;
    },

    displayDateValue(value) {
      return value == null
        ? "近日リリース予定"
        : dayjs(value).format("YYYY/MM/DD(ddd)");
    },
  },
  async created() {
    await this.getSystemReleaseInfosAll();
    // 初期値
    this.remsFlg = this.isReMS;
    this.fnSiFlg = this.isFNSi;
    this.totalPage = Math.ceil(this.filteredReleaseInfos.length / this.perPage);
    this.dispFlg = true;
  }
};
</script>

<style scoped>
.maker-notice-input {
  text-align:left;
  margin: 10px 5px 0px 10px;
}
.body-col {
  font-size: 1.0em;
  font-family: inherit;
}
.saving-modal {
  text-align: center;
}

.meker-notice{
  height:97%;
}

.release-check {
  margin:0em 1em 1em 0em;
}

.release-list-body-tr {
  /* 一覧のボーダーライン */

  /* 一覧の文字色 */
  color: #333333;
  background-color: #fafafa;
}

.release-list {
  width:100%;
  top: 0px;
}
.release-list-date{
  color: #fff;
  background-color: #333333;
  font-weight: 100;
  padding: 8px 6px 6px 8px;
  /* 一覧のボーダーライン */
  border: solid 1px #333333;
  /* 上のボーダーラインは非表示 */
  border-top: none;
  white-space: normal;
  text-align: left;
  min-width: 120px;
  width: 25%;
  top: 0;
}
.release-list-title {
  /* 一覧のボーダーライン */
  border-bottom:1px #333333 solid;
  padding: 8px 6px 6px 8px;
  white-space: pre-line;
  word-wrap: break-word;
  width: 75%;
  background-color: var(--ntss-base-background-color);
}
.release-body{
  border-collapse:separate;
  border-spacing: 0px 8px;
  position: absolute;
  width: -webkit-fill-available;
  margin: 0.5em 0.5em 0em 1em;
  height: calc(100% - 8em);
  white-space: pre-line;
  overflow-y: auto;
}
.pagination {
  text-align: center;
  position: absolute;
  width: -webkit-fill-available;
  bottom: 5.0px;
}
.pagination * {
  display: inline;
}

.release-detail{
  border-collapse:separate;
  border-spacing: 0px 8px;
  position: absolute;
  width: -webkit-fill-available;
  margin: 0.5em 0.5em 0em 1em;
  height: calc(100% - 5em);
  white-space: pre-line;
  overflow-y: auto;
}

.release-detail-date{
  color: #fff;
  background-color: #333333;
  font-weight: 100;
  padding: 8px 6px 6px 8px;
  /* 一覧のボーダーライン */
  border: solid 1px #333333;
  /* 上のボーダーラインは非表示 */
  border-top: none;
  white-space: pre;
  text-align: left;
  top: 0;
  width: 9em;
  min-width: 9em;
}
.release-detail-title {
  /* 一覧のボーダーライン */
  border-bottom:1px #333333 solid;
  padding: 8px 6px 6px 8px;
  white-space: pre;
  width: 100%;
}

a {
  border: 0;
  background: none;
  font-size: initial;
  margin: 0 1rem;
}
.scroll-area {
  overflow-x: auto;
}
@media print {
  .release-sub .scroll-area {
    display: none;
  }
  .modal-mask {
    height: auto !important;
    background-color: inherit;
  }
  div :deep(.modal-wrapper){
    height: auto !important;
  }
  div :deep(.modal-header),
  div :deep(.modal-footer){
    display: none !important;
  }
}
</style>
