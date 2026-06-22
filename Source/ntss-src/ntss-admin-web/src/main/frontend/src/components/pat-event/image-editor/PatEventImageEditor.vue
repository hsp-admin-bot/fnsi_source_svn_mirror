<template>
  <div>
    <div id="paint-mask"></div>
    <div id="edit-image-area" @click.capture="onClickImageArea">
      <div id="edit-pat-area">
        <!-- 患者情報エリア -->
        <div id="edit-pat-va-info-area" ref="patVaInfoArea">
          <p id="edit-pat-va-info"></p>
        </div>
        <!-- ↑患者情報エリア↑ -->
        <!-- 写真エリア -->
        <div id="edit-photo-area" ref="editPhotoArea">
          <img src id="edit-va-img" ref="baseImg" v-on:load="onLoadEditImage" />
          <canvas
            id="edit-va-img-paint"
            height="730px"
            width="950px"
            ref="editCanvas"
            @touchmove.capture="draw"
            @touchstart="startTouchEvent"
            @touchend="endTouchEvent"
            @touchcancel="endTouchEvent"
            @mousemove.capture="draw"
            @mousedown="startEvent"
            @mouseup="endEvent"
          ></canvas>
        </div>
        <!-- ↑写真エリア↑ -->
      </div>
      <!-- 編集アイコンエリア -->
      <div id="edit-menu-area" class="vertical-div">
        <!-- 戻る -->
        <img :src="imgEditAsset('modoru.png')" id="edit-close-icon" @click="onClickClose" />
        <!-- 登録 -->
        <img :src="imgEditAsset('drawreg.png')" id="edit-enter" @click="onClickEnter" />
        <!-- クリア -->
        <img :src="imgEditAsset('clear.png')" id="edit-clear" @click="onClickClear($event)" />
        <!-- 戻る -->
        <img
          :src="imgEditAsset('back.png')"
          id="edit-back"
          :disabled="isDisabledBack"
          @click="backPaint"
        />
        <!-- 進む -->
        <img
          :src="imgEditAsset('forward.png')"
          id="edit-move"
          :disabled="isDisabledForward"
          @click="movePaint"
        />
        <!-- フリーハンド -->
        <img :src="getToolIconSource.free" id="edit-free" @click="onClickFreeHand($event)" />
        <!-- 直線 -->
        <!--<img  src="img/returnlist.png" id="edit-line"/>-->
        <!-- 矢印 -->
        <img :src="getToolIconSource.arrow" id="edit-arrow" @click="onClickArrow($event)" />
        <!-- 四角 -->
        <img :src="getToolIconSource.square " id="edit-square" @click="onClickSquare($event)" />
        <!-- テキスト -->
        <img :src="getToolIconSource.text " id="edit-text" @click="onClickText($event)" />
        <!-- 描画色選択 -->
        <img
          :src="imgEditAsset('color_black.png')"
          id="edit-color"
          ref="editColor"
          @click="onClickEditColor($event)"
        />
        <!-- 消しゴム -->
        <img :src="getToolIconSource.eraser" id="edit-eraser" @click="onClickEraser($event)" />
        <!-- グリッド線 -->
        <img :src="getToolIconSource.grid" id="edit-grid" @click="onClickGrid($event)" />
      </div>
      <!-- ↑編集アイコンエリア↑ -->
    </div>
    <!-- クリア確認エリア -->
    <transition name="toolbox">
      <div id="sel-clean-area" ref="selClearArea" v-if="isShowToolBox.selClearArea">
        <img :src="imgEditAsset('clear_1.png')" id="selClear" @click="onClickSelClear" />
      </div>
    </transition>
    <!-- クリア確認エリア -->
    <!-- フリーハンド線太さ選択エリア -->
    <transition name="toolbox">
      <div
        id="sel-set-free-line-size-area"
        ref="selSetFreeLineSizeArea"
        v-if="isShowToolBox.selSetFreeLineSizeArea"
      >
        <img
          :src="getLineIconSource.thick1"
          id="sel-thick-1"
          @click="setLineSize(constant.lineSize.thick1)"
        />
        <img
          :src="getLineIconSource.thick2"
          id="sel-thick-2"
          @click="setLineSize(constant.lineSize.thick2)"
        />
        <img
          :src="getLineIconSource.thick3"
          id="sel-thick-3"
          @click="setLineSize(constant.lineSize.thick3)"
        />
        <img
          :src="getLineIconSource.thick4"
          id="sel-thick-4"
          @click="setLineSize(constant.lineSize.thick4)"
        />
      </div>
    </transition>
    <!-- フリーハンド線太さ選択エリア -->
    <!-- 矢印線太さ選択エリア -->
    <transition name="toolbox">
      <div
        id="sel-set-arrow-line-size-area"
        ref="selSetArrowLineSizeArea"
        v-if="isShowToolBox.selSetArrowLineSizeArea"
      >
        <img
          :src="getLineIconSource.thick1"
          id="sel-arrow-1"
          @click="setLineSize(constant.lineSize.thick1)"
        />
        <img
          :src="getLineIconSource.thick2"
          id="sel-arrow-2"
          @click="setLineSize(constant.lineSize.thick2)"
        />
        <img
          :src="getLineIconSource.thick3"
          id="sel-arrow-3"
          @click="setLineSize(constant.lineSize.thick3)"
        />
        <img
          :src="getLineIconSource.thick4"
          id="sel-arrow-4"
          @click="setLineSize(constant.lineSize.thick4)"
        />
        <hr width="250px" />
        <img
          :src="getLineDotIconSource.solid"
          id="sel-solid"
          @click="setLineDot(constant.lineDot.solid)"
        />
        <img
          :src="getLineDotIconSource.dash"
          id="sel-dash"
          @click="setLineDot(constant.lineDot.dash)"
        />
        <img :src="getLineDotIconSource.dot" id="sel-dot" @click="setLineDot(constant.lineDot.dot)" />
      </div>
    </transition>
    <!-- 矢印線太さ選択エリア -->

    <!-- テキスト編集エリア -->
    <transition name="toolbox">
      <div id="sel-set-text-area" ref="selSetTextArea" v-if="isShowToolBox.selSetTextArea">
        <div class="horizontal-div text-area-row">
          <img
            :src="imgEditAsset('roundcheck2.png')"
            id="cv-input-text"
            v-show="isCvInputTextMode"
            @click="setActiveText(1)"
          />
          <img
            :src="imgEditAsset('round-nocheck2.png')"
            id="cv-input-text"
            v-show="!isCvInputTextMode"
            @click="setActiveText(0)"
          />
          <com-textarea
            class="com-textare"
            :content="editingText"
            cssClass="textarea-custom-text-font"
            idTextarea="edit-text-area"
            rows="4"
            cols="27"
            refProp="editText"
            defaultHeight="90px"
            @set-content-data="setContentData"
            @click="setActiveText(0)"
          />
          <img :src="imgEditAsset('del_icon.png')" id="clear-edit-text" @click="clearText" />
        </div>
        <div class="horizontal-div text-area-row">
          <img
            :src="imgEditAsset('roundcheck2.png')"
            id="cv-sel-text"
            v-show="!isCvInputTextMode"
            @click="setActiveText(0)"
          />
          <img
            :src="imgEditAsset('round-nocheck2.png')"
            id="cv-sel-text"
            v-show="isCvInputTextMode"
            @click="setActiveText(1)"
          />
          <v-ons-select
            id="text-select"
            name="text-select"
            v-model="selectedText"
            @click="setActiveText(1)"
            ref="textSelect"
          >
            <option
              v-for="(textInfo, index) in stampTextInfo"
              :key="index"
              :value="textInfo.name"
            >{{ textInfo.text }}</option>
          </v-ons-select>
        </div>
        <div class="horizontal-div">
          <img
            :src="getTxtLineSizeIconSource.size1"
            id="sel-text-thick-1"
            @click="setTextSize(constant.txtLineSize.size1)"
          />
          <img
            :src="getTxtLineSizeIconSource.size2"
            id="sel-text-thick-2"
            @click="setTextSize(constant.txtLineSize.size2)"
          />
          <img
            :src="getTxtLineSizeIconSource.size3"
            id="sel-text-thick-3"
            @click="setTextSize(constant.txtLineSize.size3)"
          />
          <img
            :src="getTxtLineSizeIconSource.size4"
            id="sel-text-thick-4"
            @click="setTextSize(constant.txtLineSize.size4)"
          />
          <img
            :src="getTxtLineSizeIconSource.size5"
            id="sel-text-thick-5"
            @click="setTextSize(constant.txtLineSize.size5)"
          />
        </div>
      </div>
    </transition>
    <!-- テキスト編集エリア -->

    <!-- 描画色選択エリア -->
    <transition name="toolbox">
      <div id="sel-color-area" ref="selColorArea" v-if="isShowToolBox.selColorArea">
        <img
          :src="imgEditAsset('color_yellow.png')"
          id="sel-col-yellow"
          ref="selCol_yellow"
          @click="setColor('yellow')"
        />
        <img
          :src="imgEditAsset('color_orange.png')"
          id="sel-col-orange"
          ref="selCol_orange"
          @click="setColor('orange')"
        />
        <img
          :src="imgEditAsset('color_red.png')"
          id="sel-col-red"
          ref="selCol_red"
          @click="setColor('red')"
        />
        <img
          :src="imgEditAsset('color_black.png')"
          id="sel-col-black"
          ref="selCol_black"
          @click="setColor('black')"
        />
        <img
          :src="imgEditAsset('color_green.png')"
          id="sel-col-green"
          ref="selCol_green"
          @click="setColor('green')"
        />
        <img
          :src="imgEditAsset('color_purple.png')"
          id="sel-col-purple"
          ref="selCol_purple"
          @click="setColor('purple')"
        />
        <img
          :src="imgEditAsset('color_blue.png')"
          id="sel-col-blue"
          ref="selCol_blue"
          @click="setColor('blue')"
        />
        <img
          :src="imgEditAsset('color_white.png')"
          id="sel-col-white"
          ref="selCol_white"
          @click="setColor('white')"
        />
      </div>
    </transition>
    <!-- 描画色選択エリア -->

    <!-- 消しゴム太さ選択エリア -->
    <transition name="toolbox">
      <div
        id="sel-set-eraser-line-size-area"
        ref="selSetEraserLineSizeArea"
        v-if="isShowToolBox.selSetEraserLineSizeArea"
      >
        <img
          :src="getEraserIconSource.thick1"
          id="sel-eraser-thick-1"
          @click="setEraserSize(constant.eraserSize.thick1)"
        />
        <img
          :src="getEraserIconSource.thick2"
          id="sel-eraser-thick-2"
          @click="setEraserSize(constant.eraserSize.thick2)"
        />
        <img
          :src="getEraserIconSource.thick3"
          id="sel-eraser-thick-3"
          @click="setEraserSize(constant.eraserSize.thick3)"
        />
        <img
          :src="getEraserIconSource.thick4"
          id="sel-eraser-thick-4"
          @click="setEraserSize(constant.eraserSize.thick4)"
        />
      </div>
    </transition>
    <!-- 消しゴム太さ選択エリア -->

    <!-- グリッド描画サイズ選択エリア -->
    <transition name="toolbox">
      <div id="sel-grid-area" ref="selGridArea" v-if="isShowToolBox.selGridArea">
        <v-ons-select
          id="grid-select"
          name="grid-select"
          v-model="selectedGridId"
          @change="setGridSize()"
        >
          <option
            v-for="(gridSize, index) in gridSizeInfo"
            :key="index"
            :value="gridSize.id"
          >{{ gridSize.name }}</option>
        </v-ons-select>
      </div>
    </transition>
    <!-- グリッド描画サイズ選択エリア -->
    <!-- 保存用 -->
    <img id="save-va-img" style="display:none;" />
    <img
      id="save-va-img01"
      ref="saveVaImg01"
      style="display:none;"
      @error="onNoImageError"
    />
    <img
      id="save-va-img02"
      ref="saveVaImg02"
      style="display:none;"
      @error="onNoImageError"
    />
    <img
      id="save-va-img03"
      ref="saveVaImg03"
      style="display:none;"
      @error="onNoImageError"
    />
    <img
      id="save-va-img04"
      ref="saveVaImg04"
      style="display:none;"
      @error="onNoImageError"
    />
    <img
      id="save-va-img05"
      ref="saveVaImg05"
      style="display:none;"
      @error="onNoImageError"
    />
    <img
      id="save-va-img06"
      ref="saveVaImg06"
      style="display:none;"
      @error="onNoImageError"
    />
    <!-- 保存用 -->
    <!-- 編集用 -->
  </div>
