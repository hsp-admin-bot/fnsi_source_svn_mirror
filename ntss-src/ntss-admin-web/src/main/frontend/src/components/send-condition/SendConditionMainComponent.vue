/** * 条件送信画面 */
<template>
  <div
    class="send-condition-main-content-area ntss-send-condition-content-area"
    :style="mainAreaStyles"
  >
    <!-- 体重/車いす切替ボタン -->
    <div
      class="send-condition-head-segment"
      v-show="getIsInitialized && !getIsScale && !getIsFromScaleBed"
      :style="{ 'background-color': formColor }"
    >
      <!-- 通常モード 体重/車いす切替ボタン -->
      <div>
        <v-ons-segment
          ref="segment"
          id="segment"
          class="send-condition-scale-mode-segment"
          :index.sync="scaleMode"
        >
          <button
            @click="onSegmentClick(0)"
            v-show="getPatScaleMode > 0"
            :disabled="getIsTreating"
          >
            体重
          </button>
          <button
            @click="onSegmentClick(1)"
            v-show="getPatScaleMode > 0"
            :disabled="getIsTreating"
          >
            体重＋車いす
          </button>
          <button @click="onSegmentClick(2)" v-show="getPatScaleMode > 1">
            車いす
          </button>
        </v-ons-segment>
      </div>
    </div>

    <!-- 中核コンテンツ部：スマホではこの中の要素が縮小表示 -->
    <div
      class="send-condition-core-content-parent"
      id="area-main"
      :style="coreParentAreaStyles"
    >
      <div
        class="send-condition-core-content"
        id="target"
        :style="targetStyle"
        @touchstart="listenerStart"
        @touchend="listenerEnd"
        @touchmove="listenerMove"
      >
        <!-- ヘッダー部 -->
        <div class="send-condition-head-content" v-show="getIsInitialized">
          <!-- 共通化：通常モード ヘッダーボタン -->
          <div id="send-condition-head-button-area" class="wrap-block">
            <div id="send-condition-scale-class-icon">
              <label>{{ getChangeBeforeAfterBtnLbl }}</label>
            </div>
            <!-- 通常モード/体重計モード スケジュールボタン -->
            <div
              id="send-condition-control-1"
              :class="[
                getIsWheelChairForAfterWeightMode
                  ? 'send-condition-control-wheel-chair'
                  : '',
              ]"
              v-show="getPatScaleMode > 0"
              :style="scheduleBtnStyle"
            >
              <!-- スケジュール -->
              <div
                id="send-condition-schedule-btn-1"
                v-show="getPatScaleMode > 0"
              >
                <v-ons-button
                  class="send-condition-schedule-button btn3-normal"
                  @click="showScheduleModal(0)"
                  :disabled="getIsTreating || isDisable"
                  ><span class="weight-mode-mst-weight-button-text">{{
                    getScheduleLabel(0)
                  }}</span></v-ons-button
                >
              </div>
              <!-- スケジュール2 -->
              <div
                id="send-condition-schedule-btn-2"
                v-show="getPatScaleMode > 0 && getScheduleLabel(1) !== null"
              >
                <v-ons-button
                  class="send-condition-schedule-button btn3-normal"
                  @click="showScheduleModal(1)"
                  :disabled="getIsTreating || isDisable"
                  ><span class="weight-mode-mst-weight-button-text">{{
                    getScheduleLabel(1)
                  }}</span></v-ons-button
                >
              </div>
            </div>
            <!-- 通常モード/体重計モード 履歴ボタン・簡易詳細切り替えボタン -->
            <div id="send-condition-control-2" v-show="getPatScaleMode > 0">
              <!-- 体重測定履歴呼び出しボタン -->
              <v-ons-button
                class="send-condition-command-button btn3-normal"
                @click="showMeasureModal"
                >履歴</v-ons-button
              >

              <!-- 簡易・詳細切り替えボタン -->
              <v-ons-button
                class="send-condition-command-button btn3-normal"
                @click="switchViewMode(), resetTargetTransform()"
                v-show="!getIsWheelChairForAfterWeightMode"
                >{{ getChangeViewBtnMsg }}</v-ons-button
              >
            </div>
          </div>

          <!-- 拡縮表示 -->
          <div class="wrap-block" style="pointer-events: auto">
            <img
              :src="image_src_normal_screen"
              @click="hideItemPopover(), showZoomPopover($event)"
              width="45px"
              height="45px"
              style="margin-top: 0.3em; z-index: 4"
            />
          </div>
        </div>

        <!-- 共通化：通常モード メイン領域 -->
        <div
          class="send-condition-main-content"
          v-show="getIsInitialized"
          style="display: flex"
        >
          <!-- ストリーミングモード 簡易画面用 -->
          <div
            v-if="
              deviceFlg &&
              (getIsWheelChairForAfterWeightMode || getIsSimpleMode)
            "
            class="deviceCls deviceClsSimple"
            style="
              width: 15em;
              --topmrgn: calc(12em - 10px);
              margin-top: var(--topmrgn);
              margin-left: auto;
            "
          >
            <div class="multi-select-list-label">
              <label class="deviceClslabel">測定値リスト</label>
            </div>
            <div class="multi-select-list">
              <label
                v-for="(item, index) in itemList"
                @click.exact="checkMultiItem(index)"
                ref="label"
                class="item-label"
                :class="computeClassItemLabel(item)"
                :key="index"
              >
                <span class="item-name"
                  >{{ Number(item.name).toFixed(2) }} kg</span
                >
              </label>
            </div>
          </div>

          <!-- 簡易画面or詳細画面 -->
          <div v-show="true" :style="mainContentMargin">
            <div
              v-show="getIsWheelChairForAfterWeightMode || getIsSimpleMode"
              class="simple-test"
            >
              <!-- 簡易画面 -->
              <send-condition-simple-main-item
                :style="mainHeightStyles"
                :treating="getIsWheelChairForAfterWeightMode"
              />
            </div>
            <div
              v-show="!getIsWheelChairForAfterWeightMode && !getIsSimpleMode"
              class="detail-test"
            >
              <!-- 詳細画面 -->
              <div v-if="getIsAfterWeight" class="detail-main-parent">
                <send-condition-after-detail-main-item
                  :style="mainHeightStyles"
                />
                <!-- ストリーミングモード 後体重詳細画面用 -->
                <div
                  v-if="deviceFlg"
                  class="deviceCls send-condition-after-measure-list"
                >
                  <div class="multi-select-list-detail-label">
                    <label class="deviceClslabelDetail">測定値リスト</label>
                  </div>
                  <div class="multi-select-list-detail">
                    <label
                      v-for="(item, index) in itemList"
                      @click.exact="checkMultiItem(index)"
                      ref="label"
                      class="item-label-detail"
                      :class="computeClassItemLabel(item)"
                      :key="index"
                    >
                      <span class="item-name"
                        >{{ Number(item.name).toFixed(2) }} kg</span
                      >
                    </label>
                  </div>
                </div>
              </div>
              <div v-else class="detail-main-parent">
                <send-condition-before-detail-main-item
                  :style="mainHeightStyles"
                  @click-show-treat-cond="showTreatCondModal"
                />
                <!-- ストリーミングモード 前体重詳細画面用 -->
                <div
                  v-if="deviceFlg"
                  class="deviceCls send-condition-before-measure-list"
                >
                  <div class="multi-select-list-detail-label">
                    <label class="deviceClslabelDetail">測定値リスト</label>
                  </div>
                  <div class="multi-select-list-detail">
                    <label
                      v-for="(item, index) in itemList"
                      @click.exact="checkMultiItem(index)"
                      ref="label"
                      class="item-label-detail"
                      :class="computeClassItemLabel(item)"
                      :key="index"
                    >
                      <span class="item-name"
                        >{{ Number(item.name).toFixed(2) }} kg</span
                      >
                    </label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- エラーメッセージ表示領域 -->
    <transition
      name="slide"
      v-show="getIsInitialized"
      v-on:after-leave="calculateContentHeight"
      v-on:after-enter="calculateContentHeight"
    >
      <!-- mod FNSI-体重計画面 徐 start -->
      <!-- <div class="send-condition-message-content" v-show="getIsShowMessage && isShowMessageArea"> -->
      <div
        class="send-condition-message-content"
        v-show="getIsShowMessage && isShowMessageArea"
      >
        <!-- mod FNSI-体重計画面 徐 end -->
        <send-condition-message-item />
      </div>
    </transition>
    <transition
      name="slide"
      v-show="isPurificationWarnMsgFlg"
      v-on:after-leave="calculateContentHeight"
      v-on:after-enter="calculateContentHeight"
    >
      <div class="send-condition-message-content" v-show="isPurificationWarnMsgFlg">
        <send-condition-purificationwarn_message-item />
      </div>
    </transition>

    <!-- ボタン表示領域 -->
    <div
      class="send-condition-footer-content flex-container"
      v-show="getIsInitialized"
      :style="{ 'background-color': formColor }"
    >
      <div class="denial-btn-area" style="background: none">
        <v-ons-button
          class="btn2-cancel denial-btn"
          @click="cancel"
          style="width: 7em; height: 2em"
          :style="footerBtnFontSizeStyle"
          >キャンセル</v-ons-button
        >
      </div>
      <div v-show="getIsShowMessage">
        <button
          class="send-condition-toggle-message"
          @click="toggleShowMessage"
          v-show="!isShowMessageArea"
        >
          <img width="40px" src="img/weight/up.png" />
        </button>
        <button
          class="send-condition-toggle-message"
          @click="toggleShowMessage"
          v-show="isShowMessageArea"
        >
          <img width="40px" src="img/weight/down.png" />
        </button>
      </div>
      <div
        class="registration-btn-area send-condition-btn-area"
        style="background: none"
      >
        <div class="send-condition-print-box" v-if="isSelectedWeightNo">
          <v-ons-checkbox v-model="isPrint" :input-id="'print-check'" />
          <label class="center ntss-send-condition-text" for="print-check"
            >印刷</label
          >
        </div>
        <v-ons-button
          class="btn1-execute registration-btn"
          @click="sendWeight"
          :disabled="disableSendBtn || disableSendBtnFlg"
          style="width: 5em; height: 2em"
          :style="footerBtnFontSizeStyle"
          >{{ getChangeViewSendBtnMsg }}</v-ons-button
        >
      </div>
    </div>

    <!-- 日時表示領域 -->
    <div
      class="send-condtition-time-content"
      :style="{ 'background-color': formColor }"
    >
      <span style="margin-left: 1em">{{ weightName }}</span>
      <span style="margin-left: 1em">{{ ymdTime }}</span>
    </div>

    <!-- アラートダイアログ類 -->
    <!-- add FNSI-分類不一致判断の追加 徐 start -->
    <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start -->
    <!-- <div v-if="buttonConfig === 0"> -->
    <div v-if="buttonConfig === '0'">
      <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'治療条件分類エラー'" :footer="{
        OK: () => diaView = false
      }" :visible="diaView" :style="height='100px'"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="diaView"
        :style="(height = '100px')"
      >
        <span slot="title">治療条件分類エラー</span>
        <template slot="footer">
          <v-ons-alert-dialog-button @click="diaView = false"
            >OK</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <v-ons-row style="height: 10%">
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              治療条件に不適切な分類の薬剤、医療材料が指定されています。
              <br />
              マスタの見直しまたは治療条件の変更をしてください。
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-row>
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-for="(radioItem, index) in recordList"
          :key="index"
          style="height: 10%"
        >
          <v-ons-col
            class="align-items-left"
            style="height: 10%; text-align: left"
          >
            <label>
              {{ radioItem }}
            </label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="align-items-left">
            <br />
          </v-ons-col>
        </v-ons-row>
      </v-ons-alert-dialog>
    </div>
    <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start -->
    <!-- <div v-if="buttonConfig === 1"> -->
    <div v-if="buttonConfig === '1'">
      <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end -->
      <!-- mod FNSI-4723 治療条件分類エラーのメッセージ不正 liumx start -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'治療条件分類エラー'" :footer="{
        キャンセル: () => diaView = false,
        OK: () => callSendConditionOK(1)
      }" :visible="diaView" :style="height='100px'"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="diaView"
        :style="(height = '100px')"
      >
        <span slot="title">治療条件分類エラー</span>
        <template slot="footer">
          <v-ons-alert-dialog-button @click="diaView = false"
            >キャンセル</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="callSendConditionOK(1)"
            >OK</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <!-- mod FNSI-4723 治療条件分類エラーのメッセージ不正 liumx end -->
        <v-ons-row style="height: 10%">
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              治療条件に不適切な分類の薬剤、医療材料が指定されています。
              <br />
              このまま条件送信しますか？
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-row>
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-for="(radioItem, index) in recordList"
          :key="index"
          style="height: 10%"
        >
          <v-ons-col
            class="align-items-left"
            style="height: 10%; text-align: left"
          >
            <label>
              {{ radioItem }}
            </label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="align-items-left">
            <br />
          </v-ons-col>
        </v-ons-row>
      </v-ons-alert-dialog>
    </div>
    <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start -->
    <!-- <div v-if="mstOverdueConfig === 0"> -->
    <div v-if="mstOverdueConfig === '0'">
      <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'マスタ期限切れエラー'" :footer="{
        OK: () => mstOverdueDiaView = false
      }" :visible="mstOverdueDiaView" :style="height='100px'">    <span slot="title">治療条件分類エラー</span>
          <template slot="footer"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="mstOverdueDiaView"
        :style="(height = '100px')"
      >
        <span slot="title">マスタ期限切れエラー</span>
        <template slot="footer">
          <v-ons-alert-dialog-button @click="mstOverdueDiaView = false"
            >OK</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <v-ons-row style="height: 10%">
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              治療予定にマスタ期限切れた薬剤、医療材料が指定されています。
              <br />
              マスタの見直しまたは治療予定の変更をしてください。
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-row>
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-for="(radioItem, index) in mstOverdueMsgList"
          :key="index"
          style="height: 10%"
        >
          <v-ons-col
            class="align-items-left"
            style="height: 10%; text-align: left"
          >
            <label>
              {{ radioItem }}
            </label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="align-items-left">
            <br />
          </v-ons-col>
        </v-ons-row>
      </v-ons-alert-dialog>
    </div>
    <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start -->
    <!-- <div v-if="mstOverdueConfig === 1"> -->
    <div v-if="mstOverdueConfig === '1'">
      <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end -->
      <!-- mod FNSI-4723 治療条件分類エラーのメッセージ不正 liumx start -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'マスタ期限切れエラー'" :footer="{
        キャンセル: () => mstOverdueDiaView = false,
        OK: () => callSendConditionOK(3)
      }" :visible="mstOverdueDiaView" :style="height='100px'"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="mstOverdueDiaView"
        :style="(height = '100px')"
      >
        <span slot="title">マスタ期限切れエラー</span>
        <template slot="footer">
          <v-ons-alert-dialog-button @click="mstOverdueDiaView = false"
            >キャンセル</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="callSendConditionOK(3)"
            >OK</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <!-- mod FNSI-4723 治療条件分類エラーのメッセージ不正 liumx end -->
        <v-ons-row style="height: 10%">
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              治療予定にマスタ期限切れた薬剤、医療材料が指定されています。
              <br />
              このまま条件送信しますか？
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-row>
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-for="(radioItem, index) in mstOverdueMsgList"
          :key="index"
          style="height: 10%"
        >
          <v-ons-col
            class="align-items-left"
            style="height: 10%; text-align: left"
          >
            <label>
              {{ radioItem }}
            </label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="align-items-left">
            <br />
          </v-ons-col>
        </v-ons-row>
      </v-ons-alert-dialog>
    </div>
    <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start -->
    <!-- <div v-if="mstDelConfig === 0"> -->
    <div v-if="mstDelConfig === '0'">
      <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'マスタ削除エラー'" :footer="{
        OK: () => mstDelDiaView = false
      }" :visible="mstDelDiaView" :style="height='100px'"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="mstDelDiaView"
        :style="(height = '100px')"
      >
        <span slot="title">マスタ削除エラー</span>
        <template slot="footer">
          <v-ons-alert-dialog-button @click="mstDelDiaView = false"
            >OK</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <v-ons-row style="height: 10%">
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              治療予定にマスタ削除済みの薬剤、医療材料が指定されています。
              <br />
              マスタの見直しまたは治療予定の変更をしてください。
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-row>
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-for="(radioItem, index) in mstDelMsgList"
          :key="index"
          style="height: 10%"
        >
          <v-ons-col
            class="align-items-left"
            style="height: 10%; text-align: left"
          >
            <label>
              {{ radioItem }}
            </label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="align-items-left">
            <br />
          </v-ons-col>
        </v-ons-row>
      </v-ons-alert-dialog>
    </div>
    <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start -->
    <!-- <div v-if="mstDelConfig === 1"> -->
    <div v-if="mstDelConfig === '1'">
      <!-- mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end -->
      <!-- mod FNSI-4723 治療条件分類エラーのメッセージ不正 liumx start -->
      <!--mod redmine#7185 centOS7サポート切れ zkq start -->
      <!-- <v-ons-alert-dialog modifier="rowfooter" :title="'マスタ削除エラー'" :footer="{
        キャンセル: () => mstDelDiaView = false,
        OK: () => callSendConditionOK(2)
      }" :visible="mstDelDiaView" :style="height='100px'"> -->
      <v-ons-alert-dialog
        modifier="rowfooter"
        :visible="mstDelDiaView"
        :style="(height = '100px')"
      >
        <span slot="title">マスタ削除エラー</span>
        <template slot="footer">
          <v-ons-alert-dialog-button @click="mstDelDiaView = false"
            >キャンセル</v-ons-alert-dialog-button
          >
          <v-ons-alert-dialog-button @click="callSendConditionOK(2)"
            >OK</v-ons-alert-dialog-button
          >
        </template>
        <!--mod redmine#7185 centOS7サポート切れ zkq end -->
        <!-- mod FNSI-4723 治療条件分類エラーのメッセージ不正 liumx end -->
        <v-ons-row style="height: 10%">
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <div>
          <v-ons-row>
            <v-ons-col class="align-items-left" style="text-align: left">
              治療予定にマスタ削除済みの薬剤、医療材料が指定されています。
              <br />
              このまま条件送信しますか？
            </v-ons-col>
          </v-ons-row>
        </div>
        <v-ons-row>
          <v-ons-col class="align-items-left" style="height: 20px">
            <br />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row
          v-for="(radioItem, index) in mstDelMsgList"
          :key="index"
          style="height: 10%"
        >
          <v-ons-col
            class="align-items-left"
            style="height: 10%; text-align: left"
          >
            <label>
              {{ radioItem }}
            </label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row>
          <v-ons-col class="align-items-left">
            <br />
          </v-ons-col>
        </v-ons-row>
      </v-ons-alert-dialog>
    </div>
    <!-- add FNSI-分類不一致判断の追加 徐 end -->

    <v-ons-popover
      cancelable
      class="zoom-popover"
      :visible.sync="zoomPopoverVisible"
      :target="zoomPopoverTarget"
      :direction="zoomPopoverDirection"
    >
      <div
        style="
          display: flex;
          justify-content: center;
          margin-top: 5px;
          margin-bottom: 5px;
        "
      >
        <span class="zoom-slider-label" @click="zoomOut()">-</span>
        <v-ons-range
          v-model="sliderVal"
          :max="sliderMax"
          :min="sliderMin"
          :step="(sliderMax - sliderMin) / 10"
          style="width: 15em"
        >
        </v-ons-range>
        <span class="zoom-slider-label" @click="zoomIn()">+</span>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
// add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou start
import { ApiHelper } from "@/apis/AxiosHelper";
// add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou end
import { mapGetters, mapActions, mapMutations } from "vuex";
import SendConditionSimpleMainItem from "@/components/send-condition/SendConditionSimpleMainComponent";
import SendConditionBeforeDetailMainItem from "@/components/send-condition/SendConditionBeforeDetailMainComponent";
import SendConditionAfterDetailMainItem from "@/components/send-condition/SendConditionAfterDetailMainComponent";
import SendConditionMessageItem from "@/components/send-condition/SendConditionMessage";
//add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
import SendConditionPurificationWarnMessageItem from "@/components/send-condition/SendConditionPurificationWarnMessage";
//add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
import SendConditionTreatingAfterWheelChairItem from "@/components/send-condition/SendConditionTreatingAfterWheelChairComponent";
import { LOCAL_STORAGE_KEY } from "@/constants/localStorageConstants";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import SendConditionMixin from "@/components/send-condition/SendConditionMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import {
  weightScaleClass,
  weightScaleMode,
  deviceModeConstant,
  dialysisState,
  machineSendable,
} from "@/constants/weightDefine";

