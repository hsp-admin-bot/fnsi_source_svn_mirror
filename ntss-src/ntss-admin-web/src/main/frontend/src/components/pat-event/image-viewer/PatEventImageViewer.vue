<template>
  <!-- 比較ビュー表示エリア -->
  <div id="compareViewArea">
    <div
      id="compareView_patNameArea"
      style="height:60px;color:#FFFFFF;font-size:24px;line-height:60px;"
    ></div>
    <img :src="imgEditAsset('returnlist.png')" id="compareView_close" @click="onClickClose" />
    <div id="compareViewContainer">
      <!-- 左側 -->
      <div id="compareViewLeft">
        <!-- ヘッダー領域 -->
        <div style="height:20px;background-color:#7FFF7F;width:100%;"></div>
        <!-- 画像情報表示領域 -->
        <div id="compareView_imgInfo_Left" style="height:110px;color:#FFFFFF;">
          <label>患者ID：</label>
          <label>{{compareViewImgLeft[0].hospPatId}}</label>
          <label>&emsp;患者名：</label>
          <label>{{compareViewImgLeft[0].patName}}</label>
          <br />
          <label>イベント開始日時：</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start-->
          <!--<label>{{formatterDate(compareViewImgLeft[0].eventDate)}}</label>-->
          <label>{{formatterDate(compareViewImgLeft[0].eventStartDate + compareViewImgLeft[0].eventStartTime)}}</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end-->
          <label>～終了日時：</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start-->
          <!--<label>{{formatterDate(compareViewImgLeft[0].eventEndDate)}}</label>-->
          <label>{{formatterDate(compareViewImgLeft[0].eventEndDate + compareViewImgLeft[0].eventEndTime)}}</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end-->
          <br />
          <label>カテゴリ名：</label>
          <label>{{getCategoryName(compareViewImgLeft[0].categoryName,compareViewImgLeft[0].subCategoryName)}}</label>
          <br />
        </div>
        <!-- 画像表示領域 -->
        <draggable
          v-model="compareViewImgLeft"
          v-bind="{
         ...dragOptions,
          handle: '.compareViewVAImgArea_Left'
          }"
          style="height:80%;"
        >
          <div id="compareViewVAImgArea_Left" class="view-droppable">
            <img
              :src="compareViewImgLeft[0].data"
              id="compareView_VAImg_Left"
              @error="onNoImageError"
              onload="startFlg = false;"
            />
          </div>
        </draggable>
      </div>
      <!-- 右側 -->
      <div id="compareViewRight">
        <!-- ヘッダー領域 -->
        <div style="height:20px;background-color:#7F7FFF;width:100%;"></div>
        <!-- 画像情報表示領域 -->
        <div id="compareView_imgInfo_Right" style="height:110px;color:#FFFFFF;">
          <label>患者ID：</label>
          <label>{{compareViewImgRight[0].hospPatId}}</label>
          <label>&emsp;患者名：</label>
          <label>{{compareViewImgRight[0].patName}}</label>
          <br />
          <label>イベント開始日時：</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start-->
          <!--<label>{{formatterDate(compareViewImgRight[0].eventDate)}}</label>-->
          <label>{{formatterDate(compareViewImgRight[0].eventStartDate + compareViewImgRight[0].eventStartTime)}}</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end-->
          <label>～終了日時：</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start-->
          <!--<label>{{formatterDate(compareViewImgRight[0].eventEndDate)}}</label>-->
          <label>{{formatterDate(compareViewImgRight[0].eventEndDate + compareViewImgRight[0].eventEndTime)}}</label>
          <!--mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end-->
          <br />
          <label>カテゴリ名：</label>
          <label>{{getCategoryName(compareViewImgRight[0].categoryName,compareViewImgRight[0].subCategoryName)}}</label>
          <br />
        </div>
        <!-- 画像表示領域 -->
        <draggable
          v-model="compareViewImgRight"
          v-bind="{
         ...dragOptions,
         handle: '.compareViewVAImgArea_Right'
        }"
          style="height:80%;"
        >
          <div id="compareViewVAImgArea_Right" class="view-droppable">
            <img
              :src="compareViewImgRight[0].data"
              id="compareView_VAImg_Right"
              @error="onNoImageError"
              onload="startFlg = false;"
            />
          </div>
        </draggable>
      </div>
    </div>
    <!-- 写真選択エリア -->
    <div id="compareView_Sel_photoArea">
      <draggable
        v-model="compareViewImgs"
        v-bind="{
         ...dragOptions,
         handle: '.compareView_selphoto'
        }"
        @end="onEnd"
        style="height:100%;"
      >
        <div v-for="(item, index) in compareViewImgs" :key="index">
          <div class="compareView_selphoto" :id="'compareView_sel' + index">
            <img
              :src="item.data"
              :id="'compareView_photo' + index"
              @error="onNoImageError"
            />
          </div>
        </div>
      </draggable>
      <!-- 添付ファイル削除アイコン -->
      <img
        :src="imgEditAsset('delicon.png')"
        id="compareView_delfile"
        @click="onCompareViewDelfile()"
      />
    </div>
    <!-- ↑写真選択エリア↑ -->
  </div>
  <!-- ↑比較ビュー表示エリア↑ -->