</template>
<script>
  import {mapActions, mapGetters} from "@/compat/vue/vuex";
  import CommonTextArea from "@/components/common/CommonTextArea";
  import { publicAssetPath } from "@/compat/assets/public-path";

  export default {
  components: {
    "com-textarea": CommonTextArea
  },
  data() {
    return {
      /** 選択中の画像番号 */
      selImageNo: 1,
      /** 選択中のテキスト選択項目ID */
      tmpSelectedText: null,
      /** 選択中のグリッド選択項目ID */
      selectedGridId: "0",
      /** 編集中画像の識別子 */
      editingIdx: null,
      /** メニュー表示系 */
      isShowToolBox: {
        selClearArea: false,
        selSetFreeLineSizeArea: false,
        selSetArrowLineSizeArea: false,
        selSetTextArea: false,
        selColorArea: false,
        selSetEraserLineSizeArea: false,
        selGridArea: false
      },
      // テキストスタンプの状態 true:編集値 false: 選択値
      isCvInputTextMode: true,
      // 進む戻るボタン状態
      isDisabledForward: true,
      isDisabledBack: true,

      // 加工ツールボックスのフェードイン時間(ミリ秒)
      timer_ToolBox_FadeIn: 150,
      // 加工ツールボックスのフェードアウト時間(ミリ秒)
      timer_ToolBox_FadeOut: 150,

      // キャンバス
      canvas: null,
      context: null,
      canScaleX: 1,
      canScaleY: 1,
      editCanvasSize: { width: 0, height: 0 },

      // 編集内容キャンバスを保存用
      editPaint: new Array(6),

      // アクティブ["free",arrow"]
      activeMode: null,

      dragFlg: false,

      // UnDoReDo用
      imageMemory: new Array(40 + 1), // キャンバスのイメージの保存用配列
      flagMemory: 0, // 現在のキャンバスの番号
      lastFlagMemory: [0, 0, 0, 0, 0, 0], // 最終保存時のキャンバスの番号

      // 再編集用
      saveImageMemory: [
        new Array(40 + 1),
        new Array(40 + 1),
        new Array(40 + 1),
        new Array(40 + 1),
        new Array(40 + 1),
        new Array(40 + 1)
      ], // キャンバスのイメージの保存用配列

      oldX: 0, //
      oldY: 0, //
      canX: 0, //
      canY: 0, //

      // 描画色
      lineColor: "black",

      // 線の太さ
      tmpLineSize: null,

      // 矢印の線の種類[実線：Solid、破線：Dash、点線：Dot]
      tmpLineDot: null,

      // 消しゴム太さ
      tmpEraserSize: null,
      eraserMemory: null,

      // テキストフォントサイズ
      tmpTxtLineSize: null,

      // グリッドサイズ
      wGrid: 15,
      hGrid: 10,
      gridLineSize: 1,

      // タッチイベント管理
      touchEventFlg: false,

      // UnDo・ReDo用フラグ
      saveFlg: false,

      selectedTextElement: null,

      selectImgName: "",
      // テキストスタンプ系
      editingText: ""
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("pat-event/image-editor", [
      "getUnRedoNum",
      "getVaEditMaxPixel",
      "getStampTextInfo",
      "getGridSizeInfo"
    ]),
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    ...mapGetters("pat-event/viewer", ["getCompareViewImgs","getTarget"]),
    ...mapGetters("pat-event/detail", [
      "getPatEventRecord"
    ]),
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    unReDoNum() {
      if (this.getUnRedoNum !== null && this.getUnRedoNum !== undefined) {
        return this.getUnRedoNum;
      } else {
        return 40;
      }
    },
    /** テキスト選択情報 */
    stampTextInfo() {
      if (this.getStampTextInfo) {
        return this.getStampTextInfo;
      } else {
        return [{ id: "0", name: "Ｖ", text: "Ｖ" }];
      }
    },
    /** グリッド選択情報 */
    gridSizeInfo() {
      if (this.getGridSizeInfo) {
        return this.getGridSizeInfo;
      } else {
        return [
          { id: "0", name: "10 × 10", wSize: 10, hSize: 10, lineWidth: 1 }
        ];
      }
    },
    /** 定数 */
    constant() {
      return {
        paintMode: {
          free: "free",
          arrow: "arrow",
          square: "square",
          text: "text",
          eraser: "eraser",
          grid: "grid"
        },
        eraserSize: {
          thick1: 78,
          thick2: 52,
          thick3: 36,
          thick4: 20
        },
        /*mod FNSI-改修内容画像編集の問題。任 start*/
        /*lineSize: {
          thick1: 10,
          thick2: 3,
          thick3: 5,
          thick4: 1.5
        },*/
        lineSize: {
          thick1: 10,
          thick2: 5,
          thick3: 3,
          thick4: 1.5
        },
        /*mod FNSI-改修内容画像編集の問題。任 end*/
        lineDot: {
          solid: "Solid",
          dash: "Dash",
          dot: "Dot"
        },
        txtLineSize: {
          size1: 36,
          size2: 26,
          size3: 20,
          size4: 14,
          size5: 10
        }
      };
    },
    selectedText: {
      get() {
        if (this.tmpSelectedText) {
          return this.tmpSelectedText;
        } else {
          return this.stampTextInfo[0].name;
        }
      },
      set(value) {
        this.tmpSelectedText = value;
      }
    },
    /** 描画モード */
    active: {
      get() {
        if (this.activeMode) {
          return this.activeMode;
        } else {
          return this.constant.paintMode.free;
        }
      },
      set(value) {
        this.activeMode = value;
      }
    },
    /** 消しゴムサイズ */
    eraserSize: {
      get() {
        if (this.tmpEraserSize) {
          return this.tmpEraserSize;
        } else {
          return this.constant.eraserSize.thick2;
        }
      },
      set(value) {
        this.tmpEraserSize = value;
      }
    },
    /** 線の太さ */
    lineSize: {
      get() {
        if (this.tmpLineSize) {
          return this.tmpLineSize;
        } else {
          return this.constant.lineSize.thick2;
        }
      },
      set(value) {
        this.tmpLineSize = value;
      }
    },
    /** 線の種類 */
    lineDot: {
      get() {
        if (this.tmpLineDot) {
          return this.tmpLineDot;
        } else {
          return this.constant.lineDot.solid;
        }
      },
      set(value) {
        this.tmpLineDot = value;
      }
    },
    /** テキストスタンプの文字サイズ */
    txtLineSize: {
      get() {
        if (this.tmpTxtLineSize) {
          return this.tmpTxtLineSize;
        } else {
          return this.constant.txtLineSize.size3;
        }
      },
      set(value) {
        this.tmpTxtLineSize = value;
      }
    },
    /** ツールバーのアイコン */
    getToolIconSource() {
      return {
        free:
          this.active === this.constant.paintMode.free
            ? this.imgEditAsset("pencil_act.png")
            : this.imgEditAsset("pencil.png"),
        arrow:
          this.active === this.constant.paintMode.arrow
            ? this.imgEditAsset("arrow_act.png")
            : this.imgEditAsset("arrow.png"),
        square:
          this.active === this.constant.paintMode.square
            ? this.imgEditAsset("square_act.png")
            : this.imgEditAsset("square.png"),
        text:
          this.active === this.constant.paintMode.text
            ? this.imgEditAsset("text_act.png")
            : this.imgEditAsset("text.png"),
        eraser:
          this.active === this.constant.paintMode.eraser
            ? this.imgEditAsset("eraser_act.png")
            : this.imgEditAsset("eraser.png"),
        grid:
          this.active === this.constant.paintMode.grid
            ? this.imgEditAsset("grid_act.png")
            : this.imgEditAsset("grid.png")
      };
    },
    /** 消しゴムアイコン */
    getEraserIconSource() {
      return {
        thick1:
          this.eraserSize === this.constant.eraserSize.thick1
            ? this.imgEditAsset("eraser_1_act.png")
            : this.imgEditAsset("eraser_1.png"),
        thick2:
          this.eraserSize === this.constant.eraserSize.thick2
            ? this.imgEditAsset("eraser_2_act.png")
            : this.imgEditAsset("eraser_2.png"),
        thick3:
          this.eraserSize === this.constant.eraserSize.thick3
            ? this.imgEditAsset("eraser_3_act.png")
            : this.imgEditAsset("eraser_3.png"),
        thick4:
          this.eraserSize === this.constant.eraserSize.thick4
            ? this.imgEditAsset("eraser_4_act.png")
            : this.imgEditAsset("eraser_4.png")
      };
    },
    /** 線の太さアイコン */
    getLineIconSource() {
      return {
        thick1:
          this.lineSize === this.constant.lineSize.thick1
            ? this.imgEditAsset("bold_1_act.png")
            : this.imgEditAsset("bold_1.png"),
        thick2:
          this.lineSize === this.constant.lineSize.thick2
            ? this.imgEditAsset("bold_2_act.png")
            : this.imgEditAsset("bold_2.png"),
        thick3:
          this.lineSize === this.constant.lineSize.thick3
            ? this.imgEditAsset("bold_3_act.png")
            : this.imgEditAsset("bold_3.png"),
        thick4:
          this.lineSize === this.constant.lineSize.thick4
            ? this.imgEditAsset("bold_4_act.png")
            : this.imgEditAsset("bold_4.png")
      };
    },
    /** 線の書式アイコン */
    getLineDotIconSource() {
      return {
        solid:
          this.lineDot === this.constant.lineDot.solid
            ? this.imgEditAsset("solid_line_act.png")
            : this.imgEditAsset("solid_line.png"),
        dash:
          this.lineDot === this.constant.lineDot.dash
            ? this.imgEditAsset("dashed_line_act.png")
            : this.imgEditAsset("dashed_line.png"),
        dot:
          this.lineDot === this.constant.lineDot.dot
            ? this.imgEditAsset("dotted_line_act.png")
            : this.imgEditAsset("dotted_line.png")
      };
    },
    /** 文字の大きさアイコン */
    getTxtLineSizeIconSource() {
      return {
        size1:
          this.txtLineSize === this.constant.txtLineSize.size1
            ? this.imgEditAsset("font_1_act.png")
            : this.imgEditAsset("font_1.png"),
        size2:
          this.txtLineSize === this.constant.txtLineSize.size2
            ? this.imgEditAsset("font_2_act.png")
            : this.imgEditAsset("font_2.png"),
        size3:
          this.txtLineSize === this.constant.txtLineSize.size3
            ? this.imgEditAsset("font_3_act.png")
            : this.imgEditAsset("font_3.png"),
        size4:
          this.txtLineSize === this.constant.txtLineSize.size4
            ? this.imgEditAsset("font_4_act.png")
            : this.imgEditAsset("font_4.png"),
        size5:
          this.txtLineSize === this.constant.txtLineSize.size5
            ? this.imgEditAsset("font_5_act.png")
            : this.imgEditAsset("font_5.png")
      };
    }
  },
  methods: {
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
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
    ...mapActions("pat-event/viewer", [
      "setCompareViewImgs",
      "setCompareViewImgsReplace"
    ]),
    ...mapActions("pat-event/image-editor", ["fetchGridSizeInfo"]),
    /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    /** 初期化処理 */
    setSelImg(selectImg) {
      // キャンバスリサイズ
      this.canvas.width = 10;
      this.canvas.height = 10;

      // キャンバスサイズ調整クリア
      this.canvas.style.width = "";
      this.canvas.style.height = "";

      // キャンバス表示拡大率クリア
      this.canScaleX = 1;
      this.canScaleY = 1;

      // 編集元画像// 編集元画像クリア
      let editImage = this.$refs.baseImg;

      // 画像表示
      editImage.src = selectImg;

      let origImage = this.$refs["saveVaImg0" + this.selImageNo];
      origImage.src = selectImg;

      // ベース画像読込み後イベント
      // NOTE: editImage.onload イベントは onLoadEditImage() とした
    },
    /** ベース画像読込み後イベント */
    onLoadEditImage() {
      const dispImg = this.$refs.baseImg;
      const ratio = dispImg.naturalWidth / dispImg.naturalHeight;
      if (isNaN(ratio) || ratio === 0) {
        // ベース画像が正しく取得できていない
        return;
      }
      let imgWidth = dispImg.height * ratio;
      let imgHeight = dispImg.height;
      if (imgWidth > dispImg.width) {
        imgWidth = dispImg.width;
        imgHeight = dispImg.width / ratio;
      }

      // 画像が変わる度にキャンバスサイズ記憶
      this.editCanvasSize.width = imgWidth;
      this.editCanvasSize.height = imgHeight;

      // キャンバスサイズ・オフセットをセット
      this.canvasSet();

      // 最終保存時のUnDoReDoデータをセット
      this.imageMemory = this.saveImageMemory[this.selImageNo - 1];
      // キャンバス表示位置セット
      this.flagMemory = this.lastFlagMemory[this.selImageNo - 1];

      // 編集データ取得
      const editCanvasData = this.imageMemory[this.flagMemory];

      // 編集データがある場合
      if (editCanvasData !== undefined) {
        this.canvas.width = this.imageMemory[this.flagMemory].width;
        this.canvas.height = this.imageMemory[this.flagMemory].height;

        // 編集中のデータを描画
        this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);
      }
      // 編集データがない場合
      else {
        // 初期イメージ保存
        this.flagMemory = 0;
        this.imageMemory[this.flagMemory] = this.context.getImageData(
          0,
          0,
          this.canvas.width,
          this.canvas.height
        );
      }

      // キャンバスサイズ・オフセットをセット
      this.setCenter();
    },
    canvasSet() {
      // キャンバスリサイズ
      this.canvas.width = this.editCanvasSize.width;
      this.canvas.height = this.editCanvasSize.height;

      // 編集領域
      const dObj = this.$refs.editPhotoArea;

      // オフセット計算
      // 2015/06/09修正：以下の計算式でも誤差が出る[縦横で1px程度]
      let setOffsetX = Math.floor(
        (dObj.offsetWidth - this.canvas.width) / 2 - 0.5
      );
      const setOffsetY = dObj.offsetTop;
      // オフセット
      this.canX = setOffsetX;
      this.canY = setOffsetY;

      // 表示位置調整
      this.canvas.style.left = setOffsetX + "px";
      this.canvas.style.top = setOffsetY + "px";
    },
    /** 回転時の表示切替 */
    setCenter() {
      // 編集元画像
      const elmImg = this.$refs.baseImg;
      const ratio = elmImg.naturalWidth / elmImg.naturalHeight;
      if (isNaN(ratio) || ratio === 0) {
        // ベース画像が正しく取得できていない
        return;
      }
      let imgWidth = elmImg.height * ratio;
      let imgHeight = elmImg.height;
      if (imgWidth > elmImg.width) {
        imgWidth = elmImg.width;
        imgHeight = elmImg.width / ratio;
      }

      // 編集領域
      const dObj = this.$refs.editPhotoArea;

      // 拡大率(キャンバスサイズ[1:canScaleX]表示サイズ)
      this.canScaleX = imgWidth / this.canvas.width;
      this.canScaleY = imgHeight / this.canvas.height;

      // キャンバスサイズ調整
      this.canvas.style.width = imgWidth + "px";
      this.canvas.style.height = imgHeight + "px";

      // オフセット計算
      // 2015/06/09修正：以下の計算式でも誤差が出る[縦横で1px程度]
      const setOffsetX = Math.floor((dObj.offsetWidth - imgWidth) / 2 - 0.5);
      const setOffsetY = dObj.offsetTop;

      // オフセット
      this.canX = setOffsetX;
      this.canY = setOffsetY;

      // 表示位置調整
      this.canvas.style.left = setOffsetX + "px";
      this.canvas.style.top = setOffsetY + "px";
    },
    /** 描画領域クリック時 */
    onClickImageArea() {
      // console.log("onClickImageArea");
      // メニュー全部消す
      this.closeMenu();
    },
    /** 閉じるボタンクリックイベント */
    onClickClose() {
      // UnDoReDo戻す
      this.cancelUnDo();
      // 前画面に戻る
      this.$emit("cancelEditor");
    },
    /** 保存ボタンクリックイベント */
    onClickEnter() {
      this.saveEditCanvas();
    },
    /** 消しゴムボタンクリックイベント */
    onClickEraser() {
      if (this.active == this.constant.paintMode.eraser) {
        // 消しゴム太さ選択ダイアログ表示切り替え
        this.isShowToolBox.selSetEraserLineSizeArea = !this.isShowToolBox
          .selSetEraserLineSizeArea;
      } else {
        // 消しゴム太さ選択ダイアログ表示
        this.isShowToolBox.selSetEraserLineSizeArea = true;
      }

      // 消しゴムをアクティブにする
      this.active = this.constant.paintMode.eraser;

      this.context.globalCompositeOperation = "destination-out";
    },
    /** フリーハンドボタン押下時 */
    onClickFreeHand(e) {
      this.$nextTick(() => {
        if (this.$refs.selSetFreeLineSizeArea) {
          /*mod FNSI-改修内容toElement->target 任 start*/
          /*this.$refs.selSetFreeLineSizeArea.top = e.toElement.offsetTop + "px";*/
          this.$refs.selSetFreeLineSizeArea.top = e.target.offsetTop + "px";
          /*mod FNSI-改修内容toElement->target 任 end*/
        }
      });
      if (this.active === this.constant.paintMode.free) {
        // フリーハンド太さ選択ダイアログ表示切り替え
        this.isShowToolBox.selSetFreeLineSizeArea = !this.isShowToolBox
          .selSetFreeLineSizeArea;
      } else {
        // フリーハンド太さ選択ダイアログ表示
        this.isShowToolBox.selSetFreeLineSizeArea = true;
      }

      // フリーハンドをアクティブにする
      this.active = this.constant.paintMode.free;

      // 消しゴム状態解除
      this.context.globalCompositeOperation = "source-over";
    },
    /** 矢印ボタン押下時 */
    onClickArrow(e) {
      this.$nextTick(() => {
        if (this.$refs.selSetArrowLineSizeArea) {
          /*mod FNSI-改修内容toElement->target 任 start*/
          /*this.$refs.selSetArrowLineSizeArea.top = e.toElement.offsetTop + "px";*/
          this.$refs.selSetArrowLineSizeArea.top = e.target.offsetTop + "px";
          /*mod FNSI-改修内容toElement->target 任 end*/
        }
      });
      if (this.active === this.constant.paintMode.arrow) {
        // 矢印太さ選択ダイアログ表示切り替え
        this.isShowToolBox.selSetArrowLineSizeArea = !this.isShowToolBox
          .selSetArrowLineSizeArea;
      } else {
        // 矢印太さ選択ダイアログ表示
        this.isShowToolBox.selSetArrowLineSizeArea = true;
      }

      // 矢印をアクティブにする
      this.active = this.constant.paintMode.arrow;

      // 消しゴム状態解除
      this.context.globalCompositeOperation = "source-over";
    },
    /** 四角ボタン押下時 */
    onClickSquare() {
      // 四角をアクティブにする
      this.active = this.constant.paintMode.square;

      // 消しゴム状態解除
      this.context.globalCompositeOperation = "source-over";
    },
    /** テキストボタン押下時 */
    onClickText(e) {
      this.$nextTick(() => {
        if (this.$refs.selSetTextArea) {
          /*mod FNSI-改修内容toElement->target 任 start*/
          /*this.$refs.selSetTextArea.top = e.toElement.offsetTop + "px";*/
          this.$refs.selSetTextArea.top = e.target.offsetTop + "px";
          /*mod FNSI-改修内容toElement->target 任 end*/
        }
      });
      if (this.active == this.constant.paintMode.text) {
        // テキスト編集エリア表示切り替え
        this.isShowToolBox.selSetTextArea = !this.isShowToolBox.selSetTextArea;
      } else {
        // テキスト編集エリア表示
        this.isShowToolBox.selSetTextArea = true;
      }

      // テキストをアクティブにする
      this.active = this.constant.paintMode.text;

      // 消しゴム状態解除
      this.context.globalCompositeOperation = "source-over";
    },
    /** 色選択ボタン押下時 */
    onClickEditColor(e) {
      this.$nextTick(() => {
        if (this.$refs.selColorArea) {
          /*mod FNSI-改修内容toElement->target 任 start*/
          /*this.$refs.selColorArea.top = e.toElement.offsetTop + "px";*/
          this.$refs.selColorArea.top = e.target.offsetTop + "px";
          /*mod FNSI-改修内容toElement->target 任 end*/
        }
      });
      // 描画色選択ダイアログ表示切り替え
      this.isShowToolBox.selColorArea = !this.isShowToolBox.selColorArea;
    },
    /** グリッド描画サイズ選択ボタン押下時 */
    onClickGrid(e) {
      this.$nextTick(() => {
        if (this.$refs.selGridArea) {
          /*mod FNSI-改修内容toElement->target 任 start*/
          /*this.$refs.selGridArea.top = e.toElement.offsetTop + "px";*/
          this.$refs.selGridArea.top = e.target.offsetTop + "px";
          /*mod FNSI-改修内容toElement->target 任 end*/
        }
      });
      // グリッド描画サイズ選択ダイアログ表示切り替え
      this.isShowToolBox.selGridArea = !this.isShowToolBox.selGridArea;
      // グリッド線をアクティブにする
      this.active = this.constant.paintMode.grid;

      // 消しゴム状態解除
      this.context.globalCompositeOperation = "source-over";
    },
    /** クリアボタンクリックイベント */
    onClickClear(e) {
      this.$nextTick(() => {
        if (this.$refs.selClearArea) {
          /*mod FNSI-改修内容toElement->target 任 start*/
          /*this.$refs.selClearArea.top = e.toElement.offsetTop + "px";*/
          this.$refs.selClearArea.top = e.target.offsetTop + "px";
          /*mod FNSI-改修内容toElement->target 任 end*/
        }
      });
      // クリア確認バルーン表示切替
      this.isShowToolBox.selClearArea = !this.isShowToolBox.selClearArea;
    },
    /** クリアボタンクリックイベント */
    onClickSelClear() {
      this.clearCanvas();
      this.saveImageData();
    },
    /** クリア */
    clearCanvas() {
      // イメージクリア
      this.context.clearRect(
        0,
        0,
        this.context.canvas.width,
        this.context.canvas.height
      );

      // クリア選択ダイアログ非表示
      this.isShowToolBox.selClearArea = false;
    },
    /** フリーハンド線太さ変更時 */
    setLineSize(size) {
      // 線の太さをセット
      this.lineSize = size;

      // 消しゴム太さ選択ダイアログ非表示
      this.isShowToolBox.selSetEraserLineSizeArea = false;

      // フリーハンド線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetFreeLineSizeArea = false;

      // 矢印線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetArrowLineSizeArea = false;
    },
    /** 矢印の線の種類をセット */
    setLineDot(value) {
      // 線の種類をセット
      this.lineDot = value;

      // 消しゴム太さ選択ダイアログ非表示
      this.isShowToolBox.selSetEraserLineSizeArea = false;

      // フリーハンド線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetFreeLineSizeArea = false;
    },
    /** 消しゴム太さ変更時 */
    setEraserSize(size) {
      // 線の太さをセット
      this.eraserSize = size;

      // 消しゴム太さ選択ダイアログ非表示
      this.isShowToolBox.selSetEraserLineSizeArea = false;

      // フリーハンド線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetFreeLineSizeArea = false;

      // 矢印線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetArrowLineSizeArea = false;
    },
    /** テキストクリア */
    clearText() {
      this.editingText = "";
    },
    /** テキストフォントサイズ変更時 */
    setTextSize(size) {
      // 線の太さをセット
      this.txtLineSize = size;
    },
    /** スタンプテキスト切り替え*/
    setActiveText(actElm) {
      this.isCvInputTextMode = actElm === 0;
    },
    /** 描画色変更時 */
    setColor(colName) {
      const elmName = "selCol_" + colName;
      const setImg = this.$refs[elmName].src;

      // 描画色画像をセット
      this.$refs.editColor.src = setImg;

      this.lineColor = colName;

      // 描画色選択ダイアログ非表示
      this.isShowToolBox.selColorArea = false;
    },
    /** グリッドサイズ変更時 */
    setGridSize() {
      const gridSize = this.gridSizeInfo.find(
        elm => elm.id === this.selectedGridId
      );

      this.wGrid = gridSize.wSize;
      this.hGrid = gridSize.hSize;
      this.gridLineSize = gridSize.lineWidth;

      // 描画色選択ダイアログ非表示
      this.isShowToolBox.selColorArea = false;
    },
    /** ツールチップ非表示 */
    closeMenu() {
      // クリア選択ダイアログ非表示
      this.isShowToolBox.selClearArea = false;

      // 消しゴム太さ選択ダイアログ非表示
      this.isShowToolBox.selSetEraserLineSizeArea = false;

      // フリーハンド線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetFreeLineSizeArea = false;

      // 矢印線太さ選択ダイアログ非表示
      this.isShowToolBox.selSetArrowLineSizeArea = false;

      // テキスト編集ダイアログ非表示
      this.isShowToolBox.selSetTextArea = false;

      // 描画色選択ダイアログ非表示
      this.isShowToolBox.selColorArea = false;

      // グリッド描画サイズ選択ダイアログ非表示
      this.isShowToolBox.selGridArea = false;
    },
    /** 描画処理 */
    draw(e) {
      if (!this.dragFlg) {
        return;
      }

      e.preventDefault();

      if (this.active === this.constant.paintMode.free) {
        // フリーハンド選択時
        const x = this.returnAdjustX(e);
        const y = this.returnAdjustY(e);
        this.context.lineJoin = "round";
        this.context.lineCap = "round";
        this.context.lineWidth = this.lineSize;
        this.strokeLine(x, y);
        this.oldX = x;
        this.oldY = y;

        this.saveFlg = true;
      } else if (this.active == this.constant.paintMode.eraser) {
        // 消しゴム選択時
        const x = this.returnAdjustX(e);
        const y = this.returnAdjustY(e);
        this.context.miterLimit = this.eraserSize / 2;
        this.context.lineWidth = 2;

        // 消しゴム状態セット
        this.context.globalCompositeOperation = "destination-out";

        if (this.oldX != x || this.oldY != y) {
          // 四角描画
          this.context.fillStyle = this.lineColor;
          this.context.fillRect(
            this.oldX - this.eraserSize / 2,
            this.oldY - this.eraserSize / 2,
            this.eraserSize,
            this.eraserSize
          );
        }

        this.oldX = x;
        this.oldY = y;

        // 四角描画
        this.context.fillStyle = this.lineColor;
        this.context.fillRect(
          x - this.eraserSize / 2,
          y - this.eraserSize / 2,
          this.eraserSize,
          this.eraserSize
        );

        // 消しゴム状態解除
        this.context.globalCompositeOperation = "source-over";

        // 描画指標四角描画
        this.context.lineJoin = "bevel";
        this.context.lineCap = "butt";
        this.context.strokeStyle = "red";
        this.context.fillStyle = "red";
        this.context.strokeRect(
          x - this.eraserSize / 2 + 2,
          y - this.eraserSize / 2 + 2,
          this.eraserSize - 4,
          this.eraserSize - 4
        );

        this.saveFlg = true;
      } else if (this.active == this.constant.paintMode.arrow) {
        // 矢印
        const x = this.returnAdjustX(e);
        const y = this.returnAdjustY(e);

        // イメージクリア
        this.context.clearRect(
          0,
          0,
          this.context.canvas.width,
          this.context.canvas.height
        );

        if (this.imageMemory[this.flagMemory] != undefined) {
          // Canvasセット
          this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);
        }

        // 矢印描画
        this.context.lineJoin = "round";
        this.context.lineCap = "round";
        this.context.lineWidth = this.lineSize;
        this.canvas_arrow(this.oldX, this.oldY, x, y);

        this.saveFlg = true;
      } else if (this.active == this.constant.paintMode.square) {
        // 四角
        const x = this.returnAdjustX(e);
        const y = this.returnAdjustY(e);

        // イメージクリア
        this.context.clearRect(
          0,
          0,
          this.context.canvas.width,
          this.context.canvas.height
        );

        if (this.imageMemory[this.flagMemory] != undefined) {
          // Canvasセット
          this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);
        }

        // 四角描画
        this.context.fillStyle = this.lineColor;
        this.context.fillRect(
          this.oldX,
          this.oldY,
          x - this.oldX,
          y - this.oldY
        );

        this.saveFlg = true;
      } else if (this.active == this.constant.paintMode.text) {
        // テキスト
        const paintText = this.isCvInputTextMode
          ? this.editingText
          : this.selectedText;
        if (paintText.length > 0) {
          const x = this.returnAdjustX(e);
          const y = this.returnAdjustY(e);

          // イメージクリア
          this.context.clearRect(
            0,
            0,
            this.context.canvas.width,
            this.context.canvas.height
          );

          if (this.imageMemory[this.flagMemory] != undefined) {
            // Canvasセット
            this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);
          }

          // 	テキスト描画
          this.drawText(paintText, x, y);
          this.saveFlg = true;
        }
      } else if (this.active == this.constant.paintMode.grid) {
        // グリッド線
        const x = this.returnAdjustX(e);
        const y = this.returnAdjustY(e);

        // イメージクリア
        this.context.clearRect(
          0,
          0,
          this.context.canvas.width,
          this.context.canvas.height
        );

        if (this.imageMemory[this.flagMemory] != undefined) {
          // Canvasセット
          this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);
        }

        // 四角描画
        // 描画色
        //context.strokeStyle = lineColor;
        //context.strokeRect(oldX, oldY, x - oldX, y - oldY);
        // グリッド線描画
        //context.lineWidth = 0.8;
        this.context.lineWidth = this.gridLineSize;
        this.drawGrig(this.oldX, this.oldY, x, y);

        this.saveFlg = true;
      }
    },
    startTouchEvent(e) {
      // 指2本以上のときキャンセル
      if (e.touches.length > 1) {
        return;
      }
      this.startEvent(e);
    },
    startEvent(e) {
      // メニュー全部消す
      this.closeMenu();

      // キーボード非表示
      if (this.$refs.editText) {
        this.$refs.editText.blur();
      }

      this.dragFlg = true;
      this.oldX = this.returnAdjustX(e);
      this.oldY = this.returnAdjustY(e);

      // 消しゴム選択時
      if (this.active == this.constant.paintMode.eraser) {
        // 消しゴム状態解除
        this.context.globalCompositeOperation = "source-over";

        // 描画指標四角描画
        this.context.strokeStyle = "red";
        this.context.strokeRect(
          this.oldX - this.eraserSize / 2 + 2,
          this.oldY - this.eraserSize / 2 + 2,
          this.eraserSize - 4,
          this.eraserSize - 4
        );
      }

      // テキスト
      const paintText = this.isCvInputTextMode
        ? this.editingText
        : this.selectedText;
      if (this.active == this.constant.paintMode.text && paintText.length > 0) {
        // 	テキスト描画
        this.drawText(paintText, this.oldX, this.oldY);
      }

      // グリッド線
      if (this.active == this.constant.paintMode.grid) {
        // 描画色
        this.context.strokeStyle = this.lineColor;
        this.context.lineWidth = this.gridLineSize;
      }
    },
    endTouchEvent(e) {
      const x = e.changedTouches[0].pageX;
      const y = e.changedTouches[0].pageY;
      this.endStroke(x, y);
    },
    endEvent(e) {
      const x = e.clientX;
      const y = e.clientY;
      this.endStroke(x, y);
    },
    endStroke(x, y) {
      this.dragFlg = false;

      x = (x - this.canX) / this.canScaleX;
      y = (y - this.canY) / this.canScaleY;

      // 消しゴム選択時
      if (this.active == this.constant.paintMode.eraser) {
        // 消しゴム状態セット
        this.context.globalCompositeOperation = "destination-out";

        // 四角描画
        this.context.fillStyle = this.lineColor;
        this.context.fillRect(
          this.oldX - this.eraserSize / 2,
          this.oldY - this.eraserSize / 2,
          this.eraserSize,
          this.eraserSize
        );

        // 四角描画
        this.context.fillStyle = this.lineColor;
        this.context.fillRect(
          x - this.eraserSize / 2,
          y - this.eraserSize / 2,
          this.eraserSize,
          this.eraserSize
        );

        this.saveFlg = true;
      }

      // 矢印
      if (this.active == this.constant.paintMode.arrow) {
        this.context.lineJoin = "round";
        this.context.lineCap = "round";
        this.context.lineWidth = this.lineSize;
        this.canvas_arrow(this.oldX, this.oldY, x, y);

        this.saveFlg = true;
      }

      // 四角
      if (this.active == this.constant.paintMode.square) {
        this.context.fillStyle = this.lineColor;
      }

      // テキスト
      const paintText = this.isCvInputTextMode
        ? this.editingText
        : this.selectedText;
      if (this.active == this.constant.paintMode.text && paintText.length > 0) {
        this.drawText(paintText, x, y);

        // テキスト編集エリア表示
        this.isShowToolBox.selSetTextArea = true;

        this.saveFlg = true;
      }

      // グリッド線
      if (this.active == this.constant.paintMode.grid) {
        // イメージクリア
        /*context.clearRect(0, 0, context.canvas.width, context.canvas.height);

        if(imageMemory[flagMemory] != undefined)
        {
        // Canvasセット
        context.putImageData(imageMemory[flagMemory], 0, 0);
        }


        // グリッド線描画
        //context.lineWidth = 0.8;
        context.lineWidth = gridLineSize;
        drawGrig(oldX, oldY, x, y);*/

        this.saveFlg = true;
      }

      if (this.saveFlg == true) {
        // 現在の状態を保存
        this.saveImageData();

        this.saveFlg = false;
      }
    },
    returnAdjustX(e) {
      let returnX = 0;

      if (e.type.startsWith("touch")) {
        returnX = e.touches[0].pageX;
      } else {
        returnX = e.clientX;
      }

      // 実際のキャンバスサイズとの比率
      returnX = (returnX - this.canX) / this.canScaleX;

      return returnX;
    },
    returnAdjustY(e) {
      let returnY = 0;
      if (e.type.startsWith("touch")) {
        returnY = e.touches[0].pageY;
      } else {
        returnY = e.clientY;
      }

      // 実際のキャンバスサイズとの比率
      returnY = (returnY - this.canY) / this.canScaleY;

      return returnY;
    },
    /** 線描画 */
    strokeLine(x, y) {
      this.context.beginPath();
      this.context.moveTo(this.oldX, this.oldY);
      this.context.lineTo(x, y);
      this.context.closePath();
      this.context.strokeStyle = this.lineColor;
      this.context.stroke();
    },
    /** 矢印描画 */
    canvas_arrow(fromX, fromY, toX, toY) {
      const headLen = this.lineSize * 4;
      const angle = Math.atan2(toY - fromY, toX - fromX);

      // パスクリア
      this.context.beginPath();

      // 実線
      let setLine = [];

      // 破線
      if (this.lineDot == "Dash") {
        setLine = [this.lineSize * 3, this.lineSize * 3];
      }
      // 点線
      else if (this.lineDot == "Dot") {
        setLine = [0.01, this.lineSize * 3];
      }

      // setLineDash関数が使用可能の場合
      if (this.context.setLineDash !== undefined)
        this.context.setLineDash(setLine);

      this.context.moveTo(fromX, fromY);
      this.context.lineTo(toX, toY);

      this.context.lineJoin = "round";
      this.context.lineCap = "round";

      // 線を描画
      this.context.stroke();

      // パスクリア
      this.context.beginPath();

      // setLineDash関数が使用可能の場合
      if (this.context.setLineDash !== undefined) this.context.setLineDash([]);

      // 矢印描画
      this.context.moveTo(
        toX - headLen * Math.cos(angle - Math.PI / 6),
        toY - headLen * Math.sin(angle - Math.PI / 6)
      );
      this.context.lineTo(toX, toY);
      this.context.lineTo(
        toX - headLen * Math.cos(angle + Math.PI / 6),
        toY - headLen * Math.sin(angle + Math.PI / 6)
      );

      // 描画色
      this.context.strokeStyle = this.lineColor;

      // 線を描画
      this.context.stroke();
    },
    /** テキスト描画 */
    drawText(text, dx, dy) {
      this.context.fillStyle = this.lineColor;
      this.context.font = this.txtLineSize + "pt 'ＭＳ ゴシック', sans-serif";
      this.context.textAlign = "left";
      this.context.textBaseline = "top";

      // 改行
      let textList = text.split("\n");
      const lineHeight = this.context.measureText("あ").width;

      textList.forEach((text, i) => {
        this.context.fillText(text, dx, dy + lineHeight * i);
      });
    },
    /** グリッド線描画 */
    drawGrig(fromX, fromY, toX, toY) {
      // 線の幅計算
      const lineWidth = Math.round(Math.abs((toX - fromX) / this.wGrid));
      const lineHeight = Math.round(Math.abs((toY - fromY) / this.hGrid));

      // 描画開始位置
      let startLineX = fromX;

      // 開始座標X
      if (fromX > toX) {
        startLineX = toX;
      }

      let startLineY = fromY;

      // 開始座標Y
      if (fromY > toY) {
        startLineY = toY;
      }

      // 描画開始
      this.context.beginPath();

      // 縦線描画
      for (let i = 0; i <= this.wGrid; i++) {
        // 直線描画
        this.context.moveTo(startLineX + lineWidth * i, startLineY);
        this.context.lineTo(
          startLineX + lineWidth * i,
          startLineY + lineHeight * this.hGrid
        );
      }

      // 横線描画
      for (let i = 0; i <= this.hGrid; i++) {
        // 直線描画
        this.context.moveTo(startLineX, startLineY + lineHeight * i);
        this.context.lineTo(
          startLineX + lineWidth * this.wGrid,
          startLineY + lineHeight * i
        );
      }

      // 描画
      this.context.stroke();
    },
    /**指定サイズを設定された最大画素数以下のサイズで返す */
    reduceImageSize(Width, Height) {
      const size = { X: Width, Y: Height };

      // VA画像編集可能最大画素数
      const imgPxMax = Math.floor(this.getVaEditMaxPixel);

      // 画素数判定
      const imgPx = Width * Height;
      if (imgPxMax < imgPx) {
        // 設定画素数を超えた場合

        // 設定された画素数以下のサイズを算出する
        const work = size.Y / size.X;
        size.X = Math.floor(Math.sqrt(imgPxMax / work));
        size.Y = Math.floor(size.X * work);
      }

      return size;
    },
    /** 保存 */
    saveEditCanvas() {
      // 最終保存時のUnDoReDoデータを保存
      this.saveImageMemory[this.selImageNo - 1] = this.imageMemory;
      // 最終保存時の編集位置を保存
      // UnDoReDo位置記憶
      this.lastFlagMemory[this.selImageNo - 1] = this.flagMemory;

      // 保存元画像
      const baseImg = this.$refs["saveVaImg0" + this.selImageNo];
      // 編集中画像
      // var editImg = this.$refs.baseImg;

      // 保存用のキャンバス作成
      const ownerDocument = baseImg?.ownerDocument || this.$el?.ownerDocument || document;
      const ownerWindow = ownerDocument.defaultView || window;
      let saveCanvas = ownerDocument.createElement("canvas");
      let saveContext = saveCanvas.getContext("2d");
      saveContext.globalCompositeOperation = "source-over";

      // 画像編集時の画像サイズで保存する
      // 編集元画像
      const dispImg = this.$refs.baseImg;
      const ratio = dispImg.naturalWidth / dispImg.naturalHeight;
      let imgWidth = dispImg.height * ratio;
      let imgHeight = dispImg.height;
      if (imgWidth > dispImg.width) {
        imgWidth = dispImg.width;
        imgHeight = dispImg.width / ratio;
      }

      //	var cvSize = reduceImageSize(editImg.width, editImg.height);
      const cvSize = this.reduceImageSize(imgWidth, imgHeight);
      saveCanvas.width = cvSize.X;
      saveCanvas.height = cvSize.Y;

      // 編集前画像取得
      /* Imageオブジェクトを生成 */
      let setImg = new (ownerWindow.Image || Image)();
      setImg.crossOrigin = "Anonymous";

      const mimeType = "image/png";

      /* 画像が読み込まれてから保存用キャンバスへ書き出す */
      setImg.onload = () => {
        // 保存用キャンバスに編集前画像描画
        saveContext.drawImage(
          setImg,
          0,
          0,
          saveCanvas.width,
          saveCanvas.height
        );

        // Canvasの内容を取得
        // Canvasからbase64エンコーディングされた画像データを取得する
        this.editPaint[this.selImageNo - 1] = this.canvas.toDataURL(mimeType);
        let saveImg = ownerDocument.createElement("img");

        /* Canvasの内容が読み込まれてから保存用のキャンバスへ書き出す */
        saveImg.onload = () => {
          // 保存用キャンバスにCanvasの内容を描画
          saveContext.drawImage(
            saveImg,
            0,
            0,
            saveCanvas.width,
            saveCanvas.height
          );

          // 保存用キャンバスからbase64エンコーディングされた画像データを取得する
          const saveData = saveCanvas.toDataURL(mimeType);

          // 画像選択画面に保存する
          // let selEditImg = document.getElementById(
          //   "dia_imgicon0" + this.selImageNo
          // );
          // selEditImg.src = saveData;

          // イメージクリア
          this.context.clearRect(
            0,
            0,
            this.context.canvas.width,
            this.context.canvas.height
          );

          // 編集不可マスク非表示
          // this.setLoadingScreenVisible(false);

          const fileName = this.selectImgName.substr(
            0,
            this.selectImgName.lastIndexOf(".")
          );

          // 前画面に戻る
          this.$emit("successEditor", {
            img: saveData,
            idx: this.editingIdx,
            name: fileName + ".png"
          });
        };
        saveImg.src = this.editPaint[this.selImageNo - 1];
      };
      setImg.src = baseImg.src;
      /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 start*/
      this.getCompareViewImgs.forEach((item,index) => {
        if(this.getPatEventRecord.patEventCd === item.patEventCd && this.getTarget === item.targetId){
          this.setCompareViewImgsReplace(index);
        }
      })
      /*add FNSI-改修内容比較中の画像について、編集しても、最新の画像で適用されない 任 end*/
    },
    /*************** 戻る・進む処理[始] ***************/
    /** キャンバス保存データをクリア */
    clearImageData() {
      this.flagMemory = 0;
      this.imageMemory = new Array(this.unReDoNum + 1);

      this.lastFlagMemory[this.selImageNo - 1] = this.flagMemory;
      this.saveImageMemory[this.selImageNo - 1] = new Array(this.unReDoNum + 1);
    },
    /** ダイアログ開くときキャンバス保存データをクリア */
    clearUnReDoData() {
      this.flagMemory = 0;
      this.imageMemory = new Array(this.unReDoNum + 1);

      // ペイント情報クリア
      this.lastFlagMemory = [0, 0, 0, 0, 0, 0]; // 最終保存時のキャンバスの番号

      // 再編集用
      this.saveImageMemory = [
        new Array(this.unReDoNum + 1),
        new Array(this.unReDoNum + 1),
        new Array(this.unReDoNum + 1),
        new Array(this.unReDoNum + 1),
        new Array(this.unReDoNum + 1),
        new Array(this.unReDoNum + 1)
      ];
    },
    /** 現在のキャンバス状態を保存 */
    saveImageData() {
      // 不要データ削除
      this.imageMemory = this.imageMemory.slice(0, this.flagMemory + 1);

      // 現在の状態を保存
      if (this.flagMemory == this.unReDoNum) {
        this.imageMemory.shift();
      } else {
        ++this.flagMemory;
      }

      if (this.flagMemory == this.unReDoNum) {
        this.isDisabledForward = true;
      }

      this.imageMemory[this.flagMemory] = this.context.getImageData(
        0,
        0,
        this.canvas.width,
        this.canvas.height
      );
      this.isDisabledBack = false;
    },
    /** 戻るボタン */
    backPaint() {
      if (this.imageMemory[this.flagMemory - 1] !== undefined) {
        this.flagMemory--;
        this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);

        this.isDisabledForward = false;
        if (this.flagMemory == 0) {
          this.isDisabledBack = true;
        }
      }
    },
    /** 進むボタン */
    movePaint() {
      if (this.imageMemory[this.flagMemory + 1] != undefined) {
        this.flagMemory++;
        this.context.putImageData(this.imageMemory[this.flagMemory], 0, 0);

        this.isDisabledBack = false;

        if (this.flagMemory == this.unReDoNum - 1) {
          this.isDisabledForward = true;
        }
      }
    },
    /** UnDoReDo戻す */
    cancelUnDo() {
      this.flagMemory = this.lastFlagMemory[this.selImageNo - 1];
    },
    /*************** 戻る・進む処理[終] ***************/
    allClear() {
      // 編集中キャンバスクリア
      this.editPaint = new Array(6);
      // キャンバス保存データをクリア
      this.clearUnReDoData();
      // 編集元画像クリア
      this.$refs.baseImg.src = "";
    },
    /** 初期化処理 */

    init(selectImg, selectImgName, selectIdx) {
      // Canvasオブジェクト作成
      this.canvas = this.$refs.editCanvas;
      this.context = this.canvas.getContext("2d");
      // グリッドサイズ初期値設定
      this.wGrid = this.gridSizeInfo[0].wSize;
      this.hGrid = this.gridSizeInfo[0].hSize;
      this.gridLineSize = this.gridSizeInfo[0].lineWidth;
      this.allClear();
      this.setSelImg(selectImg);

      this.editingIdx = selectIdx;
      this.selectImgName = selectImgName;
    },

    setContentData(newValue) {
      this.editingText = newValue;
    }
  },
  watch: {
    windowHeight() {
      this.setCenter();
    },
    windowWidth() {
      this.setCenter();
    }
  },
  async created() {
    await this.fetchGridSizeInfo();
    this.$ons.orientation.on("change", this.setCenter);
  },

  unmounted() {
    this.$ons.orientation.off("change", this.setCenter);
  },
  beforeUnmount() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>