import { deepCopy } from "@/functions/common/CommonFunctions";
import { EventBus } from "@/eventBus.js";
import moment from "moment";
import { createJournal } from "@/apis/journal";
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭博尹 start
import { WEIGHMODE_SCHEDULE_SETTING } from "@/constants/facilitySetting";
// add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭博尹 end
// add FNSI-分類不一致判断の追加 徐 start
import {
  CHK_INDCONDINFO_FLG,
  CHK_MSGDEL_FLG,
  CHK_MSGOVERDUE_FLG,
} from "@/constants/facilitySetting";
// mod FNSI-5622 バッチ操作インターフェイスを追加します 查 start
// import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue} from "@/apis/facility-setting";
import { sendRequestGetMstFacilitySettingValueMap as getMstFacilitySettingValueMap } from "@/apis/facility-setting";
// mod FNSI-5622 バッチ操作インターフェイスを追加します 查 end
// add FNSI-分類不一致判断の追加 徐 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
import MODAL_TITLE from "@/components/common/ModalTitleContrast.js";
const FLG_TRUE = "1",
  FLG_FALSE = "0";

const TOUCHSTART = "touchstart";
const TOUCHMOVE = "touchmove";
const TOUCHEND = "touchend";

const MOUSEDOWN = "mousedown";
const MOUSEMOVE = "mousemove";
const MOUSEUP = "mouseup";
const MOUSEOUT = "mouseout";