</template>
<script>
import $$ from "@/compat/jquery";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { dateFormat } from "@/functions/common/DateTimeUtils";

import { VueDraggable } from "@/compat/drag/VueDraggable";
import dayjs from "@/compat/date/dayjs";
// mod #6107 2023/03/23 メッセージボックス全調整 張博 start
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { publicAssetPath } from "@/compat/assets/public-path";
import { messageFormat } from '@/functions/common/MessageFormat';
import { getScopedJQuery as createScopedJQuery } from "@/functions/common/LayoutMeasureHelper";

// mod #6107 2023/03/23 メッセージボックス全調整 張博 end
export default {
  components: {
    draggable: VueDraggable
  },
  data() {
    return {
      compareViewImgLeft: [
        {
          hospPatId: "",
          patName: "",
          patEventCd: 0,
          targetId: "",
          data: "",
          categoryName: "",
          subCategoryName: "",
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start*/
          /*eventDate: null,*/
          eventStartDate: null,
          eventStartTime: null,
          eventEndTime: null,
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end*/
          eventEndDate: null
        }
      ],
      compareViewImgRight: [
        {
          hospPatId: "",
          patName: "",
          patEventCd: 0,
          targetId: "",
          data: "",
          categoryName: "",
          subCategoryName: "",
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start*/
          /*eventDate: null,*/
          eventStartDate: null,
          eventStartTime: null,
          eventEndTime: null,
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end*/
          eventEndDate: null
        }
      ],
      compareViewImgs: [],
      // ドラック時の詳細設定
      dragOptions: {
        animation: 250, //drag時の速度
        forceFallback: true, //trueにすると、draggable用のDnDが作動するようになる
        dragClass: "drag", //ドラッグ時のクラス名
        ghostClass: "ghost", //ドロップ時のクラス名
        group: "group1"
      },
      // 情報保持最大件数
      limitCount: 10
    };
  },
  computed: {
    ...mapGetters("pat-event/viewer", ["getCompareViewImgs"])
  },

  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  methods: {
    scopedJQuery() {
      return createScopedJQuery(this.$el || this, $$) || $$;
    },
    imgEditAsset(fileName) {
      return publicAssetPath(`img/pat-event/img-edit/${fileName}`);
    },
    onImageFallbackError(event) {
      const target = event?.target;
      if (!target || target.dataset?.ntssFallbackApplied === "1") {
        return;
      }
      target.dataset.ntssFallbackApplied = "1";
      target.src = this.imgEditAsset("noimage.png");
    },
    onNoImageError(event) {
      const img = event?.target;
      if (!img || img.dataset.ntssFallbackApplied === "true") {
        return;
      }
      img.dataset.ntssFallbackApplied = "true";
      img.src = publicAssetPath("img/pat-event/img-edit/noimage.png");
    },
    ...mapActions("pat-event/viewer", ["clearCompareViewImgs"]),
    onClickClose() {
      //TODO: 比較ビューア用情報クリア
      this.compareViewImgLeft = [
        {
          hospPatId: "",
          patName: "",
          patEventCd: 0,
          targetId: "",
          data: "",
          categoryName: "",
          subCategoryName: "",
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start*/
          /*eventDate: null,*/
          eventStartDate: null,
          eventStartTime: null,
          eventEndTime: null,
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end*/
          eventEndDate: null
        }
      ];
      this.compareViewImgRight = [
        {
          hospPatId: "",
          patName: "",
          patEventCd: 0,
          targetId: "",
          data: "",
          categoryName: "",
          subCategoryName: "",
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 start*/
          /*eventDate: null,*/
          eventStartDate: null,
          eventStartTime: null,
          eventEndTime: null,
          /*mod FNSI-改修内容画像比較で、イベント開始、終了時刻の表示が不正任 end*/
          eventEndDate: null
        }
      ];
      // 前画面に戻る
      this.$emit("cancelViewer");
    },
    onCompareViewDelfile() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "確認",
        title: DIALOG_MESSAGES[13000108].title,
        // message: "選択情報を全て削除して画面を閉じます<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000108].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            // 画像選択エリア全非表示
            for (var i = 0; i <= 9; i++) {
              //          var buf = ("0" + i).slice(-2);
              let buf = this.comPadZero(i + 1, 1);
              $$("#compareView_photo" + buf).css("display", "none");
            }
            this.compareViewImgs = [];
            this.clearCompareViewImgs();
            // 比較ビュー画面を閉じる
            this.onClickClose();
          }
        }
      });
    },
    comPadZero(value, length) {
      return new Array(length - ("" + value).length + 1).join("0") + value;
    },
    initImage() {
      this.compareViewImgs = this.getCompareViewImgs;
      // 最小サイズクリア
      this.scopedJQuery()("#compareView_VAImg_Left").css("min-height", "");
      this.scopedJQuery()("#compareView_VAImg_Left").css("min-width", "");
      this.scopedJQuery()("#compareView_VAImg_Right").css("min-height", "");
      this.scopedJQuery()("#compareView_VAImg_Right").css("min-width", "");
      // 比較ビュー表示
      this.scopedJQuery()("#compareViewArea").css("display", "block");
      // 画像選択エリア表示
      this.scopedJQuery()("#compareView_Sel_photoArea").css("display", "block");
      // 選択可能分以外を非表示
      for (let intlop = 0; intlop < this.limitCount; intlop++) {
        let buf = this.comPadZero(intlop + 1, 1);
        if (intlop < this.compareViewImgs.length) {
          // 表示
          $$("#compareView_photo" + buf).css("display", "block");
        } else {
          // 非表示
          $$("#compareView_photo" + buf).css("display", "none");
        }
      }
    },
    onEnd() {
      this.compareViewImgs = this.getCompareViewImgs;
      const lengthLeft = this.compareViewImgLeft.length;
      const lengthRight = this.compareViewImgRight.length;
      this.compareViewImgLeft.splice(0, lengthLeft - 1);
      this.compareViewImgRight.splice(0, lengthRight - 1);
    },
    formatterDate(value) {
      if (value) {
        const dt = dateFormat.utc2Jst(value);
        return dayjs(dt, "YYYY-MM-DDTHH:mm:ss+09:00").format(
          "YYYY/MM/DD HH:mm"
        );
      } else {
        return "";
      }
    },
    getCategoryName(cate, subCate) {
      if (subCate) {
        return cate + "＞" + subCate;
      } else {
        return "";
      }
    }
  }
};
</script>
<style>
@media print {
  /** 印刷時、親要素消す */
  body:has(.image-viewer-modal[style*="display: table"]) .content-container {
    display: none;
  }
}
</style>
<style scoped>
/*=========== 比較ビュー表示領域 [始] ==================*/
#compareViewArea {
  /*float:left;
	display:none;*/
  position: absolute;
  width: 100%;
  height: 100%;
  background-color: black;
  left: 0px;
  top: 0px;
  z-index: 200;
}
#compareViewContainer {
  width: 100%;
  height: 80%;
  border-bottom: solid;
  border-color: #aaaaaa;
  border-width: 1px;
  display: flex;
}
#compareViewLeft {
  width: 49.9%;
  height: 100%;
  border-right: solid;
  border-color: #aaaaaa;
  border-width: 1px;
  float: left;
}
#compareViewVAImgArea_Left,
#compareViewVAImgArea_Right {
  color: #ffffff;
  text-align: center;
  vertical-align: middle;
  width: 100%;
  height: 100%;
  margin: 0px;
  line-height: 80%;
}
#compareView_VAImg_Left,
#compareView_VAImg_Right {
  width: 100%;
  max-height: 98%;
  max-width: 98%;
  vertical-align: middle;
  object-fit: contain;
}
#compareViewRight {
  width: 50%;
  height: 100%;
  float: right;
}