<style>
@media print {
  /** 印刷時、親要素消す */
  body:has(.image-editor-modal[style*="display: table"]) .content-container {
    display: none;
  }
}
</style>
<style scoped>
.vertical-div {
  display: flex;
  flex-direction: column;
  align-content: flex-start;
  font-size: 1em;
}
.horizontal-div {
  display: flex;
  flex-direction: row;
}
/*=========== 写真編集領域[始] ==================*/
#edit-image-area {
  float: left;
  position: absolute;
  width: 100%;
  height: 100%;
  background-color: black;
  left: 0px;
  top: 0px;
  z-index: 400;
}

/* 患者VA情報表示領域[始] */
#edit-pat-va-info-area {
  background-color: black;
  width: 80%;
  height: 40px;
  margin: 0px 0px 0px 0px;
  /*overflow:scroll;*/
}
#edit-pat-va-info {
  color: white;
  text-align: left;
  margin: 10px 0px 0px 10px;
  font-size: 24px;
  line-height: 30px;
}
/* 患者VA情報表示領域[終] */

#edit-pat-area {
  width: calc(100% - 60px);
  height: 100%;
  border-right: 1px solid white;
  float: left;
}

/* VA画像表示領域[始] */
#edit-photo-area {
  background-color: black;
  width: 100%;
  height: 680px;
  /*del FNSI-改修内容画像編集の問題。任 start*/
  /*line-height: 680px; !* heightと同じ値 *!*/
  /*del FNSI-改修内容画像編集の問題。任 end*/
  text-align: center;
  vertical-align: middle;
  float: left;
  overflow: auto;
  -webkit-overflow-scrolling: touch;
  user-select: none; /* CSS3 */
  -moz-user-select: none; /* Firefox */
  -webkit-user-select: none; /* Safari、Chromeなど */
}
/* 編集用キャンバス */
#edit-va-img {
  /*del FNSI-改修内容画像編集の問題。任 start*/
  /*width: 100%;*/
  /*del FNSI-改修内容画像編集の問題。任 end*/
  max-width: 98%;
  max-height: 100%;
  vertical-align: middle;
  user-select: none; /* CSS3 */
  -moz-user-select: none; /* Firefox */
  -webkit-user-select: none; /* Safari、Chromeなど */
  object-fit: contain;
}

