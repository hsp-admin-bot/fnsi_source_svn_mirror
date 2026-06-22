<template>
  <div :id="$route.name" class="d-flex flex-column">
    <!-- Group name -->
    <div class="group-name d-flex align-items-center">
      <label for="pat-group-name" class="label">患者グループ名</label>
      <div class="flex-1 d-flex flex-column">
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
        <!-- <custom-simple-textarea-b
          id="pat-group-name"
          name="pat-group-name"
          v-model.trim="editedPatGroup.patGroupName"
          v-rules.immediate="'required'"
          autocomplete="off"
          @blur="delFocusCss($event)"
          @focus="addFocusCss($event)"
          :class="classObject"
        /> -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <custom-simple-textarea-b -->
        <!--   id="pat-group-name" -->
        <!--   name="pat-group-name" -->
        <!--   v-model.trim="editedPatGroup.patGroupName" -->
        <!--   v-rules.immediate="'required'" -->
        <!--   autocomplete="off" -->
        <!--   @blur="delFocusCss($event)" -->
        <!--   @focus="addFocusCss($event)" -->
        <!--   :class="classObject" -->
        <!--   :disabled="editFlag" -->
        <!-- /> -->
        <custom-simple-textarea-b
          id="pat-group-name"
          name="pat-group-name"
          v-model.trim="editedPatGroup.patGroupName"
          v-rules.immediate="'required'"
          autocomplete="off"
          @blur="delFocusCss($event)"
          @focus="addFocusCss($event)"
          :class="classObject"
          :disabled="editFlag || !getItemAuthorized('PatInfo', 'default_authority')"
        />
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
      </div>
    </div>
    <!-- / Group name -->

    <!-- Patient search -->
    <div class="pat-search d-flex flex-column">
      <div class="title">患者選択</div>
      <div class="d-flex align-items-center">
        <label for="free-text-search" class="label">フリーワード検索</label>
        <!--mod FNSI-改修内容6281 任 start-->
        <!--<v-ons-input
          input-id="free-text-search"
          type="text"
          v-model.trim="freeText"
          v-on:keyup.enter="searchPatSimple"
          padder
          @blur="onBlurSearch()"
        />-->
        <v-ons-input
          input-id="free-text-search"
          type="text"
          v-model.trim="freeText"
          v-on:keyup.enter="searchPatSimple"
          padder
        />
        <!--mod FNSI-改修内容6281 任 end-->
        <!--mod FNSI-改修内容画面デザイン 任 start-->
        <!--<ons-button
          class="search-button common-style-ok-button button"
          style="margin-left: 0.5rem;"
          @click="searchPatSimple"
          @mousedown="onMousedownSearch()"
        >検索</ons-button
        >
      </div>
      <div>
        <v-ons-button class="detailed-search" @click="showDetailedSearchModal"
        >詳しく検索</v-ons-button
        >-->
        <ons-button
          class="search-button common-style-ok-button button btn3-normal"
          style="margin-left: 0.5rem"
          @click="searchPatSimple"
          @mousedown="onMousedownSearch()"
          >検索</ons-button
        >
      </div>
      <div>
        <v-ons-button
          class="detailed-search btn3-normal"
          @click="showDetailedSearchModalo"
          >詳しく検索</v-ons-button
        >
        <!--mod FNSI-改修内容画面デザイン 任 end-->
      </div>
    </div>
    <!-- / Patient search -->

    <!-- Patient list -->
    <!-- 患者グループ編集  表スタイル shan start -->
    <div class="pat-list flex-1 dis_box">
      <div class="modelTop">
        <div class="modelInfo" style="overflow-y: scroll">
          <div class="color-header modelTitle">
            <!--  mod FNSI-改修内容:画面項目名違和感を修正 周 start-->
            <!-- <div class="modelTitleID">ユーザーID</div>
            <div class="modelTitleName">ユーザー名</div> -->
            <div class="modelTitleID">患者ID</div>
            <div class="modelTitleName">患者名</div>
            <!--  mod FNSI-改修内容:画面項目名違和感を修正 周 end-->
          </div>
          <div
            style="display: flex"
            class="pat-display-row"
            v-show="!isLoading"
            v-for="(pat, index) in unselectedPatList"
            :key="index"
          >
          <!-- mod コンソール繰返しkey値エラー start -->
            <div
              :class="[
                'pat-display',
                'hosp-pat-id-body',
                { selected: unselectedSelection.includes(index) },
              ]"
              :key="pat.pat_id + 'ID'"
              @click.exact="singleSelect('unselected', index)"
              @click.shift.exact="rangeSelect('unselected', index)"
              style="
                width: 50%;
                border-bottom: 1px solid #dee2e6;
                border-right: 1px solid #dee2e6;
              "
            >
            <!-- mod コンソール繰返しkey値エラー end -->
              {{ formatPatId(pat) }}
            </div>
            <div
              :class="[
                'pat-display',
                pat.in_out_class === 1 ? 'pat-name-in-hospital' : '',
                { selected: unselectedSelection.includes(index) },
              ]"
              :key="pat.pat_id"
              @click.exact="singleSelect('unselected', index)"
              @click.shift.exact="rangeSelect('unselected', index)"
              style="width: 50%; border-bottom: 1px solid #dee2e6"
            >
              {{ formatPatName(pat) }}
              <img
                v-if="pat.is_same === '1'"
                class="same-icon"
                :src="image_src_same"
              />
            </div>
          </div>
        </div>
      </div>

      <!-- Tools -->
      <div class="tools d-flex flex-column justify-content-center">
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
        <!-- <button
          class="k-button k-button-icon"
          @click="addAllPat"
          :disabled="unselectedPatList.length === 0"
        > -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <button -->
        <!--   class="k-button k-button-icon" -->
        <!--   @click="addAllPat" -->
        <!--   :disabled="unselectedPatList.length === 0 || editFlag" -->
        <!-- > -->
        <button
          class="k-button k-button-icon"
          @click="addAllPat"
          :disabled="unselectedPatList.length === 0 || editFlag || !getItemAuthorized('PatGroup', 'default_authority')"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
          <span class="k-icon k-i-arrow-double-60-right"></span>
        </button>

        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
        <!-- <button
          class="k-button k-button-icon"
          @click="addPat"
          :disabled="unselectedSelection.length === 0"
        > -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <button -->
        <!--   class="k-button k-button-icon" -->
        <!--   @click="addPat" -->
        <!--   :disabled="unselectedSelection.length === 0 || editFlag" -->
        <!-- > -->
        <button
          class="k-button k-button-icon"
          @click="addPat"
          :disabled="unselectedSelection.length === 0 || editFlag || !getItemAuthorized('PatGroup', 'default_authority')"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
          <span class="k-icon k-i-arrow-60-right"></span>
        </button>

        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
        <!-- <button
          class="k-button k-button-icon"
          @click="removePat"
          :disabled="selectedSelection.length === 0"
        > -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <button -->
        <!--   class="k-button k-button-icon" -->
        <!--   @click="removePat" -->
        <!--   :disabled="selectedSelection.length === 0 || editFlag" -->
        <!-- > -->
        <button
          class="k-button k-button-icon"
          @click="removePat"
          :disabled="selectedSelection.length === 0 || editFlag || !getItemAuthorized('PatGroup', 'default_authority')"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
          <span class="k-icon k-i-arrow-60-left"></span>
        </button>

        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
        <!-- <button
          class="k-button k-button-icon"
          @click="removeAllPat"
          :disabled="editedPatGroup.selectedPatList.length === 0"
        > -->
        <!-- mod #10359 編集権限の動作不正 dengshen start -->
        <!-- <button -->
        <!--   class="k-button k-button-icon" -->
        <!--   @click="removeAllPat" -->
        <!--   :disabled="editedPatGroup.selectedPatList.length === 0 || editFlag" -->
        <!-- > -->
        <button
          class="k-button k-button-icon"
          @click="removeAllPat"
          :disabled="editedPatGroup.selectedPatList.length === 0 || editFlag || !getItemAuthorized('PatGroup', 'default_authority')"
        >
        <!-- mod #10359 編集権限の動作不正 dengshen end -->
        <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
          <span class="k-icon k-i-arrow-double-60-left"></span>
        </button>
      </div>
      <!-- / Tools -->

      <!-- Selected pat list -->
      <!--mod FNSI-改修内容移動前と移動後の様式修正、行を単位で選択。 任 start-->
      <!--<div class="d-flex flex-column flex-1">
        <div class="selected-pat-list flex-1">
          <div class="list-wrapper">
            <div
              v-for="(pat, index) in editedPatGroup.selectedPatList"
              :class="[
                'pat-display',
                { selected: selectedSelection.includes(index) }
              ]"
              :key="pat.pat_id"
              @click.exact="singleSelect('selected', index)"
              @click.shift.exact="rangeSelect('selected', index)"
            >
              {{ formatPatId(pat) }}
            </div>
          </div>
        </div>

        <span class="error-message">
          {{ getValidationError("selected-pat-list") }}
        </span>
      </div>
      &lt;!&ndash; Selected pat list &ndash;&gt;
    </div>-->
      <div class="modelTop">
        <div class="modelInfo" style="overflow-y: scroll; width: 100%">
          <div class="color-header modelTitle">
            <!--  mod FNSI-改修内容:画面項目名違和感を修正 周 start-->
            <!-- <div class="modelTitleID">ユーザーID</div>
            <div class="modelTitleName">ユーザー名</div> -->
            <div class="modelTitleID">患者ID</div>
            <div class="modelTitleName">患者名</div>
            <!--  mod FNSI-改修内容:画面項目名違和感を修正 周 end-->
          </div>
          <!-- <div
            class="d-flex flex-column flex-1"
            style="
              float: left;
              border-right: 1px solid #dee2e6;
              word-break: break-all;
            "
          >
            <div
              class="selected-pat-list flex-1"
              style="width: 100%; border-right: 1px solid #dee2e6"
            >
              <div
                style="display: flex"
                v-for="(pat, index) in editedPatGroup.selectedPatList"
                :key="index"
              >
                <div
                  :class="[
                    'pat-display',
                    { selected: selectedSelection.includes(index) },
                  ]"
                  :key="pat.pat_id"
                  @click.exact="singleSelect('selected', index)"
                  @click.shift.exact="rangeSelect('selected', index)"
                  style="
                    width: 50%;
                    border-bottom: 1px solid #dee2e6;
                    border-right: 1px solid #dee2e6;
                  "
                >
                  {{ formatPatId(pat) }}
                </div>

                <div
                  :class="[
                    'pat-display',
                    pat.in_out_class === 1 ? 'pat-name-in-hospital' : '',
                    { selected: selectedSelection.includes(index) },
                  ]"
                  :key="pat.pat_id"
                  @click.exact="singleSelect('selected', index)"
                  @click.shift.exact="rangeSelect('selected', index)"
                  style="width: 50%; border-bottom: 1px solid #dee2e6"
                >
                  {{ formatPatName(pat) }}
                  <img
                    v-if="pat.is_same === '1'"
                    class="same-icon"
                    :src="image_src_same"
                  />
                </div>
              </div>
            </div>
            <span class="error-message">
              {{ getValidationError("selected-pat-list") }}
            </span>
          </div> -->
          <div
            style="display: flex"
            class="pat-display-row"
            v-for="(pat, index) in editedPatGroup.selectedPatList"
            :key="index"
          >
          <!-- mod コンソール繰返しkey値エラー start -->
            <div
              :class="[
                'pat-display',
                'hosp-pat-id-body',
                { selected: selectedSelection.includes(index) },
              ]"
              :key="pat.pat_id + 'ID'"
              @click.exact="singleSelect('selected', index)"
              @click.shift.exact="rangeSelect('selected', index)"
              style="
                width: 50%;
                border-bottom: 1px solid #dee2e6;
                border-right: 1px solid #dee2e6;
              "
            >
            <!-- mod コンソール繰返しkey値エラー end -->
              {{ formatPatId(pat) }}
            </div>
            <div
              :class="[
                'pat-display',
                pat.in_out_class === 1 ? 'pat-name-in-hospital' : '',
                { selected: selectedSelection.includes(index) },
              ]"
              :key="pat.pat_id"
              @click.exact="singleSelect('selected', index)"
              @click.shift.exact="rangeSelect('selected', index)"
              style="width: 50%; border-bottom: 1px solid #dee2e6"
            >
              {{ formatPatName(pat) }}
              <img
                v-if="pat.is_same === '1'"
                class="same-icon"
                :src="image_src_same"
              />
            </div>
          </div>
        </div>
        <!-- Selected pat list -->
      </div>
    </div>
    <!-- 患者グループ編集  表スタイル shan start -->
    <!-- / Patient list -->

    <!-- Actions -->
    <div class="actions d-flex">
      <!--      mod  FNSI-権限 陳 start-->
      <!--      <v-ons-button-->
      <!--        class="nik-btn remove"-->
      <!--        @click="remove"-->
      <!--        :disabled="$route.name === 'pat-group-new'"-->
      <!--        >削除</v-ons-button-->
      <!--      >-->

      <!--      mod  FNSI-印刷対応 xie start-->
      <!--      <v-ons-button
        class="nik-btn remove"
        @click="remove"
        :disabled="$route.name === 'pat-group-new' || !hasPatInfoAuthority"
      >削除</v-ons-button
      >
