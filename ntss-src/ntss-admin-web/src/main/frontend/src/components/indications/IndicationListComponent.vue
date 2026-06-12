<template>
  <div class="main-content-area d-flex flex-column">
    <!-- Patient list  Treatment Unit -->
    <div class="grid flex-1" v-if="isTreatmentUnit">
      <table style="width: max-content;">
        <thead>
          <tr>
            <th class="resize-colomn-table manual-width">
              <span @click="sortTreatmentList('id')" :class="getSortedClass('id')">患者ID</span>
            </th>
            <th class="resize-colomn-table manual-width">
              <span @click="sortTreatmentList('name')" :class="getSortedClass('name')">患者名</span>
            </th>
            <th class="resize-colomn-table manual-width">
              <span @click="sortTreatmentList('treatment')" :class="getSortedClass('treatment')">治療方法</span>
            </th>
            <th class="resize-colomn-table manual-width">
              <span @click="sortTreatmentList('kur')" :class="getSortedClass('kur')">クール</span>
            </th>
            <th class="resize-colomn-table manual-width">
              <span @click="sortTreatmentList('bed')" :class="getSortedClass('bed')">ベッド</span>
            </th>
<!-- mod sort 修正 chen start -->
            <th class="checker manual-width" v-show="columnStatus.isShowChecker1">
<!--            <th @click="sortCheck1" class="checker" v-show="columnStatus.isShowChecker1">-->
              <div class="d-flex align-items-center">
                <div class="flex-1" :class="getSortedClass('check1')" @click="sortTreatmentList('check1')" >指示受け1</div>
<!--                <div class="flex-1" :class="getSortedClass('check1')">指示受け1</div>-->
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click="checkAll1"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                  visibility: unchecked1Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  ALL <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click="checkAll1" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--   visibility: unchecked1Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click="checkAll1"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: unchecked1Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </th>
            <th class="checker manual-width" v-show="columnStatus.isShowChecker2">
<!--            <th @click="sortCheck2" class="checker" v-show="columnStatus.isShowChecker2">-->
              <div class="d-flex align-items-center">
                <div class="flex-1" :class="getSortedClass('check2')" @click="sortTreatmentList('check2')">指示受け2</div>
<!--                <div class="flex-1" :class="getSortedClass('check2')">指示受け2</div>-->
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click="checkAll2"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25 ,
                  visibility: unchecked2Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  ALL <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click="checkAll2" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25 , -->
                <!--   visibility: unchecked2Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click="checkAll2"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25 ,
                  visibility: unchecked2Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </th>
            <th class="approver manual-width" v-show="columnStatus.isShowApprover1">
<!--            <th @click="sortApprove1" class="approver" v-show="columnStatus.isShowApprover1">-->
              <div class="d-flex align-items-center">
                <div class="flex-1" :class="getSortedClass('approve1')" @click="sortTreatmentList('approve1')">指示承認1</div>
<!--                <div class="flex-1" :class="getSortedClass('approve1')">指示承認1</div>-->
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click="approveAll1"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                    visibility: isShowBtnOK && unapproved1Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  ALL <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click="approveAll1" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--     visibility: isShowBtnOK && unapproved1Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click="approveAll1"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: isShowBtnOK && unapproved1Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </th>
            <th class="approver manual-width" v-show="columnStatus.isShowApprover2">
<!--            <th @click="sortApprove2" class="approver" v-show="columnStatus.isShowApprover2">-->
              <div class="d-flex align-items-center">
                <div class="flex-1" :class="getSortedClass('approve2')" @click="sortTreatmentList('approve2')">指示承認2</div>
<!--                <div class="flex-1" :class="getSortedClass('approve2')">指示承認2</div>-->
<!-- mod sort 修正 chen end -->
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click="approveAll2"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                    visibility: isShowBtnOK && unapproved2Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  ALL <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click="approveAll2" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--     visibility: isShowBtnOK && unapproved2Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click="approveAll2"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: isShowBtnOK && unapproved2Indications.length > 0 && this.isAllApproverUnit ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="indication in treatmentIndications" :key="indication.ord_no">
            <td class="id resize-colomn-table hosp-pat-id-body">
              {{ indication.hosp_pat_id }}
            </td>
            <!--mod 入外区分が入院の場合、患者名は紫色にする chen start -->
            <td class="name resize-colomn-table" :class="indication.in_out_class == 1 ? 'in_class' : ''">{{ indication.pat_full_name }}
              <img v-if="indication.is_same === '1'" class='same-icon' :src="image_src_same" />
            </td>
            <!--<td class="name resize-colomn-table">{{ indication.pat_full_name }}</td>-->
            <!--mod 入外区分が入院の場合、患者名は紫色にする chen start -->
            <td class="treatment-method resize-colomn-table">
              <!-- modify by chamaojia 2025-03-03 [11471] change in the assignment of 【treatmentName】 start -->
<!--              {{ treatmentName(indication.ind_treatment_cd) }}-->
              {{ treatmentName(indication) }}
              <!-- modify by chamaojia 2025-03-03 [11471] change in the assignment of 【treatmentName】 end -->
            </td>

            <td v-if="isTreatmentUnit" class="resize-colomn-table">{{ kurName(indication.ind_kur_cd) || "未登録" }}</td>

            <td v-if="isTreatmentUnit" class="resize-colomn-table">{{ bedName(indication.ind_bed_cd) || "未登録 " }}</td>

            <td
              :class="[
                'checker',
                { empty: !indication.check_user1_cd },
                { 'content-change': !!+indication.is_content_changed }
              ]"
              @click="goToDetail(indication, 'receive')"
              v-show="columnStatus.isShowChecker1"
            >
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ userName(indication.check_user1_cd) }}
                </div>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click.stop="check1(indication)"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                  visibility: !!+indication.is_content_changed || !indication.check_user1_cd ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click.stop="check1(indication)" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--   visibility: !!+indication.is_content_changed || !indication.check_user1_cd ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click.stop="check1(indication)"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: !!+indication.is_content_changed || !indication.check_user1_cd ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </td>

            <td
              :class="[
                'checker',
                { empty: !indication.check_user2_cd },
                { 'content-change': !!+indication.is_content_changed }
              ]"
              @click="goToDetail(indication, 'receive')"
              v-show="columnStatus.isShowChecker2"
            >
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ userName(indication.check_user2_cd) }}
                </div>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click.stop="check2(indication)"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                  visibility: !!+indication.is_content_changed || !indication.check_user2_cd ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click.stop="check2(indication)" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--   visibility: !!+indication.is_content_changed || !indication.check_user2_cd ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click.stop="check2(indication)"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: !!+indication.is_content_changed || !indication.check_user2_cd ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </td>

            <td
              :class="[
                'approver',
                { empty: !indication.approve_user1_cd },
                { 'content-change': !!+indication.is_content_appd_changed }
              ]"
              v-show="columnStatus.isShowApprover1"
              @click="goToDetail(indication, 'approve')"
            >
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ userName(indication.approve_user1_cd) }}
                </div>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click.stop="approve1(indication)"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                  visibility: isShowBtnOK && (!!+indication.is_content_appd_changed || !indication.approve_user1_cd) ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click.stop="approve1(indication)" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--   visibility: isShowBtnOK && (!!+indication.is_content_appd_changed || !indication.approve_user1_cd) ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click.stop="approve1(indication)"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: isShowBtnOK && (!!+indication.is_content_appd_changed || !indication.approve_user1_cd) ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
              </div>
            </td>

            <td
              :class="[
                'approver',
                { empty: !indication.approve_user2_cd },
                { 'content-change': !!+indication.is_content_appd_changed }
              ]"
              v-show="columnStatus.isShowApprover2"
              @click="goToDetail(indication, 'approve')"
            >
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ userName(indication.approve_user2_cd) }}
                </div>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 start -->
                <!-- <div
                  class="icon btn1-execute btn-ntss-custom"
                  @click.stop="approve2(indication)"
                  :style="{ opacity: hasIndReceiveAuthority ? 1 : .25,
                  visibility: isShowBtnOK && (!!+indication.is_content_appd_changed || !indication.approve_user2_cd) ? 'visible' : 'hidden',
                   'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}"
                >
                  <img :src="okIcon" alt="ok icon" />
                </div> -->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   @click.stop="approve2(indication)" -->
                <!--   :style="{ opacity: hasIndReceiveAuthority ? 1 : .25, -->
                <!--   visibility: isShowBtnOK && (!!+indication.is_content_appd_changed || !indication.approve_user2_cd) ? 'visible' : 'hidden', -->
                <!--    'pointer-events': hasIndReceiveAuthority ? 'auto' : 'none'}" -->
                <!-- > -->
                <button
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click.stop="approve2(indication)"
                  :style="{ opacity: getItemAuthorized('IndicationList', 'default_authority') ? 1 : .25,
                  visibility: isShowBtnOK && (!!+indication.is_content_appd_changed || !indication.approve_user2_cd) ? 'visible' : 'hidden',
                  'pointer-events': getItemAuthorized('IndicationList', 'default_authority') ? 'auto' : 'none'}"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <img :src="okIcon" alt="ok icon" />
                </button>
                <!-- mod 8074 【デグレ】ログに誤った利用者が記録される 関 end -->
              </div>
            </td>
          </tr>
        </tbody>
      </table>

    <!-- Legend & Actions -->
    <div
      class="d-flex align-items-center slide_bottom"
      ref="legendAndActions"
      v-if="isTreatmentUnit"
    >
      <!-- Legend -->
      <div class="legend flex-1 d-flex">
        <div class="unprocessed d-flex align-items-center">
          <div class="color"></div>
          <div class="text">未チェック</div>
        </div>

        <div class="changed d-flex align-items-center">
          <div class="color"></div>
          <div class="text">変更あり</div>
        </div>
      </div>
      <!-- / Legend -->
    </div>
    <!-- / Legend & Actions -->
    </div>
    <!-- / Patient list -->


    <!-- Patient list Indication -->
    <div class="grid flex-1" v-if="!isTreatmentUnit">
      <table style="width: max-content;">
        <thead>
          <tr>
            <th class="resize-colomn-table manual-width">
              <span @click="sortIndicationsList('id')" :class="getSortedClass('id')">患者ID</span>
            </th>
            <th class="resize-colomn-table manual-width">
              <span @click="sortIndicationsList('name')" :class="getSortedClass('name')">患者名</span>
            </th>
            <th class="checker manual-width" v-show="columnStatus.isShowChecker1">
              <div class="d-flex align-items-center">
                <div @click="sortIndicationsList('check1')" class="flex-1" :class="getSortedClass('check1')">指示受け1</div>