/* 編集用キャンバス(ペイント用) */
#edit-va-img-paint {
  position: absolute;
  background-color: transparent;
  max-width: 100%;
  max-height: 100%;
  vertical-align: middle;

  /*z-index:210;*/
}

/* 文字サイズ表示 */
#lineSize {
  float: left;
  background-color: white;
  margin-top: 5px;
  margin-left: 25px;
  width: 32px;
  height: 32px;
}
/* 文字サイズ選択 */
#sizeSelect {
  float: left;
  margin-top: 8px;
  margin-left: 10px;
  font-size: 14px;
}

/* VA画像表示領域[終] */

/* メニュー領域 */
#edit-menu-area {
  float: left;
  height: 100%;
  background-color: black;
  padding-left: 5px;
}
/* 編集完了ボタン */
#edit-close-icon {
  display: block;
  width: 50px;
  height: 50px;
  /*margin-top: 20px;*/
  margin-top: 10px;
  z-index: 210;
}
/* 登録ボタン */
#edit-enter {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  z-index: 210;
}
/* クリアボタン */
#edit-clear {
  width: 50px;
  height: 50px;
  /*margin-top: 30px;*/
  margin-top: 15px;
  z-index: 210;
}
#sel-clean-area {
  background-color: white;
  width: 70px;
  height: 70px;
  position: absolute;
  right: 80px;
  top: 130px;
  border-radius: 10px;
  z-index: 410;
}
#selClear {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 10px;
}

