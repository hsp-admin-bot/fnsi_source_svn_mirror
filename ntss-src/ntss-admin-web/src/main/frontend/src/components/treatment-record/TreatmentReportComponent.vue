/**
 * 治療記録の透析レポートページ
 */
<template>
  <div>
    <!-- add 治療記録改修1 房 start -->
    <div v-if="errMessageText != ''">
      <p style="color: var(--treatment-record-text-color);">{{errMessageText}}</p>
    </div>
    <!-- add 治療記録改修1 房 end -->
    <div class="submenu-container">
      <div class="scroll-table">
        <div class="report-main" id="report-main" :style="heightStyles">
          <!-- mod Aspose.cells plug-in integration - レコード破り，ドラッグ問題の処理 付 start -->
          <!-- <div class="report-trans"
            id="target"
            :style="targetStyle"
            @mousedown="listenerStart"
            @mouseup="listenerEnd"
            @mousemove="listenerMove"
            @touchstart="listenerStart"
            @touchend="listenerEnd"
            @touchmove="listenerMove">
          </div> -->
          <div class="report-trans"
            id="target"
            v-drag
            :style="targetStyle">
          </div>
          <!-- mod Aspose.cells plug-in integration - レコード破り，ドラッグ問題の処理 付 end -->
        </div>
      </div>
      <!-- ズームスライダー -->
      <div class="zoom-slider" v-if="reportHTML">
        <span class="zoom-slider-label" @click="zoomIn()">+</span>
        <v-ons-range
          class="zoom-slider"
          style="display: inline-block; transform: rotateY(180deg);"
          :style="getHeight"
          v-model="sliderVal"
          :max="sliderMax"
          :min="sliderMin"
        ></v-ons-range>
        <span class="zoom-slider-label" @click="zoomOut()">-</span>
      </div>
    </div>

  </div>
</template>

<script>
import { mapGetters, mapActions, mapState } from "vuex";
import {
  sendRequestGetReportInfoByOrdNoWithLoader
} from "@/apis/treatment-record";
import $ from "jquery";
import { EventBus } from "@/eventBus.js";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
//add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
import moment from "moment";
//add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
const TOUCHSTART = "touchstart";
const TOUCHMOVE = "touchmove";
const TOUCHEND = "touchend";

const MOUSEDOWN = "mousedown";
const MOUSEMOVE = "mousemove";
const MOUSEUP = "mouseup";
const MOUSEOUT = "mouseout";