/* 患者VA情報表示領域[始] */
#compareView_imgInfo_Left,
#compareView_imgInfo_Right {
  background-color: black;
  width: 100%;
  height: 70px;
  margin: 0px 0px 0px 0px;
  font-size: 14px;
  overflow: auto;
}
#compareView_patVAInfo_Left,
#compareView_patVAInfo_Right {
  color: white;
  text-align: left;
  margin: 10px 0px 0px 10px;
  font-size: 24px;
  line-height: 30px;
}
/* 患者VA情報表示領域[終] */

/* VA画像表示領域[始] */
#compareView_photoArea_Left,
#compareView_photoArea_Right {
  background-color: black;
  width: 100%;
  height: 670px;
  text-align: center;
  line-height: 670px; /* heightと同じ値 */
  text-align: center;
  vertical-align: middle;
}
#compareView_VAImg {
  max-width: 100%;
  max-height: 100%;
  vertical-align: middle;
}
/* 終了ボタン */
#compareView_close {
  width: 50px;
  height: 50px;
  position: absolute;
  top: 5px;
  right: 20px;
  z-index: 210;
}
/* 写真選択エリア */
#compareView_Sel_photoArea {
  background-color: black;
  width: 100%;
  height: 10%;
  /*margin: 0 auto 0 auto;*/
  /*border-collapse:separate;
    border-spacing:5px 8px;*/
}
.compareView_selphoto {
  float: left;
  width: 85px;
  height: 100%;
  line-height: 55px;
  margin: 10px 0px 0px 5px;
  /*margin:0px;*/
  text-align: center;
  vertical-align: middle;
  border: 3px solid black;
  /*display:table-cell;*/
  position: relative;
}
#compareView_photo0,
#compareView_photo1,
#compareView_photo2,
#compareView_photo3,
#compareView_photo4,
#compareView_photo5,
#compareView_photo6,
#compareView_photo7,
#compareView_photo8,
#compareView_photo9 {
  /*max-height: 55px; */
  max-width: 85px;
  clear: both;
  /*float:left;*/
  /*width:80px;*/
  /*height:50px;*/
  /*margin: 14px 0px 0px 8px;*/
  /*border: 3px black solid;*/
  /*vertical-align: middle;*/
  top: 0;
  right: 0;
  /*bottom: 0;*/
  left: 0;
  position: absolute;
  margin: auto;
}
/* 全削除ボタン */
#compareView_delfile {
  display: block;
  width: 52px;
  height: 52px;
  position: absolute;
  bottom: 20px;
  right: 10px;
  z-index: 211;
}
/* ドロップしている要素 */
.ghost {
  opacity: 0.5;
}
/* ドラッグしている要素*/
.drag {
  display: none;
}

.category-handle,
.column-handle {
  cursor: move;
}

/*=========== 比較ビュー表示領域 [終] ==================*/
</style>