/* 戻るボタン */
#edit-back {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}
/* 進むボタン */
#edit-move {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}
/* 消しゴム */
#edit-eraser {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}
/* 消しゴム太さ選択エリア */
#sel-set-eraser-line-size-area {
  background-color: white;
  width: 270px;
  height: 70px;
  position: absolute;
  right: 80px;
  top: 605px;
  border-radius: 10px;
  z-index: 410;
}

#sel-eraser-thick-1,
#sel-eraser-thick-2,
#sel-eraser-thick-3,
#sel-eraser-thick-4 {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 10px;
}
/* ↑消しゴム太さ選択エリア */

/* グリッド線 */
#edit-grid {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}
/* フリーペイントボタン */
#edit-free {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}
/* フリーハンド線太さ選択エリア */
#sel-set-free-line-size-area {
  background-color: white;
  width: 270px;
  height: 70px;
  position: absolute;
  right: 80px;
  top: 310px;
  border-radius: 10px;
  z-index: 410;
}

#sel-thick-1,
#sel-thick-2,
#sel-thick-3,
#sel-thick-4 {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 10px;
}
/* ↑フリーハンド線太さ選択エリア */

/* 直線ボタン */
#edit-line {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}

#sel-line-1,
#sel-line-2,
#sel-line-3,
#sel-line-4 {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 10px;
}
/* ↑直線太さ選択エリア↑ */