export default {
  // add Aspose.cells plug-in integration - レコード破り，ドラッグ問題の処理 付 start
  directives: {
    drag: {
      bind: function(el) {
        let oDiv = el;
        let userMessage = navigator.userAgent.toLowerCase();
        if (/ipad/i.test(userMessage)) {
          oDiv.addEventListener('touchstart', function(e) {
            let disX = e.changedTouches[0].clientX - oDiv.offsetLeft;
            let disY = e.changedTouches[0].clientY - oDiv.offsetTop;
            document.addEventListener('touchmove', function(e){
              let left = e.changedTouches[0].clientX - disX;
              let top = e.changedTouches[0].clientY - disY;
              oDiv.style.left = left + 'px';
              oDiv.style.top = top + 'px';
            }, false)
            document.addEventListener('touchend', function(e){
              document.ontouchmove = null;
              document.ontouchend = null;
            }, false)
          }, false)
        } else {
          oDiv.onmousedown = (e) => {
            let disX = e.clientX - oDiv.offsetLeft;
            let disY = e.clientY - oDiv.offsetTop;
            document.onmousemove = (e) => {
              let left = e.clientX - disX;
              let top = e.clientY - disY;
              oDiv.style.left = left + 'px';
              oDiv.style.top = top + 'px';

            };
            document.onmouseup = (e) => {
              document.onmousemove = null;
              document.onmouseup = null;
            }
          }
        }
      }
    }
  },
  // add Aspose.cells plug-in integration - レコード破り，ドラッグ問題の処理 付 end
  data() {
    return {
      reportClass: 1,
      reportType: 1,
      dataKey: {
        ordNo: "",
        patId: ""
      },
      reportHTML: "",
      reportAreaHeight: 0,
      reportAreaWidth: 0,
      currentOrdNo: "",
      sliderMax: 300,
      sliderMin: 0,
      minimumScale: 0.1,
      sliderVal: 0,
      notchVal: 0,
      targetTransForm: {
        x: 0,
        y: 0,
        scale: 1.0
      },
      mouseListenerInf: {
        containerElm: null,
        targetElm: null,
        basePoint: {
          x: Number,
          y: Number
        },
        basisTouchID: Number,
        touchListArray: [],
        lastWheelEvent: 0,
        isTouched: false,
        oldDistance: null,
        zoomPos: {
          x: 0,
          y: 0
        }
      },
      target: document.getElementById("target"),
      //自画面の名称
      selfScreenName: "",
      // レポート表示処理中フラグ
      repLoadFlg: false,
      sliderStep: 10,
      // add 治療記録改修1 房 start
      errMessageText:"",
      // add 治療記録改修1 房 start
      treatmentDate:"",
    };
  },
  watch: {
    getOrdNo(_, oldValue) {
      // 帳票を表示する
      //add redmine 6254 yuqizheng start
      this.repLoadFlg = false;
      //add redmine 6254 yuqizheng end
      this.currentOrdNo = this.getOrdNo;
      // レポートレイアウトの状態をストアに保存
      if (oldValue !== null) {
        // 他機能から遷移時(oldValueがnull)は既にストアに値が保存されているため、実績切替時のみストアの値を更新する
        this.updateLayoutState();
      }

      this.showReportHTML(this.currentOrdNo);
    },
    windowWidth() {
      this.calculateReportArea();
    },
    windowHeight() {
      this.calculateReportArea();
    },
    getFontSize() {
      this.calculateReportArea();
    },
    getIsMenuOpen() {
      this.calculateReportAreaIsMenuOpen();
    },
    reportHTML() {
      // レポートをセット
      let target = document.getElementById("target");
      target.innerHTML = this.reportHTML;

      if (target.innerHTML) {
        // レポート1枚目の高さを取得
        /* modify by shiyinwang 2022-11-30 -- Aspose.cells plug-in integration --start */
        let table;
        if($('#target').find('svg').length > 0){
          table = $('#target').find('svg')[0]
        }else {
          const targetDiv = $("#target").children('div')[0];
          table = $("#" + targetDiv.id).children('table')[0];
        }
        /* modify by shiyinwang 2022-11-30 -- Aspose.cells plug-in integration --end */
        const reportHeight = table ? table.clientHeight + 10 : 0;
        // スライダー値の設定
        const submenuHeight = document.getElementsByClassName("submenu-area")[0].clientHeight;
        const fitScale = submenuHeight / reportHeight * 100;

        // this.layoutState.sliderVal === 0 は、サインイン後の初回表示時、パンくず押下時(refresh)
        // this.layoutState.sliderVal !== 0 は、機能遷移後の表示
        // スライダー倍率をセット
        this.sliderMin = fitScale;
        this.sliderVal = this.layoutState.sliderVal === 0 ? fitScale : this.layoutState.sliderVal;
        this.sliderMax = fitScale + 300;
        // 初期表示拡大率の計算
        this.notchVal = (submenuHeight / reportHeight - this.minimumScale) / fitScale;
        // 初期位置の設定
        this.$nextTick(() => {
          $("#target").css({
            "left": "0px",
            "top":  "0px"
          });
        });
      }
    },
    /**
     * スライダー変更時の拡大縮小処理
     */
    targetScale() {
      // Zoom後の表示位置調整
      this.adjustBLayourtAreaPosition();
    }
  },
  computed: {
    ...mapState("treatment-record/common", ["ordNoDataSourcesState", "layoutState"]),
    ...mapGetters("treatment-record/common", ["getOrdNo","getIsMenuOpen"]),
    //mod FNSI-redmine4746 房 start
    ...mapGetters("pat-info", ["selectedPatId", "isNullPat", "srcFuncName", "treatmentPatList"]),
    //mod FNSI-redmine4746 房 end
    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
    ...mapGetters("user", ["getFacilityCd"]),
    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize"
    }),
    heightStyles() {
      // report部の高さをCSS変数を利用して書き換え
      return {
        height: `${this.reportAreaHeight}px`,
      };
    },
    isTouch() {
      return this.mouseListenerInf.touchListArray.length
        ? this.mouseListenerInf.touchListArray.length
        : 0;
    },
    zoomPos() {
      return `zoomPos(${this.mouseListenerInf.zoomPos.x}, ${this.mouseListenerInf.zoomPos.y})`;
    },
    targetStyle() {
      return {
        transform: `translate(${this.targetTransForm.x}px, ${this.targetTransForm.y}px) scale(${this.targetScale})`
      };
    },
    targetScale() {
      return this.minimumScale + this.notchVal * this.sliderVal;
    },
    getHeight(){
      // 縦を計算
      const sah = document.getElementsByClassName("submenu-area")[0]
        .clientHeight;

      return 'width: ' + sah/2 + 'px';
    }
  },
  methods: {
    ...mapActions("report", ["getReportHTMLByReportCd", "setCreateReportParam"]),
    ...mapActions("treatment-record/common", ["setLayoutState"]),
    //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
    requestrReportParams(param) {
      // 機能コード判定
        // 印刷パラメータを応答
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        var curDate = new Date();
        // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        const param1 = {
          patId: this.selectedPatId,
          ordNo: this.getOrdNo,
          facilityCd: this.getFacilityCd,
          functionCd:"00601",
          // mod #9558 機能帳票で正しく変数が引き渡されていない 高 start
          // date: moment(this.treatmentDate).format("YYYY/MM/DD"),
          // fromDate: moment(this.treatmentDate).format("YYYY/MM/DD"),
          // toDate: moment(this.treatmentDate).format("YYYY/MM/DD"),
          // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
          // date: this.treatmentDate == null ? moment(new Date()).format("YYYY/MM/DD") : moment(this.treatmentDate).format("YYYY/MM/DD"),
          date: this.treatmentDate == null ? moment(new Date()).format("YYYY/MM/DD") : moment(this.treatmentDate, "YYYY/MM/DD(EE)").format("YYYY/MM/DD"),
          // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // fromDate: this.treatmentDate == null ? moment(new Date()).format("YYYY/MM/DD") : moment(this.treatmentDate).format("YYYY/MM/DD"),
          // toDate: this.treatmentDate == null ? moment(new Date()).format("YYYY/MM/DD") : moment(this.treatmentDate).format("YYYY/MM/DD"),
          // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
          // treatDate: this.treatmentDate == null ? moment(new Date()).format("YYYYMMDD") : moment(this.treatmentDate).format("YYYYMMDD"),
          treatDate: this.treatmentDate == null ? moment(new Date()).format("YYYYMMDD") : moment(this.treatmentDate, "YYYYMMDD(EE)").format("YYYYMMDD"),
          // mod #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
          fromDate: moment(new Date()).format("YYYYMMDD"),
          toDate: moment(new Date(curDate.setMonth(curDate.getMonth() + 1))).format("YYYYMMDD"),
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #9558 機能帳票で正しく変数が引き渡されていない 高 end
        };
        EventBus.$emit("sendReportParams", param1);
      }
    },
    //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
    showReportHTML(ordNo) {
      // 帳票表示をクリアする
      this.reportHTML = "";
      if (!ordNo || this.repLoadFlg) {
        return;
      }
      const dataSource = this.srcFuncName ? this.treatmentPatList : this.ordNoDataSourcesState;
      const curItem = dataSource?.find((item) => {
        return item.ordNo === ordNo;
      })
      if (curItem?.hasDeleteRecord) {
        this.errMessageText = "指定日のデータはありません";
        return;
      }
      if (curItem?.hasCancelSendCond) {
        this.errMessageText = "治療前、治療中、未確定データはありません。";
        return;
      }
      this.errMessageText = "";
      // 複数のwatch対象から呼び出される処理の為、2重処理にならないようにフラグで管理
      this.repLoadFlg = true;
      // レポート表示
      sendRequestGetReportInfoByOrdNoWithLoader(ordNo).then(res => {
        this.repLoadFlg = false;
        // ベッド・クール・治療方法未登録の場合（実績削除後のデータ）
        if (!res.data && !this.isNullPat) {
          this.errMessageText = "治療前、治療中、未確定データはありません。";
          return;
        }
        // 治療方法が未設定の場合
        if (!res.data.rstTreatmentCd && !this.isNullPat) {
          this.errMessageText = "治療方法が設定されていません。";
          return;
        }
        // 治療方法マスタに透析レポートの帳票コードが未設定
        if (!res.data.reportId) {
          this.errMessageText = "治療方法が未登録、または登録されている治療方法に帳票が設定されていません。";
          return;
        }

        // 治療方法マスタに帳票コードが設定されている場合
        this.dataKey.ordNo = ordNo;
        this.dataKey.patId = this.selectedPatId;
                this.setCreateReportParam({
          reportCd: res.data.reportId,
          reportParam: {
            dataKey: this.dataKey,
            targetPrinter: null,
            excelPath: null,
            pdfPath: null,
          }
        });
        this.getReportHTMLByReportCd(false)
          .then(response => {
            if (this.getOrdNo === response.data.dataKey.ordNo) {
              this.reportHTML = response.data.reportHtml;
            } else {
              this.reportHTML = "";
            }
          this.calculateReportArea();
          EventBus.$emit("showTitleFlag", true)
        }).catch(()=>{
           EventBus.$emit("showTitleFlag", false)
          this.errMessageText = "帳票の出力に失敗しました";
          getErrorMessage('TreatmentReportComponent.vue','showReportHTML','帳票の出力に失敗しました');
        });
      });
    },
    calculateReportArea() {
      // 縦を計算
      const sah = document.getElementsByClassName("submenu-area")[0]
        .clientHeight;
      this.reportAreaHeight = sah;

      // 横を計算
      const saw =
        document.getElementsByClassName("submenu-area")[0].clientWidth - 60;
      this.reportAreaWidth = saw;

      const zoomSlider = document.getElementsByClassName("zoom-slider")[0];
      if (zoomSlider != undefined) {
        zoomSlider.style.width = sah/2+ 'px';
      }
    },

    calculateReportAreaIsMenuOpen() {
      // 横のみを計算
      const saw =
        document.getElementsByClassName("submenu-area")[0].clientWidth - 60;
      this.reportAreaWidth = saw;

      let main = document.getElementById("report-main");
      main.style.width = `calc(100% - ${this.getIsMenuOpen ? "(10em + 70px)" : "70px"} )`;
    },
    listenerStart(event) {
      switch (event.type) {
        case TOUCHSTART:
          for (let i = 0; i < event.changedTouches.length; i++) {
            const touch = {
              x: event.changedTouches[i].pageX,
              y: event.changedTouches[i].pageY,
              identifier: event.changedTouches[i].identifier
            };
            this.mouseListenerInf.touchListArray.push(touch);
          }
          // 初回タッチのとき
          // 開始点の取得
          if (event.changedTouches.length === 1) {
            // タッチ座標を取得し、開始点とする
            this.mouseListenerInf.basePoint.x = event.touches[0].pageX;
            this.mouseListenerInf.basePoint.y = event.touches[0].pageY;

            // 基準点タッチIDを登録
            this.mouseListenerInf.basisTouchID = event.touches[0].identifier;

            // タッチ状態に変更
            this.mouseListenerInf.isTouched = true;
          } else if (event.changedTouches.length > 1) {
            const newP1 = {
              x: event.changedTouches[0].pageX,
              y: event.changedTouches[0].pageY
            };
            const newP2 = {
              x: event.changedTouches[1].pageX,
              y: event.changedTouches[1].pageY
            };
            this.mouseListenerInf.oldDistance = this.getDistance(newP1, newP2);
          }
          this.mouseListenerInf.zoomPos = null;
          break;
        case MOUSEDOWN:
          // 開始点の取得
          this.mouseListenerInf.basePoint.x = event.pageX;
          this.mouseListenerInf.basePoint.y = event.pageY;

          // マウスのボタンが押されている状態に変更
          this.mouseListenerInf.isTouched = true;
          break;
        default:
          break;
      }
    },
    listenerEnd(event) {
      if (this.mouseListenerInf.isTouched) {
        // タッチイベントのとき
        switch (event.type) {
          case TOUCHEND: {
            for (let i = 0; i < event.touches.length; i++) {
              this.mouseListenerInf.touchListArray = this.mouseListenerInf.touchListArray.filter(
                x => x.identifier !== event.changedTouches[i].identifier
              );
            }
            // 他のタッチが存在する場合
            if (event.touches.length > 0) {
              // 基準となるタッチが離れた場合
              if (
                event.changedTouches[0].identifier ===
                this.mouseListenerInf.basisTouchID
              ) {
                // 基準となるタッチの更新
                this.mouseListenerInf.basisTouchID =
                  event.touches[0].identifier;
              }
            } else if (event.touches.length === 0) {
              // タッチ状態を解除
              this.mouseListenerInf.isTouched = false;
            }
            this.mouseListenerInf.oldDistance = 0;
            this.mouseListenerInf.zoomPos = null;
            break;
          }
          case MOUSEUP:
          case MOUSEOUT: {
            // タッチ状態を解除
            this.mouseListenerInf.isTouched = false;
            break;
          }

          default:
            break;
        }
      }
    },
    listenerMove(event) {
      if (this.mouseListenerInf.isTouched) {
        event.preventDefault();
        switch (event.type) {
          case TOUCHMOVE: {
            if (event.touches.length === 1) {
              const p1 = {
                x: event.touches[0].pageX,
                y: event.touches[0].pageY
              };
              this.targetMove(p1);
            } else if (event.touches.length > 1) {
              const newP1 = {
                x: event.touches[0].pageX,
                y: event.touches[0].pageY
              };
              const newP2 = {
                x: event.touches[1].pageX,
                y: event.touches[1].pageY
              };
              const newDistance = this.getDistance(newP1, newP2);
              if (this.mouseListenerInf.oldDistance === 0) {
                this.mouseListenerInf.oldDistance = newDistance;
              }
              // 拡大率
              const scale =
                this.targetScale +
                (newDistance / this.mouseListenerInf.oldDistance - 1);
              if (scale > 0) {
                // ズームする場所(ターゲット要素内座標)
                const zoomPosX = Math.floor((newP1.x + newP2.x) / 2);
                const zoomPosY = Math.floor((newP1.y + newP2.y) / 2);
                const displayArea = document
                  .getElementById("report-main")
                  .getBoundingClientRect();

                if (this.mouseListenerInf.zoomPos === null) {
                  this.mouseListenerInf.zoomPos = {
                    x:
                      (zoomPosX - (displayArea.left + this.targetTransForm.x)) /
                      this.targetScale,
                    y:
                      (zoomPosY - (displayArea.top + this.targetTransForm.y)) /
                      this.targetScale
                  };
                }
                this.targetZoom(
                  scale,
                  {
                    x: this.mouseListenerInf.zoomPos.x,
                    y: this.mouseListenerInf.zoomPos.y
                  },
                  {
                    x: zoomPosX - displayArea.left,
                    y: zoomPosY - displayArea.top
                  }
                );
              }
              this.mouseListenerInf.oldDistance = newDistance;
            }
            break;
          }

          case MOUSEMOVE: {
            if (event.buttons === 0) {
              // タッチ状態を解除
              this.mouseListenerInf.isTouched = false;
            } else {
              const p1 = {
                x: event.pageX,
                y: event.pageY
              };
              this.targetMove(p1);
            }
            break;
          }

          default:
            break;
        }
      }
    },
    /**
     * 拡大率変更
     * @param scale 拡大率
     * @param zoomPos ズームする場所（ターゲット要素内座標）
     * @param targetPos ターゲット要素の座標
     */
    targetZoom(scale, zoomPos, targetPos) {
      const moveScale = scale - this.minimumScale;
      if (moveScale > 0) {
        if (this.sliderMax < Math.ceil(moveScale / this.notchVal)) {
          this.sliderVal = this.sliderMax;
        } else {
          this.sliderVal = Math.ceil(moveScale / this.notchVal);
        }
      } else {
        this.sliderVal = this.sliderMin;
      }
      this.targetTransForm.x = targetPos.x - this.targetScale * zoomPos.x;
      this.targetTransForm.y = targetPos.y - this.targetScale * zoomPos.y;
      this.sliderWatchOff = true;
      // Zoom後の表示位置調整
      this.adjustBLayourtAreaPosition();
    },
    /**
     * ターゲット要素を動かす。
     * @param newMousePos マウス位置
     */
    targetMove(newMousePos) {
      const newPos = {
        x:
          this.targetTransForm.x +
          (newMousePos.x - this.mouseListenerInf.basePoint.x),
        y:
          this.targetTransForm.y +
          (newMousePos.y - this.mouseListenerInf.basePoint.y)
      };
      // X軸方向への動き
      const canvasWidth =
        document.getElementById("target").clientWidth * this.targetScale;
      const displayArea = document
        .getElementById("report-main")
        .getBoundingClientRect();
      this.targetTransForm.x = this.getTransform(
        canvasWidth,
        displayArea.width,
        newPos.x,
        this.targetTransForm.x
      );
      this.mouseListenerInf.basePoint.x = newMousePos.x;

      // y軸方向への動き
      const canvasHeight =
        document.getElementById("target").clientHeight * this.targetScale;
      this.targetTransForm.y = this.getTransform(
        canvasHeight,
        displayArea.height,
        newPos.y,
        this.targetTransForm.y
      );
      this.mouseListenerInf.basePoint.y = newMousePos.y;
    },
    getTransform(canvasLength, displayAreaLength, newPosition, oldPosition) {
      const moveArea = displayAreaLength / 2;

      //  表示開始位置判定
      if( moveArea < newPosition ) {
        return oldPosition;
      }
      //  最終端位置判定
      if(( newPosition + canvasLength ) < moveArea ) {
        return oldPosition;
      }

      return newPosition;
    },
    /**
     * 線の衝突判定
     */
    isLineInner(line1, line2) {
      const dist = Math.abs(
        line1.pos * 2 + line1.length - (line2.pos * 2 + line2.length)
      );
      const sumLen = line1.length + line2.length;
      return dist < sumLen;
    },
    /**
     * 一点の範囲内判定
     */
    isRectInner(point, x1, x2, y1, y2) {
      return point.x >= x1 && point.x <= x2 && point.y >= y1 && point.y <= y2;
    },

    /**
     * 二点間距離の計算
     */
    getDistance(p1, p2) {
      return Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2);
    },
    /**
     * 指定したidentifierのタッチ開始時の座標を返す
     */
    getInitialXYById(touchId) {
      const bufArray = this.mouseListenerInf.touchListArray.filter(
        x => x.identifier === touchId
      );
      const rtn = {
        x: bufArray[0].x,
        y: bufArray[0].y
      };
      return rtn;
    },
    startPolling() {
      this.timerId = setInterval(this.reFetchTreatmentStatus, 60000);
    },
    endPolling() {
      clearInterval(this.timerId);
    },
    // ベッドレイアウト表示位置調整
    adjustBLayourtAreaPosition() {
      if (this.targetTransForm.x === 0 || this.targetTransForm.y === 0) return;
      const displayArea = document.getElementById("report-main").getBoundingClientRect();
      const targetArea = document.getElementById("target").getBoundingClientRect();
      if (!displayArea || !targetArea ) return;
      const areaX = displayArea.width / 2;
      const areaY = displayArea.height / 2;

      // 表示位置調整
      let posX = this.targetTransForm.x;
      let posY = this.targetTransForm.y;
      const posX2 = posX + targetArea.width;
      const posY2 = posY + targetArea.height;
      if( areaX < posX ) {
        posX = areaX;
      }
      if( areaY < posY ) {
        posY = areaY;
      }
      if( posX2 < areaX ) {
        posX += areaX - posX2;
      }
      if( posY2 < areaY ) {
        posY += areaY - posY2;
      }

      this.targetTransForm.x = posX;
      this.targetTransForm.y = posY;
    },
    /**
     * 再描画処理
     */
    refresh() {
      //add 治療記録改修1 房 start
      this.errMessageText = "";
      //add 治療記録改修1 房 end
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      // レポートレイアウトの状態をクリア
      this.updateLayoutState(true);

      this.showReportHTML(this.getOrdNo);
    },
    zoomIn() {
      if (+this.sliderVal === this.sliderMax) {
        return;
      }
      this.sliderVal = +this.sliderVal >= (this.sliderMax - this.sliderStep) ? this.sliderMax : +this.sliderVal + this.sliderStep;
    },
    zoomOut() {
      if (+this.sliderVal === this.sliderMin) {
        return;
      }
      this.sliderVal = +this.sliderVal <= (this.sliderMin + this.sliderStep) ? this.sliderMin : +this.sliderVal - this.sliderStep;
    },
    //add FSNI修正外結バッグ35 房 start
    setMessage(message){
      this.errMessageText = message;
    },
    //add FSNI修正外結バッグ35 房 end
    setTreatmentDate(date){
      this.treatmentDate = date;
    },
    /**
     * レポートレイアウトの状態をストアに保存
     * @param isClear 値クリアフラグ
     */
    updateLayoutState(isClear) {
      this.setLayoutState({
        sliderVal: isClear ? 0 :  this.sliderVal
      });
    }
  },
  mounted() {
    // オーダー番号の設定状況により再表示させる
    this.showReportHTML(this.getOrdNo);
    //add FNSI-redmine5655 fang start
    this.calculateReportAreaIsMenuOpen();
    //add FNSI-redmine5655 fang end
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;

    // イベント解除
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("savePatInfoSuccess", this.refresh);
    //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
    // del 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    // EventBus.$on("requestReportParams", this.requestrReportParams);
    // del 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
  },
  /**
   * コンポーネント破棄
   */
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    EventBus.$off("refresh", this.refresh);
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    EventBus.$off("savePatInfoSuccess");
    //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    // del 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    // EventBus.$off("requestReportParams", this.requestrReportParams);
    // del 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end
    // レポートレイアウトの状態をストアに退避
    this.updateLayoutState();

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
.submenu-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}
.report-main {
  background-color: #fafafa;
  /* #10011 治療記録画面での複数ページの透析レポート表示について linjunfeng start */
  /* overflow: hidden; */
  overflow: auto;
  /* #10011 治療記録画面での複数ページの透析レポート表示について linjunfeng end */
  position: absolute;
  width: calc(100% - 13.5em);
  padding: 0px 30px;
}
div.zoom-slider {
  position: absolute;
  bottom: -1em;
  /* #10011 治療記録画面での複数ページの透析レポート表示について linjunfeng start */
  /* right: 0.1em; */
  right: 1em;
  /* #10011 治療記録画面での複数ページの透析レポート表示について linjunfeng end */
  background-color: #e4d8d8;
  display: flex;
  align-items: center;
  font-size: 3em;
  transform: rotate(90deg);
  transform-origin: right top;
  padding: 0em 0.3em 0em 0.3em;
  opacity: 0.2;
}
.zoom-slider:active {
  opacity: 1;
}
#target {
  position: absolute;
  /* #10011 治療記録画面での複数ページの透析レポート表示について linjunfeng start */
  /* display: flex;
  flex-wrap: wrap; */
  /* #10011 治療記録画面での複数ページの透析レポート表示について linjunfeng end */
  transform-origin: left top 0;
}
span.zoom-slider-label {
  transform: rotate(-90deg);
}
@media print {
  .report-main {
    width: 100% !important;
  }
  #target {
    transform: none !important;
    position: relative !important;
    left: 0px !important;
    top: 0px !important;
  }
  #target >>> div {
    width: fit-content;
  }
}
</style>