export default {
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null,
  },
  mixins: [NextTransitionMixin, SendConditionMixin, PatHeaderControlMixin],
  components: {
    /**
     * 体重測定子画面
     */
    "send-condition-simple-main-item": SendConditionSimpleMainItem,
    "send-condition-before-detail-main-item": SendConditionBeforeDetailMainItem,
    "send-condition-after-detail-main-item": SendConditionAfterDetailMainItem,
    "send-condition-message-item": SendConditionMessageItem,
    "send-condition-purificationwarn_message-item": SendConditionPurificationWarnMessageItem,
    "send-condition-treating-after-wheel-chair-item":
      SendConditionTreatingAfterWheelChairItem,
  },
  // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
  async beforeRouteLeave(to, from, next) {
    if (to.name != "signin" && !this.isClicking && this.isChanged) {
      await this.$ons.notification.confirm({
        title: DIALOG_MESSAGES[13000004].title,
        message: messageFormat(DIALOG_MESSAGES[13000004].message),
        callback: (answer) => {
          if (answer === 1) {
            next();
          } else {
            next(false);
          }
        },
      });
    } else {
      next();
    }
  },
  // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
  data() {
    return {
      mainContentHeight: 500,
      scaleContentHeight: 300,
      coreParentHeight: 300,
      scheduleBtnMaxWidth: 600,
      previousWeightSourceClass: null,
      isClicking: false,
      autoSendTimer: null,
      isShowing: false,
      isShowMessageArea: true,
      treatingViewMode: 0,
      // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
      isDisable: false,
      // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 end

      // add FNSI-田中衡機の追加 徐 start
      itemList: [],
      itemListSort: [],
      newItemList: [],
      deviceFlg: false,
      isClick: false,
      // add FNSI-田中衡機の追加 徐 end
      // add FNSI-分類不一致判断の追加 徐 start
      recordList: [],
      diaView: false,
      // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
      // buttonConfig: 0,
      buttonConfig: "0",
      // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
      disableSendBtnFlg: false,
      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
      // //add by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --start /
      // disableSendBtnResqFlg: false,
      // //add by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --end /
      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      deviceModeUnknownFlg: false,
      isPurificationWarnMsgFlg: false,
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
      mstDelMsgList: [],
      mstDelDiaView: false,
      // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
      // mstDelConfig: 0,
      mstDelConfig: "0",
      // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
      mstOverdueMsgList: [],
      mstOverdueDiaView: false,
      // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
      // mstOverdueConfig: 0,
      mstOverdueConfig: "0",
      // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
      // add FNSI-分類不一致判断の追加 徐 end
      // add FNSI-体重計画面 徐 start
      breadMode: true,
      weightNo: "",
      weightName: "",
      ymdTime: "",
      ymdUpdateProc: null,
      isShowMultiple: false,
      // add FNSI-体重計画面 徐 end
      // add FNSI-外部連携APIの修正 徐 start
      sendConditionFlg: false,
      sendConditionAfterFlg: false,
      // add FNSI-外部連携APIの修正 徐 end
      sliderMax: 100,
      sliderMin: 0,
      sliderStep: 10,
      minimumScale: 0.3,
      sliderVal: 50,
      notchVal: 0.014,
      targetTransForm: {
        x: 0,
        y: 0,
        scale: 1.0,
      },
      mouseListenerInf: {
        containerElm: null,
        targetElm: null,
        basePoint: {
          x: Number,
          y: Number,
        },
        basisTouchID: Number,
        touchListArray: [],
        lastWheelEvent: 0,
        isTouched: false,
        oldDistance: null,
        zoomPos: {
          x: 0,
          y: 0,
        },
      },
      isMobile: false,
      zoomPopoverVisible: false,
      zoomPopoverTarget: null,
      zoomPopoverDirection: "down",
      image_src_normal_screen: require("../../assets/status-map-normal-screen.png"),
      selfScreenName: "",
      // 編集後クリックキャンセ,未提示破棄popup画面
      initWeightValue: 0,
      // add 10553 連携イベント発生部分不正 関 start
      inOutFlag: false,
      // add 10553 連携イベント発生部分不正 関 end
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("pat-info", ["selectedPat"]),
    ...mapGetters("send-condition/scale", [
      "getIsInitialized",
      "getScaleMode",
      "getInputPatId",
      "getPatId",
      "getSelectedOrdNo",
      "getTreatmentMode",
      "getIsPrint",
      "getIsSimpleMode",
      "getScaleClass",
      "getIsShowMessage",
      "getMessageSwitch",
      "getKurInfo",
      "getBedInfo",
      "getMeasuredValue",
      "getIsMeasuring",
      "getBodyWeightValue",
      "getBodyWeightInfo",
      "getOffWaterChangeFlg",
      "getSelectWheelchair",
      "getIsHasOrdWeightScale",
      "getTreatDate",
      "getIndTreatStartTime",
      "getOrderIndCondInfo",
      "getIsCurrentDialysisStateEqualDialysisState",
      "getMachineState",
      "getMachineStateError",
      "getPatDeviceSetWarnInfo",
      "getIndDryWeight",
      "getIndTargetWeight",
      "getLastScaleValue",
      "getLastWheelChairCd",
      "getLastWheelChairValue",
      "getLastScaleMode",
      "getSelectWheelchairWeight",
      "getIsUsePatWheelChair",
    ]),
    ...mapGetters("send-condition/scale/setting", [
      "getWeightConfigInfo",
      "getWeightScaleConfigInfo",
      "getWeightAudioSetting",
      "getWeightCheckSetting",
      "getWeightColorSetting",
      "getWeightPrintSetting",
      "getWheelChairList",
    ]),
    ...mapGetters("send-condition/scale/message", [
      "getCheckMessageHasError",
      "getCheckMessageHasWarn",
      "getCheckDoubleSettingByMv",
      "getCheckDoubleSettingByWc",
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      "getPurificationWarnmessageList",
      "getPurificationWarnmessageHasError",
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    ]),
    ...mapGetters("send-condition/weight", [
      "getSelectedMstWeight",
      "getWeightMode",
      "getSelectedWeightNo",
    ]),
    ...mapGetters("user", {
      facilityCd: "getFacilityCd",
      // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
      getUserAuthorityCds: "getUserAuthorityCds",
      // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 end
    }),
    ...mapGetters("pat-viewer-modal", [
      "getDefaultSettingIndConditionData",
      "getDefaultSettingIndPlanCreateNewData",
      "getDefaultSettingIndScheduleData",
      "getIsShowIndModal",
      "getSettingIndData",
    ]),
    // #11987 2026.02.10 add スケールベッドからの呼び出しに対応 TDC片口 start
    ...mapGetters("scale-bed/send-cond", ["getIsFromScaleBed", "getScaleBedValue"]),
    // #11987 2026.02.10 add スケールベッドからの呼び出しに対応 TDC片口 end
    // add FNSI-体重計画面 徐 start
    ...mapGetters("app", ["getQueryParameters"]),
    // add FNSI-体重計画面 徐 end
    // mod FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
    //...mapGetters("account-edit", ["getUserId"]),
    ...mapGetters("account-edit", ["getUserId", "isDispMenu"]),
    // mod FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
    // add FNSI-体重計画面 徐 start
    getButName: {
      get() {
        var name = this.getScheduleLabel(0);
        if (name.length > 18) {
          return name.substring(0, 18) + "...";
        } else {
          return name;
        }
      },
    },
    // add FNSI-体重計画面 徐 end
    mainAreaStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return {
        "--height": `${this.mainContentHeight}px`,
        "background-color": this.formColor,
      };
    },
    // add FNSI-体重計画面 徐 start
    coreParentAreaStyles() {
      // id:area-mainの高さを書き換え
      const widthPersent = Math.floor(100 / this.targetScale);
      const heightPixel = Math.floor(
        (this.coreParentHeight * widthPersent) / 100
      );
      return {
        width: `${widthPersent}%`,
        height: `${heightPixel}px`,
      };
    },
    // add FNSI-体重計画面 徐 end
    mainHeightStyles() {
      // main-content部の高さをCSS変数を利用して書き換え

      // 切替ボタンの高さを取得できれば取得する "重"の場合は取得しない
      let segmentHeight = 0;
      if (this.getScaleClass !== weightScaleClass.scale) {
        segmentHeight = 70;
      }

      // return { height: `${this.scaleContentHeight}px` };
      return {
        "--topmrgn": `calc(12em - ${segmentHeight}px)`,
        "margin-top": `var(--topmrgn)`,
      };
    },
    /* add FNSI-体重計画面 徐 start */
    mainHeightWidthStyles() {
      return { height: `${this.scaleContentHeight}px` };
    },
    mainContentMargin() {
      if (this.deviceFlg && this.getIsSimpleMode) {
        return "margin-right: auto;";
      } else {
        return "margin-left: auto; margin-right: auto;";
      }
    },
    /* add FNSI-体重計画面 徐 end */
    formColor: {
      get() {
        let val = "inherit";
        if (
          this.getWeightColorSetting !== undefined &&
          this.getWeightColorSetting !== null &&
          this.getWeightColorSetting.form !== undefined &&
          this.getWeightColorSetting.form !== null
        ) {
          val = this.getWeightColorSetting.form;
        }
        /* パンくずリスト背景色を設定 */
        const elm = document.getElementsByClassName("breadcrumb-area");
        if (elm) {
          elm[0].style.backgroundColor = val;
        }
        return val;
      },
    },
    // 体重測定:0 スケジュールなし患者: 1 それ以外: 2
    getPatScaleMode() {
      if (this.getScaleClass === weightScaleClass.noSchedule) {
        return 1;
      } else if (this.getScaleClass === weightScaleClass.scale) {
        return 0;
      }
      return 2;
    },
    // 透析治療中表示モード
    getIsTreating() {
      if (this.getScaleClass === weightScaleClass.dialysis) {
        // 治療中
        return true;
      }
      return false;
    },
    // 重量モード
    getIsScale() {
      if (this.getScaleClass === weightScaleClass.scale) {
        // 治療中
        return true;
      }
      return false;
    },
    // 透析中状態表示可能フラグ設定
    getIsCanTreatingDialysisStatusView() {
      if (this.getWeightScaleConfigInfo) {
        return this.getWeightScaleConfigInfo.isDuringDialysisView === FLG_TRUE;
      }
      return false;
    },
    // 後体重用車いす測定モードかどうか判定
    getIsWheelChairForAfterWeightMode() {
      return this.getIsTreating && this.treatingViewMode === 1;
    },
    // 選択中の測定モード [体重/体重+車いす/車いす]
    scaleMode: {
      get() {
        return this.getScaleMode;
      },
      set() {},
    },
    primaryOrderIsPurification() {
      // 指示１が特殊浄化ならばTrue
      if (
        this.getTreatmentMode !== undefined &&
        this.getTreatmentMode[0].deviceMode !== undefined
      ) {
        if (
          this.getTreatmentMode[0].deviceMode ===
          deviceModeConstant.PURIFICATION
        ) {
          return {
            isPurification: true,
            btnText:
              this.getScaleClass === weightScaleClass.after ? "退室" : "入室",
          };
        }
      }
      return {
        isPurification: false,
        btnText:
          this.getScaleClass === weightScaleClass.after ? "確定" : "送信",
      };
    },
    /**
     * 前体重/後体重切替ボタンの表示文字列設定
     * @returns {"前" | "後" | "重" | "中" | "  "}
     */
    getChangeBeforeAfterBtnLbl() {
      switch (this.getScaleClass) {
        case weightScaleClass.before:
          return "前";

        case weightScaleClass.after:
          return "後";

        case weightScaleClass.scale:
          return "重";

        case weightScaleClass.dialysis:
          return "中";

        case weightScaleClass.noSchedule:
          return "前";
        default:
          return "　";
      }
    },
    /**
     * メッセージ表示領域の開閉ボタンラベル
     * @returns {"▼" : "▲"}
     */
    getMessageButtonText() {
      return this.isShowMessageArea ? "▼" : "▲";
    },
    /**
     * 簡易詳細ボタンの表示文字列設定
     * @returns {"詳細" | "簡易"}
     */
    getChangeViewBtnMsg() {
      return this.getIsSimpleMode ? "詳細" : "簡易";
    },
    /**
     * 後体重測定モードか否か
     * @returns {boolean}
     */
    getIsAfterWeight() {
      return this.getScaleClass === weightScaleClass.after;
    },
    /**
     * 送信ボタンの表示文字列設定
     * @returns {String}
     */
    getChangeViewSendBtnMsg() {
      if (this.sendConditionButtonInfo === undefined) {
        return "";
      }
      return this.sendConditionButtonInfo.btnText;
    },
    /**
     * 条件送信ボタンのアクションを規定
     * @returns {{btnText: string, func: function;}}
     */
    sendConditionButtonInfo() {
      if (this.getScaleClass === weightScaleClass.before) {
        // 前体重
        switch (this.getScaleMode) {
          case weightScaleMode.weight:
            // 体重
            // 条件送信
            return {
              btnText: this.primaryOrderIsPurification.btnText,
              func: () => this.actionBeforeConfirm(this.callSendCondition),
            };
          case weightScaleMode.weightAndChair:
            // 体重+車いす
            if (
              this.getSelectWheelchair.code !== null &&
              this.getBodyWeightInfo.isSuccess
            ) {
              // 車いすがマスタ登録済み車いすだった場合は条件送信
              return {
                btnText: this.primaryOrderIsPurification.btnText,
                func: () => this.actionBeforeConfirm(this.callSendCondition),
              };
            } else {
              if (this.getBodyWeightInfo.isSuccess) {
                // 車いすが未登録車いす（重量測定済み）の場合は条件送信
                return {
                  btnText: this.primaryOrderIsPurification.btnText,
                  func: () => this.actionBeforeConfirm(this.callSendCondition),
                };
              } else {
                // 車いすが未登録車いす（重量未測定）の場合は一時保存
                return {
                  btnText: "保存",
                  func: () => this.callSaveWeightAndChair(),
                };
              }
            }
          case weightScaleMode.wheelChair:
            // 車いす
            // #12236 体重測定の動作不正 linjunfeng start
            // if (!this.getIsHasOrdWeightScale) {
            if (!this.getMeasuredValue) {
            // #12236 体重測定の動作不正 linjunfeng end
              // 体重値未測定の場合は一時保存
              return {
                btnText: "保存",
                func: () => this.callSaveChair(),
              };
            } else {
              // 体重値計算済みの場合は条件送信
              return {
                btnText: this.primaryOrderIsPurification.btnText,
                func: () => this.actionBeforeConfirm(this.callSendCondition),
              };
            }

          default:
            return {
              btnText: "送信不可",
              func: () =>
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "無処理",
                  // message: "処理対象特定不可"
                  title: DIALOG_MESSAGES["00200035"].title,
                  message: messageFormat(DIALOG_MESSAGES["00200035"].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                }),
            };
        }
      } else if (this.getScaleClass === weightScaleClass.after) {
        // 後体重
        switch (this.getScaleMode) {
          case weightScaleMode.weight:
            // 体重
            // 除水補正変更時
            if (this.getOffWaterChangeFlg == true) {
              return {
                btnText: this.primaryOrderIsPurification.btnText,
                func: () => this.callSendAfterWeightWithRstChange(),
              };
            } else {
              // 除水補正変更なし
              // 後体重送信
              return {
                btnText: this.primaryOrderIsPurification.btnText,
                func: () => this.callSendAfterWeight(),
              };
            }

          case weightScaleMode.weightAndChair:
            // 体重+車いす
            if (
              this.getSelectWheelchair.code !== null &&
              this.getBodyWeightInfo.isSuccess
            ) {
              // 車いすがマスタ登録済み車いすだった場合は確定
              if (this.getOffWaterChangeFlg == true) {
                return {
                  btnText: this.primaryOrderIsPurification.btnText,
                  func: () => this.callSendAfterWeightWithRstChange(),
                };
              } else {
                return {
                  btnText: this.primaryOrderIsPurification.btnText,
                  func: () => this.callSendAfterWeight(),
                };
              }
            } else {
              if (this.getBodyWeightInfo.isSuccess) {
                // 車いすが未登録車いす（重量測定済み）の場合は確定
                if (this.getOffWaterChangeFlg == true) {
                  return {
                    btnText: this.primaryOrderIsPurification.btnText,
                    func: () => this.callSendAfterWeightWithRstChange(),
                  };
                } else {
                  return {
                    btnText: this.primaryOrderIsPurification.btnText,
                    func: () => this.callSendAfterWeight(),
                  };
                }
              } else {
                // 車いすが未登録車いす（重量未測定）の場合は一時保存
                return {
                  btnText: "保存",
                  func: () => this.callSaveWeightAndChair(),
                };
              }
            }

          case weightScaleMode.wheelChair:
            // 車いす
            // #12236 体重測定の動作不正 linjunfeng start
            // if (!this.getIsHasOrdWeightScale) {
            if (!this.getMeasuredValue) {
            // #12236 体重測定の動作不正 linjunfeng end
              // 体重値未測定の場合は一時保存
              return {
                btnText: "保存",
                func: () => this.callSaveChair(),
              };
            } else {
              // 体重値計算済みの場合は後体重保存
              if (this.getOffWaterChangeFlg == true) {
                return {
                  btnText: this.primaryOrderIsPurification.btnText,
                  func: () => this.callSendAfterWeightWithRstChange(),
                };
              } else {
                return {
                  btnText: this.primaryOrderIsPurification.btnText,
                  func: () => this.callSendAfterWeight(),
                };
              }
            }

          default:
            return {
              btnText: "送信不可",
              func: () =>
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "無処理",
                  // message: "処理対象特定不可"
                  title: DIALOG_MESSAGES["00200035"].title,
                  message: messageFormat(DIALOG_MESSAGES["00200035"].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                }),
            };
        }
      } else if (this.getScaleClass === weightScaleClass.noSchedule) {
        // 前体重(スケジュールなし患者)
        switch (this.getScaleMode) {
          case weightScaleMode.weight:
            // 体重
            // 条件送信
            return {
              btnText: "保存",
              func: () => this.callSendCondition(),
            };
          case weightScaleMode.weightAndChair:
            // 体重+車いす
            if (
              this.getSelectWheelchair.code !== null &&
              this.getBodyWeightInfo.isSuccess
            ) {
              // 車いすがマスタ登録済み車いすだった場合は保存
              return {
                btnText: "保存",
                func: () => this.callSendCondition(),
              };
            } else {
              // 車いすが未登録車いすの場合は送信不可
              return {
                btnText: "車いす不明",
                func: () => false,
              };
            }
          case weightScaleMode.wheelChair:
            // 車いすが未登録車いすの場合は送信不可
            return {
              btnText: "車いす不明",
              func: () => false,
            };

          default:
            return {
              btnText: "送信不可",
              func: () =>
                this.$ons.notification.alert({
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // title: "無処理",
                  // message: "処理対象特定不可"
                  title: DIALOG_MESSAGES["00200035"].title,
                  message: messageFormat(DIALOG_MESSAGES["00200035"].message),
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                }),
            };
        }
      } else if (this.getScaleClass === weightScaleClass.scale) {
        // 重量測定
        return {
          btnText: "保存",
          func: () => this.callSaveWeight(),
        };
      } else if (this.getScaleClass === weightScaleClass.dialysis) {
        // 透析中
        if (this.getScaleMode === weightScaleMode.wheelChair) {
          // 後体重用車いす一時保存
          return {
            btnText: "保存",
            func: () => this.callSaveChair(),
          };
        } else {
          return {
            btnText: "送信不可",
            func: () =>
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "無処理",
                // message: "処理対象特定不可"
                title: DIALOG_MESSAGES["00200035"].title,
                message: messageFormat(DIALOG_MESSAGES["00200035"].message),
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              }),
          };
        }
      } else {
        // 不明な状態
        return {
          btnText: "送信不可",
          func: () =>
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "無処理",
              // message: "処理対象特定不可"
              title: DIALOG_MESSAGES["00200035"].title,
              message: messageFormat(DIALOG_MESSAGES["00200035"].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            }),
        };
      }
    },
    /**
     * 印刷設定
     */
    isPrint: {
      get() {
        return this.getIsPrint;
      },
      set(value) {
        // 印刷モードセット
        this.setPrintMode(value);
      },
    },
    /**
     * 送信ボタン非活性ならばtrue
     */
    disableSendBtn() {
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      if(this.deviceModeUnknownFlg) {
        this.disableSendBtnFlg = true
        return true;
      }
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
      // //add by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --start /
      // if(this.disableSendBtnResqFlg
      //     && this.getScaleMode === weightScaleMode.weight
      //     && (this.sendConditionButtonInfo.btnText == '送信'
      //         || this.sendConditionButtonInfo.btnText == '入室' || this.sendConditionButtonInfo.btnText == '退室')){
      //   return true;
      // }
      // //add by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --end /
      // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
      //mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      // if (this.primaryOrderIsPurification.isPurification) {
      if (this.primaryOrderIsPurification.isPurification && !this.getPurificationWarnmessageHasError) {
        this.disableSendBtnFlg = false
        this.isPurificationWarnMsgFlg = false
        // 特殊浄化
        return false;
      }
      //mod #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
      // add FNSI-透析装置が通信不良になっても後体重が測定出来るように修正する 徐 start
      // if (
      //   this.getMachineStateError === machineSendable.notSendable &&
      //   this.sendConditionButtonInfo.btnText !== "保存"
      // ) {
      //   // 装置側が通信エラーまたは治療中のため送信不可
      //   return true;
      // }
      if (
        this.getMachineStateError === machineSendable.notSendable &&
        this.sendConditionButtonInfo.btnText !== "保存" &&
        this.getScaleClass !== weightScaleClass.after
      ) {
        // 装置側が通信エラーまたは治療中のため送信不可
        return true;
      }
      if (
        this.getMachineStateError === machineSendable.notSendable &&
        this.getScaleClass === weightScaleClass.after
      ) {
        // 後体重測定の場合は通信不良の場合でも後体重測定可能とする。
        return false;
      }
      // add FNSI-透析装置が通信不良になっても後体重が測定出来るように修正する 徐 end

      if (
        ((this.getScaleClass === weightScaleClass.dialysis && // 透析中でない（透析中ならば後体重用車いす測定モードであること）
          this.getScaleMode === weightScaleMode.wheelChair) ||
          this.getScaleClass !== weightScaleClass.dialysis) &&
        !this.isClicking && // クリック処理中ではない
        !this.getIsMeasuring // 測定値確定済み
      ) {
        // 透析中でない（透析中ならば後体重用車いす測定モードであること）、
        // かつ条件送信確認済み状態でない、クリック中でもない、測定値は確定済み
        if (
          (this.getScaleClass !== weightScaleClass.noSchedule &&
            this.sendConditionButtonInfo.btnText === "保存") ||
          (this.getBodyWeightInfo.isSuccess &&
            !this.getCheckMessageHasError &&
            !this.getCheckMessageHasWarn)
        ) {
          // #10463 2024.06.13 mod 体重計マスタ未選択時でも2回測定チェックは実施する TDC米沢 start
          // /* modify by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --start */
          // // 一時保存モード、または条件送信可能でエラーも警告もなし
          // if (
          //     (this.scaleMode === weightScaleMode.wheelChair &&
          //         this.getSelectWheelchair.weight > 0 &&
          //         (!this.getCheckDoubleSettingByWc ||
          //             this.getSelectedMstWeight == null)) ||
          //     (this.scaleMode !== weightScaleMode.wheelChair &&
          //         this.getMeasuredValue > 0 &&
          //         (!this.getCheckDoubleSettingByMv ||
          //             this.getSelectedMstWeight == null))
          // ) {
          //   // 車いすモードで車いす重量あり
          //   // またはそれ以外のモードで測定値あり
          //   if (!this.getCheckMessageHasError) {
          //     return false;
          //   }
          // }
          // /* modify by chamaojia 2023-07-07 体重測定：2回測定checkが有効な場合、第1回試験後の保存/送信/確定ボタンの表示が間違っている  --end */
          // 一時保存モード、または条件送信可能でエラーも警告もなし
          if (
            (this.scaleMode === weightScaleMode.wheelChair &&
              this.getSelectWheelchair.weight > 0 &&
              !this.getCheckDoubleSettingByWc) ||
            (this.scaleMode !== weightScaleMode.wheelChair &&
              this.getMeasuredValue > 0 &&
              !this.getCheckDoubleSettingByMv)
          ) {
            // 車いすモードで車いす重量あり
            // またはそれ以外のモードで測定値あり
            if (!this.getCheckMessageHasError) {
              return false;
            }
          }
          // #10463 2024.06.13 mod 体重計マスタ未選択時でも2回測定チェックは実施する TDC米沢 end
        }
      }
      return true;
    },
    /**
     * クール・ベッドが未設定かどうか
     * @returns {{all: boolean, individual: [boolean, boolean]}}
     */
    isNotSetKurBed() {
      const noSetKur1 =
        this.getKurInfo[0].code === null || this.getKurInfo[0].code === 0;

      const noSetKur2 =
        this.getSelectedOrdNo.ordNo2 !== null &&
        (this.getKurInfo[1].code === null || this.getKurInfo[1].code === 0);

      const noSetBed1 =
        this.getBedInfo[0].code === null || this.getBedInfo[0].code === 0;
      const noSetBed2 =
        this.getSelectedOrdNo.ordNo2 !== null &&
        (this.getBedInfo[1].code === null || this.getBedInfo[1].code === 0);

      return {
        all: noSetKur1 || noSetBed1 || noSetKur2 || noSetBed2,
        individual: [noSetKur1 || noSetBed1, noSetKur2 || noSetBed2],
      };
    },
    isSelectedWeightNo() {
      const selectedWeightNo = this.getSelectedWeightNo;
      if (selectedWeightNo === null) {
        return false;
      }
      return true;
    },
    targetStyle() {
      return {
        transform: `translate(${this.targetTransForm.x}px, ${this.targetTransForm.y}px) scale(${this.targetScale})`,
        height: "100%",
      };
    },
    targetScale() {
      return this.minimumScale + this.notchVal * Number(this.sliderVal);
    },
    getHeight() {
      // 縦を計算
      const sah = document.getElementById("main-id").clientHeight;

      return "width: " + sah / 2 + "px";
    },
    /**
     * 拡縮変更UIの有効化
     * 通常モードかつスマホ(iPhone/Android)使用時のみ
     */
    enableZoom() {
      return this.breadMode && this.isMobile;
    },
    scheduleBtnStyle() {
      return {
        maxWidth: `${this.scheduleBtnMaxWidth}px`,
      };
    },
    footerBtnFontSizeStyle() {
      if (this.breadMode) {
        return "font-size: 1.5em;";
      } else {
        return "font-size: 30px;";
      }
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
    isChanged() {
      /* modify by chamaojia 2024-12-20 [11387] 【たくしん会】前/後体重測定時に重量測定モードとなる　V1.0B --start */
      /**
       * #11387 modify content:
       * 1. this.getLastScaleValue -> this.getLastWheelChairValue
       *     【this.getLastScaleValue】 it is a measurement of weight（scaleValue）
       *        cannot compare with the weight of a wheelchair
       * 2. add judgment criteria
       *     this.getLastWheelChairCd != this.getSelectWheelchair.code
       */
      return (
          this.initWeightValue != this.getMeasuredValue ||
          this.getLastWheelChairValue != this.getSelectWheelchair.weight ||
          this.getLastWheelChairCd != this.getSelectWheelchair.code
      );
      // return (
      //   this.initWeightValue != this.getMeasuredValue ||
      //   this.getLastScaleValue != this.getSelectWheelchair.weight
      // );
      /* modify by chamaojia 2024-12-20 [11387] 【たくしん会】前/後体重測定時に重量測定モードとなる　V1.0B --end */
    },
    // add #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
  },
  methods: {
    ...mapActions("multi-modal", [
      "showMeasureHistoryModal",
      "showPatSearch",
      "showIndEditModal",
    ]),
    ...mapActions("send-condition/scale", [
      "setIsInitialized",
      "setInputPatId",
      "setPatId",
      "setSelectOrdNo",
      "setScaleMode",
      "setMeasuredValue",
      "setViewModeIsSimple",
      "switchViewMode",
      "setPrintMode",
      "fetchIndRstData",
      "fetchNoSchedulePatData",
      "fetchLastRstWeight",
      "setLastTimeWeight",
      "hideCheckMessage",
      "sendCondition",
      "setOffWaterRegFlg",
      "sendAfterWeight",
      "setSendConditionResponseCd",
      "setSelectWheelChair",
      "resetIsHasOrdWeightScale",
      "setIsHasOrdWeightScale",
      "startWeightScaleMode",
      "setBaseOrdWeightNo",
      "loadPhysicalInfo",
      "changeWheelChairWeightValue",
      "calcWeightValue",
      "sendPrintOrder",
      "saveMeasure",
      "preSaveCheckDBChanged",
      // add FNSI-田中衡機の追加 徐 start
      "sendWeightAppOk",
      // add FNSI-田中衡機の追加 徐 end
      // add FNSI-分類不一致判断の追加 徐 start
      "chkIndCondInfoData",
      "setChkIndCondInfoFlg",
      "setErrorMessage",
      "showErrorMessage",
      "setMstDelFlg",
      "setMstOverdueFlg",
      // add FNSI-分類不一致判断の追加 徐 end
      // add FutreNetWeb+SI課題管理No6705 趙 start
      "setOffWaterChangeFlg",
      // add FutreNetWeb+SI課題管理No6705 趙 end
    ]),
    ...mapActions("send-condition/scale/setting", [
      "fetchWeightScaleSetting",
      "setWeightScaleSetting",
      "fetchWheelChairList",
      "fetchDefaultWeightSetting",
      "setDefaultWeightConfigInfo",
    ]),
    ...mapActions("send-condition/scale/message", [
      "initMessage",
      "setCheckConfig",
      "setPrintConfig",
      "setDoubleCheckSetting",
      "checkMessageList",
      "setPatInfo",
      "buildPrintData",
      // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
      "setIsBeforeWeightToleranceRangeCheck",
      // #10290 2024.03.08 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end
      // #10463 2024.06.13 add 2回測定チェック用前回測定値をクリアする TDC米沢 start
      "clearDoubleCheckPastValues",
      // #10463 2024.06.13 add 2回測定チェック用前回測定値をクリアする TDC米沢
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
      "setPurificationWarnMessageList",
      //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("pat-viewer-popover", ["setCellInfo"]),
    ...mapActions("pat-viewer-modal", ["showIndModal"]),
    ...mapActions("account-edit", ["setIsDispSidebarBtn"]),
    // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
    ...mapActions("mst-facility-setting", {
      getFacilitySettingDataList: "getFacilitySettingDataList",
    }),
    ...mapActions("user", {
      fetchUserAuthorityCds: "fetchUserAuthorityCds",
    }),
    // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 end
    // add FNSI-分類不一致判断の追加 徐 start
    ...mapMutations("send-condition/scale/message", ["resetMessage"]),
    // add FNSI-分類不一致判断の追加 徐 end
    // #11987 2026.02.10 add スケールベッドからの呼び出しに対応 TDC片口 start
    ...mapActions("scale-bed/send-cond", ["resetScaleBedToWeightView"]),
    // #11987 2026.02.10 add スケールベッドからの呼び出しに対応 TDC片口 end
    toggleShowMessage() {
      this.isShowMessageArea = !this.isShowMessageArea;
    },
    // add FNSI-体重計画面 徐 start
    showPopover() {
      this.isShowMultiple = true;
    },
    setMaskShow(e) {
      if (!this.$refs.child.contains(e.target)) {
        this.isShowMultiple = false;
      }
    },
    // add FNSI-体重計画面 徐 end
    // add FNSI-田中衡機の追加 徐 start
    /**
     * @description 複数チェック処理
     * @summary クリックした項目のチェック状態に応じてチェックフラグを切り替える
     * @param {Number} checkedIndex チェック項目インデックス
     */
    checkMultiItem(checkedIndex) {
      if (this.getScaleMode === weightScaleMode.wheelChair) {
        this.changeWheelChairWeightValue(this.itemList[checkedIndex].name);
      } else {
        this.setMeasuredValue(this.itemList[checkedIndex].name);
      }
      this.calcWeightValue();
      this.isClick = true;
      for (let i = 0; i < this.itemList.length; i++) {
        if (i === checkedIndex) {
          this.itemList[i].isChecked = true;
        } else {
          this.itemList[i].isChecked = false;
        }
      }
      // add FNSI-体重計画面 徐 start
      this.isShowMultiple = false;
      // add FNSI-体重計画面 徐 end
    },
    /**
     * @description チェック状態に応じたCSSクラス付与
     */
    computeClassItemLabel(selectedItem) {
      return {
        // マウスオーバー時の薄い背景色
        "item-label-hovered": !selectedItem.isChecked,
        // チェック時の背景色
        "item-label-checked": selectedItem.isChecked,
      };
    },
    // add FNSI-田中衡機の追加 徐 end
    /**
     * 指示更新による画面更新処理
     */
    // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20240105 ztc start
    // refresh() {
    refresh(reFlag) {
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      // if (this.isChanged) {
      if (this.isChanged && !reFlag) {
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20240105 ztc end
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer === 1) {
              if (this.selfScreenName !== this.$router.currentRoute.name) {
                return;
              }
              this.$nextTick(() => {
                if (this.isShowing) {
                  if (
                    this.getSelectedOrdNo.ordNo === null &&
                    this.getInputPatId !== null
                  ) {
                    // 更新前にスケジュールがなかった（おそらくスケジュール割り当てしてリフレッシュ）
                    EventBus.$emit("searchHospPatIdSchedule", {
                      hospPatId: this.getInputPatId,
                    });
                  } else {
                    this.loadInitialData();
                  }
                }
              });
            }
          },
        });
      } else {
        if (this.selfScreenName !== this.$router.currentRoute.name) {
          return;
        }
        this.$nextTick(() => {
          if (this.isShowing) {
            if (
              this.getSelectedOrdNo.ordNo === null &&
              this.getInputPatId !== null
            ) {
              // 更新前にスケジュールがなかった（おそらくスケジュール割り当てしてリフレッシュ）
              EventBus.$emit("searchHospPatIdSchedule", {
                hospPatId: this.getInputPatId,
              });
            } else {
              this.loadInitialData();
            }
          }
        });
      }
      // if (this.selfScreenName !== this.$router.currentRoute.name) {
      //   return;
      // }
      // this.$nextTick(() => {
      //   if (this.isShowing) {
      //     if (
      //         this.getSelectedOrdNo.ordNo === null &&
      //         this.getInputPatId !== null
      //     ) {
      //       // 更新前にスケジュールがなかった（おそらくスケジュール割り当てしてリフレッシュ）
      //       EventBus.$emit("searchHospPatIdSchedule", {
      //         hospPatId: this.getInputPatId
      //       });
      //     } else {
      //       this.loadInitialData();
      //     }
      //   }
      // });
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
    },
    insertCoopJournal() {
      // add FNSI-外部連携APIの修正 徐 start
      // createJournal({
      //   facility_cd: this.facilityCd,
      //   coop_cd: "accept",
      //   coop_cd_index: "",
      //   crud: "C",
      //   direction: "S",
      //   ana_result: "0",
      //   coop_result: "0",
      //   pat_id: this.getPatId,
      //   ord_no: this.getSelectedOrdNo.ordNo,
      //   user_id: this.getUserId
      // });
      createJournal({
        ope_cd: this.sendConditionFlg ? "013001" : "013002",
        crud: this.sendConditionFlg ? "C" : "U",
        facility_cd: this.facilityCd,
        hosp_pat_id: this.selectedPat
          ? this.selectedPat.pat_personal_main.hosp_pat_id
          : null,
        pat_id: this.getPatId,
        ord_no: this.getSelectedOrdNo.ordNo,
        base_date: moment().format("YYYYMMDD"),
        user_id: this.getUserId,
      });
      // add FNSI-外部連携APIの修正 徐 end
    },
    // add 10553 連携イベント発生部分不正 関 start
    createCoopJournal() {
      createJournal({
        ope_cd: "013028",
        crud: "C",
        facility_cd: this.facilityCd,
        hosp_pat_id: this.selectedPat
          ? this.selectedPat.pat_personal_main.hosp_pat_id
          : null,
        pat_id: this.getPatId,
        ord_no: this.getSelectedOrdNo.ordNo,
        base_date: moment().format("YYYYMMDD"),
        user_id: this.getUserId,
      });
    },
    // add 10553 連携イベント発生部分不正 関 end
    async loadInitialData() {
      // add FNSI-分類不一致判断の追加 徐 start
      this.disableSendBtnFlg = false;
      // add FNSI-分類不一致判断の追加 徐 end
      // 指示が選択されている場合
      if (this.getSelectedOrdNo.ordNo !== null) {
        // add FutreNetWeb+SI課題管理No7091 趙 start
        this.initMessage();
        // add FutreNetWeb+SI課題管理No7091 趙 end
        // add FNSI-分類不一致判断の追加 徐 start
        // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
        // this.buttonConfig = 0;
        // this.mstDelConfig = 0;
        // this.mstOverdueConfig = 0;
        this.buttonConfig = "0";
        this.mstDelConfig = "0";
        this.mstOverdueConfig = "0";
        // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
        // add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou start
        ApiHelper.get(
          `weight/order/hasSameOrd/${this.getSelectedOrdNo.ordNo}`
        ).then(async (r) => {
          if (r.data) {
            this.disableSendBtnFlg = true;
            let param = {
              message: `同患者，同日，同クールでの治療は，透析＋透析は許可していない。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
        });
        // add #7524 2022/11/10 同日同クールで同時に透析治療が実施できてしまう dou end
        // mod FutreNetWeb+SI課題管理No6404 趙 start
        // 選択スケジュールの指示・実績情報取得
        this.fetchIndRstData({
          ordNo: this.getSelectedOrdNo.ordNo,
          ordNo2: this.getSelectedOrdNo.ordNo2,
          facilityCd: this.facilityCd,
          // #11987 2026.03.27 add スケールベッドから呼び出された場合の測定値追加 TDC片口 start
          isScaleBed: this.getIsFromScaleBed,
          scaleBedMeasureValue: this.getScaleBedValue,
          // #11987 2026.03.27 add スケールベッドから呼び出された場合の測定値追加 TDC片口 end
        }).then((r) => {
          // #11987 2026.05.20 スケールベッドから呼び出された場合の測定値をセットする。 TDC渡辺 start
          //スケールベッドから呼び出された場合は、スケールベッドの測定値をセットする
          if(this.getIsFromScaleBed) {
              this.setMeasuredValue(this.getScaleBedValue);
          }
          // #11987 2026.05.20 add スケールベッドから呼び出された場合の測定値をセットする。 TDC渡辺 end

          if (r) {
            this.setSelectedPatHeader(this.getPatId);
            // 前回後体重
            this.fetchLastRstWeight({
              ordNo: this.getSelectedOrdNo.ordNo,
              previousWeightSourceClass: this.previousWeightSourceClass,
            }).then((r) => {
              if (
                r.data === null ||
                r.data === "" ||
                r.data.weight_after === null ||
                isNaN(Number(r.data.weight_after))
              ) {
                this.setLastTimeWeight(null);
              } else {
                this.setLastTimeWeight(r.data.weight_after);
              }
            });
            this.initialized();
          } else {
            // オーダー削除済みなどで指示取得できず
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "スケジュール無し",
              // message: "スケジュールが取得できませんでした"
              title: DIALOG_MESSAGES[12000217].title,
              message: messageFormat(DIALOG_MESSAGES[12000217].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            this.setViewModeIsSimple(true);
            this.startWeightScaleMode().then(() => {
              this.initialized();
            });
          }
        });
        // mod FutreNetWeb+SI課題管理No6404 趙 end
        await this.chkIndCondInfoData({
          ordNo: this.getSelectedOrdNo.ordNo,
          ordNo2: this.getSelectedOrdNo.ordNo2,
        }).then(async (r) => {
          // del FutreNetWeb+SI課題管理No6902 趙 start
          // this.initMessage();
          // del FutreNetWeb+SI課題管理No6902 趙 end
          // add FutreNetWeb+SI課題管理No6649 趙 start
          let after = await this.getIsAfterWeight;
          // add FutreNetWeb+SI課題管理No6649 趙 end
          // マスタ削除
          if (r.data.mstDelFlgMsgList.length > 0) {
            this.mstDelMsgList = r.data.mstDelFlgMsgList;
            this.mstDelDiaView = true;
          } else {
            this.mstDelDiaView = false;
          }
          // マスタ期限切れMsgList
          if (r.data.mstOverdueMsgList.length > 0) {
            this.mstOverdueMsgList = r.data.mstOverdueMsgList;
            this.mstOverdueDiaView = true;
          } else {
            this.mstOverdueDiaView = false;
          }
          // 治療条件分類不一致
          if (r.data.msgList.length > 0) {
            this.recordList = r.data.msgList;
            this.diaView = true;
          } else {
            this.diaView = false;
          }
          // 治療条件未登録
          // mod FutreNetWeb+SI課題管理No6649 趙 start
          // if (r.data.indCondInfoNoLoginMsgList.length > 0) {
          if (r.data.indCondInfoNoLoginMsgList.length > 0 && !after) {
            // mod FutreNetWeb+SI課題管理No6649 趙 end
            this.disableSendBtnFlg = true;
            let msg = "";
            for (let i = 0; i < r.data.indCondInfoNoLoginMsgList.length; i++) {
              if (i === r.data.indCondInfoNoLoginMsgList.length - 1) {
                msg =
                  msg +
                  r.data.indCondInfoNoLoginMsgList[i] +
                  "が未登録のため条件送信できません。指示を変更してください。";
              } else {
                msg = msg + r.data.indCondInfoNoLoginMsgList[i] + "、";
              }
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "治療条件未登録",
              title: DIALOG_MESSAGES["00300023"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: msg,
            });
          }
          // 治療条件上限
          if (r.data.indCondInfoTopLimitMsgList.length > 0) {
            this.disableSendBtnFlg = true;
            let msg = "";
            for (let i = 0; i < r.data.indCondInfoTopLimitMsgList.length; i++) {
              if (i === r.data.indCondInfoTopLimitMsgList.length - 1) {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // msg = msg + r.data.indCondInfoTopLimitMsgList[i] + "が上限を超えているため条件送信できません。治療条件または装置設定を変更してください。";
                msg =
                  msg +
                  r.data.indCondInfoTopLimitMsgList[i] +
                  DIALOG_MESSAGES[12000219].message;
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              } else {
                msg = msg + r.data.indCondInfoTopLimitMsgList[i] + "、";
              }
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "治療条件上限",
              title: DIALOG_MESSAGES[12000219].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: msg,
            });
          }
          // 治療条件下限
          if (r.data.indCondInfoLowerLimitMsgList.length > 0) {
            this.disableSendBtnFlg = true;
            let msg = "";
            for (
              let i = 0;
              i < r.data.indCondInfoLowerLimitMsgList.length;
              i++
            ) {
              if (i === r.data.indCondInfoLowerLimitMsgList.length - 1) {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // msg = msg + r.data.indCondInfoLowerLimitMsgList[i] + "が下限を下回っているため条件送信できません。治療条件または装置設定を変更してください。";
                msg =
                  msg +
                  r.data.indCondInfoLowerLimitMsgList[i] +
                  DIALOG_MESSAGES[12000220].message;
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              } else {
                msg = msg + r.data.indCondInfoLowerLimitMsgList[i] + "、";
              }
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "治療条件下限",
              title: DIALOG_MESSAGES[12000220].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: msg,
            });
          }
          // I-HDF治療条件不整合
          if (r.data.indCondInfoUseIHDFMsgList.length > 0) {
            this.disableSendBtnFlg = true;
            let msg = "";
            for (let i = 0; i < r.data.indCondInfoUseIHDFMsgList.length; i++) {
              if (i === r.data.indCondInfoUseIHDFMsgList.length - 1) {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // msg = "I-HDF治療では、" + msg + r.data.indCondInfoUseIHDFMsgList[i] + "を使用できません。治療条件または装置設定を変更してください。";
                msg = messageFormat(
                  DIALOG_MESSAGES[12000221].message,
                  msg + r.data.indCondInfoUseIHDFMsgList[i]
                );
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              } else {
                msg = msg + r.data.indCondInfoUseIHDFMsgList[i] + "、";
              }
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "I-HDF治療条件不整合",
              title: DIALOG_MESSAGES[12000221].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: msg,
            });
          }
          // AFBF治療条件不整合
          if (r.data.indCondInfoUseAFBFMsgList.length > 0) {
            this.disableSendBtnFlg = true;
            let msg = "";
            for (let i = 0; i < r.data.indCondInfoUseAFBFMsgList.length; i++) {
              if (i === r.data.indCondInfoUseAFBFMsgList.length - 1) {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // msg = "AFBF治療では、" + msg + r.data.indCondInfoUseAFBFMsgList[i] + "を使用できません。治療条件または装置設定を変更してください。";
                msg = messageFormat(
                  DIALOG_MESSAGES[12000222].message,
                  msg + r.data.indCondInfoUseAFBFMsgList[i]
                );
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              } else {
                msg = msg + r.data.indCondInfoUseAFBFMsgList[i] + "、";
              }
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "AFBF治療条件不整合",
              title: DIALOG_MESSAGES[12000222].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: msg,
            });
          }
          // SN治療条件不整合
          if (r.data.indCondInfoUseSNMsgList.length > 0) {
            this.disableSendBtnFlg = true;
            let msg = "";
            for (let i = 0; i < r.data.indCondInfoUseSNMsgList.length; i++) {
              if (i === r.data.indCondInfoUseSNMsgList.length - 1) {
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // msg = "シングルニードルを使用する場合、" + msg + r.data.indCondInfoUseSNMsgList[i] + "は使用できません。治療条件または装置設定を変更してください。";
                msg = messageFormat(
                  DIALOG_MESSAGES[12000223].message,
                  msg + r.data.indCondInfoUseSNMsgList[i]
                );
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              } else {
                msg = msg + r.data.indCondInfoUseSNMsgList[i] + "、";
              }
            }
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "SN治療条件不整合",
              title: DIALOG_MESSAGES[12000223].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: msg,
            });
          }
          // Na注入プログラム使用Flg
          if (r.data.naInjectionProgramFlg) {
            let param = {
              message: `透析液濃度プログラムを使用するため、Na注入プログラムを使用しないで送信します。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // シングルニードル使用Flg
          if (r.data.singleNeedleFlg) {
            let param = {
              message: `シングルニードル使用するため、BV計、アクセス再循環を使用しないで送信します。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // TMP自動追従使用Flg
          if (r.data.tmpAutomaticTrackingFlg) {
            // add #6925 2022/10/14 治療モードを変更した際の制限事項，注意メッセージについて dou start
            this.disableSendBtnFlg = true;
            // add #6925 2022/10/14 治療モードを変更した際の制限事項，注意メッセージについて dou end
            let param = {
              message: `AFBF治療のためTMP監視モード自動追従を自動設定で送信します。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // 装置オプション不整合
          if (r.data.deviceOptionsMsgList.length > 0) {
            let msg = "";
            for (let i = 0; i < r.data.deviceOptionsMsgList.length; i++) {
              if (i === r.data.deviceOptionsMsgList.length - 1) {
                msg =
                  "送信対象装置のオプションに" +
                  msg +
                  r.data.deviceOptionsMsgList[i] +
                  "がないため使用できません。";
              } else {
                msg = msg + r.data.deviceOptionsMsgList[i] + "、";
              }
            }
            setTimeout(() => {
              let param = {
                message: msg,
                isError: true,
                isWarn: false,
              };
              this.setErrorMessage(param);
              let showErrorMessage = { isList: true };
              this.showErrorMessage(showErrorMessage);
            }, 500);
          }
          // 特殊浄化MsgFlg
          if (r.data.isPurificationMsgFlg) {
            let param = {
              message: `特殊浄化治療のため装置には治療条件を送信せずオフライン運用装置として動作します。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
          if (r.data.isPurificationWarnMsgFlg) {
            this.disableSendBtnFlg = true;
            if (!r.data.isPurificationMsgFlg) {
              this.isPurificationWarnMsgFlg = true;
              const msgList = [];
              msgList.push({
                calc: "",
                condition: {
                  use: 0,
                  left: "0",
                  right: "0",
                  ineq: 0,
                  result: false
                },
                value: "",
                message: "装置の治療モードと不一致",
                isWarnValue: false,
                isWarn: true,
                isError: false,
                isChecked: false,
                isDisp: true
              });
              this.setPurificationWarnMessageList(msgList);
            }
          }
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
          // mod FutreNetWeb+SI課題管理No6404 趙 start
          // 補液量と補液速度についてMsgFlg
          // if (r.data.replenishmentMsgFlg) {
          if (!after && r.data.replenishmentMsgFlg) {
            // mod FutreNetWeb+SI課題管理No6404 趙 end
            let param = {
              message: `補液量から補液速度を算出して送信します。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // 補液量と補液比率についてMsgFlg
          // mod FutreNetWeb+SI課題管理No6404 趙 start
          // if (r.data.replenishmentMsgFlg2) {
          if (!after && r.data.replenishmentMsgFlg2) {
            // mod FutreNetWeb+SI課題管理No6404 趙 end
            // mod FutreNetWeb+SI課題管理No7193 趙 start
            // let param = {
            // message: `補液量から補液比率を算出して送信します。`,
            // isError: true,
            // isWarn: false
            // };

            let param = {
              message: `補液比率から算出した補液速度と補液量を送信します。`,
              isError: true,
              isWarn: false,
            };
            // mod FutreNetWeb+SI課題管理No7193 趙 end
            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // 補液量と濾過率についてMsgFlg
          // mod FutreNetWeb+SI課題管理No6404 趙 start
          // if (r.data.replenishmentMsgFlg3) {
          if (!after && r.data.replenishmentMsgFlg3) {
            // mod FutreNetWeb+SI課題管理No6404 趙 end
            // mod FutreNetWeb+SI課題管理No7193 趙 start
            // let param = {
            //   message: `補液量から濾過率を算出して送信します。`,
            //   isError: true,
            //   isWarn: false
            //   };
            let param = {
              message: `濾過率から補液速度と補液量を算出して送信することはできません。`,
              isError: true,
              isWarn: false,
            };
            // mod FutreNetWeb+SI課題管理No7193 趙 end

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // add FutreNetWeb+SI課題管理No7195 趙 start
          if (!after && r.data.replenishmentMsgFlg4) {
            let param = {
              message: `補液量から算出した補液速度を送信します。`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // add FutreNetWeb+SI課題管理No7195 趙 end
          // 装置モード不一致チェックMsgFlg
          if (r.data.deviceModeMismatchMsgFlg) {
            let param = {
              message: `装置の治療モードと不一致`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
          if (r.data.deviceModeUnknownMsgFlg) {
            this.deviceModeUnknownFlg = true;
            let param = {
              message: `治療方法が不明です`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
          // VA方向不一致チェックMsgFlg
          if (r.data.vaDirectionInconsistentMsgFlg) {
            let param = {
              message: `ベッドのVA方向と不一致`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // 感染症不一致チェックMsgFlg
          if (r.data.infectionNotConsistentMsgFlg) {
            let param = {
              message: `感染症ベッドと不一致`,
              isError: true,
              isWarn: false,
            };

            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou start
          // 感染症不一致チェックMsgFlg
          if (r.data.diversionBvufcFlg) {
            let param = {
              // mod #7810 2022/11/30 BV-UFCと両方ONの状態で体重測定時、表示されるメッセージが不正 張 start
              // message: DIALOG_MESSAGES[12000033],
              message: DIALOG_MESSAGES[12000031].message,
              // mod #7810 2022/11/30 BV-UFCと両方ONの状態で体重測定時、表示されるメッセージが不正 張 end
              isError: true,
              isWarn: false,
            };
            this.disableSendBtnFlg = true;
            await this.setErrorMessage(param);
            let showErrorMessage = { isList: true };
            this.showErrorMessage(showErrorMessage);
          }
          // add #7810 2022/11/20 BVUFCを使用する予定に除水プログラム使用するを展開する場合は警告。。 dou end
        });
        // add FNSI-分類不一致判断の追加 徐 end
        // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
        // //upd by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --start /
        // await getMstFacilitySettingValueMap(this.facilityCd, [CHK_INDCONDINFO_FLG])
        //   .then((response) => {
        //     //upd by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --start /
        //     if (response.data[CHK_INDCONDINFO_FLG] && this.getTreatmentMode !== undefined) {
        //       this.disableSendBtnResqFlg = this.diaView && response.data[CHK_INDCONDINFO_FLG] == 0;
        //     }
        //     //upd by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --end /
        //   })
        //   .catch((error) => {
        //     getErrorMessage('SendConditionMainComponent.vue', 'callSendCondition', error);
        //   });
        // //upd by ztc 2023-04-23 #8603 分類エラーで送信不可に設定しても送信が活性化 bug --end /
        // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end
      } else if (this.getInputPatId !== null) {
        // 指示は未選択だが患者選択の場合
        this.setSelectedPatHeader(this.getPatId);
        this.fetchNoSchedulePatData({
          patId: this.getPatId,
          facilityCd: this.facilityCd,
        }).then(() => {
          // 前回後体重
          this.fetchLastRstWeight({
            ordNo: null,
            patId: this.getPatId,
            previousWeightSourceClass: this.previousWeightSourceClass,
          }).then((r) => {
            if (
              r.data === null ||
              r.data === "" ||
              r.data.weight_after === null ||
              isNaN(Number(r.data.weight_after))
            ) {
              this.setLastTimeWeight(null);
            } else {
              this.setLastTimeWeight(r.data.weight_after);
            }
          });
          this.initialized();
        });
      } else {
        // 患者未選択(重量測定)
        this.setViewModeIsSimple(true);
        this.startWeightScaleMode().then(() => {
          this.initialized();
        });
      }
    },
    /**
     * @param {number} index
     * @return {String | null}
     */
    getScheduleLabel(index) {
      if (
        index === 0 &&
        this.getSelectedOrdNo !== undefined &&
        this.getSelectedOrdNo.ordNo === null
      ) {
        return "スケジュールなし";
      } else if (
        (index === 0 && this.getSelectedOrdNo.ordNo !== null) ||
        (index === 1 && this.getSelectedOrdNo.ordNo2 !== null)
      ) {
        const kur =
          this.getKurInfo[index].code !== null &&
          this.getKurInfo[index].code > 0
            ? this.getKurInfo[index].name
            : "クール未設定";
        const bed =
          this.getBedInfo[index].code !== null &&
          this.getBedInfo[index].code > 0
            ? this.getBedInfo[index].name
            : "ベッド未設定";
        return `${kur}/${bed}(${this.getTreatmentMode[index].treatName})`;
      }
      return null;
    },
    showScheduleModal(ordIndex) {
      // スケジュール割り当てモーダル表示
      if (
        this.getPatScaleMode > 0 && // 重量測定モードではない
        this.getSelectedOrdNo !== undefined &&
        this.getSelectedOrdNo.ordNo === null
      ) {
        // スケジュール無し
        // スケジュールなし患者の場合は指示作成モーダル

        // 取得したセル情報を格納
        const cellInfo = { ordNo: null, treatDate: null, value1: null };
        this.setCellInfo({ cellInfo });

        // 治療予定作成モーダルに渡す情報の設定
        const settingData = deepCopy(
          this.getDefaultSettingIndPlanCreateNewData
        );
        // 【通常】【隔日】切替ボタン-非表示
        settingData.showSegment = false;
        // 患者ID
        settingData.patId = this.getPatId;
        // 施設コード
        settingData.facilityCd = this.facilityCd;
        // 開始日
        settingData.startDate = moment().format("YYYY-MM-DD");
        // 終了日
        settingData.endDate = settingData.startDate;
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 選択された曜日以外すべてfalseに変更
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] =
            i !== moment().day() ? false : true;
        }
        // 治療予定作成モーダルを直接呼び出す
        this.showIndModal({
          dispComponentId: "ind-plan-create",
          settingIndData: settingData,
        });
      } else {
        // クールベッド割り当てモーダル
        /** @type {number} */
        let ordNo = null;
        if (ordIndex === 0) {
          ordNo = this.getSelectedOrdNo.ordNo;
        } else if (ordIndex === 1) {
          ordNo = this.getSelectedOrdNo.ordNo2;
        } else {
          return;
        }
        const treatDate = this.getTreatDate[ordIndex];
        const treatStartTime = this.getIndTreatStartTime[ordIndex];

        // 取得したセル情報を格納
        const cellInfo = { ordNo: ordNo, treatDate: treatDate, value1: null };
        this.setCellInfo({ cellInfo });

        // スケジュールに渡す情報の設定(IndEditBase)
        const settingData = deepCopy(this.getDefaultSettingIndScheduleData);
        // 患者ID
        settingData.patId = this.getPatId;
        // 施設コード
        settingData.facilityCd = this.facilityCd;
        // オーダー番号
        settingData.ordNo = ordNo;
        // 開始日(一番左の日付)
        settingData.startDate = moment(treatDate, "YYYYMMDD").format(
          "YYYY-MM-DD"
        );
        // 終了日(一番右の日付)
        settingData.endDate = moment(treatDate, "YYYYMMDD").format(
          "YYYY-MM-DD"
        );
        // 開始日操作不可
        settingData.startDateEdit = true;
        // 終了日操作不可
        settingData.endDateEdit = true;
        // 全曜日選択をfalse
        settingData.allWeek = false;
        // 選択された曜日以外をfalseへ変更
        for (let i = 0; i < 7; i++) {
          settingData[this.changeWeekStr(i)] =
            i !== moment(treatDate, "YYYYMMDD").day() ? false : true;
        }

        // 子コンポーネントへ渡すデータ
        const settingChildData = {};
        // 施設コード
        settingChildData.propsFacilityCd = this.facilityCd;
        // 透析開始時刻
        // mod #9429 2023-12-04 体重測定画面でのスケジュール編集で治療開始時刻の表示が不正 宮崎 start
        settingChildData.propsIndTreatStartTime = treatStartTime;
        // mod #9429 2023-12-04 体重測定画面でのスケジュール編集で治療開始時刻の表示が不正 宮崎 end
        // クール
        settingChildData.propsSelectedKur = this.getKurInfo[ordIndex].code;
        // ベッド
        settingChildData.propsSelectedBed = this.getBedInfo[ordIndex].code;

        this.showIndModal({
          dispComponentId: "ind-sch-edit",
          settingIndData: settingData,
          settingIndChildData: settingChildData,
        });
      }
    },
    showTreatCondModal(category) {
      // 取得したデータを格納
      if (
        this.getSelectedOrdNo.ordNo === null ||
        (category !== 0 && category !== 1)
      ) {
        return;
      }
      const cellInfo = {
        ordNo: this.getSelectedOrdNo.ordNo,
        treatDate: this.getTreatDate[0],
        value1: null,
      };
      this.setCellInfo({ cellInfo });

      // 治療条件に渡す情報の設定(IndEditBase)
      const settingData = deepCopy(this.getDefaultSettingIndConditionData);
      // 患者ID
      settingData.patId = this.getPatId;
      // 施設コード
      settingData.facilityCd = this.facilityCd;
      // オーダー番号
      settingData.ordNo = this.getSelectedOrdNo.ordNo;
      // 開始日
      settingData.startDate = moment(this.getTreatDate[0], "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 終了日
      settingData.endDate = moment(this.getTreatDate[0], "YYYYMMDD").format(
        "YYYY-MM-DD"
      );
      // 開始日操作不可
      settingData.startDateEdit = true;
      // 終了日操作不可
      settingData.endDateEdit = true;
      // 全曜日選択をfalse
      settingData.allWeek = false;
      // 選択された曜日以外をfalseへ変更
      for (let i = 0; i < 7; i++) {
        settingData[this.changeWeekStr(i)] =
          i !== moment(this.getTreatDate[0], "YYYYMMDD").day() ? false : true;
      }

      // 子コンポーネントへ渡すデータ
      const settingChildData = {};
      const dataObject = this.getOrderIndCondInfo[0];

      if (category === 0) {
        settingChildData.componentNames = [
          // 目標体重
          // add FNSI-popupのパラメータ補正 徐 start
          // {
          //   name: "ind-treat-target-weight",
          //   fields: dataObject["3"].value,
          //   groupCd: 2,
          //   cd: 3
          // }
          {
            name: "ind-treat-target-weight",
            fields: {
              value: dataObject["3"].value,
            },
            groupCd: 2,
            cd: 3,
          },
          // add FNSI-popupのパラメータ補正 徐 end
        ];
        // ヘッダータイトル(groupCd=2)
        settingData.headerTitle = MODAL_TITLE["目標体重編集"];
      } else if (category === 1) {
        settingChildData.componentNames = [
          // 除水量制限
          // add FNSI-popupのパラメータ補正 徐 start
          // {
          //   name: "ind-treat-filter-limit",
          //   fields: dataObject["4"].value,
          //   groupCd: 2,
          //   cd: 4
          // }
          {
            name: "ind-treat-filter-limit",
            fields: {
              value: dataObject["4"].value,
            },
            groupCd: 2,
            cd: 4,
          },
          // add FNSI-popupのパラメータ補正 徐 end
        ];

        // ヘッダータイトル(groupCd=2)
        settingData.headerTitle = MODAL_TITLE["除水量制限編集"];
      } else {
        return;
      }

      // モーダル表示
      this.showIndModal({
        dispComponentId: "ind-action-chart",
        settingIndData: settingData,
        settingIndChildData: settingChildData,
      });
    },
    /**
     * 曜日を英語表記に変換
     */
    changeWeekStr(num) {
      switch (num) {
        case 0:
          return "sunday";
        case 1:
          return "monday";
        case 2:
          return "tuesday";
        case 3:
          return "wednesday";
        case 4:
          return "thursday";
        case 5:
          return "friday";
        case 6:
          return "saturday";
        default:
          return null;
      }
    },
    showMeasureModal() {
      // 測定履歴モーダル表示
      this.showMeasureHistoryModal();
    },
    cancel() {
      // 編集後クリックキャンセ,未提示破棄popup画面
      // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
      // if ((this.initWeightValue != this.getMeasuredValue || this.getLastScaleValue != this.getSelectWheelchair.weight)===true) {
      if (this.isChanged) {
        // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
        this.$ons.notification.confirm({
          // title: "内容破棄",
          title: DIALOG_MESSAGES[13000004].title,
          // message: "編集内容が破棄されます。</br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
          callback: (answer) => {
            if (answer === 1) {
              this.isClicking = true;
              this.setMeasuredValue(0);
              this.isClick = false;
              this.$router.go(-1);
            }
          },
        });
      } else {
        // 前の画面に戻る
        this.setMeasuredValue(0);
        // // add FNSI-田中衡機の追加 徐 start
        this.isClick = false;
        // add FNSI-田中衡機の追加 徐 end
        this.$router.go(-1);
      }
    },
    sendWeight() {
      this.isClicking = true;
      const pat = this.selectedPat;
      this.setPatInfo({
        hospPatId: pat ? pat.pat_personal_main.hosp_pat_id : null,
        patName: pat
          ? `${pat.pat_personal_main.pat_last_name} ${pat.pat_personal_main.pat_first_name}`
          : null,
      });
      // add FNSI-外部連携APIの修正 徐 start
      this.sendConditionFlg = false;
      this.sendConditionAfterFlg = false;
      if (
        this.sendConditionButtonInfo.btnText === "送信" &&
        this.getScaleClass !== weightScaleClass.after
      ) {
        this.sendConditionFlg = true;
      }
      // add 10553 連携イベント発生部分不正 関 start
      if (this.sendConditionButtonInfo.btnText === "入室") {
        this.inOutFlag = true;
      }
      // add 10553 連携イベント発生部分不正 関 end
      if (this.getScaleClass === weightScaleClass.after) {
        this.sendConditionAfterFlg = true;
      }
      // add FNSI-外部連携APIの修正 徐 end
      // タイマーが動いている場合は停止させる
      clearTimeout(this.autoSendTimer);

      // 指示が外部で変更されていないかどうかチェック
      this.preSaveCheckDBChanged(0).then(
        /** @param {boolean} r*/
        async (r) => {
          if (r) {
            // 前体重測定時は条件確認済みのチェックをする
            if (
              (this.getScaleClass === weightScaleClass.before ||
                this.getScaleClass === weightScaleClass.noSchedule) && // 前体重測定時であること
              (this.getMachineStateError === machineSendable.patVerified ||
                this.getIsCurrentDialysisStateEqualDialysisState(
                  dialysisState.checkedSendCondition
                )) && // 装置、またはオーダーが条件確認済みであること
              !this.primaryOrderIsPurification.isPurification && // 特殊浄化治療でないこと
              this.getMachineState[0].isCommonComFormatProtocol !== "1" && // 医器工でないこと
              this.getMachineState[0].isOffline !== "1" // オフライン装置でないこと
            ) {
              this.$ons.notification.confirm({
                // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
                // title: "条件送信確認済み",
                title: DIALOG_MESSAGES[13000124].title,
                // message:
                //   "透析装置にて条件送信確認済みです。<br>" +
                //   "システムと透析装置で不整合が発生している場合を除き、透析装置で条件送信確認済みの場合この条件送信透析装置に送信されません。<br>" +
                //   "透析装置にて条件送信確認解除をしてから再度条件送信をしてください。<br>" +
                //   "条件送信しますか？",
                message: messageFormat(DIALOG_MESSAGES[13000124].message),
                // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
                callback: async (answer) => {
                  if (answer == 1) {
                    //OK
                    // ボタンに対応するアクションを実行
                    await this.sendConditionButtonInfo.func();
                    // add FNSI-外部連携APIの修正 徐 start
                    // this.insertCoopJournal();
                    if (this.sendConditionFlg || this.sendConditionAfterFlg) {
                      this.insertCoopJournal();
                    }
                    // add FNSI-外部連携APIの修正 徐 end
                  }
                  this.isClicking = false;
                },
              });
            }
            // mod 取得DWの形式が不適切を対応する。 dengshen start
            // else if(this.getIndDryWeight == -1 && this.getIndTargetWeight == this.getIndDryWeight){
            else if (
              this.getIndDryWeight.value == -1 &&
              this.getIndTargetWeight.value == this.getIndDryWeight.value
            ) {
              // mod 取得DWの形式が不適切を対応する。 dengshen end
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title:"DWが取得できませんでした。",
                // message:this.selectedPat.pat_unique+"の身体情報からDWの値が取得できませんでした"+this.getSelectedOrdNo.ordNo
                title: DIALOG_MESSAGES[12000325].title,
                // mod メッセージ不正を修正する。 dengshen start
                // message: messageFormat(DIALOG_MESSAGES[12000325].message, this.selectedPat.pat_unique, this.getSelectedOrdNo.ordNo)
                message: messageFormat(DIALOG_MESSAGES[12000325].message),
                // mod メッセージ不正を修正する。 dengshen end
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              });
            } else {
              // ボタンに対応するアクションを実行
              await this.sendConditionButtonInfo.func();
              // add FNSI-外部連携APIの修正 徐 start
              // this.insertCoopJournal();
              if (this.sendConditionFlg || this.sendConditionAfterFlg) {
                this.insertCoopJournal();
              }
              // add FNSI-外部連携APIの修正 徐 end
            }
          } else {
            /* modify by chamaojia 2024-12-20 [11387] 【たくしん会】前/後体重測定時に重量測定モードとなる　V1.0B --start */
            /**
             * reason for modification:
             * 1. #10054 the prompt information should not be deleted,
             *       so the content should be rolled back
             * 2. this.refresh() -> this.refresh(true)
             *       【refresh】 Method parameter true: No need to prompt 【破棄】 again
             */
            this.$ons.notification.confirm({
              title: DIALOG_MESSAGES[13000123].title,
              message: messageFormat(DIALOG_MESSAGES[13000123].message),
              callback: answer => {
                if (answer == 1) {
                  //OK
                  this.refresh(true);
                }
                this.isClicking = false;
              }
            });
            // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc start
            // this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "外部変更あり",
            // title: DIALOG_MESSAGES[13000123].title,
            // message: "治療情報の変更がありました。再取得します。",
            // message: messageFormat(DIALOG_MESSAGES[13000123].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            // callback: answer => {
            //   if (answer == 1) {
            //OK
            // this.refresh();
            // }
            // this.isClicking = false;
            // }
            // });
            // mod #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20231219 ztc end
            /* modify by chamaojia 2024-12-20 [11387] 【たくしん会】前/後体重測定時に重量測定モードとなる　V1.0B --end */
          }
        }
      );
      // add 10553 連携イベント発生部分不正 関 start
      if (this.inOutFlag) {
        this.createCoopJournal();
      }
      // add 10553 連携イベント発生部分不正 関 end
    },
    initialized() {
      // 初期化完了
      if (
        this.getPatScaleMode > 0 && // 重量測定モードではない
        this.getSelectedOrdNo !== undefined &&
        this.getSelectedOrdNo.ordNo === null
      ) {
        // スケジュール無し
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "スケジュール無し",
          // message: "スケジュールを割り当ててください"
          title: DIALOG_MESSAGES[12000224].title,
          message: messageFormat(DIALOG_MESSAGES[12000224].message),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
      } else {
        if (this.isNotSetKurBed.all) {
          // スケジュール無し
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "クール／ベッド未設定",
            // message: "クール／ベッドを割り当ててください"
            title: DIALOG_MESSAGES[12000225].title,
            message: messageFormat(DIALOG_MESSAGES[12000225].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        } else if (this.getPatDeviceSetWarnInfo.isWarn) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "TMP補液制御設定値エラー",
            title: DIALOG_MESSAGES["00300026"].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: this.getPatDeviceSetWarnInfo.msg,
          });
        }
      }
      if (
        this.getScaleClass === weightScaleClass.before ||
        this.getScaleClass === weightScaleClass.noSchedule
      ) {
        // 前体重
        this.isPrint =
          this.getWeightConfigInfo.isDefaultPrintBefore === FLG_TRUE;
      } else if (this.getScaleClass === weightScaleClass.after) {
        // 後体重
        this.isPrint =
          this.getWeightConfigInfo.isDefaultPrintAfter === FLG_TRUE;
      } else if (this.getScaleClass === weightScaleClass.dialysis) {
        // 治療中
        if (this.getWeightScaleConfigInfo.isDuringDialysisView === FLG_FALSE) {
          this.treatingViewMode = 1;
          this.setTreatingWheelScaleMode();
        } else {
          this.treatingViewMode = 0;
        }
      } else if (this.getScaleClass === weightScaleClass.pastDialysis) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // 実績確定後
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "治療済",
          // message: "過去の実績に対して体重測定はできません。"
          title: DIALOG_MESSAGES[12000226].title,
          message: messageFormat(DIALOG_MESSAGES[12000226].message),
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
        });
        this.$router.go(-1);
      }
      this.isShowMessageArea = true;
      //共通ローダー：表示終了
      this.setLoadingScreenVisible(false);
      this.setIsInitialized(true);

      // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
      //
      ////mod #12064 体重測定画面の重量測定モードで「お乗りください」の音声が流れる。 zrx start
      //// this.playAudio(this.getWeightAudioSetting).patOk();
      //if (this.getScaleClass !== weightScaleClass.scale) {
      //  this.playAudio(this.getWeightAudioSetting).patOk();
      //}
      if (this.getScaleClass !== weightScaleClass.scale && !this.getIsFromScaleBed) {
        this.playAudio(this.getWeightAudioSetting).patOk();
      }
      //mod #12064 体重測定画面の重量測定モードで「お乗りください」の音声が流れる。 zrx end
      // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end

      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    },
    async actionBeforeConfirm(func) {
      if (
        this.getPatScaleMode > 0 && // 重量測定モードではない
        this.getSelectedOrdNo !== undefined &&
        this.getSelectedOrdNo.ordNo === null
      ) {
        // スケジュール無し
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "スケジュール無し",
          title: DIALOG_MESSAGES[13000125].title,
          // message: "条件送信できません。<br>よろしいですか？",
          message: messageFormat(DIALOG_MESSAGES[13000125].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          callback: (answer) => {
            if (answer == 1) {
              //OK
              func();
            }
          },
        });
      } else {
        if (this.isNotSetKurBed.all) {
          return new Promise((resolve) => {
            // クールベッド未設定
            this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "クール・ベッド未設定",
              title: DIALOG_MESSAGES[13000126].title,
              // message: "条件送信できません。<br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000126].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
              callback: async (answer) => {
                if (answer == 1) {
                  //OK
                  await func();
                }
                resolve();
              },
            });
          });
        } else {
          await func();
        }
      }
    },
    // add FNSI-分類不一致判断の追加 徐 start
    callSendConditionOK(e) {
      if (e === 1) {
        this.setChkIndCondInfoFlg(true);
        this.diaView = false;
      } else if (e === 2) {
        this.setMstDelFlg(true);
        this.mstDelDiaView = false;
      } else if (e === 3) {
        this.setMstOverdueFlg(true);
        this.mstOverdueDiaView = false;
      }
      this.callSendCondition(0);
    },
    // add FNSI-分類不一致判断の追加 徐 end
    /**
     * 条件送信
     * @param {number} idx 指示インデックス
     */
    async callSendCondition(idx = 0) {
      // mod FNSI-5622 バッチ操作インターフェイスを追加します 查 start
      // add FNSI-分類不一致判断の追加 徐 start
      //upd by ztc 2023-04-23 #8603 タスクで検出された追加の既存の問題の解決 bug --start /
      const settingNos = [
        CHK_INDCONDINFO_FLG,
        CHK_MSGDEL_FLG,
        CHK_MSGOVERDUE_FLG,
      ];
      await getMstFacilitySettingValueMap(this.facilityCd, settingNos)
        .then((response) => {
          if (response.data[CHK_INDCONDINFO_FLG]) {
            this.buttonConfig = response.data[CHK_INDCONDINFO_FLG];
          } else {
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
            // this.buttonConfig = 0;
            this.buttonConfig = "0";
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
          }

          if (response.data[CHK_MSGDEL_FLG]) {
            this.mstDelConfig = response.data[CHK_MSGDEL_FLG];
          } else {
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
            // this.mstDelConfig = 0;
            this.mstDelConfig = "0";
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
          }

          if (response.data[CHK_MSGOVERDUE_FLG]) {
            this.mstOverdueConfig = response.data[CHK_MSGOVERDUE_FLG];
          } else {
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
            // this.mstOverdueConfig = 0;
            this.mstOverdueConfig = "0";
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
          }
        })
        //upd by ztc 2023-04-23 #8603 タスクで検出された追加の既存の問題の解決 bug --end /
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "callSendCondition",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen start
            // this.buttonConfig = 0;
            // this.mstDelConfig = 0;
            // this.mstOverdueConfig = 0;
            this.buttonConfig = "0";
            this.mstDelConfig = "0";
            this.mstOverdueConfig = "0";
            // mod #9357 施設設定マスタNo118,No119で条件送信可にしても条件送信ができない dengshen end
          }
        });
      // add FNSI-分類不一致判断の追加 徐 end

      /*// add FNSI-分類不一致判断の追加 徐 start
      await getMstFacilitySettingValue(this.facilityCd, CHK_INDCONDINFO_FLG)
        .then((response) => {
          if (response.data) {
            this.buttonConfig = response.data;
          } else {
            this.buttonConfig = 0;
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('SendConditionMainComponent.vue', 'callSendCondition', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.buttonConfig = 0;
          }
        });

      await getMstFacilitySettingValue(this.facilityCd, CHK_MSGDEL_FLG)
        .then((response) => {
          if (response.data) {
            this.mstDelConfig = response.data;
          } else {
            this.mstDelConfig = 0;
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('SendConditionMainComponent.vue', 'callSendCondition', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.mstDelConfig = 0;
          }
        });

        await getMstFacilitySettingValue(this.facilityCd, CHK_MSGOVERDUE_FLG)
        .then((response) => {
          if (response.data) {
            this.mstOverdueConfig = response.data;
          } else {
            this.mstOverdueConfig = 0;
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('SendConditionMainComponent.vue', 'callSendCondition', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.mstOverdueConfig = 0;
          }
        });
      // add FNSI-分類不一致判断の追加 徐 end*/
      // mod FNSI-5622 バッチ操作インターフェイスを追加します 查 end
      let category = weightScaleMode.weight;
      if (this.isNotSetKurBed.individual[idx]) {
        // クールベッド未設定ならば体重保存のみ
        category = -1;
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      await this.sendCondition({
        ordIndex: idx,
        facilityCd: this.facilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getWeightConfigInfo,
        category: category,
        isPrint: this.isPrint ? FLG_TRUE : FLG_FALSE,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 start
        isScaleBed: this.getIsFromScaleBed,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 end
      })
        .then(async (r) => {
          // 条件送信成功
          this.setBaseOrdWeightNo(null);
          this.setSendConditionResponseCd(r.data.weightScaleNo);
          if (this.isPrint) {
            // 印刷
            this.sendPrintOrder({
              weightScaleNo: r.data.printWeightScaleNo,
              facilityCd: this.facilityCd,
              weightNo: this.getWeightConfigInfo.weightNo,
            })
              .then()
              .catch((error) => {
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                getErrorMessage(
                  "SendConditionMainComponent.vue",
                  "callSendCondition",
                  error
                );
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                // #10833 2024.08.22 add 画面遷移処理を印刷指示応答後に行うようにする TDC米沢 start
              })
              .finally(async () => {
                // 最初の指示で次の指示がない場合、または2回目の指示の場合
                if (
                  (idx === 0 && this.getSelectedOrdNo.ordNo2 === null) ||
                  idx === 1
                ) {
                  // 指示成功による音声通知、前の画面に戻る
                  this.delayGoBack();
                  // 共通ローダー:表示終了
                  this.setLoadingScreenVisible(false);
                }
                // #10833 2024.08.22 add 画面遷移処理を印刷指示応答後に行うようにする TDC米沢 end
              });
          }
          // #10833 2024.08.22 mod 次の指示がある場合は印刷指示後に即時実施する TDC米沢 start
          // if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
          //   // 次の指示がある
          //   this.callSendCondition(1);
          // } else {
          //   this.delayGoBack();
          // }
          // // 共通ローダー:表示終了
          // this.setLoadingScreenVisible(false);

          // 最初の指示で次の指示がある場合
          if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
            // 次の指示がある
            this.callSendCondition(1);
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
          } else if (!this.isPrint) {
            // 印刷がない場合
            // 指示成功による音声通知、前の画面に戻る
            this.delayGoBack();
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
          }
          // #10833 2024.08.22 mod 次の指示がある場合は印刷指示後に即時実施する TDC米沢 end
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "callSendCondition",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            // add FNSI-分類不一致判断の追加 徐 start
            // if (error.response.data && error.response.data.errorMessage) {
            //   msg = error.response.data.errorMessage;
            // }
            // this.$ons.notification.alert({
            //   title: "条件送信に失敗しました。",
            //   message: msg
            // });
            // if (this.isPrint) {
            //   // 印刷
            //   this.sendPrintOrder({
            //     weightScaleNo: error.response.data.printWeightScaleNo,
            //     facilityCd: this.facilityCd,
            //     weightNo: this.getWeightConfigInfo.weightNo
            //   })
            //     .then()
            //     .catch();
            // }
            if (error.response.data && error.response.data.errorMessage) {
              let msg = "";
              msg = error.response.data.errorMessage;
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "治療条件異常",
                title: DIALOG_MESSAGES["00300027"].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen start
            // マスタ削除特殊MsgList
            // if (error.response.data.mstDelSpecialMsgList !== null && error.response.data.mstDelSpecialMsgList.length > 0) {
            //   this.mstDelConfig = 0;
            //   this.mstDelMsgList = error.response.data.mstDelSpecialMsgList;
            //   this.mstDelDiaView = true;
            // } else {
            //   this.mstDelDiaView = false;
            // }
            // del #9356 体重測定画面への遷移時と送信ボタン押下時のポップアップ内容の相違 dengshen end

            // マスタ削除
            if (
              error.response.data.mstDelFlgMsgList !== null &&
              error.response.data.mstDelFlgMsgList.length > 0
            ) {
              this.mstDelMsgList = error.response.data.mstDelFlgMsgList;
              let buttonElem = document.getElementsByClassName(
                "alert-dialog-button"
              );
              for (let i = 0; i < buttonElem.length; i++) {
                if (buttonElem[i].classList.length < 3) {
                  buttonElem[i]?.classList?.add(
                    "alert-dialog-button--rowfooter"
                  );
                  buttonElem[i]?.classList?.add(
                    "alert-dialog-button--rowfooter--rowfooter"
                  );
                }
              }
              this.mstDelDiaView = true;
            } else if (!this.mstDelDiaView) {
              this.mstDelDiaView = false;
            }
            // マスタ期限切れMsgList
            if (
              error.response.data.mstOverdueMsgList !== null &&
              error.response.data.mstOverdueMsgList.length > 0
            ) {
              this.mstOverdueMsgList = error.response.data.mstOverdueMsgList;
              let buttonElem = document.getElementsByClassName(
                "alert-dialog-button"
              );
              for (let i = 0; i < buttonElem.length; i++) {
                if (buttonElem[i].classList.length < 3) {
                  buttonElem[i]?.classList?.add(
                    "alert-dialog-button--rowfooter"
                  );
                  buttonElem[i]?.classList?.add(
                    "alert-dialog-button--rowfooter--rowfooter"
                  );
                }
              }
              this.mstOverdueDiaView = true;
            } else {
              this.mstOverdueDiaView = false;
            }
            // 治療条件分類不一致
            if (
              error.response.data.errorMessagelist !== null &&
              error.response.data.errorMessagelist.length > 0
            ) {
              this.recordList = error.response.data.errorMessagelist;
              let buttonElem = document.getElementsByClassName(
                "alert-dialog-button"
              );
              for (let i = 0; i < buttonElem.length; i++) {
                if (buttonElem[i].classList.length < 3) {
                  buttonElem[i]?.classList?.add(
                    "alert-dialog-button--rowfooter"
                  );
                  buttonElem[i]?.classList?.add(
                    "alert-dialog-button--rowfooter--rowfooter"
                  );
                }
              }
              this.diaView = true;
            } else {
              this.diaView = false;
            }
            // 治療条件未登録
            if (
              error.response.data.indCondInfoNoLoginMsgList &&
              error.response.data.indCondInfoNoLoginMsgList.length > 0
            ) {
              this.disableSendBtnFlg = true;
              let msg = "";
              for (
                let i = 0;
                i < error.response.data.indCondInfoNoLoginMsgList.length;
                i++
              ) {
                if (
                  i ===
                  error.response.data.indCondInfoNoLoginMsgList.length - 1
                ) {
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // msg = msg + error.response.data.indCondInfoNoLoginMsgList[i] + "が未登録のため条件送信できません。指示を変更してください。";
                  msg =
                    msg +
                    error.response.data.indCondInfoNoLoginMsgList[i] +
                    DIALOG_MESSAGES[12000218].message;
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                } else {
                  msg =
                    msg +
                    error.response.data.indCondInfoNoLoginMsgList[i] +
                    "、";
                }
              }
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "治療条件未登録",
                title: DIALOG_MESSAGES[12000218].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // 治療条件上限
            if (
              error.response.data.indCondInfoTopLimitMsgList &&
              error.response.data.indCondInfoTopLimitMsgList.length > 0
            ) {
              this.disableSendBtnFlg = true;
              let msg = "";
              for (
                let i = 0;
                i < error.response.data.indCondInfoTopLimitMsgList.length;
                i++
              ) {
                if (
                  i ===
                  error.response.data.indCondInfoTopLimitMsgList.length - 1
                ) {
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // msg = msg + error.response.data.indCondInfoTopLimitMsgList[i] + "が上限を超えているため条件送信できません。治療条件または装置設定を変更してください。";
                  msg =
                    msg +
                    error.response.data.indCondInfoTopLimitMsgList[i] +
                    DIALOG_MESSAGES[12000219].message;
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                } else {
                  msg =
                    msg +
                    error.response.data.indCondInfoTopLimitMsgList[i] +
                    "、";
                }
              }
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "治療条件上限",
                title: DIALOG_MESSAGES[12000219].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // 治療条件下限
            if (
              error.response.data.indCondInfoLowerLimitMsgList &&
              error.response.data.indCondInfoLowerLimitMsgList.length > 0
            ) {
              this.disableSendBtnFlg = true;
              let msg = "";
              for (
                let i = 0;
                i < error.response.data.indCondInfoLowerLimitMsgList.length;
                i++
              ) {
                if (
                  i ===
                  error.response.data.indCondInfoLowerLimitMsgList.length - 1
                ) {
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // msg = msg + error.response.data.indCondInfoLowerLimitMsgList[i] + "が下限を下回っているため条件送信できません。治療条件または装置設定を変更してください。";
                  msg =
                    msg +
                    error.response.data.indCondInfoLowerLimitMsgList[i] +
                    DIALOG_MESSAGES[12000220].message;
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                } else {
                  msg =
                    msg +
                    error.response.data.indCondInfoLowerLimitMsgList[i] +
                    "、";
                }
              }
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "治療条件下限",
                title: DIALOG_MESSAGES[12000220].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // I-HDF治療条件不整合
            if (
              error.response.data.indCondInfoUseIHDFMsgList &&
              error.response.data.indCondInfoUseIHDFMsgList.length > 0
            ) {
              this.disableSendBtnFlg = true;
              let msg = "";
              for (
                let i = 0;
                i < error.response.data.indCondInfoUseIHDFMsgList.length;
                i++
              ) {
                if (
                  i ===
                  error.response.data.indCondInfoUseIHDFMsgList.length - 1
                ) {
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // msg = "I-HDF治療では、" + msg + error.response.data.indCondInfoUseIHDFMsgList[i] + "を使用できません。治療条件または装置設定を変更してください。";
                  msg = messageFormat(
                    DIALOG_MESSAGES[12000221].message,
                    msg + error.response.data.indCondInfoUseIHDFMsgList[i]
                  );
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                } else {
                  msg =
                    msg +
                    error.response.data.indCondInfoUseIHDFMsgList[i] +
                    "、";
                }
              }
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "I-HDF治療条件不整合",
                title: DIALOG_MESSAGES[12000221].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // AFBF治療条件不整合
            if (
              error.response.data.indCondInfoUseAFBFMsgList &&
              error.response.data.indCondInfoUseAFBFMsgList.length > 0
            ) {
              this.disableSendBtnFlg = true;
              let msg = "";
              for (
                let i = 0;
                i < error.response.data.indCondInfoUseAFBFMsgList.length;
                i++
              ) {
                if (
                  i ===
                  error.response.data.indCondInfoUseAFBFMsgList.length - 1
                ) {
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // msg = "AFBF治療では、" + msg + error.response.data.indCondInfoUseAFBFMsgList[i] + "を使用できません。治療条件または装置設定を変更してください。";
                  msg = messageFormat(
                    DIALOG_MESSAGES[12000222].message,
                    msg + error.response.data.indCondInfoUseAFBFMsgList[i]
                  );
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                } else {
                  msg =
                    msg +
                    error.response.data.indCondInfoUseAFBFMsgList[i] +
                    "、";
                }
              }
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "AFBF治療条件不整合",
                title: DIALOG_MESSAGES[12000222].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // SN治療条件不整合
            if (
              error.response.data.indCondInfoUseSNMsgList &&
              error.response.data.indCondInfoUseSNMsgList.length > 0
            ) {
              this.disableSendBtnFlg = true;
              let msg = "";
              for (
                let i = 0;
                i < error.response.data.indCondInfoUseSNMsgList.length;
                i++
              ) {
                if (
                  i ===
                  error.response.data.indCondInfoUseSNMsgList.length - 1
                ) {
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                  // msg = "シングルニードルを使用する場合、" + msg + error.response.data.indCondInfoUseSNMsgList[i] + "は使用できません。治療条件または装置設定を変更してください。";
                  msg = messageFormat(
                    DIALOG_MESSAGES[12000223].message,
                    msg + error.response.data.indCondInfoUseSNMsgList[i]
                  );
                  // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                } else {
                  msg =
                    msg + error.response.data.indCondInfoUseSNMsgList[i] + "、";
                }
              }
              this.$ons.notification.alert({
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // title: "SN治療条件不整合",
                title: DIALOG_MESSAGES[12000223].title,
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                message: msg,
              });
            }
            // del 9728 サーマルプリンタからの印刷が実施されない　吉 start
            // if (this.isPrint) {
            //   // 印刷
            //   this.sendPrintOrder({
            //     weightScaleNo: error.response.data.printWeightScaleNo,
            //     facilityCd: this.facilityCd,
            //     weightNo: this.getWeightConfigInfo.weightNo
            //   }).then().catch();
            // }
            // del 9728 サーマルプリンタからの印刷が実施されない　吉 end
            // add FNSI-分類不一致判断の追加 徐 end
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
          //this.playAudio(this.getWeightAudioSetting).sendNg();
          if (!this.getIsFromScaleBed) {
            this.playAudio(this.getWeightAudioSetting).sendNg();
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end

          this.isClicking = false;
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        });
    },
    // 体重＋車いす一時保存
    callSaveWeightAndChair(idx = 0) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.sendCondition({
        ordIndex: idx,
        facilityCd: this.facilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getWeightConfigInfo,
        category: weightScaleMode.weightAndChair,
        isPrint: FLG_FALSE,
      })
        .then(() => {
          // 保存成功
          this.setBaseOrdWeightNo(null);
          if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
            // 次の指示がある
            this.callSaveWeightAndChair(1);
          } else {
            this.delayGoBack();
          }
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "callSaveWeightAndChair",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "測定値保存に失敗しました。",
              title: DIALOG_MESSAGES["00300028"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
          //this.playAudio(this.getWeightAudioSetting).sendNg();
          if (!this.getIsFromScaleBed) {
            this.playAudio(this.getWeightAudioSetting).sendNg();
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
          this.isClicking = false;
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        });
    },
    // 車いす一時保存
    callSaveChair(idx = 0) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.sendCondition({
        ordIndex: idx,
        facilityCd: this.facilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getWeightConfigInfo,
        category: weightScaleMode.wheelChair,
        isPrint: FLG_FALSE,
      })
        .then(() => {
          // 保存成功
          this.setBaseOrdWeightNo(null);
          if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
            // 次の指示がある
            this.callSaveChair(1);
          } else {
            this.delayGoBack();
          }
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "callSaveChair",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "車いす値保存に失敗しました。",
              title: DIALOG_MESSAGES["00300029"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
          //this.playAudio(this.getWeightAudioSetting).sendNg();
          if (!this.getIsFromScaleBed) {
            this.playAudio(this.getWeightAudioSetting).sendNg();
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
          this.isClicking = false;
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        });
    },
    callSendAfterWeightWithRstChange() {
      // 確認メッセージ表示
      this.$ons.notification
        .confirm({
          title: "設定変更",
          message: "除水補正を変更します",
          buttonLabels: ["キャンセル", "実績のみ変更", "指示と実績を変更"],
        })
        .then((answer) => {
          if (answer > 0) {
            // 実績のみ変更または指示と実績を変更
            // 除水補正登録方法セット
            this.setOffWaterRegFlg(answer).then(() => {
              // 後体重送信
              this.callSendAfterWeight();
            });
          } else {
            this.isClicking = false;
          }
        });
    },
    // 後体重保存
    callSendAfterWeight(idx = 0) {
      let category = weightScaleMode.weight;
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.sendAfterWeight({
        ordIndex: idx,
        facilityCd: this.facilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getWeightConfigInfo,
        category: category,
        isPrint: this.isPrint ? FLG_TRUE : FLG_FALSE,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 start
        isScaleBed: this.getIsFromScaleBed,
        // #11987 2026.02.11 add スケールベッド状態書込み用のベッド番号を追加 TDC片口 end
      })
        .then((r) => {
          // 後体重送信成功
          this.setBaseOrdWeightNo(null);
          if (this.isPrint) {
            // 印刷
            this.sendPrintOrder({
              weightScaleNo: r.data.printWeightScaleNo,
              facilityCd: this.facilityCd,
              weightNo: this.getWeightConfigInfo.weightNo,
            })
              .then()
              // #10833 2024.08.22 add 画面遷移処理を印刷指示応答後に行うようにする TDC米沢 start
              // .catch();
              .catch()
              .finally(async () => {
                // 最初の指示で次の指示がない場合、または2回目の指示の場合
                if (
                  (idx === 0 && this.getSelectedOrdNo.ordNo2 === null) ||
                  idx === 1
                ) {
                  // 指示成功による音声通知、前の画面に戻る
                  this.delayGoBack();
                  // 共通ローダー:表示終了
                  this.setLoadingScreenVisible(false);
                }
              });
            // #10833 2024.08.22 add 画面遷移処理を印刷指示応答後に行うようにする TDC米沢 end
          }

          // #10833 2024.08.22 mod 次の指示がある場合は印刷指示後に即時実施する TDC米沢 start
          // if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
          //   // 次の指示がある
          //   this.callSendAfterWeight(1);
          // } else {
          //   this.delayGoBack();
          // }
          // // 共通ローダー:表示終了
          // this.setLoadingScreenVisible(false);

          // 最初の指示で次の指示がある場合
          if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
            // 次の指示がある
            this.callSendAfterWeight(1);
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
          } else if (!this.isPrint) {
            // 印刷がない場合
            // 指示成功による音声通知、前の画面に戻る
            this.delayGoBack();
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
          }
          // #10833 2024.08.22 mod 次の指示がある場合は印刷指示後に即時実施する TDC米沢 end
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "callSendAfterWeight",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "後体重送信に失敗しました。",
              title: DIALOG_MESSAGES["00300032"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
            if (this.isPrint) {
              // 印刷
              this.sendPrintOrder({
                weightScaleNo: error.response.data.printWeightScaleNo,
                facilityCd: this.facilityCd,
                weightNo: this.getWeightConfigInfo.weightNo,
              })
                .then()
                .catch((error) => {
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                  getErrorMessage(
                    "SendConditionMainComponent.vue",
                    "callSendAfterWeight",
                    error
                  );
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                });
            }
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
          //this.playAudio(this.getWeightAudioSetting).sendNg();
          if (!this.getIsFromScaleBed) {
            this.playAudio(this.getWeightAudioSetting).sendNg();
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
          this.isClicking = false;
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        });
    },
    // 体重測定
    callSaveWeight(idx = 0) {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.sendCondition({
        ordIndex: idx,
        facilityCd: this.facilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getWeightConfigInfo,
        category: -1,
        isPrint: this.isPrint ? FLG_TRUE : FLG_FALSE,
      })
        .then((r) => {
          // 保存成功
          this.setBaseOrdWeightNo(null);
          if (this.isPrint) {
            // 印刷
            this.sendPrintOrder({
              weightScaleNo: r.data.printWeightScaleNo,
              facilityCd: this.facilityCd,
              weightNo: this.getWeightConfigInfo.weightNo,
            })
              .then()
              .catch((error) => {
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                getErrorMessage(
                  "SendConditionMainComponent.vue",
                  "callSaveWeight",
                  error
                );
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                // #10833 2024.08.22 add 画面遷移処理を印刷指示応答後に行うようにする TDC米沢 start
              })
              .finally(async () => {
                // 最初の指示で次の指示がない場合、または2回目の指示の場合
                if (
                  (idx === 0 && this.getSelectedOrdNo.ordNo2 === null) ||
                  idx === 1
                ) {
                  // 指示成功による音声通知、前の画面に戻る
                  this.delayGoBack();
                  // 共通ローダー:表示終了
                  this.setLoadingScreenVisible(false);
                }
                // #10833 2024.08.22 add 画面遷移処理を印刷指示応答後に行うようにする TDC米沢 end
              });
          }
          // #10833 2024.08.22 mod 次の指示がある場合は印刷指示後に即時実施する TDC米沢 start
          // if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
          //   // 次の指示がある
          //   this.callSaveWeight(1);
          // } else {
          //   this.delayGoBack();
          // }
          // // 共通ローダー:表示終了
          // this.setLoadingScreenVisible(false);

          // 最初の指示で次の指示がある場合
          if (idx === 0 && this.getSelectedOrdNo.ordNo2 !== null) {
            // 次の指示がある場合
            this.callSaveWeight(1);
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
          } else if (!this.isPrint) {
            // 印刷がない場合
            // 指示成功による音声通知、前の画面に戻る
            this.delayGoBack();
            // 共通ローダー:表示終了
            this.setLoadingScreenVisible(false);
          }
          // #10833 2024.08.22 mod 次の指示がある場合は印刷指示後に即時実施する TDC米沢 end
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "callSaveWeight",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "体重保存に失敗しました。",
              title: DIALOG_MESSAGES["00300031"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
            if (this.isPrint) {
              // 印刷
              this.sendPrintOrder({
                weightScaleNo: error.response.data.printWeightScaleNo,
                facilityCd: this.facilityCd,
                weightNo: this.getWeightConfigInfo.weightNo,
              })
                .then()
                .catch((error) => {
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                  getErrorMessage(
                    "SendConditionMainComponent.vue",
                    "callSaveWeight",
                    error
                  );
                  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                });
            }
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
          //this.playAudio(this.getWeightAudioSetting).sendNg();
          if (!this.getIsFromScaleBed) {
            this.playAudio(this.getWeightAudioSetting).sendNg();
          }
          // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
          this.isClicking = false;
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        });
    },
    // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
    // 2回測定チェック用前回データクリア処理
    callClearDoubleCheckPastValue() {
      this.$nextTick(() => {
        // 2回測定チェック用前回測定値をクリア
        this.clearDoubleCheckPastValues();
      });
    },
    // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 end

    // 測定モード手動変更
    onSegmentClick(idx) {

    if (
        idx === weightScaleMode.weight &&
        this.getLastScaleMode === weightScaleMode.weight &&
        this.getLastScaleValue !== null
      ) {
        // 測定モード読み直し 体重モード遷移時
        if (
          // #12236 体重測定の動作不正 linjunfeng start
          // Number(this.getLastScaleValue).toFixed(2) !== this.getMeasuredValue
          this.getLastScaleValue != this.getMeasuredValue
          // #12236 体重測定の動作不正 linjunfeng end
        ) {
          // 前回測定値と測定値が異なる場合、読み直す
          // 確認メッセージ表示
          this.$ons.notification
            .confirm({
              title: "測定モード変更",
              message: "前回測定した値をセットします",
              buttonLabels: ["キャンセル", "変更"],
            })
            .then((answer) => {
              if (answer === 0) {
                // キャンセル
                this.isClick = false;
                this.setScaleMode(idx);
              } else {
                // 変更
                this.setMeasuredValue(this.getLastScaleValue);
                this.isClick = false;
                this.setIsHasOrdWeightScale(true);
                this.setSelectWheelChair(null);
                this.setScaleMode(idx);
              }

              // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
              // 2回測定チェック用前回測定値をクリア
              this.callClearDoubleCheckPastValue();
              // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
            });
        } else {
          // 前回測定値と測定値が同じ場合、読み直しを行わず変更
          this.isClick = false;
          this.setScaleMode(idx);
        }
      } else if (
        idx === weightScaleMode.weightAndChair &&
        (this.getLastScaleMode === weightScaleMode.weightAndChair ||
          this.getLastScaleMode === weightScaleMode.wheelChair)
      ) {
        // 測定モード読み直し 体重＋車いすモード遷移時
        // 前回の測定モードが体重モードのときも読み直しを行う
        const wheelChairValueKg =
          this.getLastWheelChairValue === null ||
          this.getLastWheelChairValue === 0
            ? null
            : this.getLastWheelChairValue / 1000;
        if (
          // #12236 体重測定の動作不正 linjunfeng start
          // Number(this.getLastScaleValue).toFixed(2) !== this.getMeasuredValue
          this.getLastScaleValue != this.getMeasuredValue
          // #12236 体重測定の動作不正 linjunfeng end
        ) {
          // 前回測定値と測定値が異なる場合、読み直す
          // 確認メッセージ表示
          this.$ons.notification
            .confirm({
              title: "測定モード変更",
              message: "前回測定した値をセットします",
              buttonLabels: ["キャンセル", "変更"],
            })
            .then((answer) => {
              if (answer === 0) {
                // キャンセル
                this.isClick = false;
                this.setScaleMode(idx);
              } else {
                // 変更
                this.setMeasuredValue(this.getLastScaleValue);
                this.isClick = false;
                this.setIsHasOrdWeightScale(true);
                this.setSelectWheelChair(this.getLastWheelChairCd);
                this.changeWheelChairWeightValue(wheelChairValueKg);
                this.setScaleMode(idx);
              }

              // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
              // 2回測定チェック用前回測定値をクリア
              this.callClearDoubleCheckPastValue();
              // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
            });
        } else {
          // 前回測定値と測定値が同じ場合、読み直しを行わず変更
          this.isClick = false;
          this.setScaleMode(idx);
        }
      } else if (
        idx === weightScaleMode.wheelChair &&
        (this.getLastScaleMode === weightScaleMode.weightAndChair ||
          this.getLastScaleMode === weightScaleMode.wheelChair)
      ) {
        // 測定モード読み直し 車いすモード遷移時
        // 前回の測定モードが体重＋車いすモードのときも読み直しを行う
        const wheelChairValueKg =
          this.getLastWheelChairValue === null ||
          this.getLastWheelChairValue === 0
            ? 0
            : this.getLastWheelChairValue / 1000;
        // 前回測定値と測定値が異なる場合、読み直す
        // 確認メッセージ表示
        this.$ons.notification
          .confirm({
            title: "測定モード変更",
            message: "前回測定した値をセットします",
            buttonLabels: ["キャンセル", "変更"],
          })
          .then((answer) => {
            if (answer === 0) {
              // キャンセル
              this.isClick = false;
              this.setScaleMode(idx);
              // #12236 体重測定の動作不正 linjunfeng start
              if (this.getMeasuredValue == 0) {
                this.setMeasuredValue(null);
              }
              // #12236 体重測定の動作不正 linjunfeng end
            } else {
              // 変更
              const measuredValue =
                this.getLastScaleValue === 0 ? null : this.getLastScaleValue;
              this.setMeasuredValue(measuredValue);
              this.isClick = false;
              this.setIsHasOrdWeightScale(true);
              // 個人車いすがあっても反映しない
              if (this.getIsUsePatWheelChair === true) {
                this.setSelectWheelChair(null);
                this.changeWheelChairWeightValue(null);
              } else {
                this.setSelectWheelChair(this.getLastWheelChairCd);
                this.changeWheelChairWeightValue(wheelChairValueKg);
              }
              this.setScaleMode(idx);
            }

            // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
            // 2回測定チェック用前回測定値をクリア
            this.callClearDoubleCheckPastValue();
            // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
          });
      } else if (
        this.getMeasuredValue > 0 ||
        this.getIsHasOrdWeightScale ||
        this.getSelectWheelchair.code !== null
      ) {
        // 測定モード初期化(測定値あり or 体重値測定済み or 車いす選択済み)
        // 確認メッセージ表示
        this.$ons.notification
          .confirm({
            title: "測定モード変更",
            message: "測定した値は初期化されます",
            buttonLabels: ["キャンセル", "変更"],
          })
          .then((answer) => {
            if (answer === 0) {
              // キャンセル
              this.isClick = false;
              this.setScaleMode(idx);
              // add #12236 体重測定の動作不正 linjunfeng start
              this.setIsHasOrdWeightScale(true);
              // add #12236 体重測定の動作不正 linjunfeng end
            } else {
              // 変更
              // #12236 体重測定の動作不正 linjunfeng start
              // this.setMeasuredValue(0);
              if (idx === weightScaleMode.wheelChair) {
                this.setMeasuredValue(null);
              } else {
                this.setMeasuredValue(0);
              }
              // #12236 体重測定の動作不正 linjunfeng end
              // add FNSI-田中衡機の追加 徐 start
              this.isClick = false;
              // add FNSI-田中衡機の追加 徐 end
              this.resetIsHasOrdWeightScale();
              this.setSelectWheelChair(null);
              this.setScaleMode(idx);
            }

            // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
            // 2回測定チェック用前回測定値をクリア
            this.callClearDoubleCheckPastValue();
            // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
          });
      } else {
        // 変更
        // #12236 体重測定の動作不正 linjunfeng start
        // this.setMeasuredValue(0);
        if (idx === weightScaleMode.wheelChair) {
          this.setMeasuredValue(null);
        } else {
          this.setMeasuredValue(0);
        }
        // #12236 体重測定の動作不正 linjunfeng end
        // add FNSI-田中衡機の追加 徐 start
        this.isClick = false;
        // add FNSI-田中衡機の追加 徐 end
        this.resetIsHasOrdWeightScale();
        this.setSelectWheelChair(null);
        this.setScaleMode(idx);
      }

      // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
      // 2回測定チェック用前回測定値をクリア
      this.callClearDoubleCheckPastValue();
      // #10463 2024.06.13 add 測定モードが変わった場合に2回測定チェック用前回測定値をクリアする TDC米沢 start
    },
    // 測定値受信
    onReceiveMeasureValue(value) {
      // add FNSI-田中衡機の追加 徐 start
      if (this.deviceFlg) {
        let indexItemList = String(value).split(",");
        this.newItemList = [];
        indexItemList.forEach((item) => {
          let list = {
            name: item,
            isChecked: false,
          };
          this.itemListSort.push(list);
          this.newItemList.push(list);
        });

        this.itemListSort = this.itemListSort.sort(function (a, b) {
          return a.name - b.name;
        });
        let paramList = [];
        paramList = this.itemList;
        this.itemList = [];

        for (let k = 0; k < paramList.length; k++) {
          let indexList = {
            name: paramList[k].name,
            isChecked: false,
          };
          this.itemList.push(indexList);
        }

        for (let j = 0; j < this.newItemList.length; j++) {
          let indexList = {
            name: this.newItemList[j].name,
            isChecked: false,
          };
          this.itemList.push(indexList);
        }

        for (let a = 0; a < this.itemList.length; a++) {
          for (let b = this.itemList.length - 1; b > a; b--) {
            if (this.itemList[a].name === this.itemList[b].name) {
              this.itemList.splice(b, 1);
            }
          }
        }

        if (
          String(this.getWeightConfigInfo.dataSelectType) === "0" &&
          !this.isClick
        ) {
          value = this.newItemList[0].name;
          for (let i = 0; i < this.itemList.length; i++) {
            if (this.itemList[i].name === value) {
              this.itemList[i].isChecked = true;
              break;
            }
          }
        } else if (
          String(this.getWeightConfigInfo.dataSelectType) === "1" &&
          !this.isClick
        ) {
          value = this.itemListSort[0].name;
          for (let i = 0; i < this.itemList.length; i++) {
            if (this.itemList[i].name === value) {
              this.itemList[i].isChecked = true;
              break;
            }
          }
        } else if (
          String(this.getWeightConfigInfo.dataSelectType) === "2" &&
          !this.isClick
        ) {
          value = this.itemListSort[this.itemListSort.length - 1].name;
          for (let i = 0; i < this.itemList.length; i++) {
            if (this.itemList[i].name === value) {
              this.itemList[i].isChecked = true;
              break;
            }
          }
        } else {
          if (this.getScaleMode === weightScaleMode.wheelChair) {
            value = this.getSelectWheelChair.weight;
          } else {
            value = this.getMeasuredValue;
          }
          for (let i = 0; i < this.itemList.length; i++) {
            if (this.itemList[i].name === value) {
              this.itemList[i].isChecked = true;
              break;
            }
          }
        }
      }
      // add FNSI-田中衡機の追加 徐 end
      // 測定値受信
      if (this.getScaleMode === weightScaleMode.wheelChair) {
        this.changeWheelChairWeightValue(value);
      } else {
        this.setMeasuredValue(value);
      }
      this.calcWeightValue();

      // 測定記録保存
      this.saveMeasure({
        facilityCd: this.facilityCd,
        userId: this.getStateUserAccountInfo.userId,
        weightInfo: this.getSelectedMstWeight,
        category: this.getScaleMode,
        isPrint: FLG_FALSE,
      })
        .then((r) => {
          // 保存成功
          this.setBaseOrdWeightNo(r.data.weightScaleNo);
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage(
            "SendConditionMainComponent.vue",
            "onReceiveMeasureValue",
            error
          );
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          if (error.response.status === 400) {
            // 記録に失敗
          }
        });

      // 自動送信
      if (
        (this.getScaleClass === weightScaleClass.before ||
          this.getScaleClass === weightScaleClass.noSchedule) &&
        this.getWeightConfigInfo.isAutoSendBefore === FLG_TRUE
      ) {
        // 前体重
        const timeout =
          this.getWeightConfigInfo.waitAutoSendBefore > 0
            ? this.getWeightConfigInfo.waitAutoSendBefore * 1000
            : 500;
        this.autoSendTimer = setTimeout(() => {
          if (!this.disableSendBtn) {
            this.sendWeight();
          }
        }, timeout);
      } else if (
        (this.getScaleClass === weightScaleClass.after ||
          this.getScaleClass === weightScaleClass.dialysis) &&
        this.getWeightConfigInfo.isAutoSendAfter === FLG_TRUE
      ) {
        // 後体重
        const timeout =
          this.getWeightConfigInfo.waitAutoSendAfter > 0
            ? this.getWeightConfigInfo.waitAutoSendAfter * 1000
            : 500;
        this.autoSendTimer = setTimeout(() => {
          if (!this.disableSendBtn) {
            this.sendWeight();
          }
        }, timeout);
      }
    },
    setTreatingWheelScaleMode() {
      // 後体重用車いす測定
      // add FNSI-田中衡機の追加 徐 start
      this.isClick = false;
      // add FNSI-田中衡機の追加 徐 end
      this.setScaleMode(2);
    },
    onTreatingSegmentClick(mode) {
      if (mode === this.treatingViewMode) {
        // 変更なし
        return;
      }
      if (mode === 0) {
        // 送信時前体重参照
        this.refresh();
      } else if (mode === 1) {
        // 後体重用車いす測定
        this.setTreatingWheelScaleMode();
      }
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateContentHeight() {
      const wh = this.windowHeight;
      const hh = Array.prototype.slice
        .call(document.getElementsByClassName("header"))
        .shift().clientHeight;
      const fmh =
        (this.isDispMenu === 1
          ? document.getElementById("footer-menu").clientHeight
          : 0) + 5;
      this.mainContentHeight = wh - hh - fmh - 3;
      this.mainContentHeight =
        this.mainContentHeight < 100 ? 100 : this.mainContentHeight;

      const cfh = Array.prototype.slice
        .call(document.getElementsByClassName("send-condition-footer-content"))
        .shift().clientHeight;
      const csh = Array.prototype.slice
        .call(document.getElementsByClassName("send-condition-head-segment"))
        .shift().clientHeight;
      const cmh = Array.prototype.slice
        .call(document.getElementsByClassName("send-condition-message-content"))
        .shift().clientHeight;
      const cth = Array.prototype.slice
        .call(document.getElementsByClassName("send-condtition-time-content"))
        .shift().clientHeight;

      this.scaleContentHeight =
        this.mainContentHeight - (cfh + csh + cmh + cth) + 12;

      this.coreParentHeight =
        this.mainContentHeight - (cfh + csh + cmh + cth) + 12;

      // スケジュールボタンのmax-width
      const headerBtnAreaWidth = document.getElementById(
        "send-condition-head-button-area"
      ).clientWidth;
      const scaleClassIconWidth = document.getElementById(
        "send-condition-scale-class-icon"
      ).clientWidth;
      const control2IconWidth = document.getElementById(
        "send-condition-control-2"
      ).clientWidth;
      this.scheduleBtnMaxWidth =
        headerBtnAreaWidth - scaleClassIconWidth - control2IconWidth - 10;
    },
    delayGoBack() {
      this.setLoadingScreenVisible(true);
      /* modify by chamaojia 2022-10-19 [5622] setTimeOutは左右がないと判断し、削除する  --start */
      // setTimeout(() => {
      this.setMeasuredValue(0);
      // add FNSI-田中衡機の追加 徐 start
      this.isClick = false;
      // add FNSI-田中衡機の追加 徐 end
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20240105 ztc start
      // this.isClicking = false;
      // del #10054 破棄確認・保存活性(複数変更含む)・削除対応_測定 20240105 ztc end
      // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
      //this.playAudio(this.getWeightAudioSetting).sendOk();
      if (!this.getIsFromScaleBed) {
        this.playAudio(this.getWeightAudioSetting).sendOk();
      }
      // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
      this.$router.go(-1);
      this.setLoadingScreenVisible(false);
      // mod FNSI-5622 時間を2000 msから500 msに調整 查 start
      // }, 500);
      // mod FNSI-5622 時間を2000 msから500 msに調整 查 end
      /* modify by chamaojia 2022-10-19 [5622] setTimeOutは左右がないと判断し、削除する  --end */
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致

        // 印刷パラメータを応答
        const param = {
          facilityCd: this.facilityCd,
          patId: this.getPatId,
          ordNo: this.getSelectedOrdNo.ordNo,
          ordNos: [this.getSelectedOrdNo.ordNo, this.getSelectedOrdNo.ordNo2],
          // add #5984 体重測定 コンテンツを追加する 孟堅 start
          functionCd: "01301",
          date: moment(Date.now()).format("YYYYMMDD"), // 日付（1日）：今日
          fromDate: moment(Date.now()).format("YYYY/MM/DD"), //  日付（期間）：今日から今日
          toDate: moment(Date.now()).format("YYYY/MM/DD"),
          // add #5984 体重測定 コンテンツを追加する 孟堅 end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
    // 活性と非活性の設定
    async setDisabled() {
      let setList = null;
      //施設のシステム利用設定を取得する
      await this.getFacilitySettingDataList(this.facilityCd).then(
        (response) => {
          setList = response;
        }
      );
      //体重計モード・スケジュール変更設定を取得する
      let row = setList.data.localDataSource.data.filter(
        (rows) => rows.facilitySettingNo == WEIGHMODE_SCHEDULE_SETTING
      );
      //利用者権限情報を取得する
      await this.fetchUserAuthorityCds();
      let userAuthorityCds = this.getUserAuthorityCds;
      // mod #10359、#10331 編集権限について、対応する。 dengshen start
      // //変更不可の場合
      // if(null != row && row[0].value == "0"){
      //   // 編集権限ON：治療指示の代行編集可チェックOR編集可チェック
      //   // mod #7437 スケジュール移動の権限が仕様通りではない dou start
      //   // if(userAuthorityCds.filter(rows => rows == "052" || rows == "053").length > 0){
      //   if(userAuthorityCds.filter(rows => rows == "133").length > 0){
      //     // mod #7437 スケジュール移動の権限が仕様通りではない dou end
      //     // 活性を設定
      //     this.isDisable = false;
      //   }else{
      //     // 編集権限OFF：治療指示の代行編集可チェックなしAND編集可チェックなし
      //     // 非活性を設定
      //     this.isDisable = true;
      //   }
      // }else{
      //   // 変更可の場合
      //   // 編集権限ON：治療指示の代行編集可チェックOR編集可チェック
      //   // mod #7437 スケジュール移動の権限が仕様通りではない dou start
      //   // if(userAuthorityCds.filter(rows => rows == "052" || rows == "053").length > 0){
      //   if(userAuthorityCds.filter(rows => rows == "133").length > 0){
      //     // mod #7437 スケジュール移動の権限が仕様通りではない dou end
      //     // 活性を設定
      //     this.isDisable = false;
      //   }else{
      //     // 非活性を設定
      //     this.isDisable = true;
      //   }
      // }
      // mod 11102 施設設定マスタNo.100の設定が適応されない 関  start
      // this.isDisable = false;
      // mod #10359、#10331 編集権限について、対応する。 dengshen start

      //変更不可の場合
      if (null != row && row[0].value == "0"){
        this.isDisable = this.getWeightMode.isWeightMode ? true : false;
      }else{
        this.isDisable = false;
      }
      // mod 11102 施設設定マスタNo.100の設定が適応されない 関  end
    },
    // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 end

    listenerStart(event) {
      if (!this.enableZoom) {
        return;
      }
      switch (event.type) {
        case TOUCHSTART:
          for (let i = 0; i < event.changedTouches.length; i++) {
            const touch = {
              x: event.changedTouches[i].pageX,
              y: event.changedTouches[i].pageY,
              identifier: event.changedTouches[i].identifier,
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
              y: event.changedTouches[0].pageY,
            };
            const newP2 = {
              x: event.changedTouches[1].pageX,
              y: event.changedTouches[1].pageY,
            };
            this.mouseListenerInf.oldDistance = this.getDistance(newP1, newP2);
          }
          this.mouseListenerInf.zoomPos = null;
          break;
        default:
          break;
      }
    },
    listenerEnd(event) {
      if (!this.enableZoom) {
        return;
      }
      if (this.mouseListenerInf.isTouched) {
        // タッチイベントのとき
        switch (event.type) {
          case TOUCHEND: {
            for (let i = 0; i < event.touches.length; i++) {
              this.mouseListenerInf.touchListArray =
                this.mouseListenerInf.touchListArray.filter(
                  (x) => x.identifier !== event.changedTouches[i].identifier
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
          default:
            break;
        }
      }
    },
    listenerMove(event) {
      if (!this.enableZoom) {
        return;
      }
      if (this.mouseListenerInf.isTouched) {
        event.preventDefault();
        switch (event.type) {
          case TOUCHMOVE: {
            if (event.touches.length === 1) {
              const p1 = {
                x: event.touches[0].pageX,
                y: event.touches[0].pageY,
              };
              this.targetMove(p1);
            } else if (event.touches.length > 1) {
              const newP1 = {
                x: event.touches[0].pageX,
                y: event.touches[0].pageY,
              };
              const newP2 = {
                x: event.touches[1].pageX,
                y: event.touches[1].pageY,
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
                      this.targetScale,
                  };
                }
                this.targetZoom(
                  scale,
                  {
                    x: this.mouseListenerInf.zoomPos.x,
                    y: this.mouseListenerInf.zoomPos.y,
                  },
                  {
                    x: zoomPosX - displayArea.left,
                    y: zoomPosY - displayArea.top,
                  }
                );
              }
              this.mouseListenerInf.oldDistance = newDistance;
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
      this.adjustBedLayourtAreaPosition();
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
          (newMousePos.y - this.mouseListenerInf.basePoint.y),
      };
      // X軸方向への動き
      const canvasWidth =
        document.getElementById("target").clientWidth * this.targetScale;
      const displayArea = document
        .getElementById("area-main")
        .getBoundingClientRect();
      this.targetTransForm.x = this.getTransform(
        canvasWidth,
        displayArea.width * this.targetScale,
        newPos.x,
        this.targetTransForm.x
      );
      this.mouseListenerInf.basePoint.x = newMousePos.x;

      // y軸方向への動き
      const canvasHeight =
        document.getElementById("target").clientHeight * this.targetScale;
      this.targetTransForm.y = this.getTransform(
        canvasHeight,
        displayArea.height * this.targetScale,
        newPos.y,
        this.targetTransForm.y
      );
      this.mouseListenerInf.basePoint.y = newMousePos.y;
    },
    resetTargetTransform() {
      this.targetTransForm.x = 0;
      this.targetTransForm.y = 0;
    },
    getTransform(canvasLength, displayAreaLength, newPosition, oldPosition) {
      // 表示開始位置判定
      if (0 < newPosition) {
        return oldPosition;
      }
      // 最終端位置判定
      if (newPosition - displayAreaLength < canvasLength * -1) {
        return oldPosition;
      }

      return newPosition;
    },
    /**
     * 二点間距離の計算
     */
    getDistance(p1, p2) {
      return Math.sqrt((p1.x - p2.x) ** 2 + (p1.y - p2.y) ** 2);
    },
    // ベッドレイアウト表示位置調整
    adjustBedLayourtAreaPosition() {
      const displayArea = document
        .getElementById("area-main")
        .getBoundingClientRect();
      const targetArea = document
        .getElementById("target")
        .getBoundingClientRect();
      const areaX = displayArea.width / 2;
      const areaY = displayArea.height / 2;

      // 表示位置調整
      let posX = this.targetTransForm.x;
      let posY = this.targetTransForm.y;
      const posX2 = posX + targetArea.width;
      const posY2 = posY + targetArea.height;
      if (areaX < posX) {
        posX = areaX;
      }
      if (areaY < posY) {
        posY = areaY;
      }
      if (posX2 < areaX) {
        posX += areaX - posX2;
      }
      if (posY2 < areaY) {
        posY += areaY - posY2;
      }

      this.targetTransForm.x = posX;
      this.targetTransForm.y = posY;
    },
    zoomIn() {
      if (+this.sliderVal === this.sliderMax) {
        return;
      }
      this.sliderVal =
        +this.sliderVal >= this.sliderMax - this.sliderStep
          ? this.sliderMax
          : +this.sliderVal + this.sliderStep;
    },
    zoomOut() {
      if (+this.sliderVal === this.sliderMin) {
        return;
      }
      this.sliderVal =
        +this.sliderVal <= this.sliderMin + this.sliderStep
          ? this.sliderMin
          : +this.sliderVal - this.sliderStep;
    },
    // ズームスライダーのポップオーバー非表示
    hideItemPopover() {
      this.zoomPopoverTarget = null;
      this.zoomPopoverVisible = false;
    },
    // ズームスライダーのポップオーバー表示
    showZoomPopover() {
      this.zoomPopoverTarget = event.target;
      this.zoomPopoverVisible = true;
    },
  },
  watch: {
    // スケジュール/目標体重/降水量モーダル生成
    getIsShowIndModal(isShow) {
      if (isShow) {
        this.showIndEditModal(this.getSettingIndData.headerTitle);
      }
    },
    // 体重計設定読み込み
    getWeightConfigInfo() {
      this.setCheckConfig(this.getWeightCheckSetting);
      this.setPrintConfig(this.getWeightPrintSetting);
    },
    // 患者個人情報更新チェック
    "selectedPat.pat_unique.physical_info"(newValue) {
      if (newValue !== undefined && newValue !== null) {
        const physicalInfoList = JSON.parse(newValue);
        this.loadPhysicalInfo({
          physicalInfoList: physicalInfoList,
          treatDate: this.getTreatDate[0]
            ? this.getTreatDate[0]
            : moment().format("YYYYMMDD"),
        }).then(() => {
          // DW未登録
          if (
            this.getIndDryWeight.value === null &&
            !this.primaryOrderIsPurification.isPurification
          ) {
            this.disableSendBtnFlg = true;
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "DW未登録",
              // message: "DWが登録されていないため条件送信できません。患者情報の身体情報にDWを登録してください。"
              title: DIALOG_MESSAGES[12000227].title,
              message: messageFormat(DIALOG_MESSAGES[12000227].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
          this.calcWeightValue();
        });
      }
    },
    windowHeight() {
      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    },
    isDispMenu() {
      this.calculateContentHeight();
    },
    getFontSize() {
      this.calculateContentHeight();
    },
    getMessageSwitch() {
      this.$nextTick(() => {
        this.calculateContentHeight();
      });
    },
    /**
     * スライダー変更時の拡大縮小処理
     */
    targetScale(newScale, oldScale) {
      // 強制的に左上起点表示
      this.targetTransForm.x = 0;
      this.targetTransForm.y = 0;
      // if (false === this.sliderWatchOff) {
      // const displayArea = document
      //   .getElementById("area-main")
      //   .getBoundingClientRect();
      // const bedRoomCenter = {
      //   x: displayArea.width / 2,
      //   y: displayArea.height / 2
      // };
      // const canvasWidth = document.getElementById("target").clientWidth;
      // const canvasHeight = document.getElementById("target").clientHeight;

      // // 拡大縮小の中心を取得
      // const getZoomCenter = (roomCenter, transForm, canvasSize, scale) => {
      //   if (roomCenter > transForm + canvasSize * scale) {
      //     // 拡大対象の正方向端が表示領域中心に達しない
      //     return canvasSize;
      //   } else if (roomCenter < transForm) {
      //     // 拡大対象の負方向端が表示領域中心を通り過ぎている
      //     return 0;
      //   } else {
      //     // 拡大対象の内側に表示領域中心が存在する
      //     return (roomCenter - transForm) / scale;
      //   }
      // };

      // const zoomCenter = {
      //   x: getZoomCenter(
      //     bedRoomCenter.x,
      //     this.targetTransForm.x,
      //     canvasWidth,
      //     oldScale
      //   ),
      //   y: getZoomCenter(
      //     bedRoomCenter.y,
      //     this.targetTransForm.y,
      //     canvasHeight,
      //     oldScale
      //   )
      // };
      // const zoomCenter = {
      //   x: (bedRoomCenter.x - this.targetTransForm.x) / oldScale,
      //   y: (bedRoomCenter.y - this.targetTransForm.y) / oldScale
      // };

      // this.targetTransForm.x += zoomCenter.x * (oldScale - newScale);
      // this.targetTransForm.y += zoomCenter.y * (oldScale - newScale);
      // } else {
      //   this.sliderWatchOff = false;
      // }
      // Zoom後の表示位置調整
      // this.adjustBedLayourtAreaPosition();
    },
    sliderVal(newVal) {
      localStorage.setItem(LOCAL_STORAGE_KEY.WEIGHT_SCALE_ZOOM, newVal);
    },
  },
  created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("isRefresh", this.refresh);
    EventBus.$off("loadSendConditionView", this.loadInitialData);
    EventBus.$off("onReceiveMeasureValue", this.onReceiveMeasureValue);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
    // #11165 2024.10.11 mod EventBus.$onが動作していない不具合を修正 TDC米沢 start
    // EventBus.$on("loadSendConditionView", this.loadInitialData);
    // EventBus.$on("onReceiveMeasureValue", this.onReceiveMeasureValue);
    // EventBus.$on("refresh", this.refresh);
    // EventBus.$on("isRefresh", this.refresh); // 指示変更モーダル
    // DOM要素構築後にEventBus.$onを実施
    this.$nextTick(() => {
      EventBus.$on("loadSendConditionView", this.loadInitialData);
      EventBus.$on("onReceiveMeasureValue", this.onReceiveMeasureValue);
      EventBus.$on("refresh", this.refresh);
      EventBus.$on("isRefresh", this.refresh); // 指示変更モーダル
      // 印刷パラメータ要求
      EventBus.$on("requestReportParams", this.requestrReportParams);
    });
    // #11165 2024.10.11 mod EventBus.$onが動作していない不具合を修正 TDC米沢 end

    // add FNSI-体重計画面 徐 start
    const queryParameters = this.getQueryParameters;
    if (Number(queryParameters.WEIGHTNO) > 0) {
      if (Number(queryParameters.MODE) == 1) {
        this.breadMode = false;
      }
    }
    // add FNSI-体重計画面 徐 end

    // #11165 2024.10.11 del EventBus.$on処理をnextTickで実施 TDC米沢 start
    // // 印刷パラメータ要求
    // EventBus.$on("requestReportParams", this.requestrReportParams);
    // #11165 2024.10.11 del EventBus.$on処理をnextTickで実施 TDC米沢 end

    // add FNSI-田中衡機の追加 徐 start
    let deviceClass = null;
    if (
      this.getWeightConfigInfo !== undefined &&
      this.getWeightConfigInfo !== null
    ) {
      deviceClass = this.getWeightConfigInfo.deviceClass;
    }
    if (String(deviceClass) === "1") {
      this.deviceFlg = true;
    }
    if (this.deviceFlg) {
      this.sendWeightAppOk({
        weightCd: this.getWeightConfigInfo.weightCd,
        facilityCd: this.facilityCd,
        weightNo: this.getWeightConfigInfo.weightNo,
      })
        .then()
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage("SendConditionMainComponent.vue", "created", error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        });
    }
    // add FNSI-田中衡機の追加 徐 end
    // add FNSI-分類不一致判断の追加 徐 start
    this.disableSendBtnFlg = false;
    this.setChkIndCondInfoFlg(false);
    this.setMstDelFlg(false);
    this.setMstOverdueFlg(false);
    this.diaView = false;
    this.mstDelDiaView = false;
    this.mstOverdueDiaView = false;
    // add FNSI-分類不一致判断の追加 徐 end
    // 共通ローダー:表示開始
    this.setLoadingScreenVisible(true);
    this.setIsInitialized(false);
    this.initMessage();
    this.isShowing = true;

    // add FutreNetWeb+SI課題管理No6705 趙 start
    this.setOffWaterChangeFlg(false);
    // add FutreNetWeb+SI課題管理No6705 趙 end

    // 体重測定設定読み込み
    this.fetchWeightScaleSetting(this.facilityCd)
      .then((r) => {
        if (r.data === null || r.data === "") {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "設定読み込みエラー",
            // message: "体重計マスタから画面設定が読み込めませんでした"
            title: DIALOG_MESSAGES[12000228].title,
            message: messageFormat(DIALOG_MESSAGES[12000228].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          this.$router.go(-1);
        } else {
          this.setWeightScaleSetting(r.data).then(() => {
            this.setCheckConfig(this.getWeightCheckSetting);
            this.setPrintConfig(this.getWeightPrintSetting);
            this.setDoubleCheckSetting({
              enable: r.data.isDoubleCheck,
              tolerance: r.data.doubleCheckTolerance,
            });
          });
          this.setViewModeIsSimple(r.data.defaultScreenClass === 0);
          this.previousWeightSourceClass = r.data.previousWeightSourceClass;

          // 選択中の指示や患者から表示するデータ読み込み
          this.loadInitialData();
        }
      })
      .catch((err) => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage(
          "SendConditionMainComponent.vue",
          "created",
          "体重計マスタからの設定取得時にエラー"
        );
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        if (err.response.status === 400) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "設定読み込みエラー",
            // message: "体重計マスタからの設定取得時にエラー"
            title: DIALOG_MESSAGES[12000229].title,
            message: messageFormat(DIALOG_MESSAGES[12000229].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
        // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
        //this.playAudio(this.getWeightAudioSetting).sendNg();
        if (!this.getIsFromScaleBed) {
          this.playAudio(this.getWeightAudioSetting).sendNg();
        }
        // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
      });
    // デフォルト体重計設定読み込み
    this.fetchDefaultWeightSetting(this.facilityCd)
      .then((r) => {
        if (r.data === null || r.data === "") {
          // 設定なし
          this.setDefaultWeightConfigInfo(null);
        } else {
          this.setDefaultWeightConfigInfo(r.data);
          this.setCheckConfig(this.getWeightCheckSetting);
          this.setPrintConfig(this.getWeightPrintSetting);
        }
      })
      .catch((err) => {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage(
          "SendConditionMainComponent.vue",
          "created",
          "体重計マスタからの設定取得時にエラー"
        );
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        if (err.response.status === 400) {
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "設定読み込みエラー",
            // message: "体重計マスタからの設定取得時にエラー"
            title: DIALOG_MESSAGES[12000229].title,
            message: messageFormat(DIALOG_MESSAGES[12000229].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
        }
        // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 start
        //this.playAudio(this.getWeightAudioSetting).sendNg();
        if (!this.getIsFromScaleBed) {
          this.playAudio(this.getWeightAudioSetting).sendNg();
        }
        // #11987 2026.05.20 mod スケールベッド対応 スケールベッドから呼び出された場合は音声ガイダンスは再生させない TDC渡辺 end
      });

    this.fetchWheelChairList(this.facilityCd);
    // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 start
    this.setDisabled();
    // add FNSI-体重測定・条件送信 「クール設定／ベッド設定」ボタンは条件により非活性 鄭 end
    const ua = navigator.userAgent;
    if (ua.match(/iPhone|Android/)) {
      this.isMobile = true;
    }

    // ymdtime更新処理(初回)
    this.weightName =
      this.getWeightConfigInfo.weightName !== null &&
      this.getWeightConfigInfo.weightName !== undefined
        ? this.getWeightConfigInfo.weightName
        : "体重計接続なし";
    var weekday = ["日", "月", "火", "水", "木", "金", "土"];
    this.ymdTime =
      moment().format("YYYY/MM/DD") +
      "(" +
      weekday[moment().day()] +
      ") " +
      moment().format("HH:mm");

    this.ymdUpdateProc = setInterval(() => {
      // ymdtime更新処理(1秒ごと)
      this.weightName =
        this.getWeightConfigInfo.weightName !== null &&
        this.getWeightConfigInfo.weightName !== undefined
          ? this.getWeightConfigInfo.weightName
          : "体重計接続なし";
      var weekday = ["日", "月", "火", "水", "木", "金", "土"];
      this.ymdTime =
        moment().format("YYYY/MM/DD") +
        "(" +
        weekday[moment().day()] +
        ") " +
        moment().format("HH:mm");
    }, 1000);

    // #10290 2024.03.09 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 start
    // 施設設定「前体重許容範囲チェックの実施可否」を読み込み、storeに設定する
    this.setIsBeforeWeightToleranceRangeCheck(this.facilityCd);
    // #10290 2024.03.09 add 施設設定により前体重許容範囲チェックを実施可否を決定する TDC米沢 end

  },
  mounted() {
    // エラーメッセージ非表示
    this.hideCheckMessage();
    this.$nextTick(() => {
      this.calculateContentHeight();

    });
    // 編集後クリックキャンセ,未提示破棄popup画面
    setTimeout(() => {
      this.initWeightValue = this.getMeasuredValue;
    }, 1000);
    // サイドメニューを閉じる
    EventBus.$emit("forceCloseSideBar");
    // サイドメニュー、サイドメニュー開閉ボタンを非表示化
    this.setIsDispSidebarBtn(false);

    let storedSliderVal = localStorage.getItem(
      LOCAL_STORAGE_KEY.WEIGHT_SCALE_ZOOM
    );
    if (storedSliderVal) {
      this.sliderVal = storedSliderVal;
    }
  },
  update() {
    this.$nextTick(() => {
      this.calculateContentHeight();
    });
  },
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("isRefresh", this.refresh); // 指示変更モーダル
    EventBus.$off("loadSendConditionView", this.loadInitialData);
    EventBus.$off("onReceiveMeasureValue", this.onReceiveMeasureValue);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);

    // タイマーが動いている場合は停止させる
    clearTimeout(this.autoSendTimer);
    this.stopDelayAudio().patOk();
    this.stopDelayAudio().receiveWeight();
    this.isShowing = false;
    clearInterval(this.ymdUpdateProc);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());

    // #11987 2026.02.10 add スケールベッドからの呼び出しに対応 TDC片口 start
    // スケールベッドモードの削除
    this.resetScaleBedToWeightView();
    // #11987 2026.02.10 add スケールベッドからの呼び出しに対応 TDC片口 end
  },
  destroyed() {
    this.setBaseOrdWeightNo(null);
    this.setIsInitialized(false);
    this.setMeasuredValue(0);
    // add FNSI-田中衡機の追加 徐 start
    this.isClick = false;
    // add FNSI-田中衡機の追加 徐 end
    this.scaleMode = weightScaleMode.weight;
    this.setInputPatId(null);
    this.setPatId(null);
    this.setSelectOrdNo({ ordNo: null, ordNo2: null });
    this.startWeightScaleMode();
    this.initMessage();
    // upd #9562 患者カレンダーの表示が遅い 20230403 ztc start
    //this.resetSelectedPatHeader();
    // upd #9562  患者カレンダーの表示が遅い 20230403 ztc end
    if (!this.getWeightMode.isWeightMode) {
      // 体重計モードでない場合はサイドメニュー展開ボタン表示復活
      this.setIsDispSidebarBtn(true);
    }
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx start
    this.deviceModeUnknownFlg = false,
    this.isPurificationWarnMsgFlg = false;
    //add #11846 感染症不一致ロジック不正＆スケジュール表で不一致アイコンが点灯しない zrx end
  },
};
</script>
<style scoped>
.send-condition-main-content-area {
  display: flex;
  flex-direction: column;
}

.wrap-block {
  display: flex;
  flex-direction: row;
  flex-wrap: wrap;
}

#send-condition-control-2 {
  display: inline-block;
  margin-left: auto;
  font-size: 1.5em;
  z-index: 2;
}

.send-condition-btn-area {
  display: flex;
}

.hidden-item {
  display: none;
}

.fade-enter-active,
.fade-leave-active {
  transition: opacity 0.5s;
}
.fade-enter,
.fade-leave {
  opacity: 0;
}
.slide-enter-active,
.slide-leave-active {
  transition: transform 0.5s;
}
.slide-enter {
  transform: translateY(100px);
}
.slide-leave-active {
  transform: translateY(150px);
}
/* add FNSI-田中衡機の追加 徐 start */
.multi-select-list {
  height: 18.8em;
  border: 1px solid;
  overflow: auto;
  width: 15em;
  text-align: center;
  background-color: var(--body-background-color);
}
.multi-select-list-label {
  width: 15.15em;
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: unset;
  border: solid 0px var(--ntss-list-border-color);
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
.multi-select-list-detail {
  height: 18.8em;
  border: 1px solid;
  overflow: auto;
  width: 17em;
  text-align: center;
  background-color: var(--body-background-color);
}
.multi-select-list-detail-label {
  width: 17.1em;
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: unset;
  border: solid 0px var(--ntss-list-border-color);
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
.deviceCls {
  padding-left: 70px;
  color: var(--send-cond-font-color);
  text-align: center;
}
.deviceClsSimple {
  padding-left: 10px;
  padding-right: 10px;
}
.deviceClslabel {
  font-weight: bold;
  font-size: 1.5em;
}
.deviceClslabelDetail {
  font-weight: bold;
  font-size: 2em;
}
.item-name {
  user-select: none;
  font-size: 2.7em;
}
.item-label {
  display: inline-block;
  width: 100%;
  outline: none;
  border-bottom: 1px solid;
}
.item-label-detail {
  display: inline-block;
  width: 100%;
  outline: none;
  font-size: 10.5px;
  padding-top: 0.6em;
  padding-bottom: 0.6em;
  border-bottom: 1px solid;
}
/* マルチ選択項目ホバー時 */
/* .item-label-hovered:hover {
  background-color: #ddeeff80;
  transition: background-color 0.3s;
} */

/* マルチ選択項目チェック時 */
/* .item-label-checked {
  background-color: #0076ff;
  color: white;
  transition: background-color 0.3s;
} */
.send-rows {
  display: flex;
}
/* add FNSI-田中衡機の追加 徐 end */
/* add FNSI-体重計画面 徐 start */
.head-button {
  float: right;
  width: 5em;
  height: 2em;
  color: rgba(0, 110, 255, 0.863);
  background: rgba(209, 208, 208, 0.911);
}
.t-button {
  font-size: 30px;
  font-weight: bold;
  height: 60px;
}
#segment .segment__item {
  border-radius: 0px;
  box-shadow: unset;
}
.send-condition-button {
  font-size: 30px;
  width: 18em;
  height: 2em;
  color: rgba(0, 110, 255, 0.863);
  background: rgba(209, 208, 208, 0.911);
  font-weight: bold;
}
.model {
  width: 100%;
  height: 100%;
  position: fixed;
  top: 0;
  left: 0;
  z-index: 999;
  background-color: rgba(0, 0, 0, 0.6);
}
.modelFixed {
  position: absolute;
  top: 120px;
  left: 10px;
  padding: 5px;
  background: #ffffff;
  box-shadow: 3px 2px 5px #7777;
}
.set-width {
  width: 85%;
  overflow-x: hidden;
}
div.zoom-slider {
  position: absolute;
  bottom: 1em;
  right: 0.8em;
  background-color: #fff4;
  display: flex;
  align-items: center;
  font-size: 3em;
  transform: rotate(90deg);
  transform-origin: right top;
  padding: 0em 0.3em 0em 0.3em;
}
span.zoom-slider-label {
  font-size: 2em !important;
  margin-left: 5px;
  margin-right: 5px;
}
/* add FNSI-体重計画面 徐 end */
#target {
  transform-origin: left top 0;
}
/* 画面確認用 */
.checker {
  background: linear-gradient(
      45deg,
      rgb(0, 128, 0) 25%,
      rgb(128, 255, 128) 25%,
      rgb(128, 255, 128) 75%,
      rgb(0, 128, 0) 75%
    ),
    linear-gradient(
      45deg,
      rgb(0, 128, 0) 25%,
      rgb(128, 255, 128) 25%,
      rgb(128, 255, 128) 75%,
      rgb(0, 128, 0) 75%
    );
  background-size: 40px 40px;
  background-position: 0 0, 20px 20px;
}
.zoom-popover
  >>> div.popover.popover--top
  >>> div.popover__content.popover--top__content {
  height: fit-content;
  min-height: unset;
}
.detail-main-parent {
  position: relative;
  margin: auto;
  width: max-content;
}
</style>