/* 四角 */
#edit-square {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}

/* 矢印 */
#edit-arrow {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}

/* 矢印線太さ選択エリア */
#sel-set-arrow-line-size-area {
  background-color: white;
  width: 270px;
  height: 145px;
  position: absolute;
  right: 80px;
  top: 330px;
  border-radius: 10px;
  z-index: 410;
}
#sel-arrow-1,
#sel-arrow-2,
#sel-arrow-3,
#sel-arrow-4 {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 10px;
}
#sel-solid,
#sel-dash,
#sel-dot {
  width: 50px;
  height: 50px;
  margin-top: 3px;
  margin-left: 27px;
}
/* ↑矢印太さ選択エリア↑ */

/* テキストボタン */
#edit-text {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}
/* テキスト編集エリア */
#sel-set-text-area {
  background-color: white;
  width: 375px;
  height: 230px;
  position: absolute;
  right: 80px;
  top: 410px;
  border-radius: 10px;
  z-index: 410;
}
#cv-input-text {
  width: 25px;
  height: 25px;
  margin-left: 10px;
}
#clear-edit-text {
  margin-left: 2px;
  width: 20px;
  height: 20px;
}
#sel-text-thick-1,
#sel-text-thick-2,
#sel-text-thick-3,
#sel-text-thick-4,
#sel-text-thick-5 {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 17px;
}
div :deep(#edit-text-area) {
  margin-top: 10px;
  margin-left: 5px;
  font-size: 18px;
  width: 94%;
  height: 90px !important;
  resize: none;
  box-sizing: border-box;
}
#cv-sel-text {
  width: 25px;
  height: 25px;
  margin-left: 10px;
}
#text-select {
  margin-top: 10px;
  margin-left: 5px;
  font-size: 18px;
  width: 300px;
  height: 32px;
  vertical-align: middle;
}
.text-area-row {
  align-items: center;
}
/* ↑テキスト編集エリア↑ */