<!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute icon btn-ntss-custom" -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   v-if="+selectedAll.totalCheck1 !== +selectedAll.summary" -->
                <!--   :style="{ -->
                <!--     visibility: this.isAllApproverUnit ? 'visible' : 'hidden' -->
                <!--   }" -->
                <!--   @click=" -->
                <!--     onClickUpdate( -->
                <!--       indicationsListSorted, -->
                <!--       INDICATIONTYPE.RECEIVER1, -->
                <!--       true -->
                <!--     ) -->
                <!--   " -->
                <!-- > -->
                <button
                  class="button btn1-execute icon btn-ntss-custom"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  v-if="+selectedAll.totalCheck1 !== +selectedAll.summary"
                  :style="{
                    visibility: this.isAllApproverUnit ? 'visible' : 'hidden'
                  }"
                  @click="
                    onClickUpdate(
                      sortedIndicationsList,
                      INDICATIONTYPE.RECEIVER1,
                      true
                    )
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
<!--                <button-->
<!--                  class="button icon btn-ntss-custom"-->
<!--                  v-if="+selectedAll.totalCheck1 !== +selectedAll.summary"-->
<!--                  @click="-->
<!--                    onClickUpdate(-->
<!--                      indicationsListSorted,-->
<!--                      INDICATIONTYPE.RECEIVER1,-->
<!--                      true-->
<!--                    )-->
<!--                  "-->
<!--                >-->
<!--                  ALL <img :src="okIcon" alt="ok icon" />-->
<!--                </button>-->
                <!--            mod    FNSI-権限 陳 end-->
              </div>
            </th>
            <th class="checker manual-width" v-show="columnStatus.isShowChecker2">
              <div class="d-flex align-items-center">
                <div @click="sortIndicationsList('check2')" class="flex-1" :class="getSortedClass('check2')">指示受け2</div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   class="button btn1-execute icon btn-ntss-custom" -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   v-if="+selectedAll.totalCheck2 !== +selectedAll.summary" -->
                <!--   :style="{ -->
                <!--     visibility: this.isAllApproverUnit ? 'visible' : 'hidden' -->
                <!--   }" -->
                <!--   @click=" -->
                <!--     onClickUpdate( -->
                <!--       indicationsListSorted, -->
                <!--       INDICATIONTYPE.RECEIVER2, -->
                <!--       true -->
                <!--     ) -->
                <!--   " -->
                <!-- > -->
                <button
                  class="button btn1-execute icon btn-ntss-custom"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  v-if="+selectedAll.totalCheck2 !== +selectedAll.summary"
                  :style="{
                    visibility: this.isAllApproverUnit ? 'visible' : 'hidden'
                  }"
                  @click="
                    onClickUpdate(
                      sortedIndicationsList,
                      INDICATIONTYPE.RECEIVER2,
                      true
                    )
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
<!--                <button-->
<!--                  class="button icon btn-ntss-custom"-->
<!--                  v-if="+selectedAll.totalCheck2 !== +selectedAll.summary"-->
<!--                  @click="-->
<!--                    onClickUpdate(-->
<!--                      indicationsListSorted,-->
<!--                      INDICATIONTYPE.RECEIVER2,-->
<!--                      true-->
<!--                    )-->
<!--                  "-->
<!--                >-->
<!--                  ALL <img :src="okIcon" alt="ok icon" />-->
<!--                </button>-->
                <!--            mod    FNSI-権限 陳 end -->
              </div>
            </th>
            <th
              class="checker manual-width"
              v-show="columnStatus.isShowApprover1"
            >
              <div class="d-flex align-items-center">
                <div @click="sortIndicationsList('approve1')" class="flex-1" :class="getSortedClass('approve1')">指示承認1</div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   class="button btn1-execute icon btn-ntss-custom" -->
                <!--   v-if="isShowBtnOK && +selectedAll.totalApprover1 !== +selectedAll.summary" -->
                <!--   :style="{ -->
                <!--     visibility: this.isAllApproverUnit ? 'visible' : 'hidden' -->
                <!--   }" -->
                <!--   @click=" -->
                <!--     onClickUpdate( -->
                <!--       indicationsListSorted, -->
                <!--       INDICATIONTYPE.APPROVER1, -->
                <!--       true -->
                <!--     ) -->
                <!--   " -->
                <!-- > -->
                <button
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  class="button btn1-execute icon btn-ntss-custom"
                  v-if="isShowBtnOK && +selectedAll.totalApprover1 !== +selectedAll.summary"
                  :style="{
                    visibility: this.isAllApproverUnit ? 'visible' : 'hidden'
                  }"
                  @click="
                    onClickUpdate(
                      sortedIndicationsList,
                      INDICATIONTYPE.APPROVER1,
                      true
                    )
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                  <button-->
<!--                  class="button icon btn-ntss-custom"-->
<!--                  v-if="isShowBtnOK && +selectedAll.totalApprover1 !== +selectedAll.summary"-->
<!--                  @click="-->
<!--                    onClickUpdate(-->
<!--                      indicationsListSorted,-->
<!--                      INDICATIONTYPE.APPROVER1,-->
<!--                      true-->
<!--                    )-->
<!--                  "-->
<!--                >-->
                  <!--            mod    FNSI-権限 陳 end-->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
              </div>
            </th>
            <th
              class="checker manual-width"
              v-show="columnStatus.isShowApprover2"
            >
              <div class="d-flex align-items-center">
                <div @click="sortIndicationsList('approve2')" class="flex-1" :class="getSortedClass('approve2')">指示承認2</div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   class="button btn1-execute icon btn-ntss-custom" -->
                <!--   v-if="isShowBtnOK && +selectedAll.totalApprover2 !== +selectedAll.summary" -->
                <!--   :style="{ -->
                <!--     visibility: this.isAllApproverUnit ? 'visible' : 'hidden' -->
                <!--   }" -->
                <!--   @click=" -->
                <!--     onClickUpdate( -->
                <!--       indicationsListSorted, -->
                <!--       INDICATIONTYPE.APPROVER2, -->
                <!--       true -->
                <!--     ) -->
                <!--   " -->
                <!-- > -->
                <button
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  class="button btn1-execute icon btn-ntss-custom"
                  v-if="isShowBtnOK && +selectedAll.totalApprover2 !== +selectedAll.summary"
                  :style="{
                    visibility: this.isAllApproverUnit ? 'visible' : 'hidden'
                  }"
                  @click="
                    onClickUpdate(
                      sortedIndicationsList,
                      INDICATIONTYPE.APPROVER2,
                      true
                    )
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                  <button-->
<!--                  class="button icon btn-ntss-custom"-->
<!--                  v-if="isShowBtnOK && +selectedAll.totalApprover2 !== +selectedAll.summary"-->
<!--                  @click="-->
<!--                    onClickUpdate(-->
<!--                      indicationsListSorted,-->
<!--                      INDICATIONTYPE.APPROVER2,-->
<!--                      true-->
<!--                    )-->
<!--                  "-->
<!--                >-->
                  <!--            mod    FNSI-権限 陳 end-->
                  ALL <img :src="okIcon" alt="ok icon" />
                </button>
              </div>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="indication in sortedIndicationsList"
            :key="indication.hospPatId"
          >
            <td class="id resize-colomn-table hosp-pat-id-body">
              {{ indication.hospPatId }}
            </td>
            <!--mod FNSI-入外区分が入院の場合、患者名は紫色にする dou start -->
            <!--<td class="name resize-colomn-table">{{ indication.patName }}</td> -->
            <td class="name resize-colomn-table" :class="inOutFlag(indication)">{{ indication.patName }}
              <img v-show="indication.is_same === '1'" class='same-icon' :src="image_src_same" />
            </td>
            <!--mod FNSI-入外区分が入院の場合、患者名は紫色にする dou end -->
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 start -->
            <td
              class="name"
              v-show="columnStatus.isShowChecker1"
              @click="goToIndicationDetail(indication, 'receive')"
              :class="[
                { 'check-approver-dark-grey' : indication.check1 === indication.total ? true : false}
                ]"
            >
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 end -->
              <div class="d-flex align-items-center">
                <div class="flex-1 align-items-center">
                  {{ indication.check1 }} / {{ indication.total }}
                </div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   v-if="!hasIndReceiveAuthority" -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!-- > -->
                <button
                  v-if="+indication.check1 !== +indication.total"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click.stop="
                    onClickUpdate(indication, INDICATIONTYPE.RECEIVER1, false)
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <img :src="okIcon" alt="ok icon" />
                </button>
<!--                <button-->
<!--                  class="button indication-icon btn-ntss-custom"-->
<!--                  :style="{-->
<!--                    opacity: +indication.check1 === +indication.total ? 0 : 1-->
<!--                  }"-->
<!--                  @click.stop="-->
<!--                    onClickUpdate(indication, INDICATIONTYPE.RECEIVER1, false)-->
<!--                  "-->
<!--                >-->
<!--                  <img :src="okIcon" alt="ok icon" />-->
<!--                </button>-->
                <!--            mod    FNSI-権限 陳 end-->
              </div>
            </td>
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 start -->
            <td
              class="name"
              v-show="columnStatus.isShowChecker2"
              @click="goToIndicationDetail(indication, 'receive')"
              :class="[
                { 'check-approver-dark-grey' : indication.check2 === indication.total ? true : false}
                ]"
            >
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 end -->
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ indication.check2 }} / {{ indication.total }}
                </div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   v-if="!hasIndReceiveAuthority" -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!-- > -->
                <button
                  v-if="+indication.check2 !== +indication.total"
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  @click.stop="
                    onClickUpdate(indication, INDICATIONTYPE.RECEIVER2, false)
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
                  <img :src="okIcon" alt="ok icon" />
                </button>