-->
      <!--mod FNSI-改修内容画面デザイン 任 start-->
      <!--<v-ons-button
        class="nik-btn remove print-none"
        @click="remove"
        :disabled="$route.name === 'pat-group-new' || !hasPatInfoAuthority"
      >削除</v-ons-button
      >-->
      <v-ons-button
        class="nik-btn cancel print-none btn2-cancel"
        @click="cancelToScreen"
        >キャンセル</v-ons-button
      >
      <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
      <!-- <v-ons-button
        class="nik-btn remove print-none btn4-alert"
        @click="remove"
        :disabled="$route.name === 'pat-group-new' || !hasPatInfoAuthority"
        >削除</v-ons-button
      > -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button -->
      <!--   class="nik-btn remove print-none btn4-alert" -->
      <!--   @click="remove" -->
      <!--   :disabled="($route.name === 'pat-group-new' || !hasPatInfoAuthority) || editFlag" -->
      <!--   >削除</v-ons-button -->
      <!-- > -->
      <v-ons-button
        class="nik-btn remove print-none btn4-alert"
        @click="remove"
        :disabled="($route.name === 'pat-group-new' || editFlag || !getItemAuthorized('PatGroup', 'default_authority'))"
        >削除</v-ons-button
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
      <!--mod FNSI-改修内容画面デザイン 任 end-->
      <!--      mod  FNSI-印刷対応 xie end -->

      <!--      mod  FNSI-権限 陳 end-->

      <!--      mod  FNSI-印刷対応 xie start-->
      <!--  <div class="spacer"></div>
      <v-ons-button class="nik-btn cancel" @click="gotoListScreen"
        >キャンセル</v-ons-button>