/* 描画色選択ボタン */
#edit-color {
  width: 50px;
  height: 50px;
  /*margin-top: 10px;*/
  margin-top: 5px;
  z-index: 210;
}

/* 描画色選択エリア */
#sel-color-area {
  background-color: white;
  width: 270px;
  height: 140px;
  position: absolute;
  right: 80px;
  top: 515px;
  border-radius: 10px;
  z-index: 410;
}
#sel-col-black,
#sel-col-white,
#sel-col-blue,
#sel-col-red,
#sel-col-green,
#sel-col-yellow,
#sel-col-orange,
#sel-col-purple {
  width: 50px;
  height: 50px;
  margin-top: 10px;
  margin-left: 10px;
}
/* ↑描画色選択エリア↑ */
/* グリッド描画サイズ選択エリア */
#sel-grid-area {
  background-color: white;
  width: 170px;
  height: 60px;
  position: absolute;
  right: 80px;
  top: 675px;
  border-radius: 10px;
  z-index: 410;
  align-items: center;
  display: flex;
}
#grid-select {
  margin-left: 15px;
  font-size: 18px;
  width: 140px;
  height: 32px;
  vertical-align: middle;
}
/* ↑グリッド描画サイズ選択エリア↑ */
/*=========== 写真編集[終] ==================*/