<!--                <button-->
<!--                  class="button indication-icon btn-ntss-custom"-->
<!--                  :style="{-->
<!--                    opacity: +indication.check2 === +indication.total ? 0 : 1-->
<!--                  }"-->
<!--                  @click.stop="-->
<!--                    onClickUpdate(indication, INDICATIONTYPE.RECEIVER2, false)-->
<!--                  "-->
<!--                >-->
<!--                  <img :src="okIcon" alt="ok icon" />-->
<!--                </button>-->
                <!--            mod    FNSI-権限 陳 end-->
              </div>
            </td>
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 start -->
            <td
              class="name"
              v-show="columnStatus.isShowApprover1"
              @click="goToIndicationDetail(indication, 'approve')"
              :class="[
                { 'check-approver-dark-grey' : indication.approver1 === indication.total ? true : false}
                ]"
            >
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 end -->
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ indication.approver1 }} / {{ indication.total }}
                </div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   v-if="isShowBtnOK && +indication.approver1 !== +indication.total" -->
                <!--   @click.stop=" -->
                <!--     onClickUpdate(indication, INDICATIONTYPE.APPROVER1, false) -->
                <!--   " -->
                <!-- > -->
                <button
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  v-if="isShowBtnOK && +indication.approver1 !== +indication.total"
                  @click.stop="
                    onClickUpdate(indication, INDICATIONTYPE.APPROVER1, false)
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                  <button-->
<!--                    class="button indication-icon btn-ntss-custom"-->
<!--                    v-if="isShowBtnOK && +indication.approver1 !== +indication.total"-->
<!--                    @click.stop="-->
<!--                    onClickUpdate(indication, INDICATIONTYPE.APPROVER1, false)-->
<!--                  "-->
<!--                  >-->
                  <!--            mod    FNSI-権限 陳 end-->
                  <img :src="okIcon" alt="ok icon" />
                </button>
              </div>
            </td>
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 start -->
            <td
              class="name"
              v-show="columnStatus.isShowApprover2"
              @click="goToIndicationDetail(indication, 'approve')"
              :class="[
                { 'check-approver-dark-grey' : indication.approver2 === indication.total ? true : false}
                ]"
            >
            <!-- add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 end -->
              <div class="d-flex align-items-center">
                <div class="flex-1">
                  {{ indication.approver2 }} / {{ indication.total }}
                </div>
                <!--            mod    FNSI-権限 陳 start-->
                <!-- mod #10359 編集権限の動作不正 dengshen start -->
                <!-- <button -->
                <!--   :disabled="!hasIndReceiveAuthority" -->
                <!--   class="button btn1-execute indication-icon btn-ntss-custom" -->
                <!--   v-if="isShowBtnOK && +indication.approver2 !== +indication.total" -->
                <!--   @click.stop=" -->
                <!--     onClickUpdate(indication, INDICATIONTYPE.APPROVER2, false) -->
                <!--   " -->
                <!-- > -->
                <button
                  :disabled="!getItemAuthorized('IndicationList', 'default_authority')"
                  class="button btn1-execute indication-icon btn-ntss-custom"
                  v-if="isShowBtnOK && +indication.approver2 !== +indication.total"
                  @click.stop="
                    onClickUpdate(indication, INDICATIONTYPE.APPROVER2, false)
                  "
                >
                <!-- mod #10359 編集権限の動作不正 dengshen end -->
<!--                  <button-->
<!--                    class="button indication-icon btn-ntss-custom"-->
<!--                    v-if="isShowBtnOK && +indication.approver2 !== +indication.total"-->
<!--                    @click.stop="-->
<!--                    onClickUpdate(indication, INDICATIONTYPE.APPROVER2, false)-->
<!--                  "-->
<!--                  >-->
                  <!--            mod    FNSI-権限 陳 end-->
                  <img :src="okIcon" alt="ok icon" />
                </button>
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <!-- / Patient list Indication -->

    <!-- Loading -->
    <v-ons-modal :visible="isLoading">
      <p class="loading-modal">
        {{ loadingMessage }}
        <v-ons-icon icon="fa-spinner" spin />
      </p>
    </v-ons-modal>
    <!-- / Loading -->
  </div>
</template>