-->
      <!--mod FNSI-改修内容画面デザイン 任 start-->
      <!--<div class="spacer"></div>
      <v-ons-button class="nik-btn cancel print-none" @click="gotoListScreen"
      >キャンセル</v-ons-button>-->
      <div class="spacer"></div>
      <!--mod FNSI-改修内容画面デザイン 任 end-->
      <!--      mod  FNSI-印刷対応 xie end -->

      <!--      mod  FNSI-権限 陳 start-->
      <!--      mod  FNSI-印刷対応 xie start-->
      <!--  <v-ons-button
        class="nik-btn save"
        @click="save"
        :disabled="!hasPatInfoAuthority"
        >保存</v-ons-button>
-->
      <!--mod FNSI-改修内容画面デザイン 任 start-->
      <!--<v-ons-button
        class="nik-btn save print-none"
        @click="save"
        :disabled="!hasPatInfoAuthority"
      >保存</v-ons-button
      >-->
      <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start -->
      <!-- <v-ons-button
        class="nik-btn save print-none btn1-execute"
        @click="save"
        :disabled="!hasPatInfoAuthority"
        >保存</v-ons-button
      > -->
      <!-- mod #10109 2023-12-11 患者グループ画面の保存ボタンの色が不正 宮崎 start -->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button -->
      <!--   class="nik-btn print-none btn1-execute" -->
      <!--   @click="save" -->
      <!--   :disabled="!hasPatInfoAuthority || editFlag || !isChanged" -->
      <!--   >保存</v-ons-button -->
      <!-- > -->
      <v-ons-button
        class="nik-btn print-none btn1-execute"
        @click="save"
        :disabled="editFlag || !getItemAuthorized('PatGroup', 'default_authority') || !isChanged"
        >保存</v-ons-button
      >
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      <!-- mod #10109 2023-12-11 患者グループ画面の保存ボタンの色が不正 宮崎 end -->
      <!-- mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end -->
      <!--mod FNSI-改修内容画面デザイン 任 end-->

      <!--      mod  FNSI-印刷対応 xie end -->

      <!--      mod  FNSI-権限 陳 start-->
    </div>
    <!-- / Actions -->

    <!-- Loading -->
    <v-ons-modal :visible="isLoading">
      <p class="loading-modal">
        {{ loadingMessage }}
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
    <!-- / Loading -->
    <!-- add BUG修正 陳 start -->
    <message-dialog
      v-model:visible="isDialogVisble"
      v-bind="dialogProps"
      type="1"
    />
    <!-- add BUG修正 陳 end -->
    <!--add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start-->
    <message-dialog
      v-if="messageDialogInfo.isDialogVisible"
      v-model:visible="messageDialogInfo.isDialogVisible"
      :message-cd="messageDialogInfo.messageCd"
      :type="messageDialogInfo.type"
    />
    <!--add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end-->
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import PatGroup from "@/apis/pat-group";
// add  FNSI-権限 陳 start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import messageDialog from "@/components/common/message-dialog/MessageDialog.vue";
// add  FNSI-権限 陳 end
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { EventBus } from "@/compat/vue/event-bus.js";
// add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
import {PATIENT_SEARCH} from "@/constants/defaultSettingConstants";
import {deepCopy} from "@/functions/common/CommonFunctions";
// add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
// add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
import { FUNC_PAT_INFO, FUNC_PAT_INFO_CREATE } from "@/constants/function-code";
// add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
import { messageFormat } from '@/functions/common/MessageFormat';
import nameDuplicationImg from "../../assets/name_duplication.png";
import { getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
import { findAncestorWithMethod } from "@/functions/common/ComponentOwnerResolver";

// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
// del #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
// import store from "@/stores";
// del #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end

export default {
  // add BUG修正 陳 start
  components: {
    "message-dialog": messageDialog,
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB
  },
  // add BUG修正 陳 end
  name: "PatGroupEditComponent",
  // add  FNSI-権限 陳 start
  mixins: [ComponentGuardMixin],
  // add  FNSI-権限 陳 end
  data() {
    return {
      isAdd: null,
      freeText: "",
      // del #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      //unselectedPatList: [],
      // del #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      unselectedSelection: [],
      selectedSelection: [],
      // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      sortConditions: [
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 }
      ],
      // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      /*add FNSI-改修内容患者groupbug 任 start*/
      image_src_same: nameDuplicationImg,
      /*add FNSI-改修内容患者groupbug 任 end*/
      isShowDetailSearch: false,
      isLoading: false,
      loadingMessage: "",
      handleEventBlur: true,
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
      messageDialogInfo: {
        isDialogVisible: false,
        messageCd: null,
        type: null,
        stringParams: [],
        targetName: null,
      },
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
      // add  FNSI-権限 陳 start
      isDialogVisble: false,
      dialogProps: null,
      // del #10359 編集権限の動作不正 dengshen start
      // hasPatInfoAuthority: false,
      // del #10359 編集権限の動作不正 dengshen end
      // add  FNSI-権限 陳 end
      // del #10359 編集権限の動作不正 dengshen start
      // // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
      // isPatViewAuthorized: null,
      // isPatEditAuthorized: null,
      // isCreatePatViewAuthorized: null,
      // del #10359 編集権限の動作不正 dengshen end
      editFlag: null,
      // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
      isButtonClicked: false,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc start
      initEditedPatGroup: null,
      isChanged: false,
      // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc end
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng start
      initPatList: [],
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng end
    };
  },
  // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
  props: {
    // 新規登録フラグ
    isCreationPat: { type: Boolean, default: false }
  },
  // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
  computed: {
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    // mod 10389 患者リストのソートが遅い gjn start
    ...mapGetters("pat-info", ["searchedPatListPatGroup","unselectedPatList","getSortPatInfo", "getSortPatInfo", "selectedPatId"]),
    // mod 10389 患者リストのソートが遅い gjn end
    // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    // mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    //...mapGetters("account-edit", ["getDefaultSetting"]),
    ...mapGetters("account-edit", ["getDefaultSetting", "getStateUserAccountInfo", "getUseFunctions"]),
    // mod #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    /*mod FNSI-改修内容redmine4120 任 start*/
    /*...mapGetters("pat-group", ["editedPatGroup"]),*/
    ...mapGetters("pat-group", ["editedPatGroup", "selectedPatGroup"]),
    /*mod FNSI-改修内容redmine4120 任 end*/
    // add BUG修正 陳 start
    classObject() {
      return {
        // 編集時に適用されるclass
        "custom-input-edited": false,
        "custom-input-color": true,
      };
    },
    // add BUG修正 陳 end
  },
  watch: {
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
    // del #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
//     selectedSelection:{
//       handler(newVal) {
//         if(newVal==''){
//           store.dispatch("report/getMstReport", {funcCd: "02303",printFlag: 0});
//         }else{
//           store.dispatch("report/getMstReport", {funcCd: "02303",printFlag: 1});
//         }
//       }
//     },
    // del #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
    // add BUG修正 陳 start
    isDialogVisble() {
      // 共通ローダーを非表示
      this.setLoadingScreenVisible(false);
    },
    // add BUG修正 陳 end
    $route(to) {
      this.initData(to.name, true);
    },
    // del FNSI-改修内容患者グループ名を入力たけ、グループ保存できるように修正 王 start
    //"editedPatGroup.selectedPatList"() {
    //  this.checkSelectedPatListError();
    //},
    // del FNSI-改修内容患者グループ名を入力たけ、グループ保存できるように修正 王 end
    // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    // searchedPatListPatGroup(patList) {
    //   this.setUnselectedPatList(patList);
    // },
    async searchedPatListPatGroup(patList) {
      this.startLoading("患者ソート中");
      // 追加検索
      await this.setUnselectedPatList(patList, this.unselectedPatList.length > 0);
    },
    // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc start
    editedPatGroup: {
      handler(newVal){
        if (!!this.initEditedPatGroup && !!newVal &&
            JSON.stringify(this.initEditedPatGroup).replace(/\s/g, '')
            !== JSON.stringify(newVal).replace(/\s/g, '')) {
          this.isChanged = true;
        } else {
          this.isChanged = false;
        }
      },
      deep: true
    },
    // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc end
    // add start 馬 #9578
    getDefaultSetting: {
      handler() {
        this.setDefaultCondition();
      },
      deep: true,
      immediate: true
    },
    // add end 馬 #9578
  },
  methods: {
    formatPatId({ hosp_pat_id }) {
      return `${hosp_pat_id}`;
    },
    formatPatName({ pat_last_name, pat_first_name }) {
      return `${pat_last_name == null ? "" : pat_last_name} ${pat_first_name == null ? "" : pat_first_name}`;
    },
    ...mapActions("multi-modal", ["showDetailedSearchModalo"]),
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    ...mapActions("pat-info", ["sortPatList","setUnselectedPatListForGroup"]),
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    // mod 10389 患者リストのソートが遅い gjn start
    ...mapActions("pat-group", [
      "setSelectedPatGroup",
      "setEditedPatGroup",
      "clearState",
      "sortPatListRight",
    ]),
    // mod 10389 患者リストのソートが遅い gjn end
    // add  FNSI-権限 陳 start
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    // mod 10389 患者リストのソートが遅い gjn start
    ...mapMutations("pat-info", ["setPatGroupEditSortCondition", "setSortPatInfo"]),
    // mod 10389 患者リストのソートが遅い gjn end
    // del #10359 編集権限の動作不正 dengshen start
    // // 權限を取得する
    // getPatInfoAuthority() {
    //   return (
    //     this.hasAuthorityByCd(AUTHORITY_CODES.PAT_PEDIT) ||
    //     this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT)
    //   );
    // },
    // del #10359 編集権限の動作不正 dengshen end
    // add  FNSI-権限 陳 end
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    initData(routeName, needReset) {
      if (needReset) {
        this.resetData();
      }
      /*add FNSI-改修内容グループ详细画面，仍表示被选中的グループ 任 start*/
      if (routeName === "pat-group-new") {
        this.setEditedPatGroup({
          patGroupName: "",
          selectedPatList: [],
        });
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc start
        this.initEditedPatGroup = JSON.parse(JSON.stringify({
          patGroupName: "",
          selectedPatList: [],
        }));
        // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc end
      }
      /*add FNSI-改修内容グループ详细画面，仍表示被选中的グループ 任 end*/

      if (routeName === "pat-group-edit") {
        this.getPatGroup().then(() => this.searchPatSimple());
        return;
      }
      // mod FNSI-改修内容患者グループ名を入力たけ、グループ保存できるように修正 王 start
      //this.searchPatSimple().then(() => this.checkSelectedPatListError());
      this.searchPatSimple();
      // mode FNSI-改修内容患者グループ名を入力たけ、グループ保存できるように修正 王 end
    },
    // 患者グループ名の初期化
    initPatGroupName() {
      // 背景色の初期化
      const objPatGroupName = this.getPatGroupNameInput();
      if (objPatGroupName) {
        objPatGroupName.style.background = "#ffff99";
      }
    },
    getPatGroup() {
      /*mod FNSI-改修内容画面が正常表示できないとメッセージ不正修正 任 start*/
      /*this.startLoading("患者グループ情報を習得しています");*/
      this.startLoading("患者グループ情報を取得しています");
      /*mod FNSI-改修内容画面が正常表示できないとメッセージ不正修正 任 end*/
      return PatGroup.get({
        facilityCd: this.facilityCd,
        patGroupCd: this.$route.params.patGroupCd,
      })
        .then(({ data }) => {
          const patGroupName = data.patGroupInfo.patGroupName;
          /*mod FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 start*/
          /*const selectedPatList = data.patGroupDetail.map(
            ({ patId, patHospId, patLastName, patFirstName }) => ({
              pat_id: patId,
              hosp_pat_id: patHospId,
              pat_last_name: patLastName,
              pat_first_name: patFirstName
            }));*/
          const selectedPatList = data.patGroupDetail.map(
            ({ patId, patHospId, patLastName, patFirstName, inOutClass }) => ({
              pat_id: patId,
              hosp_pat_id: patHospId,
              pat_last_name: patLastName,
              pat_first_name: patFirstName,
              in_out_class: inOutClass,
              is_same: 0
            })
          );
          /*mod FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 end*/
          this.setSelectedPatGroup({
            patGroupName,
            selectedPatList: this.clone(selectedPatList),
          });
          this.setEditedPatGroup({
            patGroupName,
            selectedPatList: this.clone(selectedPatList),
          });
          /*add FNSI-改修内容患者groupbug 任 start*/
          if (this.editedPatGroup.selectedPatList.length > 0) {
            this.editedPatGroup.selectedPatList.forEach((item) => {
              // add 8220 施設イベント詳細画面の表示が遅い 関 start
              item.is_same = 0;
              // add 8220 施設イベント詳細画面の表示が遅い 関  end
              if (this.$route.params.sameList != null) {
                this.$route.params.sameList.forEach((param) => {
                  if (item.pat_id === param.pat_id) {
                    item.is_same = param.is_same;
                  }
                });
              }
            });
          }
          /*add FNSI-改修内容redmine4120 任 start*/
          if (this.selectedPatGroup.selectedPatList.length > 0) {
            this.selectedPatGroup.selectedPatList.forEach((item) => {
              // add 8220 施設イベント詳細画面の表示が遅い 関 start
              item.is_same = 0;
              // add 8220 施設イベント詳細画面の表示が遅い 関  end
              if (this.$route.params.sameList != null) {
                this.$route.params.sameList.forEach((param) => {
                  if (item.pat_id === param.pat_id) {
                    item.is_same = param.is_same;
                  }
                });
              }
            });
          }
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc start
          this.initEditedPatGroup = JSON.parse(JSON.stringify(this.editedPatGroup));
          // add #10053 破棄確認・保存活性(複数変更含む)・削除対応_患者グループ 20231124 ztc end
          /*add FNSI-改修内容redmine4120 任 end*/
          /*add FNSI-改修内容患者groupbug 任 end*/
        })
        .catch(() => this.gotoListScreen())
        .finally(() => this.stopLoading());
    },
    searchPatSimple() {
      this.handleEventBlur = true;
      this.startLoading("患者検索中");
      return ApiHelper.configPost("/patInfo/getSimpleSearchResult", {
        facilityCdList: [this.facilityCd],
      }, {
        params: { selectedPatId: this.selectedPatId }
      })
        .then(({ data }) => this.normalizePatData(data))
        // modify #9578 start
        // .then((data) => this.setUnselectedPatList(data))
        // .finally(() => this.stopLoading());
        .then(async(data) => {
          this.setUnselectedPatListForGroup(data);
          //del 10389 フロントエンドソート解除機能 gjn start
          // if (this.sortConditions?.[0]?.key) {
          //   await this.sortPatList(this.sortConditions);
          // }
          //del 10389 フロントエンドソート解除機能 gjn end
          this.initPatList = deepCopy(this.unselectedPatList);
          this.initPatList.forEach((item, index)=>{
            item.sort = index + 1;
          });
          data = this.freeText ? this.filterByFreetext(data) : data;
          this.setUnselectedPatList(data);
        });
        // modify #9578 end
    },
    filterByFreetext(patList) {
      const regex = new RegExp(`.*${this.freeText}.*`, "i");
      return patList.filter(
        (pat) =>
          regex.test(`${pat.pat_last_name}${pat.pat_first_name}`) ||
          regex.test(pat.hosp_pat_id)
      );
    },
    singleSelect(name, index) {
      this[`${name}Selection`].includes(index)
        ? this[`${name}Selection`].splice(
            this[`${name}Selection`].indexOf(index),
            1
          )
        : this[`${name}Selection`].push(index);
    },
    rangeSelect(name, index) {
      const selectedIndexes = this[`${name}Selection`].sort(this.sortNumber);
      const firstSelectedIndex = selectedIndexes[0];
      const lastSelectedIndex = selectedIndexes[selectedIndexes.length - 1];
      if (index < firstSelectedIndex) {
        this[`${name}Selection`] = Array.from(
          { length: lastSelectedIndex - index + 1 },
          (v, i) => i + index
        );
      } else if (index > lastSelectedIndex) {
        this[`${name}Selection`] = Array.from(
          { length: index - firstSelectedIndex + 1 },
          (v, i) => i + firstSelectedIndex
        );
      } else {
        this[`${name}Selection`] = Array.from(
          { length: lastSelectedIndex - firstSelectedIndex + 1 },
          (v, i) => i + firstSelectedIndex
        );
      }
    },
    // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng start
    sortPat(arr, key) {
      arr.sort((a, b)=>{
        let x = a[key]
        let y = b[key]
        return (x<y) ? -1 :((x>y) ? 1 : 0)
      })
      return arr;
    },
    // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng end
    addAllPat() {
      this.unselectedSelection = [];
      // #11732 患者グループ編集中、重複して登録される start
      // this.editedPatGroup.selectedPatList = [
      //   ...this.editedPatGroup.selectedPatList,
      //   ...this.unselectedPatList,
      // ];
      const epg = deepCopy(this.editedPatGroup);
      epg.selectedPatList.push(...this.unselectedPatList);
      this.setEditedPatGroup(epg);
      // add 10389 患者リストのソートが遅い gjn start
      // this.selectedPatGroup.selectedPatList = [
      //   ...this.selectedPatGroup.selectedPatList,
      //   ...this.unselectedPatList,
      // ];
      const spg = deepCopy(this.selectedPatGroup);
      spg.selectedPatList.push(...this.unselectedPatList);
      this.setSelectedPatGroup(spg);
      // #11732 患者グループ編集中、重複して登録される end

      // add 10389 患者リストのソートが遅い gjn end
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng start
      // del 10389 gjn 患者リストのソートが遅い start
      //this.editedPatGroup.selectedPatList = this.sortPat(this.editedPatGroup.selectedPatList, 'sort');
      // del 10389 gjn 患者リストのソートが遅い end
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng end
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      this.setUnselectedPatListForGroup([]);
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    },
    addPat() {
      // #11732 患者グループ編集中、重複して登録される start
      const epg = deepCopy(this.editedPatGroup);
      const uspl = deepCopy(this.unselectedPatList);
      this.unselectedSelection.sort(this.sortNumber).forEach((index) => {
        // this.editedPatGroup.selectedPatList.push(this.unselectedPatList[index]);
        epg.selectedPatList.push(uspl[index]);
      });
      this.setEditedPatGroup(epg);
      this.unselectedSelection.reverse().forEach((index) => {
        // this.unselectedPatList.splice(index, 1);
        uspl.splice(index, 1);
      });
      this.setUnselectedPatListForGroup(uspl);
      // #11732 患者グループ編集中、重複して登録される end
      this.unselectedSelection = [];
      // del #11732 患者グループ編集中、重複して登録される start
      // add 10389 患者リストのソートが遅い gjn start
      // this.setEditedPatGroup(this.editedPatGroup);
      this.setSelectedPatGroup(this.editedPatGroup);
      // add 10389 患者リストのソートが遅い gjn end
      // del #11732 患者グループ編集中、重複して登録される end
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng start
      // del 10389 gjn 患者リストのソートが遅い start
      //this.editedPatGroup.selectedPatList = this.sortPat(this.editedPatGroup.selectedPatList, 'sort')
      // del 10389 gjn 患者リストのソートが遅い end
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng end
    },
    removePat() {
      // #11732 患者グループ編集中、重複して登録される start
      const epg = deepCopy(this.editedPatGroup);
      const uspl = deepCopy(this.unselectedPatList);
      this.selectedSelection.sort(this.sortNumber).forEach((index) => {
        // this.unselectedPatList.push(this.editedPatGroup.selectedPatList[index]);
        uspl.push(epg.selectedPatList[index]);
      });
      this.setUnselectedPatListForGroup(uspl);
      this.selectedSelection.reverse().forEach((index) => {
        // this.editedPatGroup.selectedPatList.splice(index, 1);
        epg.selectedPatList.splice(index, 1);
      });
      this.setEditedPatGroup(epg);
      // #11732 患者グループ編集中、重複して登録される end
      this.selectedSelection = [];
      // del #11732 患者グループ編集中、重複して登録される start
      // add 10389 患者リストのソートが遅い gjn start
      // this.setEditedPatGroup(this.editedPatGroup);
      this.setSelectedPatGroup(this.editedPatGroup);
      // add 10389 患者リストのソートが遅い gjn end
      // del #11732 患者グループ編集中、重複して登録される end
    },
    removeAllPat() {
      this.selectedSelection = [];
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      const unselectedPatList = [
        ...this.unselectedPatList,
        ...this.editedPatGroup.selectedPatList,
      ];
      this.setUnselectedPatListForGroup(unselectedPatList);
      // #11732 患者グループ編集中、重複して登録される start
      const epg = deepCopy(this.editedPatGroup);
      const spg = deepCopy(this.selectedPatGroup);
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      // this.editedPatGroup.selectedPatList = [];
      epg.selectedPatList = [];
      this.setEditedPatGroup(epg);
      // add 10389 患者リストのソートが遅い gjn start
      // this.selectedPatGroup.selectedPatList = [];
      spg.selectedPatList = [];
      this.setSelectedPatGroup(spg);
      // add 10389 患者リストのソートが遅い gjn end
      // #11732 患者グループ編集中、重複して登録される end
    },
    remove() {
      this.$ons.notification
        .confirm({
          title: "削除確認",
          message: "削除すると二度と元に戻せません。削除してもよろしいですか？"
        })
        .then((ok) => {
          if (ok) {
            this.startLoading("患者グループ削除中");
            //mod #11607 患者グループを削除した時の通知メッセージが不適切 zrx start
            let hasPatFlag = false
            PatGroup.get({
              facilityCd: this.facilityCd,
              patGroupCd: this.$route.params.patGroupCd,
            }).then(({ data }) => {
              const hasPatList = data.patGroupDetail;
              if(hasPatList && hasPatList.length > 0) {
                hasPatFlag = true
              }
            }).finally(() => {
              PatGroup.remove(this.$route.params.patGroupCd)
                .then(() => {
                  this.removeToScreen()
                  if(hasPatFlag) {
                    ApiHelper.post("/pat_group/notification-message", {
                      patGroupName: this.editedPatGroup.patGroupName,
                      ficilityCd: this.facilityCd,
                      patGroupCd: this.$route.params.patGroupCd,
                    });
                  }
                })
                .finally(() => this.stopLoading());
            });
            //mod #11607 患者グループを削除した時の通知メッセージが不適切 zrx end
          }
        });
    },
    async save() {
      // add BUG修正 陳 start
      // 患者グループ名の必須入力スタイル
      const patGroupNameInput = this.getPatGroupNameInput();
      const isPatGroupNameValid = await this.validateField("pat-group-name");

      if (patGroupNameInput) {
        patGroupNameInput.style.background = isPatGroupNameValid
          ? "#ffff99"
          : "rgba(255, 0, 0, 0.5)";
      }

      if (!isPatGroupNameValid) {
        const firstEmptyFormName = "患者グループ名";
        this.showDialog({
          messageCd: 22010001,
          title: DIALOG_MESSAGES[22010001].title,
          stringParams: [firstEmptyFormName],
        });
        return false;
      }
      // add BUG修正 陳 end
      this.$route.name === "pat-group-new"
        ? this.createPatGroup()
        : this.updatePatGroup();
    },
    /*mod FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
    /*createPatGroup() {*/
    async createPatGroup() {
      /*mod FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
      let isCreate = true;
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
      this.startLoading("患者グループ作成中");
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
      await PatGroup.list(this.facilityCd).then(({ data }) => {
        if (data.patGroupInfo) {
          data.patGroupInfo.forEach((item) => {
            if (item.patGroupName === this.editedPatGroup.patGroupName) {
              let messageCd = "02300019";
              this.messageDialogInfo.messageCd = messageCd;
              this.messageDialogInfo.type = "1";
              this.messageDialogInfo.isDialogVisible = true;
              isCreate = false;
            }
          });
        }
      });
      if (isCreate) {
        /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
        PatGroup.create({
          facilityCd: this.facilityCd,
          patGroupName: this.editedPatGroup.patGroupName,
          patIds: this.editedPatGroup.selectedPatList.map(
            ({ pat_id }) => pat_id
          ),
        })
          // add 9664 by kangjie 20231220 start
          // .then() => {
          .then((resp) => {
            this.patGroupCdOfCreated = resp.data;
            // add 9664 by kangjie 20231220 end
            //add #11607 患者グループを削除した時の通知メッセージが不適切 zrx start
            const createPatGroupName = this.editedPatGroup.patGroupName;
            //add #11607 患者グループを削除した時の通知メッセージが不適切 zrx end
            this.resetData(true);
            this.searchPatSimple();
            this.isButtonClicked = true;
            this.setSelectedPatGroup(this.clone(this.editedPatGroup));
            // add FNSI-4788 范 start
            this.isAdd = "0";
            this.$router.push({ name: "pat-group" });
            // add FNSI-4788 范 end
            // add 9546 by kangjie 20231220 start
            ApiHelper.post("/pat_group/notification-message", {
              //mod #11607 患者グループを削除した時の通知メッセージが不適切 zrx start
              // patGroupName: this.editedPatGroup.patGroupName,
              patGroupName: createPatGroupName,
              //mod #11607 患者グループを削除した時の通知メッセージが不適切 zrx end
              ficilityCd: this.facilityCd,
              // mode 9546 by kangjie 20230830 start
              patGroupCd: this.patGroupCdOfCreated,
              // mode 9546 by kangjie 20230830 end
            });
            // add 9546 by kangjie 20231220 end
          })
          .finally(() => this.stopLoading());
        /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
      } else {
        this.stopLoading();
      }
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
    },
    /*mod FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
    /*updatePatGroup() {*/
    async updatePatGroup() {
      /*mod FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
      this.startLoading("患者グループ更新中");
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
      let isCreate = true;
      await PatGroup.list(this.facilityCd).then(({ data }) => {
        if (data.patGroupInfo) {
          data.patGroupInfo
            .filter((info) => {
              return info.patGroupCd != this.$route.params.patGroupCd;
            })
            .forEach((item) => {
              if (item.patGroupName === this.editedPatGroup.patGroupName) {
                let messageCd = "02300019";
                this.messageDialogInfo.messageCd = messageCd;
                this.messageDialogInfo.type = "1";
                this.messageDialogInfo.isDialogVisible = true;
                isCreate = false;
              }
            });
        }
      });
      if (isCreate) {
        /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
        PatGroup.update({
          patGroupCd: this.$route.params.patGroupCd,
          facilityCd: this.facilityCd,
          patGroupName: this.editedPatGroup.patGroupName,
          patIds: this.editedPatGroup.selectedPatList.map(
            ({ pat_id }) => pat_id
          ),
        })
          .then(() => {
            // add 9546 by kangjie 20231220 start
            //add FutreNetWeb+SI課題管理 no.4266 劉全航 start
            ApiHelper.post("/pat_group/notification-message", {
              patGroupName: this.editedPatGroup.patGroupName,
              ficilityCd: this.facilityCd,
              // mode 9546 by kangjie 20230830 start
              patGroupCd: this.$route.params.patGroupCd,
              // mode 9546 by kangjie 20230830 end
            });
            //add FutreNetWeb+SI課題管理 no.4266 劉全航 end
            // add 9546 by kangjie 20231220 end
            this.isButtonClicked = true;
            this.setSelectedPatGroup(this.clone(this.editedPatGroup));
            // add FNSI-4788 范 start
            this.isAdd = "0";
            this.$router.push({ name: "pat-group" });
            // add FNSI-4788 范 end

          })
          .catch(() => this.gotoListScreen())
          .finally(() => this.stopLoading());
        /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 start*/
      } else {
        this.stopLoading();
      }
      /*add FNSI-改修内容患者グループ名を重複登録可の問題対応 任 end*/
    },
    normalizePatData(data) {
      /*mod FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 start*/
      /*return data.map(
        ({ pat_id, hosp_pat_id, pat_last_name, pat_first_name }) => ({
          pat_id,
          hosp_pat_id,
          pat_last_name,
          pat_first_name
        }));*/
      return data.map(
        ({
          pat_id,
          hosp_pat_id,
          pat_last_name,
          pat_first_name,
          in_out_class,
        }) => ({
          pat_id,
          hosp_pat_id,
          pat_last_name,
          pat_first_name,
          in_out_class,
        })
      );
      /*mod FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 end*/
    },
    // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    // modify #9578 start
    async setUnselectedPatList(unselectedPatList, isAdd = false) {
    // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      const selectedPatIDs = this.editedPatGroup.selectedPatList.map(
        ({ pat_id }) => pat_id
      );
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      const patList = unselectedPatList.filter(
        ({ pat_id }) => !selectedPatIDs.includes(pat_id)
      );
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      /*add FNSI-改修内容患者groupbug 任 start*/
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
      //if (this.unselectedPatList.length > 0) {
      //  this.unselectedPatList.forEach((item) => {
      if (patList.length > 0) {
        patList.forEach((item) => {
      // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
          // add 8220 施設イベント詳細画面の表示が遅い 関 start
          item.is_same = 0;
          // add 8220 施設イベント詳細画面の表示が遅い 関  end
          if (this.$route.params.sameList != null) {
            this.$route.params.sameList.forEach((param) => {
              if (item.pat_id === param.pat_id) {
                item.is_same = param.is_same;
              }
            });
          }
        });
        // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
        // mod 10389 患者リストのソートが遅い gjn start
        this.setUnselectedPatListForGroup(patList);
        if (this.getSortPatInfo?.[0]?.key && !isAdd) {
          let gsp = deepCopy(this.getSortPatInfo);
          var param = { patGroup: null }
          gsp.push(param);
          // 患者グループ画面左側の患者リストを順に更新
          await this.sortPatList({
            sortConditions: gsp,
            selectedPatId: this.selectedPatId
          });
          // 患者グループ画面右側の患者リストを順に更新
          await this.sortPatListRight({
            sortConditions: gsp,
            selectedPatId: this.selectedPatId
          });
        }
        // mod 10389 患者リストのソートが遅い gjn end
        // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
        // if(null !== this.sortConditions[0].key) {
        //   await this.sortPatList(this.sortConditions);
        // }
      } else {
        this.setUnselectedPatListForGroup([]);
      }
      /*add FNSI-改修内容患者groupbug 任 end*/
      this.unselectedSelection = [];
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng start
      // del 10389 患者リストのソートが遅い gjn start
      // this.editedPatGroup.selectedPatList.forEach((item)=>{
      //   let sortObj = this.initPatList.find(ele => ele.pat_id === item.pat_id)
      //   item.sort = sortObj && sortObj.sort ? sortObj.sort : null;
      // })
      // this.editedPatGroup.selectedPatList = this.sortPat(this.editedPatGroup.selectedPatList, 'sort')
      // this.unselectedPatList.forEach((item)=>{
      //   let sortObj = this.initPatList.find(ele => ele.pat_id === item.pat_id)
      //   item.sort = sortObj && sortObj.sort ? sortObj.sort : null;
      // })
      // del 10389 患者リストのソートが遅い gjn end
      // #9579 患者グループ編集で個人設定のソート条件が適応されていない linjunfeng end
      this.stopLoading();
      // #9578 end
    },
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
    setDefaultCondition() {
      // 初期値を入れる
      this.sortConditions = [
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 },
        { key: null, isAsc: 1 }
      ];

      // デフォルト設定
      const defaultCondition = deepCopy(this.getDefaultSetting[PATIENT_SEARCH.KEY_NAME]);
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS] != null) {
          this.sortConditions = defaultCondition[PATIENT_SEARCH.KEY_NAME_SORT_CONDITIONS];
        }
      }
      var param = { patGroup: null }
      this.sortConditions.push(param)
      // add start 馬 #9578
      this.setPatGroupEditSortCondition(this.sortConditions);
      // add end 馬 #9578
    },
    // add #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
    /* del FNSI-改修内容患者グループ名を入力たけ、グループ保存できるように修正 王 start */
    /*checkSelectedPatListError() {
      if (this.editedPatGroup.selectedPatList.length === 0) {
        this.pushValidationError({
          field: "selected-pat-list",
          msg: "患者が一人以上ご選択ください。"
        });
      } else {
        this.removeValidationErrorById("selected-pat-list");
      }
    },*/
    /* del FNSI-改修内容患者グループ名を入力たけ、グループ保存できるように修正 王 end */
    gotoListScreen() {
      this.$router.push({ name: "pat-group" });
    },
    // キャンセルイベント
    cancelToScreen() {
      this.isButtonClicked = true;
      this.gotoListScreen();
    },
    // 削除イベント
    removeToScreen() {
      this.isButtonClicked = true;
      this.gotoListScreen();
    },
    resetData(resetAll = false) {
      if (resetAll) {
        // Dont reset patGroupName, unselectedPatList, selectedPatList
        // for cloning pat group when click add new from edit screen
        this.setEditedPatGroup({
          patGroupName: "",
          selectedPatList: [],
        });
        // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 start
        this.setUnselectedPatListForGroup([]);
        // mod #9579 患者グループ編集で個人設定のソート条件が適応されていない 商 end
      }

      this.freeText = "";
      this.unselectedSelection = [];
      this.selectedSelection = [];
      this.isShowDetailSearch = false;
      this.isLoading = false;
      this.loadingMessage = "";
      // 背景色の初期化
      const objPatGroupName = this.getPatGroupNameInput();
      if (objPatGroupName) {
        objPatGroupName.style.background = "#ffff99";
      }
    },
    clone(data) {
      return JSON.parse(JSON.stringify(data));
    },
    sortNumber(num1, num2) {
      return num1 - num2;
    },
    startLoading(message) {
      this.isLoading = true;
      this.loadingMessage = message;
    },
    stopLoading() {
      this.isLoading = false;
    },
    onBlurSearch() {
      if (this.handleEventBlur) {
        this.searchPatSimple();
      }
    },

    // add BUG修正 陳 start
    /**
     * @description ダイアログ表示
     * @param {String} messageCd ダイアログメッセージコード
     * @param {String} title ダイアログタイトル
     * @param {Array} stringParams メッセージ引数
     */
    showDialog({ messageCd, title, stringParams }) {
      this.isDialogVisble = true;
      // ダイアログに与えるprops作成
      this.dialogProps = { messageCd, title, stringParams };
    },
    addFocusCss(event) {
      let element = event.target;
      element?.classList?.add("custom-input-edited");
    },
    delFocusCss(event) {
      let element = event.target;
      element.classList.remove("custom-input-edited");
    },
    // add BUG修正 陳 end

    onMousedownSearch() {
      this.handleEventBlur = false;
    },
    // 検索条件のクリア
    clearCondition() {
      EventBus.$emit("clearCondition")
    },
    getPatGroupNameInput() {
      return getScopedElementById("pat-group-name", this.$el || null);
    },
    resolvePatGroupOwner() {
      return findAncestorWithMethod(this, ["isContentChanged"], { maxDepth: 12 });
    },
    // #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng start
    refresh(flag = false) {
      // 引数がtrueの場合処理を行う
      if(flag){
        const patGroupOwner = this.resolvePatGroupOwner();
        if (patGroupOwner?.isContentChanged?.()) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[13000004].title,
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer == 1) {
                this.initData(this.$route.name);
                this.initPatGroupName();
              }
            }
          });
        } else {
          this.initData(this.$route.name);
          this.initPatGroupName();
        }
      }
    },
    // #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng end
  },
  created() {
    // #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng start
    EventBus.$off('refresh', this.refresh);
    EventBus.$on('refresh', this.refresh);
    // #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng end
    // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 start
    // mod #10359 編集権限の動作不正 dengshen start
    // if ( this.isCreationPat ) {
    //   this.isCreatePatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isCreatePatViewAuthorized && this.isPatEditAuthorized);
    // } else {
    //   this.isPatViewAuthorized = this.getUseFunctions.includes(FUNC_PAT_INFO);
    //   this.isPatEditAuthorized = this.getStateUserAccountInfo.userSettings.authorized_authorities.includes(AUTHORITY_CODES.PAT_EDIT);
    //   this.editFlag = !(this.isPatViewAuthorized && this.isPatEditAuthorized);
    // }
    if ( this.isCreationPat) {
      this.editFlag = !this.getUseFunctions.includes(FUNC_PAT_INFO_CREATE);
    } else {
      this.editFlag = !this.getUseFunctions.includes(FUNC_PAT_INFO);
    }
    // mod #10359 編集権限の動作不正 dengshen end
    // add #9820 利用者マスタの患者情報編集権限がOFFなのに患者経過総合ビューアで編集/保存ができてしまう 商 end
    this.initData(this.$route.name);
    // del #10359 編集権限の動作不正 dengshen start
    // // add  FNSI-権限 陳 start
    // this.hasPatInfoAuthority = this.getPatInfoAuthority();
    // // add  FNSI-権限 陳 end
    // del #10359 編集権限の動作不正 dengshen end
  },

  beforeUnmount() {
    this.clearState();
    // #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng start
    EventBus.$off('refresh', this.refresh);
    // #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng end
  },
};
</script>