/*===================== 縦画面専用CSS ==============================*/
@media only screen and (orientation: portrait) {
  /*=========== 写真編集領域[始] ==================*/
  #edit-image-area {
    float: left;
    position: absolute;
    width: 100%;
    height: 100%;
    background-color: black;
    left: 0px;
    top: 0px;
    z-index: 400;
  }

  #edit-pat-area {
    height: 100%;
    border-right: 1px solid white;
    float: left;
  }

  /* VA画像表示領域[始] */
  #edit-photo-area {
    background-color: black;
    width: 100%;
    /* height: 1280px; */
    /* line-height: 1280px; */ /* heightと同じ値 */
    height: 100%;
    line-height: 100%;
    text-align: center;
    vertical-align: middle;
    float: left;
  }

  /* 編集用キャンバス(ペイント用) */
  #edit-va-img-paint {
    position: absolute;
    background-color: transparent;
    max-width: 100%;
    max-height: 100%;
    vertical-align: middle;

    /*z-index:210;*/
  }
  /* メニュー領域 */
  #edit-menu-area {
    float: left;
    height: 100%;
    background-color: black;
    padding-left: 7px;
  }
  /* VA画像表示領域[終] */

  /* ↑描画色選択エリア↑ */
  /*=========== 写真編集[終] ==================*/
}

/*===================== 縦画面専用CSS ==============================*/

.toolbox-enter-active,
.toolbox-leave-active {
  will-change: opacity;
  transition: opacity 150ms cubic-bezier(0.4, 0, 0.2, 1) 0ms;
}
.toolbox-enter,
.toolbox-leave-to {
  opacity: 0;
}
</style>