<script>
// add #10359 編集権限の動作不正 dengshen start
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
// add #10359 編集権限の動作不正 dengshen end
import { mapActions, mapMutations, mapGetters } from "@/compat/vue/vuex";
import Indication from "@/apis/indication";
// add  FNSI-権限 陳 start
// del #10359 編集権限の動作不正 dengshen start
// import { AUTHORITY_CODES } from "@/constants/userAuthority";
// del #10359 編集権限の動作不正 dengshen end
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add  FNSI-権限 陳 end
// add 画面印刷プレビューと印刷の実現 黄 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { EventBus } from "@/compat/vue/event-bus.js";
import dayjs from "@/compat/date/dayjs";
// add 画面印刷プレビューと印刷の実現 黄 end
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
import {createJournal} from "@/apis/journal";
import {MASTER_DELETE_DISPLAY} from "@/constants/TreatmentRecord";
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
// add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
// del #11004 連携イベント発生部分不正 piao start
// import { sendRequestGetCoopIniSchModifySendClass } from "@/apis/treatment-record";
// del #11004 連携イベント発生部分不正 piao end
// add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { sortableCompare } from "@/functions/SortFunctions";
import okImg from "../../assets/ok.png";
import nameDuplicationImg from "../../assets/name_duplication.png";
import { getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";

export default {
  name: "IndicationListComponent",
// add  FNSI-権限 陳 start
  mixins: [ComponentGuardMixin],
// add  FNSI-権限 陳 end
  data() {
    return {
      patList: [],
// mod 7570 ind_dial連携で送信する項目情報部  赵 start
      // ordNoList:[],
// mod 7570 ind_dial連携で送信する項目情報部  赵 end
      // del #10359 編集権限の動作不正 dengshen start
      // // add  FNSI-権限 陳 start
      // hasIndReceiveAuthority: false,
      // // add  FNSI-権限 陳 end
      // del #10359 編集権限の動作不正 dengshen end
      isLoading: false,
      loadingMessage: "",
      okIcon: okImg,
      sortName: false,
      INDICATIONTYPE: {
        RECEIVER1: "receiver1",
        RECEIVER2: "receiver2",
        APPROVER1: "approver1",
        APPROVER2: "approver2"
      },
      INDICATIONTYPEVALUE: {
        RECEIVER1: 1,
        RECEIVER2: 2,
        APPROVER1: 3,
        APPROVER2: 4
      },
      reRender: true,
      SIGN_TYPE: {
        REMOVE: "0",
        SETTING: "1"
      },
      FACILITY_INS_APPTYPE: {
        ONLY_DOCTOR_OPERATION: "1",
        DOCTOR_LIST: "2",
        ALL_USER: "3",
      },
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      // del #11004 連携イベント発生部分不正 piao start
      // objModSendClass: "",
      // del #11004 連携イベント発生部分不正 piao end
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      // add 画面印刷プレビューと印刷の実現 陳 start
      dataArray: null,
      image_src_same: nameDuplicationImg,
      // add 画面印刷プレビューと印刷の実現 陳 end
      /**
       * 指示単位 key：ソート項目 value：apiレスポンスfield
       */
      sortIndicationsMap: {
        id: "hospPatId",
        name: "patNameSort",
        check1: "check1",
        check2: "check2",
        approve1: "approver1",
        approve2: "approver2"
      },
      sortTreatmentMap: {
        id: "hosp_pat_id",
        name: "patNameSort",
        kur: "ind_kur_start_time",
        bed: "ind_bed_order_index",
        treatment: "ind_treatment_order_index",
        check1: "is_user1_checked",
        check2: "is_user2_checked",
        approve1: "is_user1_approved",
        approve2: "is_user2_approved"
      },
    };
  },
  computed: {
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
    ...mapGetters("indication", [
      "mstTreatment",
      "mstKur",
      "mstPersonalUser",
      "isTreatmentUnit",
      "userId",
      "isDoctor",
      "sortedIndications",
      "columnStatus",
      "mstBed",
// NSI-修正 マスタ削除の対応 chen add start
      "isAllApproverUnit",
      "mstTreatmentDel",
      "mstKurDel",
      "mstBedDel",
// NSI-修正 マスタ削除の対応 chen add end
      "sortedIndicationsList",
      "treatmentIndications",
      "initSortedIndicationList",
      "selectedAll",
      "getUserInfo",
      "getTreatmentIndicationSortStatus",
      "treatmentIndicationSortingField",
      "indContentList",
      "facilityInsApp"
    ]),
    ...mapGetters("pat-info", ["selectedPat"]),
    // add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
    ...mapGetters("account-edit", ["getUserId"]),
    // add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
    // add FNSI-改修内容表示順でソート 付 start
    ...mapGetters("user", ["getFacilityCd"]),
    // add FNSI-改修内容表示順でソート 付 end
    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add 画面印刷プレビューと印刷の実現 黄 end
    selectedIndications() {
      return this.sortedIndications.filter(({ selected }) => selected);
    },
    unchecked1Indications() {
      return this.sortedIndications.filter(
        ({ is_content_changed, check_user1_cd }) => !check_user1_cd || !!+is_content_changed
      );
    },
    unchecked2Indications() {
      return this.sortedIndications.filter(
        ({ is_content_changed, check_user2_cd }) => !check_user2_cd || !!+is_content_changed
      );
    },
    unapproved1Indications() {
      return this.sortedIndications.filter(
        ({ is_content_appd_changed, approve_user1_cd }) => !approve_user1_cd || !!+is_content_appd_changed
      );
    },
    unapproved2Indications() {
      return this.sortedIndications.filter(
        ({ is_content_appd_changed, approve_user2_cd }) => !approve_user2_cd || !!+is_content_appd_changed
      );
    },
    isShowBtnOK() {
      return this.facilityInsApp === this.FACILITY_INS_APPTYPE.ALL_USER || this.isDoctor;
    }
  },
  watch: {
    initSortedIndicationList() {
      if (!this.isTreatmentUnit) {
        this.setSortedIndicationsList(this.initSortedIndicationList);
        // 画面描画時、ソート指定ありの場合はソート
        if (this.reRender) {
          this.treatmentIndicationSortingField && this.sortIndicationsList(this.treatmentIndicationSortingField);
          this.reRender = false;
        }
      }
    },
    sortedIndicationsList() {
      if (!this.isTreatmentUnit) {
        this.patList = this.sortedIndicationsList.map(item => ({
          pat_id: item.patId,
          hosp_pat_id: item.hospPatId,
          pat_last_name: item.patName,
          pat_first_name: "",
          ord_no: null,
          // add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
          is_same: item.is_same,
          in_out_class: item.in_out_class
          // add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
        }));
        // 遷移パラメータがあれば子画面へ
        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();
        if (queryParameters.isGotoDetails &&
            queryParameters.method &&
            queryParameters.indication) {
          this.goToIndicationDetail(queryParameters.indication, queryParameters.method);
        }
        // クエリパラメータをクリアする
        this.setQueryParameters({});
      }
    },
    treatmentIndications() {
      if (this.reRender && this.isTreatmentUnit) {
        this.reSortTreatmentIndications();
        this.reRender = false;
      }

      const component = this;
      if (this.isTreatmentUnit) {
        this.patList = this.treatmentIndications.map(
          ({
            ord_no,
            pat_id,
            pat_last_name,
            pat_first_name,
            ind_kur_cd,
            ind_bed_cd,
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
            is_same,
            in_out_class
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
          }) => ({
            ord_no,
            pat_id,
            pat_last_name: pat_last_name,
            pat_first_name: pat_first_name,
            kur_name: component.kurName(ind_kur_cd) || "未登録",
            bed_name: component.bedName(ind_bed_cd) || "未登録",
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
            is_same,
            in_out_class
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
          })
        );
        // 遷移パラメータがあれば子画面へ
        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();
        if (queryParameters.isGotoDetail &&
            queryParameters.method &&
            queryParameters.PATID &&
            queryParameters.ORDNO) {
          const indication = {
            pat_id: queryParameters.PATID,
            ord_no: queryParameters.ORDNO
          }
          this.goToDetail(indication, queryParameters.method);
        }
        // クエリパラメータをクリアする
        this.setQueryParameters({});
      }
    },
    // mod FNSI6299-患者の表示順が勝手に入れ替わる start
    //patList(value) {
    async patList(value) {
    // mod FNSI6299-患者の表示順が勝手に入れ替わる end
      await this.updateTreatmentPatList(value);
      //6299 test
      let tmpStr = "6299_patList: ";
      value.forEach(elem => {
        tmpStr = tmpStr + elem.pat_id + ", ";
      });
      console.log(`${tmpStr}`);

      this.setSrcFuncName(this.$route.name);
    }
  },
  methods: {
    ...mapActions("indication", [
      "getIndications",
      "setSortedIndicationsList",
      "setIndContentList"
    ]),
    ...mapMutations("indication", [
      "setTreatmentIndications",
      "setTreatmentIndicationSortStatus",
      "resetTreatmentIndications",
      "resetTreatmentIndicationSortStatus",
      "updateTreatmentIndicationItem"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    // add 画面印刷プレビューと印刷の実現 黄 start
     getDateParams(dateParam){
      this.dataArray = dateParam;
    },
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
    getSelectPatIds(){
      var pathIds = new Array();
      if(this.isTreatmentUnit){
        if(this.treatmentIndications != null){
          if(this.treatmentIndications.every(item => Object.prototype.hasOwnProperty.call(item, 'pat_id'))) {
            pathIds = this.treatmentIndications.map(({ pat_id }) => pat_id);
          }
          else {
            pathIds = this.treatmentIndications.map(({ patId }) => patId);
          }
        }
      }
      else {
        if(this.sortedIndicationsList != null){
          if(this.sortedIndicationsList.every(item => Object.prototype.hasOwnProperty.call(item, 'pat_id'))) {
            pathIds = this.sortedIndicationsList.map(({ pat_id }) => pat_id);
          }
          else {
            pathIds = this.sortedIndicationsList.map(({ patId }) => patId);
          }
        }
      }
      return pathIds;
    },
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        //add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
        let flgPat = this.$route.path === '/indication/list/' ? null : this.selectedPatId;
        //mod #9558 機能帳票で正しく変数が引き渡されていない 杜天成 start
        //let dateTodate = this.treatmentIndications[0].treat_date ? this.treatmentIndications[0].treat_date : this.dataArray.date;
        // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
        // let dateTodate = this.treatmentIndications[0] == undefined ? this.dataArray.date
        //   : this.treatmentIndications[0].treat_date == undefined ? this.dataArray.date : this.treatmentIndications[0].treat_date;
        let dateTodate = Date.now();
        if(this.treatmentIndications[0] != undefined){
          if(this.treatmentIndications[0].treat_date != null && this.treatmentIndications[0].treat_date != "") dateTodate = this.treatmentIndications[0].treat_date;
        }else if(this.dataArray.date != undefined){
          dateTodate = this.dataArray.date;
        }
        // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        //mod #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
        //add #9558 機能帳票で正しく変数が引き渡されていない 杜天成 end
        // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        const scopedSessionStorage = getScopedSessionStorage(this.$el);
        this.bedCdListString = JSON.parse(scopedSessionStorage.getItem('roomBedGroupNameStatusList')) || '';
        this.kurGroupName = JSON.parse(scopedSessionStorage.getItem('kurGroupNameStatusList')) || '';
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        // 印刷パラメータを応答
        const param = {
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          // patId: this.dataArray.PatId,
          // patIds: this.indicationsListSorted.map(({ pat_id }) => pat_id),
          // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 start
          //patId: this.selectedPatId,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: flgPat,
          facilityCd: this.getFacilityCd,
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(dateTodate).format('YYYYMMDD'),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          // patIds: this.searchedPatList != null ? this.searchedPatList.map(({ pat_id }) => pat_id) :[],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          // patIds: this.sortedIndicationsList != null ?
          //   (this.sortedIndicationsList.every(item => Object.prototype.hasOwnProperty.call(item, 'pat_id')) ?
          //       this.sortedIndicationsList.map(({ pat_id }) => pat_id) :
          //       this.sortedIndicationsList.map(({ patId }) => patId)
          //   ) :
          //   [],
          patIds: this.getSelectPatIds(),
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          // date: dayjs(Date.now()).format("YYYY/MM/DD"),
          functionCd:'02801',
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          // date: dayjs(this.dataArray.fromDate).format("YYYY/MM/DD"),
          // //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // fromDate: this.dataArray.fromDate,
          // toDate: this.dataArray.toDate
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          // date: dayjs(this.treatmentIndications[0].treat_date).format("YYYY/MM/DD"),
          // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 start
         // date: dayjs(this.date).format("YYYY/MM/DD"),
          date: dayjs(dateTodate).format('YYYY/MM/DD'),
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
          // fromDate: dayjs(this.treatmentIndications[0].treat_date).format("YYYY/MM/DD"),
          // toDate: dayjs(this.treatmentIndications[0].treat_date).format("YYYY/MM/DD"),
          //fromDate: dayjs(this.date).format("YYYY/MM/DD"),
          fromDate: dayjs(dateTodate).format('YYYY/MM/DD'),
          //toDate: dayjs(this.date).format("YYYY/MM/DD"),
          toDate: dayjs(dateTodate).format('YYYY/MM/DD'),
          // mod #9558機能帳票でパラメータが正しく渡されていない 杜天成 end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
          // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
          bedCdListString:this.bedCdListString,
          kurNames:this.kurGroupName !=='' ? this.kurGroupName.replaceAll(",","・") : "すべて",
          patGroups:patGroups,
          // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end
    // del #10359 編集権限の動作不正 dengshen start
    // // add  FNSI-権限 陳 start
    // // 權限を取得する
    // getIndReceiveAuthority() {
    //   return this.hasAuthorityByCd(AUTHORITY_CODES.IND_RECEIVE_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.IND_RECEIVE_EDIT);
    // },
    // // add  FNSI-権限 陳 end
    // del #10359 編集権限の動作不正 dengshen end
    ...mapActions("pat-info", ["selectPat"]),
    ...mapActions("treatment-record/common", ["setOrdNoForSideBarRecord"]),
    ...mapMutations("pat-info", [
      "updateTreatmentPatList", "setSrcFuncName"
    ]),
    async approve1(indication) {
      if ((!+indication.is_content_appd_changed && indication.approve_user1_cd) || !this.isShowBtnOK ) {
        return;
      }

      try {
        this.startLoading("承認しています。");
        //mod #9507 一括指示受けに時間がかかる zrx start
        // const contentParam = await this.getCheckApprove(indication)
        // await this.setIndContentList(contentParam);
        // const contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.APPROVER1, true);
        //
        // let rstDia = indication.rst_dialysis_state;
        // let tmpList = contentList;
        // let checkContent = this.arrangeData(tmpList, rstDia, "approve");
        // tmpList[0].approve_content = JSON.stringify(checkContent);
        // await Indication.approve1(tmpList[0]);
        //
        // await this.insertPatIndApproveHistory(
        //   [indication.ord_no],
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.APPROVER1],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        const indicationWithUser = {
          ...indication,
          treat_date: indication.treat_date,
          user_id: this.getUserId
        };
        const indicationWithUserList = [indicationWithUser];
        await this.bulkCheckOrApprove(
          [indication.ord_no],
          this.userId,
          [this.INDICATIONTYPEVALUE.APPROVER1],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          null,
          null,
          indicationWithUserList,
          null
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        // ソートなし状態の場合、データを更新する
        if (this.treatmentIndicationSortingField === null) {
          await this.getIndications();
        } else {
          // ストアの更新
          indication.is_user1_approved = "1";
          indication.approve_user1_cd = this.userId;
          indication.is_content_appd_changed = "0";
          this.updateTreatmentIndicationItem(indication);
        }
      } catch (error) {
        getErrorMessage('IndicationListComponent.vue', 'approve1', error);
        this.internalServerError(error);
      }

      //del #9507 一括指示受けに時間がかかる zrx start
      // const params = {
      //   ope_cd: "028019",
      //   crud: "U",
      //   pat_id: indication.pat_id,
      //   facility_cd: this.getFacilityCd,
      //   hosp_pat_id: indication.hosp_pat_id,
      //   ord_no: indication.ord_no,
      //   base_date: indication.treat_date,
      //   user_id: this.getUserId
      // };
      // createJournal(params);
      //del #9507 一括指示受けに時間がかかる zrx end
      this.stopLoading();
    },
    async approve2(indication) {
      if ((!+indication.is_content_appd_changed && indication.approve_user2_cd) || !this.isShowBtnOK) {
        return;
      }

      try {
        this.startLoading("承認しています。");
        //mod #9507 一括指示受けに時間がかかる zrx start
        // const contentParam = await this.getCheckApprove(indication)
        // await this.setIndContentList(contentParam);
        // const contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.APPROVER2, true);
        //
        // let rstDia = indication.rst_dialysis_state;
        // let tmpList = contentList;
        // let checkContent = this.arrangeData(tmpList, rstDia, "approve");
        // tmpList[0].approve_content = JSON.stringify(checkContent);
        // await Indication.approve2(tmpList[0]);
        //
        // await this.insertPatIndApproveHistory(
        //   [indication.ord_no],
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.APPROVER2],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        const indicationWithUser = {
          ...indication,
          treat_date: indication.treat_date,
          user_id: this.getUserId
        };
        const indicationWithUserList = [indicationWithUser];
        await this.bulkCheckOrApprove(
          [indication.ord_no],
          this.userId,
          [this.INDICATIONTYPEVALUE.APPROVER2],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          null,
          null,
          null,
          indicationWithUserList
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        // ソートなし状態の場合、データを更新する
        if (this.treatmentIndicationSortingField === null) {
          await this.getIndications();
        } else {
          // ストアの更新
          indication.is_user2_approved = "1";
          indication.approve_user2_cd = this.userId;
          indication.is_content_appd_changed = "0";
          this.updateTreatmentIndicationItem(indication);
        }
      } catch (error) {
        getErrorMessage('IndicationListComponent.vue', 'approve2', error);
        this.internalServerError(error);
      }

      //del #9507 一括指示受けに時間がかかる zrx start
      // const params = {
      //   ope_cd: "028020",
      //   crud: "U",
      //   pat_id: indication.pat_id,
      //   facility_cd: this.getFacilityCd,
      //   hosp_pat_id: indication.hosp_pat_id,
      //   ord_no: indication.ord_no,
      //   base_date: indication.treat_date,
      //   user_id: this.getUserId
      // };
      // createJournal(params);
      //del #9507 一括指示受けに時間がかかる zrx end
      this.stopLoading();
    },

    async check1(indication) {
      if (!+indication.is_content_changed && indication.check_user1_cd) {
        return;
      }

      try {
        this.startLoading("指示を確認しています。");
        //mod #9507 一括指示受けに時間がかかる zrx start
        // const contentParam = await this.getCheckApprove(indication)
        // await this.setIndContentList(contentParam);
        // const contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.RECEIVER1, true);
        //
        // let rstDia = indication.rst_dialysis_state;
        // let tmpList = contentList;
        // let checkContent = this.arrangeData(tmpList, rstDia, "check");
        // tmpList[0].check_content = JSON.stringify(checkContent);
        // await Indication.check1(tmpList[0]);
        //
        // await this.insertPatIndApproveHistory(
        //   [indication.ord_no],
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.RECEIVER1],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        const indicationWithUser = {
          ...indication,
          treat_date: indication.treat_date,
          user_id: this.getUserId
        };
        const indicationWithUserList = [indicationWithUser];

        await this.bulkCheckOrApprove(
          [indication.ord_no],
          this.userId,
          [this.INDICATIONTYPEVALUE.RECEIVER1],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          indicationWithUserList,
          null,
          null,
          null
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        // ソートなし状態の場合、データを更新する
        if (this.treatmentIndicationSortingField === null) {
          await this.getIndications();
        } else {
          // ストアの更新
          indication.is_user1_checked = "1";
          indication.check_user1_cd = this.userId;
          indication.is_content_changed = "0";
          this.updateTreatmentIndicationItem(indication);
        }
      } catch (error) {
        getErrorMessage('IndicationListComponent.vue', 'check1', error);
        this.internalServerError(error);
      }
      //del #9507 一括指示受けに時間がかかる zrx start
      // if(parseInt(indication.rst_dialysis_state) < 6 && indication.ind_kur_cd != 0){
      //   let crudTmp = "U";
      //   const params = {
      //     ope_cd: "028001",
      //     crud: crudTmp,
      //     pat_id: indication.pat_id,
      //     facility_cd: this.getFacilityCd,
      //     hosp_pat_id: indication.hosp_pat_id,
      //     ord_no: indication.ord_no,
      //     base_date: indication.treat_date,
      //     user_id: this.getUserId
      //   };
      //   createJournal(params);
      // }
      //del #9507 一括指示受けに時間がかかる zrx end
      this.stopLoading();
    },
    async check2(indication) {
      if (!+indication.is_content_changed && indication.check_user2_cd) {
        return;
      }

      try {
        this.startLoading("指示を確認しています。");
        //mod #9507 一括指示受けに時間がかかる zrx start
        // const contentParam = await this.getCheckApprove(indication)
        // await this.setIndContentList(contentParam);
        // const contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.RECEIVER2, true);
        //
        // let rstDia = indication.rst_dialysis_state;
        // let tmpList = contentList;
        // let checkContent = this.arrangeData(tmpList, rstDia, "check");
        // tmpList[0].check_content = JSON.stringify(checkContent);
        // await Indication.check2(tmpList[0]);
        //
        // await this.insertPatIndApproveHistory(
        //   [indication.ord_no],
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.RECEIVER2],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        const indicationWithUser = {
          ...indication,
          treat_date: indication.treat_date,
          user_id: this.getUserId
        };
        const indicationWithUserList = [indicationWithUser];

        await this.bulkCheckOrApprove(
          [indication.ord_no],
          this.userId,
          [this.INDICATIONTYPEVALUE.RECEIVER2],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          null,
          indicationWithUserList,
          null,
          null
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        // ソートなし状態の場合、データを更新する
        if (this.treatmentIndicationSortingField === null) {
          await this.getIndications();
        } else {
          // ストアの更新
          indication.is_user2_checked = "1";
          indication.check_user2_cd = this.userId;
          indication.is_content_changed = "0";
          this.updateTreatmentIndicationItem(indication);
        }
      } catch (error) {
        getErrorMessage('IndicationListComponent.vue', 'check2', error);
        this.internalServerError(error);
      }
      //del #9507 一括指示受けに時間がかかる zrx start
      // if(parseInt(indication.rst_dialysis_state) < 6 && indication.ind_kur_cd != 0){
      //   let crudTmp = "U";
      //   const params = {
      //     ope_cd: "028001",
      //     crud: crudTmp,
      //     pat_id: indication.pat_id,
      //     facility_cd: this.getFacilityCd,
      //     hosp_pat_id: indication.hosp_pat_id,
      //     ord_no: indication.ord_no,
      //     base_date: indication.treat_date,
      //     user_id: this.getUserId
      //   };
      //   createJournal(params);
      // }
      //del #9507 一括指示受けに時間がかかる zrx end
      this.stopLoading();
    },
    async goToDetail({ pat_id, ord_no }, method = "") {
      //選択 ord_no を保持
      this.setOrdNoForSideBarRecord(ord_no);
      // mod bug #4320 修正 chen start
      this.startLoading("処理中・・・");
      // mod bug #4320 修正 chen end
      await this.selectPat(pat_id);

      this.$router.push({
        name: `indication-${method}-detail`,
        params: {
          ordNo: ord_no,
          method: method
        }
      });
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao start
      this.stopLoading();
      // add #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
    },
    async checkAll1() {
      if (this.unchecked1Indications.length === 0) {
        return;
      }

      this.startLoading("指示を確認しています。");
      // let contentList = [];
      try {
        //mod #9507 一括指示受けに時間がかかる zrx start
        // const contentParam = await this.getCheckApproveAll(this.unchecked1Indications);
        // await this.setIndContentList(contentParam);
        // contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.RECEIVER1, false);
        //
        // contentList = contentList.map(content => {
        //   const checkContent = this.arrangeData([content], content.rstDialysisState, "check");
        //   content.check_content = JSON.stringify(checkContent);
        //   delete content.rstDialysisState;
        //   return content;
        // });
        // await Indication.bulkCheck1(contentList, this.unchecked1Indications, this.getFacilityCd, this.getUserId);
        // await this.insertPatIndApproveHistory(
        //   this.unchecked1Indications.map(({ ord_no }) => ord_no),
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.RECEIVER1],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        await this.bulkCheckOrApprove(
          this.unchecked1Indications.map(({ ord_no }) => ord_no),
          this.userId,
          [this.INDICATIONTYPEVALUE.RECEIVER1],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          this.unchecked1Indications,
          null,
          null,
          null
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        await this.getIndications();
      } catch (error) {
        getErrorMessage('IndicationListComponent.vue', 'checkAll1', error);
        this.internalServerError(error);
      }
      this.stopLoading();
    },
    async checkAll2() {
      if (this.unchecked2Indications.length === 0) {
        return;
      }

      this.startLoading("指示を確認しています。");
      //mod #9507 一括指示受けに時間がかかる zrx start
      // let contentList = [];
      try {
        // const contentParam = await this.getCheckApproveAll(this.unchecked2Indications);
        // await this.setIndContentList(contentParam);
        // contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.RECEIVER2, false);
        //
        // contentList = contentList.map(content => {
        //   const checkContent = this.arrangeData([content], content.rstDialysisState, "check");
        //   content.check_content = JSON.stringify(checkContent);
        //   delete content.rstDialysisState;
        //   return content;
        // });
        // await Indication.bulkCheck2(contentList, this.unchecked2Indications, this.getFacilityCd, this.getUserId);
        // await this.insertPatIndApproveHistory(
        //   this.unchecked2Indications.map(({ ord_no }) => ord_no),
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.RECEIVER2],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        await this.bulkCheckOrApprove(
          this.unchecked2Indications.map(({ ord_no }) => ord_no),
          this.userId,
          [this.INDICATIONTYPEVALUE.RECEIVER2],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          null,
          this.unchecked2Indications,
          null,
          null
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        await this.getIndications();
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndicationListComponent.vue', 'checkAll2', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        this.internalServerError(error);
      }
      this.stopLoading();
    },
    async approveAll1() {
      if (!this.unapproved1Indications.length === 0 || !this.isShowBtnOK) {
        return;
      }

      this.startLoading("承認しています。");
      //mod #9507 一括指示受けに時間がかかる zrx start
      // let contentList = [];
      try {
        // const contentParam = await this.getCheckApproveAll(this.unapproved1Indications);
        // await this.setIndContentList(contentParam);
        // contentList = this.getContentsCh00eckApprove(this.indContentList, this.INDICATIONTYPE.APPROVER1, false);
        //
        // contentList = contentList.map(content => {
        //   const checkContent = this.arrangeData([content], content.rstDialysisState, "approve");
        //   content.approve_content = JSON.stringify(checkContent);
        //   delete content.rstDialysisState;
        //   return content;
        // });
        //
        // await Indication.bulkApprove1(contentList);
        // await this.insertPatIndApproveHistory(
        //   this.unapproved1Indications.map(({ ord_no }) => ord_no),
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.APPROVER1],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        await this.bulkCheckOrApprove(
          this.unapproved1Indications.map(({ ord_no }) => ord_no),
          this.userId,
          [this.INDICATIONTYPEVALUE.APPROVER1],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          null,
          null,
          this.unapproved1Indications,
          null
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        await this.getIndications();
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('IndicationListComponent.vue', 'approveAll1', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        this.internalServerError(error);
      }
      this.stopLoading();
    },
    async approveAll2() {
      if (this.unapproved2Indications.length === 0 || !this.isShowBtnOK) {
        return;
      }

      this.startLoading("承認しています。");
      //mod #9507 一括指示受けに時間がかかる zrx start
      // let contentList = [];
      try {
        // const contentParam = await this.getCheckApproveAll(this.unapproved2Indications);
        // await this.setIndContentList(contentParam);
        // contentList = this.getContentsCheckApprove(this.indContentList, this.INDICATIONTYPE.APPROVER2, false);
        //
        // contentList = contentList.map(content => {
        //   const checkContent = this.arrangeData([content], content.rstDialysisState, "approve");
        //   content.approve_content = JSON.stringify(checkContent);
        //   delete content.rstDialysisState;
        //   return content;
        // });
        //
        // await Indication.bulkApprove2(contentList);
        // await this.insertPatIndApproveHistory(
        //   this.unapproved2Indications.map(({ ord_no }) => ord_no),
        //   this.userId,
        //   [this.INDICATIONTYPEVALUE.APPROVER2],
        //   [+this.userId],
        //   [this.SIGN_TYPE.SETTING]
        // );
        await this.bulkCheckOrApprove(
          this.unapproved2Indications.map(({ ord_no }) => ord_no),
          this.userId,
          [this.INDICATIONTYPEVALUE.APPROVER2],
          [+this.userId],
          [this.SIGN_TYPE.SETTING],
          this.getFacilityCd,
          null,
          null,
          null,
          this.unapproved2Indications
        );
        //mod #9507 一括指示受けに時間がかかる zrx end
        await this.getIndications();
      } catch (error) {
        getErrorMessage('IndicationListComponent.vue', 'approveAll2', error);
        this.internalServerError(error);
      }
      this.stopLoading();
    },
    canApprove({ is_user1_checked, is_user1_approved }) {
      return !!+is_user1_checked && !+is_user1_approved;
    },
    /* modify by chamaojia 2025-03-03 [11471] change in the assignment of 【treatmentName】 --start */
    treatmentName(indication) {
      const treatmentCd = indication.ind_treatment_cd;
      let treatmentName = "";
      if (indication.rst_dialysis_state == "0") {
        const treatment = this.mstTreatment.find(
            treatment => treatment.treatmentCd === treatmentCd
        );
// NSI-修正 マスタ削除の対応 chen add start
        if (!treatment) {
          const treatmentTmp = this.mstTreatmentDel.find(
              treatment => treatment.treatmentCd === treatmentCd
          );
          if (treatmentTmp) {
            treatmentName = MASTER_DELETE_DISPLAY.DELETED + treatmentTmp.treatmentName;
          }
        } else {
          treatmentName = treatment.treatmentName;
        }
      } else {
        const treatmentTmp = this.mstTreatmentDel.find(
            treatment => treatment.treatmentCd === treatmentCd
        );
        if (treatmentTmp) {
          treatmentName = MASTER_DELETE_DISPLAY.DELETED + indication.ind_treatment_name;
        } else {
          treatmentName = indication.ind_treatment_name;
        }
      }
      return treatmentName;
      // return treatment ? treatment.treatmentName : "";
// NSI-修正 マスタ削除の対応 chen add end
    },
    /* modify by chamaojia 2025-03-03 [11471] change in the assignment of 【treatmentName】 --end */
    kurName(kurCd) {
      const kur = this.mstKur.find(kur => kur.kurCd === kurCd);
// NSI-修正 マスタ削除の対応 chen add start
      let kurName = "";
      if (!kur) {
        const kurTmp = this.mstKurDel.find(kur => kur.kurCd === kurCd);
        if (kurTmp) {
          kurName = MASTER_DELETE_DISPLAY.DELETED + kurTmp.kurName;
        }
      } else {
        kurName = kur.kurName;
      }
      return kurName;
      // return kur ? kur.kurName : "";
// NSI-修正 マスタ削除の対応 chen add end
    },
    userName(userId) {
      const user = this.mstPersonalUser.find(user => user.userId === userId);
      return user ? user.userFullName : "";
    },
    bedName(bedCd) {
      const bed = this.mstBed.find(bed => bed.bedCd === bedCd);
// NSI-修正 マスタ削除の対応 chen add start
      let bedName = "未登録";
      if (!bed) {
        const bedTmp = this.mstBedDel.find(bed => bed.bedCd === bedCd);
        if (bedTmp) {
          bedName = MASTER_DELETE_DISPLAY.DELETED + bedTmp.bedName;
        }
      } else {
        bedName = bed.bedName;
      }
      return bedName;
      // return bed ? bed.bedName : "未登録";
// NSI-修正 マスタ削除の対応 chen add end
    },
    startLoading(message = "") {
      // mod bug #4320 修正 chen start
      // this.isLoading = true;
      // this.loadingMessage = message;

      this.resetLoadingScreenVisibleCount();
      this.setLoadingScreenMessage(message);
      this.setLoadingScreenVisible(true);
      // mod bug #4320 修正 chen end
    },
    stopLoading() {
      // mod bug #4320 修正 chen start
      // this.isLoading = false;

      this.setLoadingScreenVisible(false);
      // mod bug #4320 修正 chen end
    },
    internalServerError(error) {
      console.log(error);
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
    },
    async onClickUpdate(indication, columnName, checkAll) {
      let param = {};
      param.userId = this.userId;
      switch (columnName) {
        case this.INDICATIONTYPE.RECEIVER1:
          param.indicationType = this.INDICATIONTYPEVALUE.RECEIVER1;
          break;
        case this.INDICATIONTYPE.RECEIVER2:
          param.indicationType = this.INDICATIONTYPEVALUE.RECEIVER2;
          break;
        case this.INDICATIONTYPE.APPROVER1:
          param.indicationType = this.INDICATIONTYPEVALUE.APPROVER1;
          break;
        case this.INDICATIONTYPE.APPROVER2:
          param.indicationType = this.INDICATIONTYPEVALUE.APPROVER2;
          break;
        default:
          break;
      }
      param._ids = [];
      if (checkAll) {
        indication.forEach(pat => {
          param._ids = param._ids.concat(pat._id);
        });
      } else {
        param._ids = indication._id;
      }
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
      let treatDate = dayjs(new Date()).format("YYYYMMDD");
      let ope_cd_all = "";
      switch (columnName) {
        case this.INDICATIONTYPE.RECEIVER1:
          ope_cd_all = "028012";
          break;
        case this.INDICATIONTYPE.RECEIVER2:
          ope_cd_all = "028013";
          break;
      }
      param.ope_cd = ope_cd_all;
      param.facility_cd = this.getFacilityCd;
      param.base_date = treatDate;
      /* upd EOL対応内部 #7010 by ztc 2023-07-09 --start */
      if (!Array.isArray(param.indication)) {
        param.indication = [param.indication];
      }else {
        param.indication = indication;
      }
      /* upd EOL対応内部 #7010 by ztc 2023-07-09 --end */
      param.checkAll = checkAll;
      param.isTreatmentUnit = this.isTreatmentUnit;
      // add by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
      this.reRender = true;
      await Indication.updIndHistoryList(param);
      await this.getIndications();

// add FNSI 1006 No.538 外部連携APIを呼び出 陳 start
    // del by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --start
    //   let treatDate = dayjs(new Date()).format("YYYYMMDD");
    //   let userid = this.getUserId;
    //   let ope_cd = "";
    //   let ope_cd_all = "";
    //   switch (columnName) {
    //     case this.INDICATIONTYPE.RECEIVER1:
    //       // mod FNSI-7570 劉全航 start
    //       // ope_cd = "028017";
    //       ope_cd_all = "028012";
    //       // mod FNSI-7570 劉全航 end
    //       break;
    //     case this.INDICATIONTYPE.RECEIVER2:
    //       // mod FNSI-7570 劉全航 start
    //       // ope_cd = "028018";
    //       ope_cd_all = "028013";
    //       // mod FNSI-7570 劉全航 end
    //       break;
    //       // del FNSI-7570 劉全航 start
    //     // case this.INDICATIONTYPE.APPROVER1:
    //     //   ope_cd = "028019";
    //     //   ope_cd_all = "028014";
    //     //   break;
    //     // case this.INDICATIONTYPE.APPROVER2:
    //     //   ope_cd = "028020";
    //     //   ope_cd_all = "028015";
    //     //   break;
    //     // default:
    //     //   break;
    //     // del FNSI-7570 劉全航 end
    //   }
    //   if (checkAll && this.isTreatmentUnit) {
    //     // mod 7570 ind_dial連携で送信する項目情報部  赵 start
    //     indication.forEach(detail => {
    //       if (ope_cd !== "") {
    //         const params = {
    //           ope_cd: ope_cd_all,
    //           crud: "U",
    //           pat_id: detail.patId,
    //           facility_cd: this.getFacilityCd,
    //           hosp_pat_id: detail.hospPatId,
    //           // mod 7570 ind_dial連携で送信する項目情報部  赵 start
    //           ord_no: "",
    //           // mod 7570 ind_dial連携で送信する項目情報部  赵 end
    //           base_date: treatDate,
    //           user_id: userid
    //         };
    //         createJournal(params);
    //       }
    //     });
    //     // indication.forEach(detail => {
    //     //   let ordNoList = detail.ordNo.split(",");
    //     //   ordNoList.forEach(item => {
    //     //   if (ope_cd !== "") {
    //     //     const params = {
    //     //       ope_cd: ope_cd_all,
    //     //       crud: "U",
    //     //       pat_id: detail.patId,
    //     //       facility_cd: this.getFacilityCd,
    //     //       hosp_pat_id: detail.hospPatId,
    //     //       ord_no: item,
    //     //       base_date: treatDate,
    //     //       user_id: userid
    //     //     };
    //     //     createJournal(params);
    //     //   }
    //     //   })
    //     // });
    //     // mod 7570 ind_dial連携で送信する項目情報部  赵 end
    //   } else {
    // // del FNSI-7570 劉全航 start
		// // mod 7570 ind_dial連携で送信する項目情報部  赵 start
    //     // this.ordNoList = indication.ordNo.split(",");
    //     // this.ordNoList.forEach(item=>{
    //     // if (ope_cd !== "") {
    //     //   const params = {
    //     //     ope_cd: ope_cd,
    //     //     crud: "U",
    //     //     pat_id: indication.patId,
    //     //     facility_cd: this.getFacilityCd,
    //     //     hosp_pat_id: indication.hospPatId,

    //     //       //ord_no: "",
    //     //       ord_no: item,

    //     //     base_date: treatDate,
    //     //     user_id: userid
    //     //   };
    //     //   createJournal(params);
    //     // }
    //     // })
    //     // mod 7570 ind_dial連携で送信する項目情報部  赵 end
    //     // del FNSI-7570 劉全航 end
    //   }
    // del by zs 2023-03-06 [#6118無期限予定の中止：js foreach call journalをjava batch call journalに変更] --end
// add FNSI 1006 No.538 外部連携APIを呼び出 陳 end
    },
    async goToIndicationDetail(indication, method = "") {
      // add FNSI-権限 陳 start
      // mod #10359 編集権限の動作不正 dengshen start
      // if (method === "receive" || (method === "approve" && this.hasIndReceiveAuthority)) {
      // mod #10359_NG対応 編集権限の動作不正 dengshen start
      // if (method === "receive" || (method === "approve" && this.getItemAuthorized('IndicationList', 'default_authority'))) {
      if (method === "receive" || method === "approve") {
      // mod #10359_NG対応 編集権限の動作不正 dengshen end
      // mod #10359 編集権限の動作不正 dengshen end
        // add FNSI-権限 陳 end
        // del bug #4320 修正 chen start
        // this.startLoading("処理中・・・");
        // del bug #4320 修正 chen end
        await this.selectPat(indication.patId);

        this.$router.push({
          name: `indication-${method}-details`,
          params: {
            patId: indication.patId,
            _id: indication._id,
            method: method
          }
        });
        // add FNSI-権限 陳 start
      }
      // add FNSI-権限 陳 end
    },
    /**
     * 治療単位 ソート処理
     * @param {String} sortingField
     */
    sortTreatmentList(sortingField) {
      const dataField = this.sortTreatmentMap[sortingField];
      const type = this.getTreatmentIndicationSortStatus(sortingField);
      // type 1: 昇順、2: 降順、3: ソートなし
      const isAsc = type === 1;

      // ソートなし
      if (type === 3) {
        this.resetTreatmentIndications();
        this.resetTreatmentIndicationSortStatus();
        return;
      }

      // ソート対象データを初期リストからコピー
      const list = [...this.initSortedIndicationList];
      let sorted = [];
      if (["check1", "check2"].includes(sortingField)) {
        sorted = this.customizeSortCheck(list, dataField, isAsc ? "asc" : "desc");
      } else {
        sorted = list.sort((a, b) => sortableCompare(a, b, dataField, isAsc));
      }

      this.setTreatmentIndications(sorted);
      this.resetTreatmentIndicationSortStatus();
      this.setTreatmentIndicationSortStatus({ field: sortingField, type: isAsc ? 2 : 3 });
    },
    /**
     * 指示受け1、指示受け2 ソート処理
     * - 昇順: [ピンク→オレンジ→ホワイト]、降順: [ホワイト→オレンジ→ピンク]
     * - ホワイト、オレンジに利用者名入っていても郡内で利用者名でのソートはしない。郡内にはデフォルトソート順(患者名)が適用される
     * @param {*} list ソート対象のリスト
     * @param {*} sortField ソートキー
     * @param {*} sortType "asc": 昇順 or "desc": 降順
     */
    customizeSortCheck(list, sortField, sortType) {
      let pinkList = [];
      let orangeList = [];
      let whiteList = [];

      list.forEach(item => {
        if (item[sortField] === "0") {
          pinkList.push(item); // ピンク
        } else if (item[sortField] === "1" && item.is_content_changed === "1") {
          orangeList.push(item); // オレンジ
        } else if (item[sortField] === "1" && item.is_content_changed === "0") {
          whiteList.push(item); // ホワイト
        }
      });

      // 並び替え
      if (sortType === "asc") {
        list = [...pinkList, ...orangeList, ...whiteList];
      } else if (sortType === "desc") {
        list = [...whiteList, ...orangeList, ...pinkList];
      }

      return list;
    },
    reSortTreatmentIndications() {
      // if it's not treatment indications screen then do nothing
      if (!this.isTreatmentUnit) {
        return null;
      }
      // if treament indications are not sorting then do nothing
      if (this.treatmentIndicationSortingField === null) {
        return null;
      }
      console.log("reSortTreatmentIndications_begin");
      // hack: decrease status number to resort
      const sortingField = this.treatmentIndicationSortingField;
      this.setTreatmentIndicationSortStatus({
        field: this.treatmentIndicationSortingField,
        type: this.getTreatmentIndicationSortStatus(
          this.treatmentIndicationSortingField
        ) - 1
      });

      // ソート実行
      this.sortTreatmentList(sortingField);

      console.log("reSortTreatmentIndications_end");
    },
    getSortedClass(type) {
      // 昇順アイコンを表示
      if (this.getTreatmentIndicationSortStatus(type) === 2) {
        return "sorted-desc";
      }
      // 降順アイコンを表示
      if (this.getTreatmentIndicationSortStatus(type) === 3) {
        return "sorted-asc";
      }
      return "";
    },
    /**
     * 指示単位 ソート処理
     * @param {String} sortingField
     */
    sortIndicationsList(sortingField) {
      const dataField = this.sortIndicationsMap[sortingField];

      // 画面描画時はストアに保存されているtypeから-1する
      // ** ソート指定した状態で他画面に遷移して戻ってきた場合を考慮 **
      const type = this.reRender ? this.getTreatmentIndicationSortStatus(sortingField) - 1 : this.getTreatmentIndicationSortStatus(sortingField);
      // 件数項目
      const isNumberField = ["check1", "check2", "approve1", "approve2"].includes(sortingField);

      // type 1: 昇順、2: 降順、3: ソートなし
      const isAsc = type === 1;
      if (type === 3) {
        this.resetTreatmentIndications();
        this.resetTreatmentIndicationSortStatus();
        return;
      }

      // ソート対象データを初期リストからコピー
      const list = [...this.initSortedIndicationList];
      let sorted = [];
      if (isNumberField) {
         sorted = list.sort((a, b) => {
          const diffA = a.total - a[dataField];
          const diffB = b.total - b[dataField];
          // ** 分母内指示受けor指示承認件数 ／ 指示変更レコード数 **
          // ** 未処理残件数＝指示変更レコード数－分母内指示受けor指示承認件 **
          // 昇順の場合：第1ソートキー：未処理残件数 降順, 第2ソートキー：指示変更レコード数 昇順
          // 降順の場合：第1ソートキー：未処理残件数 昇順, 第2ソートキー：指示変更レコード数 降順
          return (isAsc ? diffB - diffA : diffA - diffB) || (isAsc ? a.total - b.total : b.total - a.total);
        });
      } else {
        // 共通関数でソート
        sorted = list.sort((a, b) => sortableCompare(a, b, dataField, isAsc));
      }

      this.setSortedIndicationsList(sorted);
      this.resetTreatmentIndicationSortStatus();
      this.setTreatmentIndicationSortStatus({ field: sortingField, type: type + 1 });
    },
    async insertPatIndApproveHistory(ordNo, userId,  approveKind, approveAftId, signType){
      await Indication.insertPatIndApproveHistory({
       ordNo: ordNo,
       userId : userId,
       approveKind: approveKind,
       approveAftId: approveAftId,
       signType: signType
      });
    },
    //add #9507 一括指示受けに時間がかかる zrx start
    /**
     * 指示受けの更新
     */
    async bulkCheckOrApprove(ordNo, userId,  approveKind, approveAftId, signType, facilityCd,
                             unchecked1Indications, unchecked2Indications, unapproved1Indications, unapproved2Indications){
      await Indication.bulkCheckOrApprove({
        ordNo: ordNo,
        userId : userId,
        approveKind: approveKind,
        approveAftId: approveAftId,
        signType: signType,
        facilityCd: facilityCd,
        unchecked1Indications: unchecked1Indications ? JSON.stringify(unchecked1Indications) : null,
        unchecked2Indications: unchecked2Indications ? JSON.stringify(unchecked2Indications) : null,
        unapproved1Indications: unapproved1Indications ? JSON.stringify(unapproved1Indications) : null,
        unapproved2Indications: unapproved2Indications ? JSON.stringify(unapproved2Indications) : null
      });
    },
    //add #9507 一括指示受けに時間がかかる zrx end
    getContentsCheckApprove(indContentList, checkType, hasRstDialysisState) {
      const list = [];
      for (let index = 0; index < indContentList.length; index++) {
        const element = {};
        element.ord_no = indContentList[index].ordNo;
        // add 10739 コンバート施設で指示受け(治療単位)が表示されない zkm start
        if (!hasRstDialysisState) {
          element.rstDialysisState = indContentList[index]?.rstDialysisState;
        }
        // add 10739 コンバート施設で指示受け(治療単位)が表示されない zkm end
        switch (checkType) {
          case this.INDICATIONTYPE.RECEIVER1:
              element.check_user1_cd = +this.userId;
              element.check_content = JSON.stringify(indContentList[index].layout);
            break;
          case this.INDICATIONTYPE.RECEIVER2:
              element.check_user2_cd = +this.userId;
              element.check_content = JSON.stringify(indContentList[index].layout);
            break;
          case this.INDICATIONTYPE.APPROVER1:
              element.approve_user1_cd = +this.userId;
              element.approve_content = JSON.stringify(indContentList[index].layout);
            break;
          case this.INDICATIONTYPE.APPROVER2:
              element.approve_user2_cd = +this.userId;
              element.approve_content = JSON.stringify(indContentList[index].layout);
            break;
          default:
            break;
        }
        list.push(element);
      }
      return list;
    },
    async getCheckApproveAll(uncheckedList) {
      const selectedPatList = await Promise.all(uncheckedList.map(async item => {
        await this.selectPat(item.pat_id);
        return this.selectedPat;
      }));
      const ordNoList = uncheckedList.map(({ ord_no }) => ord_no);
      return {ordNoList, selectedPatList};
    },
    async getCheckApprove(indication) {
      await this.selectPat(indication.pat_id)
      const selectedPatList = [this.selectedPat];
      const ordNoList = [indication.ord_no];
      return {ordNoList, selectedPatList};
    },

// add FNSI-入外区分が入院の場合、患者名は紫色にする dou start
    inOutFlag(selectedItem) {
      return {
        "in_class": selectedItem.in_out_class == 1 ? true : false
      };
    },
// add FNSI-入外区分が入院の場合、患者名は紫色にする dou end
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi start
    //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 start
    arrangeData(tmpList, rstDia, type) {
      let checkContent;
      if (type === "check") {
        checkContent = JSON.parse(tmpList[0].check_content);
      } else if (type === "approve") {
        checkContent = JSON.parse(tmpList[0].approve_content);
      }
      // 医療材料
      checkContent.forEach(item => {
        if (6 === item.subCategoryNo) {
          item.subCategoryItem.forEach(subCategory => {
            subCategory.itemInfo.itemNo = null;
          })
        }
      });
      if (rstDia !== "0") {
        return checkContent;
      }
      checkContent.forEach(item => {
        if (2 === item.subCategoryNo) {
          item.itemInfo.data.value.unit = null;
          item.itemInfo.data.value.prefix = null;
          item.itemInfo.data.value.dispVal = null;
        }
        // スケジュール
        else if (3 === item.subCategoryNo) {
          item.subCategoryItem.forEach(subCategory => {
            // 1: クール
            // 3: ベッド
            if ([1, 3].includes(subCategory.itemInfo.itemNo)) {
              subCategory.itemInfo.data.value.unit = null;
              subCategory.itemInfo.data.value.prefix = null;
              subCategory.itemInfo.data.value.dispVal = null === subCategory.itemInfo.itemCd || 0 === subCategory.itemInfo.itemCd ? "未登録" : null;
            }
          })
        }
        // 治療条件, 投与薬剤, 医療材料
        else if (4 === item.subCategoryNo) {
          // item.subCategoryItem.forEach(subCategory => {
          //   subCategory.itemInfo.data.value.unit = null;
          //   subCategory.itemInfo.data.value.prefix = null;
          // })
          item.subCategoryItem.forEach(subCategory => {
            subCategory.itemInfo.data.value.unit = null;
            // 2:  VA
            // 5:  ダイアライザ
            // 6:  吸着カラム
            // 7:  1次膜
            // 8:  2次膜
            // 9:  穿刺針(A針)
            // 10: 穿刺針(V針)
            // 11: 穿刺針(SN)
            // 13: 血液回路
            // 15: 透析液
            // 19: 補液
            // 25: 抗凝固剤
            if ([2, 5, 6, 7, 8, 9, 10, 11, 13, 15, 19, 25].includes(subCategory.itemInfo.itemNo)) {
              subCategory.itemInfo.data.value.dispVal = null === subCategory.itemInfo.itemCd ? "未登録" : null;
              subCategory.itemInfo.data.value.prefix = null;
            }
          })
        }
        // 投与薬剤、医療材料
        else if ([5, 6].includes(item.subCategoryNo)) {
          item.subCategoryItem.forEach(subCategory => {
            subCategory.itemInfo.data.value.unit = null;
            subCategory.itemInfo.data.value.prefix = null;
          })
        }
      });
      return checkContent;
    }
    //add #10196 ord_mainのデータ定義から外れているデータ登録・参照処理の修正 zhaoqi 20240529 end
    //mod #10739 コンバート施設で指示受け(治療単位)が表示されない 20241218 zhaoqi end
  },
  // add FNSI-改修内容表示順でソート 付 start
  async created () {
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("setDateParams", this.getDateParams);
    // del #10359 編集権限の動作不正 dengshen start
    // // add  FNSI-権限 陳 start
    // this.hasIndReceiveAuthority = this.getIndReceiveAuthority();
    // // add  FNSI-権限 陳 end
    // del #10359 編集権限の動作不正 dengshen end
    // add 画面印刷プレビューと印刷の実現 黄 start
    // 印刷パラメータ要求
    // add 性能改善メモリ不足 shan start
    // add 性能改善メモリ不足 shan start
    EventBus.$on("requestReportParams", this.requestrReportParams);
    EventBus.$on("setDateParams", this.getDateParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
  },
  // add FNSI-改修内容表示順でソート 付 end
  // add 画面印刷プレビューと印刷の実現 黄 start
  beforeUnmount () {
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("setDateParams", this.getDateParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
    // add 画面パフォーマンス対応 chen start
    this.patList = null;
    // del #10359 編集権限の動作不正 dengshen start
    // this.hasIndReceiveAuthority = null;
    // del #10359 編集権限の動作不正 dengshen end
    this.isLoading = null;
    this.loadingMessage = null;
    this.okIcon = null;
    this.sortName = null;
    this.INDICATIONTYPEVALUE = null;
    this.reRender = null;
    this.SIGN_TYPE = null;
    this.FACILITY_INS_APPTYPE = null;
    this.dataArray = null;
    this.image_src_same = null;
    // add 画面パフォーマンス対応 chen end
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style scoped>
.loading-modal {
  font-size: 2.4em;
}
.grid {
  max-height: 100%;
  margin-bottom: 0.5em;
  overflow-y: auto;
}
.grid > table {
  width: max-content;
  min-width: 100%;
  border-collapse: collapse;
}
.grid > table th {
  color: #fff;
  font-weight: 400;
  text-align: left;
  background-color: var(--ntss-list-header-background-color);
}
.grid > table th {
  position: sticky;
  top: 0;
  z-index: 1;
  border-right: 1px solid var(--master-maintenance-kgrid-border-color);
}
.grid > table td {
  border-right: 1px solid var(--master-maintenance-kgrid-border-color);
}
.grid > table th,
.grid > table td {
  width: fit-content;
  min-width: 10.2em;
  padding: 0.25em;
  word-break: break-word;
  white-space: normal;
}
.grid > table th:last-child,
.grid > table td:last-child {
  border-right: none;
}
.grid > table tbody {
  color: var(--master-maintenance-kgrid-body-color);
}
.grid > table tbody tr {
  border-bottom: 1px solid var(--master-maintenance-kgrid-border-color);
}
.grid > table tr:nth-child(odd) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.grid > table tr:hover {
  background-color: var(--master-maintenance-kgrid-item-hover-background-color);
}
.grid > table td.id {
  position: relative;
}
.grid > table td.checker.empty,
.grid > table td.approver.empty {
  background-color: pink;
}
.grid > table td.checker.content-change:not(.empty),
.grid > table td.approver.content-change:not(.empty) {
  background-color: orange;
}
.checker .icon,
.approver .icon,
.indication-icon {
  display: flex;
  align-items: center;
  height: calc(1.5em + 10px);
  padding: 5px;
  border-radius: 4px;
  line-height: 20px;
  box-shadow: unset;
}
.checker .icon > img,
.approver .icon > img,
.indication-icon > img {
  width: 1.5em;
}
ons-btn.save {
  background-color: var(--ntss-btn-ok-background-color);
}
.legend {
  color: var(--ntss-list-body-color);
}
.legend .color {
  width: 20px;
  height: 20px;
  margin-right: 0.2em;
}
.legend .unprocessed {
  margin-right: 1em;
}
.legend .unprocessed > .color {
  background-color: pink;
}
.legend .changed > .color {
  background-color: orange;
}
.fr {
  float: right;
}
.button:disabled, .button[disabled] {
  opacity: 0.3;
  cursor: default;
  pointer-events: none
}
.resize-colomn-table  {
  min-width: 5em !important;
}
/* add 入外区分が入院の場合、患者名は紫色にする chen start */
.same-icon{
  height: 1.2em;
  display: inline-block;
  margin-left: 0.1em;
  margin-top: 0.1em;
}
.in_class {
  color: #A356A3;
}
/* add 入外区分が入院の場合、患者名は紫色にする chen end */
/* add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 start */
.check-approver-dark-grey {
  background-color: #696969;
}
/* add FNSI-改修内容欄の分子＝分母の場合灰色より濃い灰色表示 付 end */
/* 画面印刷のレイアウトが崩れる  6427  shan  start */
.slide_bottom{
  width: 100%;
  position: sticky;
  bottom: 0px;
  z-index: 3;
  background: var(--main-background-color);
}
/* 画面印刷のレイアウトが崩れる  6427  shan  end */
.manual-width {
  resize: horizontal;
  overflow-x: auto;
}

@media print {
  /** 横幅を紙幅に収める */
  .grid table {
    table-layout: fixed;
    width: 100% !important;
  }
  .grid th {
    width: auto !important;
  }
}
</style>