<style scoped>
div[id^="pat-group"] {
  color: var(--ntss-list-body-color);
  height: 100%;
  padding-right: 1em;
  padding-left: 1em;
  overflow: auto;
}
div[id^="pat-group"] > div {
  margin-top: 1em;
}
label {
  margin-right: 0.4em;
  white-space: nowrap;
}
ons-input :deep(input) {
  color: var(--ntss-list-body-color);
  background-color: var(--ntss-list-background-color);
}
.pat-search > div {
  margin-top: 0.5em;
}
.pat-search > div:first-child {
  margin-top: 0px;
}
.pat-search .title {
  color: #fff;
  padding: 4px;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  background-image: -webkit-linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
.pat-search ons-button.detailed-search {
  border-radius: 0;
  background-color: var(--ntss-btn-ok-background-color);
  padding-top: 2px;
  padding-bottom: 2px;
  font-size: 1em;
}
.pat-list {
  min-height: 171.2px;
}
.pat-list .unselected-pat-list,
.pat-list .selected-pat-list {
  position: relative;
}
.pat-list .tools {
  padding-right: 0.3em;
  padding-left: 0.3em;
}
.pat-list .tools > button {
  margin-bottom: 0.4em;
  font-size: 1em;
  box-shadow: none;
}
.pat-list .tools > button:last-child {
  margin-bottom: 0;
}
.pat-display {
  padding: 0.5em 0.3em;
  word-wrap: break-word;
}
/* mod 6910 デグレ：患者選択状態を解除できない 関 start */
/* .pat-display.selected {
  z-index: -1;
} */
.pat-display.selected {
  background-color: #0076ff;
}
/* mod 6910 デグレ：患者選択状態を解除できない 関  end */
.pat-display-row:hover {
  background-color: #ddeeff80;
}
.actions > ons-button {
  margin-right: 0.4em;
}
.actions > ons-button:last-child {
  margin-right: 0;
}
.actions > ons-button.remove {
  background-color: #0076ff;
}
.actions > ons-button.cancel {
  background-color: #add8e6;
}
.loading-modal {
  font-size: 2.5em;
}
.common-style-ok-button {
  min-width: 100px;
}
/*add FNSI-改修内容移動前と移動後の様式修正、行を単位で選択。 任 start*/
.modelTop {
  width: 44%;
  height: 100%;
  border: 1px solid #dee2e6;
}
.modelTitle {
  height: 2em;
  display: flex;
  align-items: center;
  position: sticky;
  top: 0px;
  z-index: 3;
}
.color-header {
  padding-left: 0px !important;
}
.modelTitleID {
  width: 50%;
  border-right: 1px solid #dee2e6;
  color: white;
  padding-left: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.modelTitleName {
  width: 50%;
  color: white;
  padding-left: 4px;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
.modelInfo {
  width: 100%;
  height: calc(100% - 0.1em);
  overflow: auto;
  word-break: break-all;
}
/* mod FNSI-改修内容3890bug修正 関 end */
/* add BUG修正 陳 start*/
.custom-input-edited {
  border: 2px green solid;
  outline: 0;
}
/* add BUG修正 陳 end*/
textarea.custom-input-color {
  color: black;
  background-color: #ffff99;
}
/*add FNSI-改修内容移動前と移動後の様式修正、行を単位で選択。 任 end*/

/*      mod  FNSI-印刷対応 xie start */
@media print {
  .print-none {
    display: none;
    visibility: hidden;
  }
  .dis_box {
    align-items: unset !important;
  }
}
/*      mod  FNSI-印刷対応 xie end */
/*add FNSI-改修内容患者groupbug 任 start*/
.same-icon {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
}
/*add FNSI-改修内容患者groupbug 任 end*/
/*add FNSI-改修内容入外区分が入院の場合、患者名は紫色にする 任 start*/
.pat-name-in-hospital {
  color: #a356a3;
}
.dis_box {
  display: flex;
  align-items: center;
  justify-content: space-around;
}



.k-button[disabled]{
  outline: none;
  cursor: default;
  opacity: .65;
  -webkit-filter: grayscale(.1);
  filter: grayscale(.1);
  pointer-events: none;
  -webkit-box-shadow: none;
  box-shadow: none;
}
</style>
