
<style scoped>
  .sortkey-popover :deep(.popover__content) {
    width: auto;
    font-size: 1.5em;
  }
  .report-list-popover :deep(.popover__content) {
    min-height: 90px;
  }
  /*スマホサイズで並び替えの表示が切れる場合がある  5935  shan   start*/
  @media screen and (max-width: 600px) {
    .sortkey-popover :deep(.popover--right) {
      right: 60px !important;

      top: 25px !important;
    }
    /* mod 5935 スマホサイズで並び替えの表示が切れる場合がある 王永吉 start */
    /* right: 130px !important;*/
    /* mod 5935 スマホサイズで並び替えの表示が切れる場合がある 王永吉 end */
    .sortkey-popover :deep(.popover--right__arrow) {
      width: 0px !important;
    }
  }

  /* スマホサイズで並び替えの表示が切れる場合がある  5935  shan   end*/
  .sortkey-popover :deep(.popover__content) {
    width: auto;
    font-size: 1.5em;
  }
  .sortkey-popover table th {
    background: none !important;
    background-image: none !important;
    height: 0em !important;
  }
</style>
<template>
  <div :id="$route.name" class="main-content-area">
    <div class="flex-1 d-flex" style="height: 100%">
      <div class="filter flex-1" ref="filterContainer">
        <div id="actions" class="actions">
          <v-ons-select
            name="cbb_report_type"
            input-id="cbb_report_type"
            class="filter-input-area"
            v-model="reportTypeID"
            @change="onChangeType"
          >
            <option :value="null" selected="selected">帳票種別:全て</option>
            <option v-for="(type, index) in reportClass" :key="index" :value="index">{{ type }}</option>
          </v-ons-select>
        </div>
        <!--add 5352 登録帳票多数でもスクロールされない 吉 start-->
        <div class="table-body-reprot">
          <!--add 5352 登録帳票多数でもスクロールされない 吉 end-->
          <div class="table-header">
            <div class="filter-list-header-wrap">
              <table class="filter-list-table-header">
                <thead>
                  <tr>
                    <th scope="col">帳票種別</th>
                    <th scope="col">帳票名</th>
                  </tr>
                </thead>
              </table>
            </div>
          </div>
          <div class="table-body">
            <table class="filter-list-table-body">
              <tbody>
                <!--mod #11293 水質検査帳票の課題対応 limingzhe start-->
                <!-- <tr
                  :class="{'tr-highlight': (item.id == selectedReportID)}"
                  style="word-break: break-all;"
                  v-for="item in filteredData"
                  :key="item.id"
                  @click="selectRow(item.id, item.reportClass, undefined, true)"
                > -->
                <tr
                  :class="{'tr-highlight': (item.id == selectedReportID)}"
                  style="word-break: break-all;"
                  v-for="item in filteredData"
                  :key="item.id"
                  @click="selectRow(item.id, item.reportClass, item.reportType, undefined, true)"
                >
                <!--mod #11293 水質検査帳票の課題対応 limingzhe end-->
                <td>{{ reportClass[item.reportClass] }}</td>
                <td>{{ item.name }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <!--add 5352 登録帳票多数でもスクロールされない 吉 start-->
        </div>
        <!--add 5352 登録帳票多数でもスクロールされない 吉 end-->
      </div>
      <!-- mod #699,700,751 陳 start -->
      <!-- <div class="patient-list flex-1"> -->
      <!--  mod Aspose.cells関連問題8の対応 夏 start -->
      <!--  <div class="patient-list flex-1" v-show="selectedReportClassID !== 7"> -->
      <!--mod #11293 水質検査帳票の課題対応 limingzhe start-->
      <!-- <div class="patient-list flex-1" v-show="selectedReportClassID !== 7 && multiTotalID !== selectedReportID"> -->
      <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe start-->
      <!-- <div class="patient-list flex-1" v-show="selectedReportClassID !== 7 && multiTotalID !== selectedReportID && !(selectedReportClassID === 11 && selectedReportTypeId === 3)"> -->
      <div class="patient-list flex-1" v-show="selectedObjectType === 1">
      <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe end-->
       <!--mod #11293 水質検査帳票の課題対応 limingzhe end-->
      <!--  mod Aspose.cells関連問題8の対応 夏 end -->
        <!-- mod #699,700,751 陳 end -->
        <div style="height: 2.2em; display: flex; align-items: flex-end; white-space: nowrap;">
          <div style="margin-right: 1em;" v-if="!hideflag">対象患者(0/0名)</div>
          <div style="margin-right: 1em;" v-else>対象患者({{selectedPatients.length}}/{{sortedPatList.length}}名)</div>
          <div>
            <label>
              <v-ons-checkbox
                class="onColor"
                checked=“checked”
                v-model="showAllflag"
                @click="showAllOrSome()"
              />帳票表示対象外の患者は表示しない
            </label>
          </div>

        </div>
        <div class="pat-container" >
          <div class="table-header">
            <div class="table-header-wrap">
              <table class="patient-table-header" cellspacing="0" >
                <thead>
                <tr>
                  <th width="10%" class="text-center" scope="col">
                    <v-ons-checkbox v-model="selectPatientAll" />
                  </th>
                  <th :width="reportHidden.indexOf(selectedReportClassID) < 0 ? '18%' : '40%'" scope="col">
                    <span @click="sortBy('hosp_pat_id')" :class="sortedClass('hosp_pat_id')" class="clickable-header-label">患者ID</span>
                  </th>
                  <!--mod #11880 帳票画面で患者氏名のソートが機能しないことがある  吉 start-->
                  <!--<th :width="reportHidden.indexOf(selectedReportClassID) < 0 ? '24%' : '50%'" scope="col" @click="sort('pat_last_name')">-->
                  <th :width="reportHidden.indexOf(selectedReportClassID) < 0 ? '24%' : '50%'" scope="col">
                    <span @click="sortBy('pat_name')" :class="sortedClass('pat_name')" class="clickable-header-label">患者氏名</span>
                  </th>
                  <th
                    width="24%"
                    scope="col"
                    v-if="reportHidden.indexOf(selectedReportClassID) < 0 "
                  >
                    <span @click="sortBy('kur_start_time')" :class="sortedClass('kur_start_time')" class="clickable-header-label">クール名</span>
                  </th>
                  <th
                    width="24%"
                    scope="col"
                    v-if="reportHidden.indexOf(selectedReportClassID) < 0 "
                  >
                    <span @click="sortBy('bed_order_index')" :class="sortedClass('bed_order_index')" class="clickable-header-label">ベッド名</span>
                  </th>
                </tr>
                </thead>
              </table>
            </div>
          </div>
          <div class="table-body">
            <table class="patient-table-body" v-if="hideflag">
              <tbody >
              <!--mod 項目別(印刷情報一覧)の項目が実装されない  吉 start-->
              <!-- <tr v-for="p in sortedPatList" :key="p.pat_id" @click="setSelectedPatient(p.pat_id,)">-->
              <tr v-for="p in sortedPatList" :key="p.pat_id" style="word-break: break-all;">
                <!--mod 項目別(印刷情報一覧)の項目が実装されない  吉 end-->
                <td width="10%" class="text-center">
                  <v-ons-checkbox v-if="p.flag == 1" v-model="selectedPatients" :value="p.pat_id" @change="setSelectedPatient(p.pat_id,p.kur_name,p.bed_name)"/>
                  <v-ons-checkbox v-else :disabled="true"  />
                </td>
                <td :width="reportHidden.indexOf(selectedReportClassID) < 0 ? '18%' : '40%'" class="hosp-pat-id-body">{{p.hosp_pat_id}}</td>
                <!--mod 帳票の患者一覧に同名の患者の右側にイメージを  吉 start-->
                <!--<td width="30%">{{p.pat_last_name}} {{p.pat_first_name}}></td>-->
                <td :width="reportHidden.indexOf(selectedReportClassID) < 0 ? '24%' : '50%'">
                  <!--mod 入外区分が入院の場合、患者名は紫色にする  吉 start-->
                  <!-- {{p.pat_last_name}} {{p.pat_first_name}}-->
                  <!-- mod 9251 nullを空文字列判定に変換します 張博 start -->
                  <!-- mod #9753 一般撮影検査依頼にて検査名が表示されない linjunfeng start -->
                  <!-- <span v-if="p.in_out_class == 1"  style="color: #A356A3;">{{p.pat_last_name == null ? "" : p.pat_last_name}} {{p.pat_first_name == null ? "" : p.pat_first_name}}</span>
                  <span v-if="p.in_out_class != 1">{{p.pat_last_name == null ? "" : p.pat_last_name}} {{p.pat_first_name == null ? "" : p.pat_first_name}}</span> -->
                  <span v-if="p.in_out_class == 1"  style="color: #A356A3;">{{p.pat_last_name}} {{p.pat_first_name}}</span>
                  <span v-if="p.in_out_class != 1">{{p.pat_last_name}} {{p.pat_first_name}}</span>
                  <!-- mod #9753 一般撮影検査依頼にて検査名が表示されない linjunfeng start -->
                  <!-- mod 9251 nullを空文字列判定に変換します 張博 end -->
                  <!--mod 入外区分が入院の場合、患者名は紫色にする  吉 end-->
                  <img :src="image_src_same"  class="pat-name-same-icon" v-if="p.is_same == 1"></td>
                <!--mod 帳票の患者一覧に同名の患者の右側にイメージを  吉 end-->
                <!-- mod #9753 一般撮影検査依頼にて検査名が表示されない linjunfeng start -->
                <!-- mod 9251 nullを空文字列判定に変換します 張博 start -->
                <!-- <td width="24%" v-if="reportHidden.indexOf(selectedReportClassID) < 0 ">{{p.bed_name == null ? "" : p.bed_name}}</td>
                <td width="24%" v-if="reportHidden.indexOf(selectedReportClassID) < 0 ">{{p.kur_name == null ? "" : p.kur_name}}</td> -->
                <td width="24%" v-if="reportHidden.indexOf(selectedReportClassID) < 0 ">{{p.kur_name}}</td>
                <td width="24%" v-if="reportHidden.indexOf(selectedReportClassID) < 0 ">{{p.bed_name}}</td>
                <!-- mod 9251 nullを空文字列判定に変換します 張博 end -->
              </tr>
              </tbody>
            </table>
          </div>
        </div>

        <v-ons-popover
          cancelable
          v-model:visible="popoverVisible"
          :target="popoverTarget"
          :direction="popoverDirection"
          :cover-target="coverTarget"
          @posthide="handlePostHide"
          :class="[fontSizeSet, 'sortkey-popover']"
        >
          <div class="p-container">
            <div class="p-title">
              <span>印刷順</span>
            </div>
            <div style="border: 1px solid #b5b5b5; min-width: 15em;">
              <table style="border: none; width: 100%">
                <tbody>
                  <tr>
                    <td colspan="2"><span>第1ソート条件</span></td>
                  </tr>
                  <tr>
                  <td>
                    <v-ons-select
                      name="sort_key_a"
                      input-id="sort_key_a"
                      style="width: 100%"
                      class="input-large"
                      v-model="sortTemp[0].key"
                    >
                      <option :value="null"></option>
                      <option
                        v-for="key in sortCondition[selectedReportClassID]"
                        :key="key.id"
                        :value="key.text"
                      >{{ key.text }}</option>
                    </v-ons-select>
                  </td>
                  <td>
                    <v-ons-radio
                      name="sort_a"
                      input-id="a_asc"
                      value="asc"
                      v-model="sortTemp[0].sort"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="a_asc">昇順</label>
                    <br />
                    <v-ons-radio
                      name="sort_a"
                      input-id="a_desc"
                      value="desc"
                      v-model="sortTemp[0].sort"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="a_desc">降順</label>
                  </td>
                </tr>
                <tr>
                  <td colspan="2"><span>第2ソート条件</span></td>
                </tr>
                <tr>
                  <td>
                    <v-ons-select
                      name="sort_key_b"
                      input-id="sort_key_b"
                      style="width: 100%"
                      class="input-large"
                      v-model="sortTemp[1].key"
                    >
                      <option :value="null"></option>
                      <option
                        v-for="key in sortCondition[selectedReportClassID]"
                        :key="key.id"
                        :value="key.text"
                      >{{ key.text }}</option>
                    </v-ons-select>
                  </td>
                  <td>
                    <v-ons-radio
                      name="sort_b"
                      input-id="b_asc"
                      value="asc"
                      v-model="sortTemp[1].sort"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="b_asc">昇順</label>
                    <br />
                    <v-ons-radio
                      name="sort_b"
                      input-id="b_desc"
                      value="desc"
                      v-model="sortTemp[1].sort"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="b_desc">降順</label>
                  </td>
                </tr>
                <tr>
                  <td colspan="2"><span>第3ソート条件</span></td>
                </tr>
                <tr>
                  <td>
                    <v-ons-select
                      name="sort_key_c"
                      input-id="sort_key_c"
                      style="width: 100%"
                      class="input-large"
                      v-model="sortTemp[2].key"
                    >
                      <option :value="null"></option>
                      <option
                        v-for="key in sortCondition[selectedReportClassID]"
                        :key="key.id"
                        :value="key.text"
                      >{{ key.text }}</option>
                    </v-ons-select>
                  </td>
                  <td>
                    <v-ons-radio
                      name="sort_c"
                      input-id="c_asc"
                      value="asc"
                      v-model="sortTemp[2].sort"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="c_asc">昇順</label>
                    <br />
                    <v-ons-radio
                      name="sort_c"
                      input-id="c_desc"
                      value="desc"
                      v-model="sortTemp[2].sort"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="c_desc">降順</label>
                  </td>
                </tr>
                </tbody>
              </table>
            </div>
            <div style="display: flex; justify-content: space-between; padding-top: 10px;">
              <!--del 4466 確定ボタンとキャンセルボタンの位置が逆  吉 start-->
              <!--<v-ons-button class="common-style-select-button" @click="clickSort">確定</v-ons-button>-->
              <!--del 4466 確定ボタンとキャンセルボタンの位置が逆  吉 end-->
              <v-ons-button
                class="common-style-select-button btn2-cancel"
                @click="closePopover"
              >キャンセル</v-ons-button>
              <!--add 4466 確定ボタンとキャンセルボタンの位置が逆  吉 start-->
              <v-ons-button class="common-style-select-button btn3-normal" @click="clickSort">確定</v-ons-button>
              <!--add 4466 確定ボタンとキャンセルボタンの位置が逆  吉 end-->
            </div>
          </div>
        </v-ons-popover>
        <v-ons-popover
          cancelable
          v-model:visible="popoverExportVisible"
          :target="popoverExportTarget"
          :direction="popoverExportDirection"
          :cover-target="coverExportTarget"
          :class="[fontSizeSet, 'sortkey-popover']"
        >
          <div class="p-container">
            <div class="d-flex checkbox-group">
              <div class="d-flex align-items-center report-type-div">
                <v-ons-radio
                  v-model="selectedExport"
                  input-id="exportItem1"
                  name="selectedExport"
                  :value="1"
                  modifier="round"
                  class="popover-content-radio"
                />
                <label for="exportItem1">PDF</label>
                <v-ons-radio
                  v-model="selectedExport"
                  input-id="exportItem2"
                  name="selectedExport"
                  :value="2"
                  modifier="round"
                  class="popover-content-radio"
                />
                <label for="exportItem2">EXCEL</label>
              </div>
            </div>
            <div class="p-button report-type-btn">
              <v-ons-button
                class="common-style-select-button btn2-cancel"
                style="margin-right: 10px;"
                @click="closeExportPopover"
              >キャンセル</v-ons-button>
              <v-ons-button class="common-style-select-button btn1-execute" @click="downloadFile">保存</v-ons-button>
            </div>
          </div>
        </v-ons-popover>
        <v-ons-popover
          cancelable
          v-model:visible="popoverPrintLableVisible"
          :target="popoverPrintLableReport"
          :direction="popoverExportDirection"
          :class="[fontSizeSet, 'sortkey-popover']"
        >
          <div class="p-container">
            <div class="p-title">
              <span>ラベル開始選択</span>
            </div>
            <div style="border: 1px solid #b5b5b5">
              <div class="head-table">
                <label for="cars">縦</label>
                <v-ons-select
                  class="on-select-input"
                  input-id="cars"
                  v-model="colHorizontalPrintLable"
                >
                  <!--mod FNSI-改修内容ラベル開始位置がテンプレートと不一致 任 start-->
                  <!--<option
                    v-for="(valRow, index) in tabVale"
                    :value="(index += 1)"
                    :key="index"
                  >{{ index }}
                  </option>
                </v-ons-select>
                <label for="cars">行 横</label>
                <v-ons-select
                  class="on-select-input"
                  input-id="cars"
                  v-model="rowVerticalPrintLable"
                >
                  <option
                    v-for="(valRow, index) in tabVale[0]"
                    :value="valRow"
                    :key="index"
                  >{{ valRow }}</option
                  >-->
                  <option
                    v-for="(valRow, index) in tabVale[0]"
                    :value="valRow"
                    :key="index"
                  >{{ valRow }}
                  </option>
                </v-ons-select>
                <label for="cars">行 横</label>
                <v-ons-select
                  class="on-select-input"
                  input-id="cars"
                  v-model="rowVerticalPrintLable"
                >
                  <option
                    v-for="(valRow, index) in tabVale"
                    :value="(index += 1)"
                    :key="index"
                  >{{ index }}</option
                  >
                  <!--mod FNSI-改修内容ラベル開始位置がテンプレートと不一致 任 end-->
                </v-ons-select>
                <label for="cars">例</label>
                <v-ons-button
                  class="common-style-select-button btn-selected btn3-normal"
                  @click="clickSelected"
                >選択</v-ons-button
                >
              </div>
              <div style="margin: 0.6em;">
                <table class="table w-full" style="border: none; table-layout: fixed;">
                  <thead>
                    <tr>
                      <th></th>
                      <!--mod FNSI-改修内容ラベル開始位置がテンプレートと不一致 任 start-->
                      <th
                        class="th-titla th-td-body"
                        v-for="(valCol, index) in tabVale"
                        :key="index"
                      >
                        {{ index += 1 }}
                      </th>
                    </tr>
                  </thead>
                  <tbody>
                    <tr v-for="(valRow, index) in tabVale[0]" :key="index">
                      <th class="th-titla-body">{{ index += 1 }}</th>
                      <td class="th-td-body" v-for="(value, ind) in tabVale" :key="ind">
                      <!--mod FNSI-改修内容ラベル開始位置がテンプレートと不一致 任 end-->
                      <div
                        class="print-lable"
                        @click="onClick(index, ind)"
                        :class="{
                            'btn-selected':
                              horizontalSelected == index &&
                              verticalSelected == ind + 1
                          }"
                      ></div>
                    </td>
                    <td></td>
                  </tr>
                  </tbody>
                </table>
              </div>
            </div>
            <div>
              <v-ons-button
                class="common-style-select-button btn2-cancel"
                style="margin-top: 10px;"
                @click="closePopoverPrintLable(0)"
              >キャンセル</v-ons-button
              >
              <v-ons-button class="common-style-select-button btn3-normal" style="margin-top: 10px;float: right" @click="closePopoverPrintLable(1)">確定</v-ons-button>
            </div>
          </div>
        </v-ons-popover>
        <v-ons-popover
          cancelable
          :class="[fontSizeSet, 'user-menu-item-popover report-list-popover']"
          v-model:visible="popoverPrintVisible"
          :target="popoverPrintTarget"
          :direction="popoverPrintDirection"
        >
          <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start -->
          <!-- <v-ons-select
            v-show="hasPrinter"
            v-model="selectedPrinter"
            data-non-authorize="true"
            class="printer-selection"
          > -->
          <v-ons-select
            :disabled="!hasPrinter"
            v-model="selectedPrinter"
            data-non-authorize="true"
            class="printer-selection"
          >
          <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end -->
            <template v-for="item in getMstPrinters" :key="item.printerCd">
              <option :value="item.printerCd">{{ item.dispPrinterName }}</option>
            </template>
          </v-ons-select>
          <div class="button-area flex-container" style="flex-direction: row-reverse;">
            <div class="registration-btn-area">
              <button
                class="button registration-btn btn3-normal"
                :disabled="!hasPrinter"
                @click="printFile">印刷実行</button>
            </div>
          </div>
        </v-ons-popover>
      </div>
      <!-- add #699,700,751 陳 start -->
      <!-- mod Aspose.cells関連問題8の対応 夏 start -->
      <!-- <div class="patient-list flex-1" v-show="selectedReportClassID === 7"> -->
      <!--mod #11293 水質検査帳票の課題対応 limingzhe start-->
      <!-- <div class="patient-list flex-1" v-show="selectedReportClassID === 7 || multiTotalID === selectedReportID"> -->
      <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe start-->
      <!-- <div class="patient-list flex-1" v-show="selectedReportClassID === 7 || multiTotalID === selectedReportID || (selectedReportClassID === 11 && selectedReportTypeId === 3)"> -->
      <div class="patient-list flex-1" v-show="selectedObjectType === 2">
      <!--mod #11973 日常点検一覧帳票が正常に出せない limingzhe end-->
      <!--mod #11293 水質検査帳票の課題対応 limingzhe end-->
      <!-- mod Aspose.cells関連問題8の対応 夏 end -->
        <div style="height: 2.2em; display: flex; align-items: flex-end;">
          <span>対象装置({{selectedMachines.length}}/{{sortedMacList.length}}台)</span>
        </div>
        <div class="pat-container">
          <div class="table-header">
            <div class="table-header-wrap">
              <table class="patient-table-header" cellspacing="0">
                <thead>
                <tr>
                  <th width="10%" class="text-center" scope="col">
                    <v-ons-checkbox v-model="selectMachineAll" />
                  </th>
                  <th width="22%" scope="col">
                    <span @click="sortMBy('bedOrderIndex')" :class="sortedMClass('bedOrderIndex')" class="clickable-header-label">ベッド名</span>
                  </th>
                  <th width="28%" scope="col">
                    <span @click="sortMBy('machineSerial')" :class="sortedMClass('machineSerial')" class="clickable-header-label">製造番号</span>
                  </th>
                  <th
                    width="22%"
                    scope="col"
                  >
                    <span @click="sortMBy('machineOrderIndex')" :class="sortedMClass('machineOrderIndex')" class="clickable-header-label">装置名称</span>
                  </th>
                  <th
                    width="18%"
                    scope="col"
                  >
                    <span @click="sortMBy('machineTypeCd')" :class="sortedMClass('machineTypeCd')" class="clickable-header-label">型式</span>
                  </th>
                </tr>
                </thead>
              </table>
            </div>
          </div>
          <div class="table-body">
            <table class="patient-table-body">
              <tbody>
              <tr v-for="p in sortedMacList" :key="p.machineNo" @click="setSelectedMachine(p.machineNo)" style="word-break: break-all;">
                <td width="10%" class="text-center">
                  <v-ons-checkbox v-model="selectedMachines" :value="p.machineNo" />
                </td>
                <td width="22%">{{p.bedName}}</td>
                <td width="28%">{{p.machineSerial}} </td>
                <td width="22%">{{p.machineName}}</td>
                <td width="18%">{{p.machineType}}</td>
              </tr>
              </tbody>
            </table>
          </div>
        </div>

      </div>
      <!-- add ******************* 陳 end -->
      <div class="condition flex-1">
        <div class="wrapper-cod-save">
          <v-ons-button class="btn3-normal cod-save-btn" @click="saveSortBtnClick()">
            条件保存
          </v-ons-button>
        </div>
        <div class="wrapper-data-condition">
          <div class="condition-cart">
            <div @click="isDataConditonVisible = !isDataConditonVisible">
              <div class="color-header">データ抽出条件</div>
            </div>
            <div v-show="isDataConditonVisible">
              <div
                class="l-margin b-margin"
                :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID) ? 'active': 'disabled'">
              <!-- mod Aspose.cells関連問題8の対応 夏 end -->
                <!-- mod #699,700,751 陳 end -->
                <div>基準日</div>
                <div style="display: flex; flex-flow: wrap;">
                  <div style="display: flex; flex-flow: nowrap; align-items: center; margin-right: 1em;">
                    <!--  mod #11226 患者情報系historyの取得条件見直し② limingzhe start -->
                    <!--  <v-ons-radio
                      input-id="dialysis_date"
                      value="true"
                      name="dialysis_date"
                      checked="checked"
                      v-model="dataCondition.isDialysisDate"
                      modifier="round"></v-ons-radio> -->
                    <v-ons-radio
                      input-id="dialysis_date"
                      value="dialysis_date"
                      name="dialysis_date"
                      v-model="dataCondition.dateKind"
                      modifier="round"></v-ons-radio>
                    <!--  mod #11226 患者情報系historyの取得条件見直し② limingzhe end -->
                    <label for="dialysis_date" id="dialysis_date_id">治療日</label>
                  </div>
                  <div style="display: flex; flex-flow: nowrap; align-items: center; margin-right: 1em;">
                    <!--  mod #11226 患者情報系historyの取得条件見直し② limingzhe start -->
                    <!--  <v-ons-radio
                      input-id="exam_date"
                      value="false"
                      name="dialysis_date"
                      v-model="dataCondition.isDialysisDate"
                      modifier="round"
                    ></v-ons-radio> -->
                    <v-ons-radio
                      input-id="exam_date"
                      value="exam_date"
                      name="dialysis_date"
                      v-model="dataCondition.dateKind"
                      modifier="round"
                    ></v-ons-radio>
                    <!--  mod #11226 患者情報系historyの取得条件見直し② limingzhe end -->
                    <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                    <!--<label for="exam_date">検査日</label>-->
                    <label for="exam_date" id="exam_date_id">検査日</label>
                    <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                  </div>
                  <!--  add #11226 患者情報系historyの取得条件見直し② limingzhe start -->
                  <div :class="(selectedReportClassID && selectedReportClassID !== 7) ? 'active': 'disabled'"
                       style="display: flex; flex-flow: nowrap; align-items: center; margin-right: 1em;">
                    <v-ons-radio
                      input-id="issue_date"
                      value="issue_date"
                      name="dialysis_date"
                      v-model="dataCondition.dateKind"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="issue_date" id="issue_date_id">処方日</label>
                  </div>
                  <!--  add #11226 患者情報系historyの取得条件見直し② limingzhe end -->
                  <div style="display: flex; flex-flow: nowrap; align-items: center; margin-right: 1em;">
                    <v-ons-radio
                      input-id="letter_issue_date"
                      value="letter_issue_date"
                      name="dialysis_date"
                      v-model="dataCondition.dateKind"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="letter_issue_date" id="letter_issue_date_id">紹介日</label>
                  </div>
                  <div style="display: flex; flex-flow: nowrap; align-items: center; margin-right: 1em;">
                    <v-ons-radio
                      input-id="all_date"
                      value="all_date"
                      name="dialysis_date"
                      v-model="dataCondition.dateKind"
                      modifier="round"
                    ></v-ons-radio>
                    <label for="all_date" id="all_date_id">すべて</label>
                  </div>
                </div>
              </div>
              <div
                class="l-margin b-margin"
                :class="(selectedReportClassID && extractCondition[selectedReportClassID]['isRangeTime']) ? 'active': 'disabled'"
              >
                <v-ons-radio
                  input-id="range_time"
                  value="range_time"
                  name="data_extraction"
                  v-model="dataCondition.timeType"
                  modifier="round"
                ></v-ons-radio>
                <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                <!--<label for="range_time">期間指定</label>-->
                <label for="range_time" id="range_time_id">期間指定</label>
                <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                <div :class="(dataCondition.timeType == 'range_time') ? 'active':'disabled'">
                  <span style="display: inline-flex; align-items: center;">
                    <!-- mod FNSI-期間指定 じょはく start-->
                    <!-- <input type="date" class="custom-input-date ntss-input-date" v-model="dataCondition.fromDate" />-->
                    <!--del   日付のチェックの追加対応 吉 start-->
                    <!--<input type="date" class="custom-input-date ntss-input-date" @blur="checkDate" v-model="dataCondition.fromDate" />-->
                    <!--del   日付のチェックの追加対応 吉 end-->
                    <!-- mod FNSI-期間指定 じょはく end-->
                    <!--del   日付のチェックの追加対応 吉 start-->
                    <!--<common-calendar v-model="dataCondition.fromDate" />-->
                    <!--del   日付のチェックの追加対応 吉 end-->
                    <!--add   日付のチェックの追加対応 吉 start-->
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                    <!-- <input type="date" class="custom-input-date ntss-input-date fromDate"
                          max="9999-12-31"
                          @keyup="showMsg(0)"
                          @blur="getDate(0)"
                          v-model="dataCondition.fromDate" /> -->
                    <date-input :classes="'custom-input-date ntss-input-date fromDate'"
                          @keyup="showMsg(0)"
                          v-model="dataCondition.fromDate"
                          isRequired
                          />
                          <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                    <common-calendar v-model="dataCondition.fromDate" class="calender fromDate-comment"/>
                  <span class="error-message" v-if="showErrorFromDate">{{
                    this.msgDiaLog
                  }}</span>
                    <!--add   日付のチェックの追加対応 吉 end-->
                  </span>
                  <span>~</span>
                  <span style="display: inline-flex; align-items: center;">
                    <!-- mod FNSI-期間指定 じょはく start-->
                    <!-- <input type="date" class="custom-input-date ntss-input-date" v-model="dataCondition.toDate" />-->
                    <!--del   日付のチェックの追加対応 吉 start-->
                    <!--<input type="date" class="custom-input-date ntss-input-date" @blur="checkDate" v-model="dataCondition.toDate" />-->
                    <!--del   日付のチェックの追加対応 吉 end-->
                    <!-- mod FNSI-期間指定 じょはく end-->
                    <!--del   日付のチェックの追加対応 吉 start-->
                    <!--<common-calendar @onmonthchange="checkDate" v-model="dataCondition.toDate"/>-->
                    <!--del   日付のチェックの追加対応 吉 end-->
                    <!--add   日付のチェックの追加対応 吉  @onmonthchange="checkDate" start-->
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                    <!-- <input type="date" class="custom-input-date ntss-input-date toDate"
                          max="9999-12-31"
                          @keyup="showMsg(1)"
                          @blur="getDate(1)"
                          v-model="dataCondition.toDate" /> -->
                      <date-input :classes="'custom-input-date ntss-input-date toDate'"
                          @keyup="showMsg(1)"
                          v-model="dataCondition.toDate"
                          isRequired
                          />
                          <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                    <common-calendar class="calender toDate-comment"  v-model="dataCondition.toDate"/>
                  <span class="error-message" v-if="showErrorToDate">{{
                    this.msgDiaLog
                  }}</span>
                    <!--add   日付のチェックの追加対応 吉 end-->
                  </span>
                </div>
              </div>
              <div
                class="l-margin b-margin"
                :class="(selectedReportClassID && extractCondition[selectedReportClassID]['isSpecifyDate']) ? 'active': 'disabled'"
              >
                <v-ons-radio
                  input-id="specify_date"
                  value="specify_date"
                  name="data_extraction"
                  v-model="dataCondition.timeType"
                  modifier="round"
                ></v-ons-radio>
                <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                <!--<label for="specify_date">1日指定</label>-->
                <label for="specify_date" id="specify_date_id">1日指定</label>
                <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                <div :class="(dataCondition.timeType == 'specify_date') ? 'active':'disabled'">
                  <!--mod FNSI-No.341 患者リストのソート項目不足 吉 start-->
                  <!--<input type="date" class="custom-input-date ntss-input-date" v-model="dataCondition.specifyDate" />
                  <common-calendar v-model="dataCondition.specifyDate" />-->
                  <span style="display: inline-flex; align-items: center;">
                    <date-input :classes="'custom-input-date ntss-input-date specifyDate'"
                          @keyup="showMsg(2)"
                          v-model="dataCondition.specifyDate"
                          isRequired
                          />
                    <common-calendar v-model="dataCondition.specifyDate"   class="calender specifyDate-comment"/>
                  </span>
                  <br/>
                  <span class="error-message" v-if="showErrorSpecifyDate">{{
                    this.msgDiaLog
                  }}</span>
                  <!--mod FNSI-No.341 患者リストのソート項目不足  吉 end-->
                </div>
              </div>
              <!-- mod #699,700,751 陳 start -->
              <!--          <div-->
              <!--            class="l-margin b-margin"-->
              <!--            :class="(selectedReportClassID && extractCondition[selectedReportClassID]['isInspectionDate']) ? 'active': 'disabled'"-->
              <!--          >-->
              <!-- mod Aspose.cells関連問題8の対応 夏 start -->
              <!--<div-->
              <!--            class="l-margin b-margin"-->
              <!--            :class="(selectedReportClassID && selectedReportClassID !== 7 && extractCondition[selectedReportClassID]['isInspectionDate']) && dataCondition.isDialysisDate =='false' ? 'active': 'disabled'"-->
              <!--          >-->
              <!--mod #11226 患者情報系historyの取得条件見直し②  房 start-->
              <div
                class="l-margin b-margin"
                :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID && extractCondition[selectedReportClassID]['isInspectionDate']) && dataCondition.dateKind === 'exam_date' ? 'active': 'disabled'"
              >
              <!--mod #11226 患者情報系historyの取得条件見直し②  房 end-->
              <!-- mod Aspose.cells関連問題8の対応 夏 end -->
                <!-- mod #699,700,751 陳 end -->
                <v-ons-radio
                  input-id="inspection_date"
                  value="inspection_date"
                  name="data_extraction"
                  v-model="dataCondition.timeType"
                  modifier="round"
                ></v-ons-radio>
                <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                <!--<label for="inspection_date">検査日数指定</label>-->
                <label for="inspection_date" id="inspection_date_id">検査日数指定</label>
                <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                <!--mod #11226 患者情報系historyの取得条件見直し②  房 start-->
                <div :class="(dataCondition.timeType == 'inspection_date') && dataCondition.dateKind === 'exam_date' ? 'active':'disabled'">
                  <!--mod #11226 患者情報系historyの取得条件見直し②  房 end-->
                  <span style="display: inline-flex; align-items: center;">
                    <!--mod FNSI-No.341 患者リストのソート項目不足 吉 start-->
                    <!--<input type="date" class="custom-input-date ntss-input-date" v-model="dataCondition.inspectionDate" />
                    <common-calendar v-model="dataCondition.inspectionDate" />-->
                    <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 start -->
                    <!-- <input type="date" class="custom-input-date ntss-input-date inspectionDate"
                          v-model="dataCondition.inspectionDate"
                          max="9999-12-31"
                          @keyup="showMsg(3)"
                          @blur="getDate(3)"/> -->
                    <date-input :classes="'custom-input-date ntss-input-date inspectionDate'"
                          v-model="dataCondition.inspectionDate"
                          @keyup="showMsg(3)"
                          isRequired
                          />
                          <!-- #5590 2023/04/20 ×を常に表示するように修正 張博 end -->
                    <common-calendar v-model="dataCondition.inspectionDate" class="calender inspectionDate-comment"/>
                    <span class="error-message" v-if="showErrorInspectionDate">{{
                      this.msgDiaLog
                    }}</span>
                    <!--mod FNSI-No.341 患者リストのソート項目不足 吉 end-->
                  </span>
                  <span>~</span>
                  <span style="display: inline-flex; align-items: center; white-space: nowrap">
                  <!-- mod FNSI-改修内容4392bug修正 関 start -->
                    <!-- <v-ons-select name="text" input-id="text" class="d-inline-flex" style="width: 20%" v-model="dataCondition.key"> -->
                    <v-ons-select name="text" input-id="text" class="d-inline-flex" style="width: 80px" v-model="dataCondition.key">
                    <!-- mod  FNSI-改修内容4392bug修正 関 end -->
                      <option value="before">前</option>
                      <option value="after" selected>後</option>
                    </v-ons-select>
                    <!-- mod FNSI-検査日数指定 じょはく start-->
                  <!-- mod  FNSI-改修内容4392bug修正 関 start -->
                    <!-- <input
                      type="number"
                      value="0"
                      min="0"
                      onkeyup="value = value.replace(/[^\d]/g,'')"
                      style="width: 15%"
                      v-model="dataCondition.numDay"
                    />日 -->
                  <input
                      type="number"
                      value="0"
                      min="0"
                      onkeyup="value = value.replace(/[^\d]/g,'')"
                      style="width: 60px"
                      v-model="dataCondition.numDay"
                    />日
                  <!-- mod  FNSI-改修内容4392bug修正 関 end -->
                    <!-- mod FNSI-検査日数指定 じょはく end-->
                  </span>
                </div>
              </div>
              <!-- mod #699,700,751 陳 start -->
              <!--          <div class="l-margin b-margin" :class="selectedReportClassID ? 'active':'disabled'">-->
              <!-- mod Aspose.cells関連問題8の対応 夏 start -->
              <!-- <div class="l-margin b-margin" :class="selectedReportClassID && selectedReportClassID !== 7 ? 'active':'disabled'"> -->
              <div class="l-margin b-margin" :class="isRegOrderClassActive ? 'active':'disabled'">
              <!-- mod Aspose.cells関連問題8の対応 夏 end -->
                <!-- mod #699,700,751 陳 end -->
                <div>検査区分</div>
                <div class="box-inline">
                  <v-ons-checkbox value="1"
                                  input-id="before_dialysis"
                                  v-model="dataCondition.regOrderClass" />
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                  <!--<label for="before_dialysis">透析前</label>-->
                  <label for="before_dialysis" id="before_dialysis_id">透析前</label>
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                </div>
                <div class="box-inline">
                  <v-ons-checkbox value="2"
                                  input-id="after_dialysis"
                                  v-model="dataCondition.regOrderClass" />
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                  <!--<label for="after_dialysis">透析後</label>-->
                  <label for="after_dialysis" id="after_dialysis_id">透析後</label>
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                </div>
                <div class="box-inline">
                  <v-ons-checkbox value="0" input-id="other" v-model="dataCondition.regOrderClass" />
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                  <!--<label for="other">その他</label>-->
                  <label for="other" id="other_id">その他</label>
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                </div>
              </div>
<!--              add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start-->
              <div class="l-margin b-margin" :class="isChkViewPreActive ? 'active':'disabled'">
                <div>処方区分</div>
                <div class="box-inline">
                  <v-ons-checkbox value="1" input-id="viewPreOut" v-model="dataCondition.prescriptionClass" />
                  <label for="viewPreOut" id="viewPreOut_id">院外</label>
                </div>
                <div class="box-inline"></div>
                <div class="box-inline">
                  <v-ons-checkbox value="2" input-id="viewPreIn" v-model="dataCondition.prescriptionClass" />
                  <label for="viewPreIn" id="viewPreIn_id">院内</label>
                </div>
              </div>
<!--              add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end-->
              <div class="l-margin b-margin" :class="isChkViewLetterActive ? 'active':'disabled'">
                <div>紹介区分</div>
                <div class="box-inline">
                  <v-ons-checkbox value="0" input-id="viewMovingOut" v-model="dataCondition.letterCategory" />
                  <label for="viewMovingOut" id="viewMovingOut_id">転出</label>
                </div>
                <div class="box-inline"></div>
                <div class="box-inline">
                  <v-ons-checkbox value="1" input-id="viewMovingIn" v-model="dataCondition.letterCategory" />
                  <label for="viewMovingIn" id="viewMovingIn_id">転入</label>
                </div>
              </div>
            </div>
          </div>
          <!-- mod #699,700,751 陳 start -->
          <!--        <div-->
          <!--          :class="(selectedReportClassID && extractCondition[selectedReportClassID]['isEquipment']) ? 'active': 'disabled'"-->
          <!--        >-->
          <!-- mod Aspose.cells関連問題8の対応 夏 start -->
          <!-- <div -->
          <!--           :class="(selectedReportClassID && selectedReportClassID !== 7 && extractCondition[selectedReportClassID]['isEquipment']) ? 'active': 'disabled'" -->
          <!--         > -->
          <div class="condition-cart">
            <div @click="isEquipConditonVisible = !isEquipConditonVisible">
              <div class="color-header">
                <span style="display: inline-table; width: 40%;">医療材料</span>
                <div style="display: inline-table; width: 40%;"
                  :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID && extractCondition[selectedReportClassID]['isEquipment']) ? 'active': 'disabled'"
                  @click.stop>
                  <v-ons-checkbox input-id="equipment_all"
                                      name="equipment_all"
                                      v-model="selectEquipmentAll"
                                      />
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                  <!--<label for="equipment_all">すべて選択</label>-->
                  <label for="equipment_all" id="equipment_all_id">すべて選択</label>
                  <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                </div>
              </div>
            </div>
            <div v-show="isEquipConditonVisible">
              <div
                  :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID && extractCondition[selectedReportClassID]['isEquipment']) ? 'active': 'disabled'"
                >
                <!-- mod Aspose.cells関連問題8の対応 夏 end -->
                  <!-- mod #699,700,751 陳 end -->
                  <div class="l-margin b-margin">
                    <div v-for="item in EQUIPMENT.childrens" :key="item.id" class="condition-list">
                      <v-ons-checkbox :input-id="'equiment' + item.id"
                                      :value="item.id"
                                      v-model="EQUIPMENT.checkedList"
                      />
                      <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                      <!--<label :for="item.id">{{item.text}}</label>-->
                      <label :for="'equiment' + item.id" :id="'equiment' + item.id">{{item.text}}</label>
                      <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                    </div>
                  </div>
              </div>
            </div>
          </div>
          <!-- mod #699,700,751 陳 start -->
          <!--        <div-->
          <!--          :class="(selectedReportClassID && selectedReportClassID !== 7 && extractCondition[selectedReportClassID]['isMedicine']) ? 'active': 'disabled'"-->
          <!--        >-->
          <!-- mod Aspose.cells関連問題8の対応 夏 start -->
          <!-- <div -->
          <!--           :class="(selectedReportClassID && selectedReportClassID !== 7 && extractCondition[selectedReportClassID]['isMedicine']) ? 'active': 'disabled'" -->
          <!--         > -->
          <div class="condition-cart">
            <div @click="isMediConditonVisible = !isMediConditonVisible">
                <div class="color-header">
                  <span style="display: inline-table; width: 40%;">薬剤</span>
                  <div style="display: inline-table; width: 40%;"
                    :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID && extractCondition[selectedReportClassID]['isMedicine']) ? 'active': 'disabled'"
                    @click.stop>
                    <v-ons-checkbox input-id="medicine_all"
                                    name="medicine_all"
                                    v-model="selectMedicineAll"
                                    />
                    <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                    <!--<label for="medicine_all">すべて選択</label>-->
                    <label for="medicine_all" id="medicine_all_id">すべて選択</label>
                    <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                  </div>
                </div>
            </div>
            <div v-show="isMediConditonVisible">
              <div
                :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID && extractCondition[selectedReportClassID]['isMedicine']) ? 'active': 'disabled'"
              >
              <!-- mod Aspose.cells関連問題8の対応 夏 end -->
                <!-- mod #699,700,751 陳 end -->
                <div class="l-margin b-margin">
                  <div v-for="item in MEDICINE.childrens" :key="item.id" class="condition-list">
                    <v-ons-checkbox :input-id="'medicine' + item.id"
                                    :value="item.id"
                                    v-model="MEDICINE.checkedList"
                    />
                    <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 start-->
                    <!--<label :for="item.id">{{item.text}}</label>-->
                    <label :for="'medicine' + item.id" :id="'medicine'+item.id">{{item.text}}</label>
                    <!--mod 8486 CSSの修正により、ファイル保存問題が発生  吉 end-->
                  </div>
                </div>
              </div>
            </div>
          </div>
          <!-- mod #699,700,751 陳 end -->
<!--          add #11603 検査予定のラベル出力とフィルタ機能 高 start-->
<!--          検査セット-->
          <div class="condition-cart">
            <div @click="isExamSetVisable = !isExamSetVisable">
              <div class="color-header">
                <span style="display: inline-table; width: 40%;">検査セット</span>
                <div style="display: inline-table; width: 40%;"
                     :class="(selectedReportClassID == 8) ? 'active': 'disabled'"
                     @click.stop>
                  <v-ons-checkbox input-id="examSet_all" name="examSet_all" v-model="selectExamSetAll"/>
                  <label for="examSet_all" id="examSet_all_id">すべて選択</label>
                </div>
              </div>
            </div>
            <div v-show="isExamSetVisable">
              <div :class="(selectedReportClassID == 8) ? 'active': 'disabled'">
                <div class="l-margin b-margin">
                  <div v-for="item in EXAMSET.childrens" :key="item.id" class="condition-list">
                    <v-ons-checkbox :input-id="'examSet' + item.id"
                                    :value="item.id"
                                    v-model="EXAMSET.checkedList"
                    />
                    <label :for="'examSet' + item.id" :id="'examSet'+item.id">{{item.text}}</label>
                  </div>
                </div>
              </div>
            </div>
          </div>
<!--          add #11603 検査予定のラベル出力とフィルタ機能 高 end-->
<!--          mod #12626 ラベル帳票で静的テキストが繰り返されない 高 start-->
<!--          <div class="condition-cart" v-if="false">-->
          <div class="condition-cart" v-show="false">
<!--          mod #12626 ラベル帳票で静的テキストが繰り返されない 高 end-->
            <div>
              <div class="color-header">
                <!-- mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start -->
<!--                mod #11603 検査予定のラベル出力とフィルタ機能 高 start-->
                 <div style="display: inline-table; width: 40%;"
                :class="(selectedReportClassID == 8) ? 'active': 'disabled'">
<!--                <div style="display: inline-table; margin-right: 1em; width: 40%;"-->
<!--                  :class="(selectedReportClassID && selectedReportClassID !== 7 && multiTotalID !== selectedReportID && extractCondition[this.selectedReportClassID]['isInspection']) ? 'active': 'disabled'">-->
<!--                   mod #11603 検査予定のラベル出力とフィルタ機能 高 end-->
                <!-- mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end -->
                  <v-ons-checkbox
                    checked=“checked”
                    input-id="check_all"
                    name="check_all"
                    v-model="inspectCheckBox"
                  />
<!--                   mod #11603 検査予定のラベル出力とフィルタ機能 高 start-->
<!--                   <label for="check_all" id="check_all_id" style="display: inline-table; width: 40%; margin-right: calc(1em + 6px);">検査</label>-->
                  <label for="check_all" id="check_all_id" style="display: inline-table; width: 40%;">採血管</label>
<!--                   mod #11603 検査予定のラベル出力とフィルタ機能 高 end-->
                </div>
              </div>
            </div>
          </div>
        </div>
        <!-- del FNSI-改修内容 画面ボタンの位置調整 穆 start -->
        <!-- <div class="btn-group">
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="(selectedPatients.length > 0 && selectedReportClassID) ? 'active':'disabled'"
            @click="showExportPopover($event, 'up', true)"
          >ファイル保存</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="selectedReportClassID == 8 ? 'active':'disabled'"
            @click="generateValueTable($event, 'up', true)"
          >ラベル開始位置</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="(selectedReportClassID && extractCondition[selectedReportClassID]['isSort']) ? 'active': 'disabled'"
            @click="showPopover($event, 'up', true)"
          >並び替え</v-ons-button>
          <br />
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="(selectedPatients.length > 0 && selectedReportClassID) ? 'active':'disabled'"
            @click="previewFile"
          >プレビュー</v-ons-button>
          <v-ons-button
            class="common-style-select-button btn-width-fix"
            :class="(selectedPatients.length > 0 && selectedReportClassID) ? 'active':'disabled'"
            @click="printFile"
          >印刷</v-ons-button>
        </div> -->
        <!-- del FNSI-改修内容 画面ボタンの位置調整 穆 end -->
        <!--mod 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 start-->
        <!--<v-ons-modal :visible="modalVisible" @postshow="postShow" :class="['custom-modal', fontSizeSet]">-->
        <v-ons-modal :visible="modalVisible" @postshow="postShow" :class="['custom-modal-specialized', fontSizeSet]">
          <!--mod 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 end-->

<!--          <div class="modal-preview"  :style="scrwidth">-->
          <div class="modal-preview">
            <!-- upd 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end -->
            <!-- <div id="modal-content" class="modal-content" v-html="resultPreview"></div> -->
            <div id="scrollArea" align="center" class="modal-content" style="font-size:11px !important;" v-html="resultPreview"></div>
            <!-- upd 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end -->
            <!--mod 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 start-->
            <!--<div style="display: flex; justify-content: space-between;">-->
            <div style="display: flex; justify-content: space-between;align-self: flex-end;">
              <!--mod 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 end-->
              <v-ons-button
                class="btn-custom common-style-select-button btn2-cancel"
                @click="modalVisibleClose"
              >閉じる</v-ons-button>
              <div style="width: calc(100% - 435px);"></div>
              <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 start -->
              <!-- <v-ons-select
                    v-show="hasPrinter"
                    v-model="selectedPrinter"
                    data-non-authorize="true"
                    class="printer-selection-preview"
                  > -->
              <v-ons-select
                :disabled="!hasPrinter"
                v-model="selectedPrinter"
                data-non-authorize="true"
                class="printer-selection-preview"
              >
              <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe 20251114 end -->
                <template v-for="item in getMstPrinters" :key="item.printerCd">
                  <option :value="item.printerCd">{{ item.dispPrinterName }}</option>
                </template>
              </v-ons-select>
              <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe start -->
              <!-- <v-ons-button
                class="btn-custom common-style-select-button btn3-normal"
                @click="printFile"
              >印刷</v-ons-button> -->
              <v-ons-button
                class="btn-custom common-style-select-button btn3-normal"
                :disabled="!hasPrinter"
                @click="printFile"
              >印刷</v-ons-button>
              <!-- mod #12107 帳票印刷失敗通知が行われない limingzhe end -->
            </div>
          </div>
        </v-ons-modal>
      </div>
    </div>

  </div>
</template>

<script>
import {getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll, getScopedDocument, getScopedWindow, triggerScopedDownload, getScopedJQuery as createScopedJQuery} from "@/functions/common/LayoutMeasureHelper";
  import {mapActions, mapGetters, mapMutations} from "@/compat/vue/vuex";
  import axios from "@/compat/http/axios";
  import dayjs from "@/compat/date/dayjs";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
  import {ApiHelper} from "@/apis/AxiosHelper.js";
  import {formatDatetime} from "@/functions/common/CommonFunctions";
  // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
  // mod #11603 検査予定のラベル出力とフィルタ機能 高 start
  // import {equipmentClass, medicineClass} from "@/functions/mst/MstGetters.js";
  import {equipmentClass, medicineClass,examSetClass} from "@/functions/mst/MstGetters.js";
  // mod #11603 検査予定のラベル出力とフィルタ機能 高 end
  // add FNSI-改修内容 画面ボタンの位置調整 穆 start
  import {EventBus} from "@/compat/vue/event-bus.js";
  // add FNSI-改修内容 画面ボタンの位置調整 穆 end
  /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
  import {EXTRACTION_CONDITION, REPORT_CLASS, REPORT_HIDDEN, SORT_CONDITION, DEFAULT_CONDITION} from "@/constants/reportMenu.js";
  import PopoverMixin from "@/components/PopoverMixin";
  // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
  import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
  import {deepCopy} from "../../functions/common/CommonFunctions";
  import $$ from "@/compat/jquery";
  //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
  // jQureyを宣言（'$'はvue.jsで使用されているため、'$$'で宣言）

  //#5590 2023/04/20 ×を常に表示するように修正 張博 start
  import DateInput from "@/components/common/DateInput.vue";
  //#5590 2023/04/20 ×を常に表示するように修正 張博 end
  import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import nameDuplicationImg from "../../assets/name_duplication.png";

  export default {
    mixins: [PopoverMixin],
    name: "ReportMenuListComponent",
    data() {
      return {
        //add 8507 2023-4-6 zhaoqj  ローラデータローディング start
        currentPatIds:[],
        //add 8507 2023-4-6 zhaoqj  ローラデータローディング end
        //同姓同名アイコン
        image_src_same: nameDuplicationImg,
        staorMap:[],
        scrwidth: {
          width:'1080px'
        },
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
        isRedrawing: 'false',
        reportOption: 0,
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
        reportClass: REPORT_CLASS,
        // add Aspose.cells関連問題8の対応 夏 start
        multiTotalID: '',
        // add Aspose.cells関連問題8の対応 夏 end
        reportHidden: REPORT_HIDDEN,
        extractCondition: EXTRACTION_CONDITION,
        sortCondition: SORT_CONDITION,
        reportTypeID: null,
        selectedReportClassID: null,
        selectedReportID: null,
        // add #11293 水質検査帳票の課題対応 limingzhe start
        selectedReportTypeId:null,
        // add #11293 水質検査帳票の課題対応 limingzhe end
        patList: [],
        selectedPatients: [],
        savedSelectedPatients: {}, // 患者毎のチェックボックスON/OFF状態 key: patId、value: チェックボックスON/OFF
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
        kulList: [],
        bedList: [],
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
        macList: [],
        // add #699,700,751 陳 start
        selectedMachines: [],
        searchedMacList: [],
        // add #699,700,751 陳 end
        mstMedicine: null,
        mstEquipment: null,
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        mstExamSet: null,
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        mstReport: null,
        popoverVisible: false,
        popoverTarget: null,
        // mod FNSI-改修内容 画面ボタンの位置調整 穆 start
        // popoverDirection: "up",
        popoverDirection: "left",
        // mod FNSI-改修内容 画面ボタンの位置調整 穆 end
        coverTarget: false,
        popoverExportVisible: false,
        popoverExportTarget: null,
        // mod FNSI-改修内容 画面ボタンの位置調整 穆 start
        // popoverExportDirection: "up",
        popoverExportDirection: "left",
        // mod FNSI-改修内容 画面ボタンの位置調整 穆 end
        coverExportTarget: false,
        popoverPrintVisible: false,
        popoverPrintTarget: null,
        popoverPrintDirection: "left",
        coverPrintTarget: false,
        selectedPrinter: null,
        // add #12107 帳票印刷失敗通知が行われない limingzhe start
        defaultPrinter: null,
        // add #12107 帳票印刷失敗通知が行われない limingzhe end
        defaultReportID: null,
        selectedExport: "1",
        modalVisible: false,
        printDirect: null,
        stPos: 1,
        // add #9323 donghao start
        pageIndex:1,
        // add #9323 donghao end
        sortTargets: [
          { key: "", sort: "asc" }, // 一番
          { key: "", sort: "asc" }, // ２番
          { key: "", sort: "asc" }
        ],
        sortTemp: [
          { key: "", sort: "asc" }, // 一番
          { key: "", sort: "asc" }, // ２番
          { key: "", sort: "asc" }
        ],
        MEDICINE: {
          id: "medicine",
          text: "薬剤",
          selected: false,
          checkedList: [],
          childrens: []
        },
        EQUIPMENT: {
          id: "equipment",
          text: "医療材料",
          selected: false,
          checkedList: [],
          childrens: []
        },
        //add 5981 薬剤の下に検査の区分を作成し、〇採血管（〇はチェックボックス）を追加する。 吉 start
        CHECKLIST: {
          id: "inspect",
          text: "检查",
          selected: false,
          checkedList: ["1"],
          childrens: [{id: "1", text: "採血管"}]
        },
        // add 5981 薬剤の下に検査の区分を作成し、〇採血管（〇はチェックボックス）を追加する。 吉 end
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        EXAMSET: {
        id: "examSet",
          text: "検査セット",
          selected: false,
          checkedList: [],
          childrens: []
        },
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        inspectCheckBox: true, // 検査カードのチェックボックス：デフォルトON
        tabVale: [],
        popoverPrintLableReport: null,
        popoverPrintLableVisible: false,
        colHorizontalPrintLable: 1,
        rowVerticalPrintLable: 1,
        horizontalSelected: 1,
        verticalSelected: 1,
        currentSort: {
          key: "",
          isAsc: true
        },
        currentSortM: {
          key: "",
          isAsc: true
        },
        // add #11226 患者情報系historyの取得条件見直し② limingzhe start
        dateType: [
          { text: 'dialysis_date', value: 0 },
          { text: 'exam_date', value: 1 },
          { text: 'issue_date', value: 2 },
          { text: 'letter_issue_date', value: 3 },
          { text: 'all_date', value: 4 }
        ],
		    // add #11226 患者情報系historyの取得条件見直し② limingzhe end
        dataCondition: {
          timeType: "specify_date",
          fromDate: dayjs().format("YYYY-MM-DD"),
          toDate: dayjs().format("YYYY-MM-DD"),
          specifyDate: dayjs().format("YYYY-MM-DD"),
          inspectionDate: dayjs().format("YYYY-MM-DD"),
          key: "after",
          numDay: 0,
          regOrderClass: ["1", "2"],
          // add #11226 患者情報系historyの取得条件見直し② limingzhe start
          dateKind: 'dialysis_date',
          // add #11226 患者情報系historyの取得条件見直し② limingzhe end
          // 指定日を透析日とするか否か
          isDialysisDate: 'true',
          // 期間指定終了の日数
          rangeEndNum: 0,
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
          prescriptionClass: ["1", "2"],
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
          // 紹介区分
          letterCategory: ["0", "1"],
        },
        //mod 2023-4-7 zhaoqj 画面のデフォルト値nullが「」に変更されました start
        resultPreview: "",
        // resultPreview: null,
        //mod 2023-4-7 zhaoqj 画面のデフォルト値nullが「」に変更されました end
        /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
        msgDiaLog: DIALOG_MESSAGES["99999995"].message,
        showErrorFromDate: false,
        showErrorToDate: false,
        showErrorSpecifyDate: false,
        showErrorInspectionDate: false,
        /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
        hideflag:true,
        realyDate:[],
        showAllflag:true,
        saveLine: 1,
        saveRow: 1,
        maxCount: 1,
        // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
        scrollControl: true,
        // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
        selfScreenName: "",
        isDataConditonVisible: true,
        isEquipConditonVisible: true,
        isMediConditonVisible: true,
        isExamConditonVisible: true,
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        isExamSetVisable: true,
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        revokeURL: null,
        allSelectedMode: true, // 対象患者リスト検索前、基準日変更時点の全体チェックボックスのON/OFF状態
        initflag: true, // 初期化フラグ true: 画面表示時、帳票変更時、false: データ抽出条件変更時
        isApplyingDataCondition: false,
        isRegOrderClassActive: false,
        sortPopoverBtnClick: false, // 並び替えポップオーバー内のボタンが押下されたかを判定するフラグ
        // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
        isChkViewPreActive: false, // 処方区分
        // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
        isChkViewLetterActive: false, // 紹介区分
      };
    },
    components: {
      "common-calendar": commonCalender,
      //#5590 2023/04/20 ×を常に表示するように修正 張博 start
      "date-input":DateInput,
      //#5590 2023/04/20 ×を常に表示するように修正 張博 end
    },
    // add Aspose.cells関連問題対応 鄭爽 start
    mounted(){
      getScopedWindow(this.$el || null)?.addEventListener('mousewheel', this.handleScroll);
    },
    // add Aspose.cells関連問題対応 鄭爽 end
    async created() {
      // 画面名称取得
      this.selfScreenName = this.$route.name;
      var mstReport;
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // add FNSI-改修内容 画面ボタンの位置調整 穆 start
      EventBus.$off("exportMsg", this.onExportMsg);
      EventBus.$on("exportMsg", this.onExportMsg);
      /*add FNSI-改修内容パンくずリスト対応 任 start*/
      EventBus.$off("refresh", this.refresh);
      EventBus.$on("refresh", this.refresh);
      /*add FNSI-改修内容パンくずリスト対応 任 end*/
      EventBus.$off("printMsg", this.onPrintMsg);
      EventBus.$on("printMsg", this.onPrintMsg);
      // del #11055 画面の最新状態を元に帳票出力するようにする 高 start
      // old msg listener:
      //   this.showPopover(param.paramEvent, param.paramDirection, param.paramCoverTarget);
      // del #11055 画面の最新状態を元に帳票出力するようにする 高 end
      // add #11055 画面の最新状態を元に帳票出力するようにする 高 start
      EventBus.$off("msg", this.onMsg);
      EventBus.$on("msg", this.onMsg);
      EventBus.$emit("invokeSearch");
      // add #11055 画面の最新状態を元に帳票出力するようにする 高 end
      EventBus.$off("previewFileMsg", this.previewFile);
      EventBus.$off("printFileMsg", this.printFile);
      EventBus.$on("previewFileMsg", this.previewFile);
      EventBus.$on("printFileMsg", this.printFile);
      EventBus.$off("printerSelectMsg", this.onPrinterSelectMsg);
      EventBus.$on("printerSelectMsg", this.onPrinterSelectMsg);
      // add FNSI-改修内容 画面ボタンの位置調整 穆 end
      try {
        // mod #699,700,751 陳 start
        // [this.mstMedicine, this.mstEquipment, mstReport] = await Promise.all([
        //   medicineClass(this.facilityCd),
        //   equipmentClass(this.facilityCd),
        //   ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd)
        // ]);
        let machinesRes = null;
        // mod #11603 検査予定のラベル出力とフィルタ機能 高 start
        // [this.mstMedicine, this.mstEquipment, mstReport, machinesRes] = await Promise.all([
        //   medicineClass(this.facilityCd),
        //   equipmentClass(this.facilityCd),
        //   ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd),
        //   ApiHelper.get("/mente-main/machines-inspection")
        // ]);
        [this.mstMedicine, this.mstEquipment, mstReport, machinesRes,this.mstExamSet] = await Promise.all([
          medicineClass(this.facilityCd),
          equipmentClass(this.facilityCd),
          ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd),
          ApiHelper.get("/mente-main/machines-inspection"),
          examSetClass(this.facilityCd)
        ]);
        // add #12107 帳票印刷失敗通知が行われない limingzhe start
        const defaultPrinterResponse = await ApiHelper.get(`/facilitySetting/getFacilitySettingValue/${this.facilityCd}/1018`);
        const defaultPrinterInfo = defaultPrinterResponse.data;
        if (defaultPrinterInfo && defaultPrinterInfo != "-1") {
          this.defaultPrinter = defaultPrinterInfo;
        } else {
          this.defaultPrinter = this.getMstPrinters[0]?.printerCd;
        }
        // add #12107 帳票印刷失敗通知が行われない limingzhe end
        // mod #11603 検査予定のラベル出力とフィルタ機能 高 end
        // mod #699,700,751 陳 end
        this.setLoadingScreenVisible(false);
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        /*let items = [{id: 10000,
          text: "未分類"}];*/
        let items = [{id: -1,
          text: "未分類"}];
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        for (const item of this.mstMedicine) {
          items.push({
            id: item.classCd,
            text: item.className
          });
        }
        this.MEDICINE.childrens = items;
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        /*let items2 = [{id: 10000,
          text: "未分類"}];*/
        let items2 = [{id: -1,
          text: "未分類"}];
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        //ダイアライザの表示
        items2.push({
          id: 0,
          text: 'ダイアライザ'
        });

        for (const item2 of this.mstEquipment) {
          items2.push({
            id: item2.classCd,
            text: item2.className
          });
        }
        this.EQUIPMENT.childrens = items2;
        // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // let items3 = [];
        // items3.push({
        //   id: "-3",
        //   reportClass: 1,
        //   name: "治療経過表",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // items3.push({
        //   id: "-2",
        //   reportClass: 1,
        //   name: "治療経過表（手書き）",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // items3.push({
        //   id: "-4",
        //   reportClass: 7,
        //   name: "日常点検記録簿",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // items3.push({
        //   id: "-5",
        //   reportClass: 7,
        //   name: "定期点検（記録簿・交換部品記録簿）",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // // mod #699,700,751 陳 start
        // for (const item3 of mstReport.data) {
        //   //   items3.push({
        //   //   id: item3.reportCd,
        //   //   reportClass: item3.reportClass,
        //   //   name: item3.reportName,
        //   //   reportType: item3.reportType,
        //   //   defaultPrinter: item3.defaultPrinter,
        //   //   extractionCondition: item3.extractionCondition,
        //   //   additionalInfo: item3.additionalInfo
        //   // });
        //   if (item3.reportClass !== 7) {
        //     if (!(item3.reportClass == 1 && item3.reportName.substr(0, 2) !== "＊＊")) {
        //       // 治療経過表 ( reportClass = 1 ) は、名称の先頭に「＊＊」がついているもののみ表示する
        //       items3.push({
        //         id: item3.reportCd,
        //         reportClass: item3.reportClass,
        //         name: item3.reportName,
        //         reportType: item3.reportType,
        //         defaultPrinter: item3.defaultPrinter,
        //         extractionCondition: item3.extractionCondition,
        //         additionalInfo: item3.additionalInfo
        //       });
        //       // add Aspose.cells関連問題8の対応 夏 start
        //       if(item3.reportClass === 11 && item3.reportType === 3){
        //         this.multiTotalID = item3.reportCd;
        //       }
        //       // add Aspose.cells関連問題8の対応 夏 end
        //     }
        //   } else {
        //     // 装置帳票 ( reportClass = 7 ) の場合、名称の先頭に「＊＊」ついている、又は reportType = 1 (マルチ)のもののみ表示する
        //     if (item3.reportName.substr(0, 2) == "＊＊" || item3.reportType !== 0) {
        //       items3.push({
        //         id: item3.reportCd,
        //         reportClass: item3.reportClass,
        //         name: item3.reportName,
        //         reportType: item3.reportType,
        //         defaultPrinter: item3.defaultPrinter,
        //         extractionCondition: item3.extractionCondition,
        //         additionalInfo: item3.additionalInfo
        //       });
        //     }
        //   }
        // }
        // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        let items4 = [];
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        for (const item of this.mstExamSet) {
          items4.push({
            id: item.examSetCd,
            text: item.examSetName
          });
        }
        this.EXAMSET.childrens = items4;
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end

        // mod #699,700,751 陳 end
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // this.mstReport = items3;
        this.mstReport = this.getMstReportInfo(mstReport);
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        this.processPatientData();
        // add #699,700,751 陳 start
        this.searchedMacList = machinesRes.data;
        this.processMachineData();
        // add #699,700,751 陳 end

        this.MEDICINE.childrens.forEach(med => {
          this.MEDICINE.checkedList.push(med.id.toString());
        });

        this.EQUIPMENT.childrens.forEach(eqi => {
          this.EQUIPMENT.checkedList.push(eqi.id.toString());
        });

        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        this.EXAMSET.childrens.forEach(exs => {
          this.EXAMSET.checkedList.push(exs.id.toString());
        });
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
        // this.setSelectedPatientsList();
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
        //add この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
        this.initializeSelectAll();
        this.initializeSelectAllMachinesList();
        //add この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end

        // add #699,700,751 陳 start
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
        // this.setSelectedMachinesList();
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
        // add #699,700,751 陳 end
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
        // スクロールが最後尾に達した時に追加読み込みを行う
        //del 4870 プレビュー画面で画面最下部に到達すると読み込みが生じる 吉 start
          $$(() => {
           this.scopedJQuery()("#scrollArea").on("scroll", () => {
             //add 8507 2023-4-4 zhaoqj  ローラデータローディング start
             const inputData = this.processData();
             if (inputData) {
               if(this.processData().reportClass !==1){
                 return;
               }
             }
             //add 8507 2023-4-4 zhaoqj  ローラデータローディング end
             // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
            this.isRefresh();
            // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
            // del #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
            // const scrollAreaHeight = $$("#scrollArea").innerHeight();
            // const scrollHeight = $$("#scrollArea").get(0).scrollHeight;
            // const bottom = Math.floor(scrollHeight - scrollAreaHeight);
            // if (this.isRedrawing !== true) {
            //   const scrollTop = Math.ceil($$("#scrollArea").scrollTop());
            //   if (bottom <= scrollTop && bottom > 0) {
            //     if(this.reportOption != 0){
            //        if( this.maxCount < this.selectedPatients.length){
            //          //this.modalVisible = false;
            //          this.updateHtml();
            //          this.maxCount += 2;
            //        }
            //     }else{
            //       this.reportOption = 1;
            //       this.isRedrawing = false;
            //     }
            //   }else{
            //     this.reportOption = 1;
            //     this.isRedrawing = false;
            //   }
            // }
            // del #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
           });
         });

        //del 4870 プレビュー画面で画面最下部に到達すると読み込みが生じる 吉 start
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
        getErrorMessage('ReportMenuListComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
        console.log(error);
        this.setLoadingScreenVisible(false);
      }

      // 帳票未指定時のデフォルト帳票 (施設設定No117) を取得
      try {
        const defaultReportResponse = await ApiHelper.get(`/facilitySetting/getFacilitySettingValue/${this.facilityCd}/3004`);
        this.defaultReportID = defaultReportResponse.data
      } catch (error) {
        console.log(error);
      }

      this.scrwidth.width= (getScopedDocument(this.$el || null)?.body?.offsetWidth || 0)+"px";
      //add  精算時間は治療日と同期している  吉 start
      this.syntime();
      //add  精算時間は治療日と同期している  吉 end
      // 画面標示時に帳票リストの一番上を選択する
      if (this.filteredData.length > 0) {
        // mod #11293 水質検査帳票の課題対応 limingzhe start
        //this.selectRow(this.filteredData[0].id, this.filteredData[0].reportClass, undefined, true);
        this.selectRow(this.filteredData[0].id, this.filteredData[0].reportClass, this.filteredData[0].reportType, undefined, true);
        // mod #11293 水質検査帳票の課題対応 limingzhe end
      }
    },

    // add FNSI-改修内容 画面ボタンの位置調整 穆 start
    beforeUnmount() {
      EventBus.$off("exportMsg", this.onExportMsg);
      // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
      // EventBus.$off("refresh");
      EventBus.$off("refresh", this.refresh);
      // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
      EventBus.$off("msg", this.onMsg);
      EventBus.$off("previewFileMsg", this.previewFile);
      EventBus.$off("printFileMsg", this.printFile);
      EventBus.$off("printMsg", this.onPrintMsg);
      EventBus.$off("printerSelectMsg", this.onPrinterSelectMsg);
      this.hideItemPopover();
      const ownerWindow = getScopedWindow(this.$el || null);
      ownerWindow?.removeEventListener('mousewheel', this.handleScroll);
      if (this.revokeURL) {
        ownerWindow?.removeEventListener("focus", this.revokeURL);
      }
      // dataの初期化
      Object.assign(this.$data, this.$options.data());
    },

    // Fab内のボタンのポップオーバー非表示
  //  del FNSI-改修内容4217bug修正 関 start
    // hideItemPopover() {
    //   this.popoverExportTarget = null;
    //   this.popoverExportVisible = false;
    //   this.popoverPrintLableReport = null;
    //   this.popoverPrintLableVisible = false;
    //   this.popoverTarget = null;
    //   this.popoverVisible = false;
    // },
  //  del FNSI-改修内容4217bug修正 関 end
    // add FNSI-改修内容 画面ボタンの位置調整 穆 end
    computed: {
      //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
      ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
      // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
      ...mapGetters("user", { facilityCd: "getFacilityCd" }),
      ...mapGetters("pat-info", ["searchedPatList"]),
      ...mapGetters("report-menu", { treatDate: "getTreatDate"}),
      ...mapGetters("report", ["getMstPrinters"]),
      // add 9283 印刷順が保存されない帳票がある　吉 start
      ...mapGetters("report-menu", ["getSortTempDay","getSortTempReg"]),
      // add 9283 印刷順が保存されない帳票がある　吉 end
      // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
      selectedObjectType() {
        var selectedType = 1; // 1:対象患者 2:対象装置
        if(this.selectedReportClassID === 7){
          selectedType = 2;
        }
        else if(this.multiTotalID === this.selectedReportID){
          selectedType = 2;
        }
        else if(this.selectedReportClassID === 11)
        {
          if(this.selectedReportTypeId === 3){
            selectedType = 2;
          }
          else if(this.selectedReportTypeId === 4){
            selectedType = 2;
          }
          // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
          else if(this.selectedReportTypeId === 5){
            selectedType = 2;
          }
          // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
        }
        return selectedType;
      },
      // add #11973 日常点検一覧帳票が正常に出せない limingzhe end
      filteredData() {
        if (!this.reportTypeID) {
          return this.mstReport;
        }
        return this.mstReport.filter(
          ({ reportClass }) => this.reportTypeID == reportClass
        );
      },
      sortedPatList() {
        const list = this.patList.slice(); // ソートでstate自体の順序を書き換えないため

        // デフォルトソート
        // - 第一ソートキー：ベッドマスタ表示順 昇順
        // - 第二ソートキー：クールマスタ時系列順 昇順
        list.sort((a, b) => {
          if (a.bed_order_index !== b.bed_order_index) {
            return sortableCompare(a, b, "bed_order_index", true);
          }
          if (a.kur_start_time !== b.kur_start_time) {
            return sortableCompare(a, b, "kur_start_time", true);
          }
          return 0;
        });

        // ソートキー指定ありの場合はそれを優先
        if (this.currentSort.key) {
          list.sort((a, b) => {
            return sortableCompare(a, b, this.currentSort.key, this.currentSort.isAsc);
          });
        }
        return list;
      },
      // 基準日: 治療日、且つ、単患者、複数患者帳票は対象外フィルタチェックボックスを非表示のため患者検索で抽出した患者、それ以外は対象外フィルタ後の患者が患者リスト表示対象
      dispPatList() {
        return this.realyDate;
      },
      selectPatientAll: {
        get() {
          const allSelected = this.dispPatList && this.dispPatList.length > 0 ? this.selectedPatients.length == this.dispPatList.length : false;
          // 初期化フラグONの場合はtrue
          return this.initflag ? true : allSelected;
        },
        set(value) {
          let selected = [];
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          let selectedkul = [];
          let selectedbed = [];
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
          if (value) {
            this.patList.forEach(pat => {
              this.realyDate.forEach(rea =>{
                if(rea === pat.pat_id.toString()){
                  selected.push(pat.pat_id.toString());
                  //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
                  if(null != pat.kur_name){
                    selectedkul.push(pat.kur_name.toString());
                  }else{
                    selectedkul.push("");
                  }
                  if(null != pat.bed_name){
                    selectedbed.push(pat.bed_name.toString())
                  }else{
                    selectedbed.push("")
                  }
                }
              })
            });
          }
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          this.kulList = selectedkul;
          this.bedList = selectedbed;
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
          this.selectedPatients = selected;
          // add FNSI-改修内容 画面ボタンの位置調整 穆 start
          let param = {paramSelected: this.selectedPatients, paramReportClassID: this.selectedReportClassID};
          EventBus.$emit("selectedPatients", param);
          // add FNSI-改修内容 画面ボタンの位置調整 穆 end
        }
      },
      // add #699,700,751 陳 start
      sortedMacList() {
        const list = this.macList.slice(); // ソートでstate自体の順序を書き換えないため

        // デフォルトソート
        // - 第一ソートキー：装置型式マスタ.機種(mst_machine_type.model)　昇順
        // - 第二ソートキー：ベッドマスタ表示順　昇順　空後方
        list.sort((a, b) => {
          if (a.model !== b.model) {
            return sortableCompare(a, b, "model", true);
          }
          if (a.bedOrderIndex !== b.bedOrderIndex) {
            return sortableCompare(a, b, "bedOrderIndex", true);
          }
          return 0;
        });

        if (this.currentSortM.key) {
          list.sort((a, b) => {
            return sortableCompare(a, b, this.currentSortM.key, this.currentSortM.isAsc);
          });
        }
        return list;
      },
      selectMachineAll: {
        get() {
          return this.searchedMacList && this.searchedMacList.length > 0
            ? this.selectedMachines.length == this.searchedMacList.length
            : false;
        },
        set(value) {
          let selected = [];
          if (value) {
            this.searchedMacList.forEach(mac => {
              selected.push(mac.machineNo.toString());
            });
          }

          this.selectedMachines = selected;
          // mod #11293 水質検査帳票の課題対応 limingzhe start
          //let param = {paramSelected: this.selectedMachines, paramReportClassID: this.selectedReportClassID};
          let param = {paramSelected: this.selectedMachines, paramReportClassID: this.selectedReportClassID, selectedReportTypeId: this.selectedReportTypeId};
          // mod #11293 水質検査帳票の課題対応 limingzhe end
          EventBus.$emit("selectedMachines", param);
        }
      },
      // add #699,700,751 陳 end
      selectEquipmentAll: {
        get() {
          return this.EQUIPMENT.childrens && this.EQUIPMENT.childrens.length > 0
            ? this.EQUIPMENT.checkedList.length == this.EQUIPMENT.childrens.length
            : false;
        },
        set(value) {
          let selected = [];
          if (value) {
            this.EQUIPMENT.childrens.forEach(eqi => {
              selected.push(eqi.id.toString());
            });
          }

          this.EQUIPMENT.checkedList = selected;
        }
      },
      selectMedicineAll: {
        get() {
          return this.MEDICINE.childrens && this.MEDICINE.childrens.length > 0
            ? this.MEDICINE.checkedList.length == this.MEDICINE.childrens.length
            : false;
        },
        set(value) {
          let selected = [];
          if (value) {
            this.MEDICINE.childrens.forEach(med => {
              selected.push(med.id.toString());
            });
          }

          this.MEDICINE.checkedList = selected;
        }
      },
      // add #11603 検査予定のラベル出力とフィルタ機能 高 start
      selectExamSetAll: {
        get() {
          return this.EXAMSET.childrens && this.EXAMSET.childrens.length > 0
            ? this.EXAMSET.checkedList.length == this.EXAMSET.childrens.length
            : false;
        },
        set(value) {
          let selected = [];
          if (value) {
            this.EXAMSET.childrens.forEach(med => {
              selected.push(med.id.toString());
            });
          }

          this.EXAMSET.checkedList = selected;
        }
      },
      // add #11603 検査予定のラベル出力とフィルタ機能 高 end
      //add 5981 薬剤の下に検査の区分を作成し、〇採血管（〇はチェックボックス）を追加する。 吉 start
      selectCheckAll: {
        get() {
          return this.CHECKLIST.childrens && this.CHECKLIST.childrens.length > 0
            ? this.CHECKLIST.checkedList.length == this.CHECKLIST.childrens.length
            : false;
        },
        set(value) {
          let selected = [];
          if (value) {
            this.CHECKLIST.childrens.forEach(med => {
              selected.push(med.id.toString());
            });
          }

          this.CHECKLIST.checkedList = selected;
        }
      },
      //add 5981 薬剤の下に検査の区分を作成し、〇採血管（〇はチェックボックス）を追加する。 吉 start
      /**
       * プリンターが登録されているか.
       *
       * @returns true : プリンタが登録されている場合
       *          false : プリンタが登録されていない場合
       */
      hasPrinter() {
        return this.getMstPrinters.length > 0;
      },
      /** 帳票生成処理で治療日指定のルートとするか否か */
      rootDialysisDate() {
        // 紹介日、すべては治療日指定と同じルートを通す
        return (this.dataCondition.dateKind === "letter_issue_date" || this.dataCondition.dateKind === "all_date")
        ? "true"
        : this.dataCondition.isDialysisDate;
      }
    },
    watch: {
      searchedPatList() {
        // 中央の患者リストの再作成処理
        this.processPatientData();
        // 全患者選択状態にする
        this.initializeSelectAll();
        // 現在の帳票種別選択状態を維持する
        // mod #11293 水質検査帳票の課題対応 limingzhe start
        //this.selectRow(this.selectedReportID, this.selectedReportClassID);
        this.selectRow(this.selectedReportID, this.selectedReportClassID, this.selectedReportTypeId);
        // mod #11293 水質検査帳票の課題対応 limingzhe end
      },
      'getStorSimlpSearchQurey.treatDate': {
        handler: function() {
          this.syntime();
        }
      },
      // add #699,700,751 陳 start
      searchedMacList() {
        this.processMachineData();
        //mod この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
        // this.setSelectedMachinesList();
        this.initializeSelectAllMachinesList();
        //mod この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
      },
      // add #699,700,751 陳 end
      /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
      'dataCondition.fromDate': {
        handler: function(newValue) {
          if (!newValue) {
            return;
          }
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      'dataCondition.toDate': {
        handler: function(newValue) {
          if (!newValue) {
            return;
          }
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      'dataCondition.specifyDate': {
        handler: function(newValue) {
          if (!newValue) {
            return;
          }
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
      popoverPrintLableVisible(){
        if(!this.popoverPrintLableVisible){
          this.onClick(this.saveLine,this.saveRow-1);
        }
      },
      // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
      // 'dataCondition.isDialysisDate': {
      //   handler: function() {
      //     this.showAllOrSomeWithoutFlagChange();
      //     if(this.dataCondition.isDialysisDate == 'true' && this.dataCondition.timeType == "inspection_date"){
      //       this.dataCondition.timeType="specify_date";
      //     }
      //   },
      // },
      'dataCondition.dateKind': {
        handler: function() {
          this.showAllOrSomeWithoutFlagChange();
          if(this.dataCondition.dateKind != 'exam_date' && this.dataCondition.timeType == "inspection_date"){
            this.dataCondition.timeType="specify_date";
          }
          this.dataCondition.isDialysisDate = this.dataCondition.dateKind === 'dialysis_date' ? 'true' : 'false';
        },
      },
      // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
      'dataCondition.prescriptionClass': {
        handler: function() {
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
      // 紹介区分
      'dataCondition.letterCategory': {
        handler: function() {
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      'dataCondition.timeType': {
        handler: function() {
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      'dataCondition.key': {
        handler: function() {
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      'dataCondition.numDay': {
        handler: function() {
          this.showAllOrSomeWithoutFlagChange();
        },
      },
      /**
       * 帳票選択が変更された場合
       */
      selectedReportID() {
        // 初期化フラグをON
        this.initflag = true;
        // 患者毎のチェックボックスON/OFF状態をクリア
        this.savedSelectedPatients = {};
      },
      /**
       * 患者選択のON/OFFが変更された場合
       */
      selectedPatients() {
        // 患者毎のチェックボックスON/OFF状態の更新
        this.updateSavedSelectedPatients();
        // 現在の全体チェックボックスのON/OFF状態を保持
        this.allSelectedMode = this.selectPatientAll;
      },
      // add #11151 帳票画面「プレビュー」のページ送りが機能しないことがある 吉 start
      modalVisible(newVal) {
        if (newVal) {
          // on status is open
          const ownerWindow = getScopedWindow(this.$el || null);
          ownerWindow?.addEventListener('mousewheel', this.handleScroll);
          ownerWindow?.addEventListener('DOMMouseScroll', this.handleScroll); // Firefox
        } else {
          // off status is close
          const ownerWindow = getScopedWindow(this.$el || null);
          ownerWindow?.removeEventListener('mousewheel', this.handleScroll);
          ownerWindow?.removeEventListener('DOMMouseScroll', this.handleScroll);
        }
      }
      // add #11151 帳票画面「プレビュー」のページ送りが機能しないことがある 吉 end
    },
    methods: {
      scopedJQuery() {
        return createScopedJQuery(this.$el || this, $$) || $$;
      },
    getScopedElementById(id) {
      return getScopedElementById(id, this);
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this);
    },
    getScopedQuery(selector) {
      return queryScopedSelector(selector, this);
    },
    getScopedQueryAll(selector) {
      return queryScopedSelectorAll(selector, this);
    },
      onExportMsg(param) {
        this.showExportPopover(param.paramEvent, param.paramDirection, param.paramCoverTarget);
      },
      onPrintMsg(param) {
        this.generateValueTable(param.paramEvent, param.paramDirection, param.paramCoverTarget);
      },
      async onMsg(param) {
        setTimeout(() => {
          this.showPopover(param.paramEvent, param.paramDirection, param.paramCoverTarget);
        }, 0);
      },
      onPrinterSelectMsg(param) {
        this.showPrintPopover(param.paramEvent, param.paramDirection, param.paramCoverTarget);
      },

      ...mapActions("loading-screen", [
        "setLoadingScreenMessage",
        "setLoadingScreenVisible"
      ]),
      /**
       * 検査区分項目のenable/disableを制御する
       */
      setRegOrderClassActive() {
        const isDialysisDate = this.dataCondition.isDialysisDate;
        const reportClass = this.selectedReportClassID;

        /**
         * 帳票種別がない場合disabled
         */
        if (!reportClass) {
          this.isRegOrderClassActive = false;
          return;
        }

        /**
         * 帳票種別:複数集計
         * 帳票区分:水質調査一覧
         * 時にdisabled
         */
        // mod #11293 水質検査帳票の課題対応 limingzhe start
        //if (this.multiTotalID === this.selectedReportID) {
        // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
        //if (this.multiTotalID === this.selectedReportID || (this.selectedReportClassID === 11 && this.selectedReportTypeId === 3)) {
        if (this.multiTotalID === this.selectedReportID || (this.selectedReportClassID === 11 && (
          this.selectedReportTypeId === 3 || this.selectedReportTypeId === 4
          // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
          || this.selectedReportTypeId === 5
          // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
          ))) {
        // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
        // mod #11293 水質検査帳票の課題対応 limingzhe end
          this.isRegOrderClassActive = false;
          return;
        }

        /**
         * 帳票種別が以下の場合にdisabled
         * ・紹介状
         * ・準備リスト
         * ・配布リスト（ベッド）
         * ・配布リスト（物品）
         * ・装置帳票
         */
        const DISABLED_REPORT_CLASS1 = [4, 5, 6, 7, 9];
        if (DISABLED_REPORT_CLASS1.includes(reportClass)) {
          this.isRegOrderClassActive = false;
          return;
        }
        /**
         * 帳票種別が以下かつ、基準日:検査日 未選択の場合にdisabled
         * ・治療経過表
         * ・単患者帳票
         * ・複数患者帳票
         * ・ラベル
         * ・単集計
         * ・複数集計
         */
        const DISABLED_REPORT_CLASS2 = [1, 2, 3, 8, 10, 11];
        // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
        //if (DISABLED_REPORT_CLASS2.includes(reportClass) && (isDialysisDate === "true")) {
        if (DISABLED_REPORT_CLASS2.includes(reportClass) && (this.dataCondition.dateKind != 'exam_date')) {
        // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
          this.isRegOrderClassActive = false;
          return;
        }

        this.isRegOrderClassActive = true;
        return;
      },
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
      setChkViewPreActive() {
        this.isChkViewPreActive = this.selectedReportClassID !== 7 && this.dataCondition.dateKind === "issue_date";
      },
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
      /** 紹介区分 活性/非活性制御 */
      setChkViewLetterActive() {
        this.isChkViewLetterActive = this.selectedReportClassID !== 7 && this.dataCondition.dateKind === "letter_issue_date";
      },
      /**
       * 検査区分の状態に応じて、処理を中断する
       */
      isRegOrderClassAlert() {
        if (this.isRegOrderClassActive) {
          // 一つでもチェックされていた場合はメッセージを表示しない
          if (
            this.getScopedElementById("before_dialysis").checked ||
            this.getScopedElementById("after_dialysis").checked ||
            this.getScopedElementById("other").checked) {
            return false;
          }

          // 一つもチェックされていない場合はメッセージ表示、処理を中断
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES[70000036].title,
            message: DIALOG_MESSAGES[70000036].message,
          });
          return true;
        }
        return false;
      },
      // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
      isRefresh(){
        const scrollAreaHeight = this.scopedJQuery()("#scrollArea").innerHeight();
        const scrollHeight = this.scopedJQuery()("#scrollArea").get(0).scrollHeight;
        const bottom = Math.floor(scrollHeight - scrollAreaHeight);
        if (this.isRedrawing !== true && this.scrollControl) {
          const scrollTop = Math.ceil(this.scopedJQuery()("#scrollArea").scrollTop());
          if (bottom <= scrollTop && bottom > 0) {
            if(this.reportOption != 0){
              if( this.maxCount < this.selectedPatients.length){
                this.scrollControl = false;
                this.updateHtml();
                this.maxCount += 2;
              }
            }else{
              this.reportOption = 1;
              this.isRedrawing = false;
            }
          }else{
            this.reportOption = 1;
            this.isRedrawing = false;
          }
        }
      },
      // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
      // mod 9283 印刷順が保存されない帳票がある　吉 start
      // ...mapMutations("report-menu", ["setSortTemp"]),
      ...mapMutations("report-menu", ["setSortTempDay","setSortTempReg"]),
      // mod 9283 印刷順が保存されない帳票がある　吉 end
      //  add FNSI-改修内容4217bug修正 関 start
      hideItemPopover() {
      this.popoverExportTarget = null;
      this.popoverExportVisible = false;
      this.popoverPrintLableReport = null;
      this.popoverPrintLableVisible = false;
      this.popoverTarget = null;
      this.popoverVisible = false;
      this.popoverPrintTarget = null;
      this.popoverPrintVisible = false;
    },
  //  add FNSI-改修内容4217bug修正 関 end
      generateValueTable(event, direction, coverTarget = false) {
        this.tabVale = [];
        let rowTable = [];
        this.mstReport.forEach(addtional => {
          if (addtional.id === this.selectedReportID && addtional.additionalInfo) {
            this.printDirect = addtional.additionalInfo.print_direct;
            for (
              let colCount = 0;
              colCount < addtional.additionalInfo.col_count;
              colCount++
            ) {
              for (
                let rowCount = 0;
                rowCount < addtional.additionalInfo.row_count;
                rowCount++
              ) {
                rowTable.push(rowCount + 1);
              }
              this.tabVale.push(rowTable);
              rowTable = [];
            }
          }
        });
        // add Aspose.cells関連問題4の対応 姜 start
        if (this.tabVale.length < this.rowVerticalPrintLable || this.tabVale[0].length < this.colHorizontalPrintLable) {
          this.onClick(1, 0);
        }
        // add Aspose.cells関連問題4の対応 姜 end
        this.coverTarget = coverTarget;
        this.popoverPrintLableReport = event.target;
        this.popoverExportDirection = direction;
        this.popoverPrintLableVisible = true;
      },
      onClick(index, ind) {
        this.index = ind;
        this.colHorizontalPrintLable = index;
        this.rowVerticalPrintLable = ind + 1;
        this.horizontalSelected = index;
        this.verticalSelected = ind + 1;
        // this.stPos = this.getLocationReport(
        //   this.colHorizontalPrintLable,
        //   this.rowVerticalPrintLable,
        //   this.printDirect
        // );
      },
      getLocationReport(colCount, rowCount, printDirect) {
        let position = 0;
        switch (printDirect) {
          /*mod FNSI-改修内容5740 任 start*/
          /*case 1:
            position =
              this.tabVale[0].length * colCount -
              (this.tabVale[0].length - rowCount);
            break;
          case 0:
            position =
              this.tabVale.length * rowCount - (this.tabVale.length - colCount);
            break;*/
          case 1:
            position =
              this.tabVale.length * (colCount - 1) + rowCount
            break;
          case 0:
            position =
              this.tabVale[0].length * (rowCount - 1) + colCount;
            break;
          /*mod FNSI-改修内容5740 任 end*/
          default:
            break;
        }
        return position;
      },
      clickSelected() {
        this.horizontalSelected = this.colHorizontalPrintLable;
        this.verticalSelected = this.rowVerticalPrintLable;
        this.stPos = this.getLocationReport(
          this.colHorizontalPrintLable,
          this.rowVerticalPrintLable,
          this.printDirect
        );
      },
      // 帳票種別のドロップダウン変更
      onChangeType(event) {
        if (this.reportTypeID && !(Number(this.reportTypeID) === Number(this.selectedReportClassID))) {
          // reportTypeID が nullか空欄(帳票種別：全て)、現在選択中の帳票種別と同じ場合は選択を解除しない
          // 現在選択中の帳票種別と異なる場合はリストの一番上の帳票が自動で選択される
          // mod #11293 水質検査帳票の課題対応 limingzhe start
          //this.selectRow(this.filteredData[0].id, this.filteredData[0].reportClass, undefined, true);
          this.selectRow(this.filteredData[0].id, this.filteredData[0].reportClass, this.filteredData[0].reportType, undefined, true);
          // mod #11293 水質検査帳票の課題対応 limingzhe end
        }
      },
      // mod #11293 水質検査帳票の課題対応 limingzhe start
      //async selectRow(id, reportClass, showFlag, getDataConditionFlag) {
      async selectRow(id, reportClass, reportType, showFlag, getDataConditionFlag) {
      // mod #11293 水質検査帳票の課題対応 limingzhe end
        this.selectedReportID = id;
        this.selectedReportClassID = reportClass;
        let changeSpecifyDateFlag = false;
        // add #11293 水質検査帳票の課題対応 limingzhe start
        this.selectedReportTypeId = reportType;
        // add #11293 水質検査帳票の課題対応 limingzhe end
        // 検査区分の項目制御
        this.setRegOrderClassActive();

        // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
        this.setChkViewPreActive();
        // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
        // 紹介区分の活性/非活性制御
        this.setChkViewLetterActive();

        // 期間指定終了の日数を保持
        this.dataCondition.rangeEndNum = dayjs(this.dataCondition.toDate).diff(dayjs(this.dataCondition.fromDate), 'days');
        // データ抽出条件取得処理
        if(null != id && getDataConditionFlag){
          await this.getSortList(id);
        }

        // 1日指定への自動変更: 期間指定の場合
        if (this.dataCondition.timeType == "range_time") {
          if (this.selectedReportClassID && !this.extractCondition[this.selectedReportClassID]['isRangeTime']) {
            changeSpecifyDateFlag = true;
          }
        }
        // 1日指定への自動変更: 検査日数指定の場合
        if (this.dataCondition.timeType == "inspection_date") {
          if (this.selectedReportClassID && !this.extractCondition[this.selectedReportClassID]['isInspectionDate']) {
            changeSpecifyDateFlag = true;
          }
        }
        if (changeSpecifyDateFlag) {
          this.dataCondition.timeType = "specify_date";
          this.setLoadingScreenVisible(false);
          return;
          // 1日指定へ変更した後、watch経由でselectRowメソッドが発火する
        }

        this.hideflag = true;
        // 帳票一覧の選択切替え時に対象外フィルタチェックボックスをONにするため`null == showFlag`の場合はtrueを設定
        this.showAllflag = null == showFlag || showFlag== 1 ? true : false;
        /*add FNSI-改修内容装置帳票の対応 任 end*/
        // add #699,700,751 陳 start
        this.setSelectedMachinesList();
        // add #699,700,751 陳 end
        // add #11293 水質検査帳票の課題対応 limingzhe start
        // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
        // if(reportClass === 11 && reportType === 3){
        if(reportClass === 11 && (
          reportType === 3 || reportType === 4
          // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
          || reportType === 5
          // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
          )){
        // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
          this.multiTotalID = this.selectedReportID;
        }
        // add #11293 水質検査帳票の課題対応 limingzhe end
        /*add FNSI-改修内容装置帳票の対応 任 start*/
        if(reportClass === 7){  // 装置帳票
          //del 5565 並び替えを実施してもその情報が保持されない 吉 start
          // this.sortTemp[0].key = "装置名称";
          // this.sortTemp[0].sort = "asc";
          // this.sortTargets = this.jsonCopy(this.sortTemp);
          //del 5565 並び替えを実施してもその情報が保持されない 吉 end
        }else{
          // 装置帳票以外
          await  this.processPatientData();
          try {
            // 帳票表示対象の患者を検索する
            this.setLoadingScreenVisible(true);

            const inputData = this.setParmFun();
            if (inputData) {
              const response = await ApiHelper.post(
                "/report_menu/getPatIdByCheckBox",
                inputData
              );
              if(response.data.length != 0){
                if(null == showFlag || showFlag== 1){
                  const arr1 = this.patList.filter((item) => {
                    const exists = response.data.some((patId) => patId == item.pat_id.toString());
                    item.flag = exists ? 1 : 0;
                    return exists;
                  });
                  this.$nextTick(() => {
                    this.patList=arr1;
                  });
                }else{
                  this.patList.filter((item) => {
                    const exists = response.data.some((patId) => patId == item.pat_id.toString());
                    item.flag = exists ? 1 : 0; // 予定のみの患者の印刷チェックボックスを無効にしないようにする修正の一次対応
                    return item;
                  });
                }
              }else{
                if(null == showFlag || showFlag== 1){
                  this.patList=response.data;
                }
              }
              // チェックボックスの選択状態を復元
              this.restoreSelectedPatients(response.data);
              this.realyDate=deepCopy(response.data);
            } else {
              // setParmFun()の内容がない場合、リストをクリアする
              this.patList=[];
              this.realyDate=[];
              this.selectedPatients = [];
              this.hideflag=false;
            }
          } catch (error) {
            this.showErrorMessage("システムエラーが発生しました。");
          }
        }
        this.setSelectedPatientsList();
        this.setLoadingScreenVisible(false);
      },
      // データ抽出条件取得処理
      async getSortList(id) {
        let shouldFetchFromApi = true;
        let sortListFromStore = null;
        /* 保存対象外の帳票かチェック */
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //if (id == "-4") {
        if (id == "-5") {
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          // Storeから取得
          sortListFromStore = this.getSortTempDay;
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //} else if (id == "-5") {
        } else if (id == "-6") {
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          // Storeから取得
          sortListFromStore = this.getSortTempReg;
        }
        // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
        else if (id == "-7") {
          // Storeから取得
          sortListFromStore = this.getSortTempReg;
        }
        // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
        if (sortListFromStore) {
          // Storeから取得できた場合、APIで最新の情報は取得しない
          this.editDataCondition(sortListFromStore);
          shouldFetchFromApi = false;
        }

        if (shouldFetchFromApi) {
          // 初期化
          this.sortTemp = [{"key": null,"sort": "asc"},{"key": null,"sort": "asc"},{"key": null,"sort": "asc"}];
          try {
            let response = await ApiHelper.post("/report_menu/getSortList/"+id);
            // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
            // 処方区分
            if (null != response.data && null != response.data.dataCond && (response.data.dataCond.prescriptionClass == undefined || response.data.dataCond.prescriptionClass == null)) {
              response.data.dataCond.prescriptionClass = ["1", "2"];
            }
            // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
            // 紹介区分
            if (null != response.data && null != response.data.dataCond && (response.data.dataCond.letterCategory == undefined || response.data.dataCond.letterCategory == null)) {
              response.data.dataCond.letterCategory = ["0", "1"];
            }
            // response.data が DEFAULT_CONDITION の全てのキーを持っていれば true、1つでも欠けていれば false を isConData に代入
            const isConData = Object.keys(DEFAULT_CONDITION).every(key => Object.prototype.hasOwnProperty.call(response.data, key));
            this.editDataCondition(isConData ? response.data : DEFAULT_CONDITION);
          } catch (error) {
            getErrorMessage('ReportMenuListComponent.vue', 'getSortList', error);
            console.log(error);
          }
        }
      },
      // データ抽出条件を画面用に設定する処理
      editDataCondition(data) {
        this.isApplyingDataCondition = true;
        /* 並び替え情報設定 */
        if (data.sortList != null) {
          this.sortTemp = data.sortList.map(item => ({
            key: item.key,
            sort: item.sort === 0 ? "asc" : "desc"
          }));
          this.sortTargets = this.jsonCopy(this.sortTemp);
        }
        /* データ抽出条件設定 */
        if (data.dataCond != null) {
          const dataCond = data.dataCond;
          // 0: 期間指定、1: 1日指定、2: 検査日数指定
          this.dataCondition.timeType = dataCond.periodType === 0 ? 'range_time' : dataCond.periodType === 1 ? 'specify_date' : 'inspection_date';
          this.dataCondition.key = dataCond.inspectionDate === 0 ? "before" : "after";
          this.dataCondition.numDay = dataCond.numDay;
          this.dataCondition.regOrderClass = dataCond.regOrderClass;
          this.dataCondition.isDialysisDate = dataCond.dateType === 0 ? 'true' : 'false';
          // add #11226 患者情報系historyの取得条件見直し② limingzhe start
          this.dataCondition.dateKind = this.dateType[dataCond.dateType].text;
          // add #11226 患者情報系historyの取得条件見直し② limingzhe end
          this.dataCondition.rangeEndNum = dataCond.rangeEndNum;
          // 日付項目は患者検索の治療日を適用
          this.syntime();
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
          this.dataCondition.prescriptionClass = dataCond.prescriptionClass;
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
          this.dataCondition.letterCategory = dataCond.letterCategory;
        }
        /* 医療材料設定 */
        if (data.equipment != null) {
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
          const allIds = this.EQUIPMENT.childrens.map(eqi => eqi.id.toString());
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          if (data.equipment.checkedList.length === 1 && data.equipment.checkedList[0] === "all") {
            this.EQUIPMENT.checkedList = this.EQUIPMENT.childrens.map(eqi => eqi.id.toString());
          } else {
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            // this.EQUIPMENT.checkedList = data.equipment.checkedList;
            this.EQUIPMENT.checkedList = data.equipment.checkedList.filter(id =>
              allIds.includes(id.toString())
            );
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          }
        }
        /* 薬剤設定 */
        if (data.medicine != null) {
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
          const allIds = this.MEDICINE.childrens.map(eqi => eqi.id.toString());
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          if (data.medicine.checkedList.length === 1 && data.medicine.checkedList[0] === "all") {
            this.MEDICINE.checkedList = this.MEDICINE.childrens.map(eqi => eqi.id.toString());
          } else {
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            // this.MEDICINE.checkedList = data.medicine.checkedList;
            this.MEDICINE.checkedList = data.medicine.checkedList.filter(id =>
              allIds.includes(id.toString())
            );
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          }
        }
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        /* 検査セット */
        if (data.examSet != null) {
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
          const allIds = this.EXAMSET.childrens.map(eqi => eqi.id.toString());
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          if (data.examSet.checkedList.length === 1 && data.examSet.checkedList[0] === "all") {
            this.EXAMSET.checkedList = this.EXAMSET.childrens.map(eqi => eqi.id.toString());
          } else {
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            // this.EXAMSET.checkedList = data.examSet.checkedList;
            this.EXAMSET.checkedList = data.examSet.checkedList.filter(id =>
              allIds.includes(id.toString())
            );
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          }
        }
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        /* 検査設定 */
        this.inspectCheckBox = data.inspect == 1;
        this.$nextTick(() => {
          this.isApplyingDataCondition = false;
        });
      },
      async showAllOrSome(){
        if(this.showAllflag){
          // mod #11293 水質検査帳票の課題対応 limingzhe start
          //await this.selectRow(this.selectedReportID,this.selectedReportClassID,0)
          await this.selectRow(this.selectedReportID,this.selectedReportClassID,this.selectedReportTypeId,0)
          // mod #11293 水質検査帳票の課題対応 limingzhe end
          this.showAllflag=false;
        }else{
          // mod #11293 水質検査帳票の課題対応 limingzhe start
          //await this.selectRow(this.selectedReportID,this.selectedReportClassID,1)
          await this.selectRow(this.selectedReportID,this.selectedReportClassID,this.selectedReportTypeId,1)
          // mod #11293 水質検査帳票の課題対応 limingzhe end
          this.showAllflag=true;
        }
      },
      // showAllOrSome()のthis.showAllflagを変更しないバージョン
      showAllOrSomeWithoutFlagChange(){
        if (this.isApplyingDataCondition) {
          return;
        }
        if(this.showAllflag){
          // mod #11293 水質検査帳票の課題対応 limingzhe start
          //this.selectRow(this.selectedReportID,this.selectedReportClassID,1)
          this.selectRow(this.selectedReportID,this.selectedReportClassID,this.selectedReportTypeId,1)
          // mod #11293 水質検査帳票の課題対応 limingzhe end
        }else{
          // mod #11293 水質検査帳票の課題対応 limingzhe start
          //this.selectRow(this.selectedReportID,this.selectedReportClassID,0)
          this.selectRow(this.selectedReportID,this.selectedReportClassID,this.selectedReportTypeId,0)
          // mod #11293 水質検査帳票の課題対応 limingzhe end
        }
      },
      // 患者毎のチェックボックスON/OFF状態から選択状態を復元
      restoreSelectedPatients(selected) {
        if (this.initflag) {
          // 画面初期表示時、帳票変更時は全選択
          this.selectedPatients = selected;
        } else {
          // 初期状態（＝患者の状態記憶がない）は全選択
          if (Object.keys(this.savedSelectedPatients).length === 0) {
            this.selectedPatients = selected;
          } else {
            this.selectedPatients = selected.filter(patId => {
              // 対象患者一覧に一度登場した患者のチェックON/OFF状態を返す
              if (Object.prototype.hasOwnProperty.call(this.savedSelectedPatients, patId)) {
                return this.savedSelectedPatients[patId];
              }
              // 対象患者一覧に初めて登場した患者のチェックON/OFFは現在の全体チェックボックスのON/OFF状態を返す
              // ※ここに到達する前にselectPatientAllは条件変更時に再計算されるためallSelectedModeに現在の全体チェックボックスのON/OFF状態を保持している
              return this.allSelectedMode;
            });
          }
        }
        // 初期化フラグOFF
        this.initflag = false;
      },
      // 患者毎のチェックボックスON/OFF状態の更新
      updateSavedSelectedPatients() {
        // 表示している患者リストのpatIdに対してチェックボックスON/OFFをチェックし、患者毎のチェックボックスON/OFF状態を更新
        this.dispPatList.forEach(patId => {
          this.savedSelectedPatients[patId] = this.selectedPatients.includes(patId);
        });
      },
      /** 指定日のデータを持つ患者IDを取得するAPI（/api/report_menu/getPatIdByCheckBox）の payload生成  */
      setParmFun(){
        var fromDate = null;
        var toDate = null;
        var specifyDate = null;
        var medicines = null;
        var equipments = null;
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        var examSets = null;
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        // フィルタリング患者の処理が終了しない限り,ページの遷移を行い,会報システムエラーを行います。林峻峰 start
        if (!this.selectedReportClassID) {
          return;
        }
        // フィルタリング患者の処理が終了しない限り,ページの遷移を行い,会報システムエラーを行います。林峻峰 end
        // add #11226 患者情報系historyの取得条件見直し② limingzhe start
        this.dataCondition.isDialysisDate = this.dataCondition.dateKind === 'dialysis_date' ? 'true' : 'false';
        // add #11226 患者情報系historyの取得条件見直し② limingzhe end
        if (
          // 期間指定
          this.extractCondition[this.selectedReportClassID]["isRangeTime"] &&
          this.dataCondition.timeType == "range_time"
        ) {
          // add 5733 期間指定の昇順・降順入力対応 Gong start
          if (this.dataCondition.fromDate > this.dataCondition.toDate) {
            fromDate = this.dataCondition.toDate;
            toDate = this.dataCondition.fromDate;
          } else {
            // add 5733 期間指定の昇順・降順入力対応 Gong end
            fromDate = this.dataCondition.fromDate;
            toDate = this.dataCondition.toDate;
            // add 5733 期間指定の昇順・降順入力対応 Gong start
          }
          // add 5733 期間指定の昇順・降順入力対応 Gong end
        }

        if (
          // 検査日数指定
          this.extractCondition[this.selectedReportClassID][
            "isInspectionDate"
            ] &&
          this.dataCondition.timeType == "inspection_date"
        ) {
          if (this.dataCondition.inspectionDate) {
            var tmpDate1 = new Date(this.dataCondition.inspectionDate);
            var tmpDate2 = new Date(tmpDate1);
            var key = this.dataCondition.key;
            var numDay = this.dataCondition.numDay;
            if (key == "after") {
              tmpDate2.setDate(tmpDate1.getDate() + parseInt(numDay));
            } else {
              tmpDate2.setDate(tmpDate1.getDate() - parseInt(numDay));
            }
            if (tmpDate1 < tmpDate2) {
              fromDate = tmpDate1;
              toDate = tmpDate2;
            } else {
              fromDate = tmpDate2;
              toDate = tmpDate1;
            }
          }
        }

        if (
          // 1日指定
          this.extractCondition[this.selectedReportClassID]["isSpecifyDate"] &&
          this.dataCondition.timeType == "specify_date"
        ) {
          specifyDate = this.dataCondition.specifyDate;
        }

        if (!specifyDate && (!fromDate || !toDate)) {
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // this.showErrorMessage("治療日をご入力ください。");
          this.showErrorMessage(DIALOG_MESSAGES[12000205].message);
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          return false;
        }
        let parseIntEquipmentList = [...this.EQUIPMENT.checkedList];
        parseIntEquipmentList.forEach((item, index) => {
          parseIntEquipmentList[index] = +item;
        });
        if (this.extractCondition[this.selectedReportClassID]["isEquipment"]) {
          // 医療材料
          equipments = parseIntEquipmentList;
        }
        let parseIntMedicineList = [...this.MEDICINE.checkedList];
        parseIntMedicineList.forEach((item, index) => {
          parseIntMedicineList[index] = +item;
        });
        if (this.extractCondition[this.selectedReportClassID]["isMedicine"]) {
          // 薬剤
          medicines = parseIntMedicineList;
        }
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        // 検査セット
        let parseIntExamSetList = [...this.EXAMSET.checkedList];
        parseIntExamSetList.forEach((item, index) => {
          parseIntExamSetList[index] = +item;
        });
        if (this.extractCondition[this.selectedReportClassID]["isExamSet"]) {
          examSets = parseIntExamSetList;
        }
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
        // 検査
        var inspections = [];
        if (this.extractCondition[this.selectedReportClassID]["isInspection"]) {
          // mod #12551 データ抽出条件「採血管」を隠す sunsy start
          // inspections.push(this.inspectCheckBox ? 1 : 0);
          inspections.push(0); //常に出さないように暫定的の対応
          // mod #12551 データ抽出条件「採血管」を隠す sunsy end
        }else{
          inspections.push(-1);
        }
        // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
        var reportName = this.mstReport.find(x => x.id == this.selectedReportID)
          .name;
        // 表示順
        var sortCond = [];
        for (let index in this.sortTargets) {
          let item = this.sortTargets[index];
          if (
            !item.key ||
            sortCond.find(e => Object.keys(e).indexOf(item.key) > -1)
          ) {
            continue;
          } else {
            sortCond.push({ [item.key]: item.sort });
          }
        }

        let parseIntPatients = []
        this.searchedPatList.forEach(pat => {
          parseIntPatients.push(pat.pat_id.toString());
        });
        parseIntPatients.forEach((item, index) => {
          parseIntPatients[index] = +item;
        });
        const machines = [];
        this.macList.forEach(item => {
          this.selectedMachines.forEach(machine => {
            if(item.machineNo.toString() === machine){
              machines.push(item);
            }
          })
        })

        let ret = {
          fromDate: this.formattedDate(fromDate),
          toDate: this.formattedDate(toDate),
          specifyDate: this.formattedDate(specifyDate),
          medicineCdList: medicines,
          equipmentCdList: equipments,
          patIds: parseIntPatients,
          reportCd: this.selectedReportID,
          reportName: reportName,
          facilityCd: this.facilityCd,
          sortCondition: sortCond.reverse(),
          reportClass: this.selectedReportClassID,
          machines: machines,
          isDialysisDate: this.dataCondition.isDialysisDate,
          // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
          inspectionCdList: inspections,
          // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
          // add #11226 患者情報系historyの取得条件見直し② limingzhe start
          dateKind: this.dataCondition.dateKind,
          // add #11226 患者情報系historyの取得条件見直し② limingzhe end
        };

        // 検査区分がdisabledでない場合はフィールドに追加
        if (this.isRegOrderClassActive) {
          ret.regOrderClassList = this.dataCondition.regOrderClass;
        }

        // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
        if (this.isChkViewPreActive) {
          ret.prescriptionClassList = this.dataCondition.prescriptionClass;
        }
        // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end

        // 紹介区分
        if (this.isChkViewLetterActive) {
          ret.letterCategoryList = this.dataCondition.letterCategory;
        }

        return ret;
      },
      showPopover(event, direction, coverTarget = false) {
        this.popoverTarget = event;
        this.popoverDirection = direction;
        this.coverTarget = coverTarget;
        this.popoverVisible = true;
      },
      showExportPopover(event, direction, coverTarget = false) {
        this.popoverExportTarget = event;
        this.popoverExportDirection = direction;
        this.coverExportTarget = coverTarget;
        this.popoverExportVisible = true;
      },
      async showPrintPopover(event, direction, coverTarget = false) {
        this.popoverPrintTarget = event;
        this.popoverPrintDirection = direction;
        this.coverPrintTarget = coverTarget;
        this.popoverPrintVisible = true;

        this.selectedPrinter = null;
        // del #12107 帳票印刷失敗通知が行われない limingzhe start
        // // ひとまず先頭のプリンターを選択
        // if (this.getMstPrinters.length > 0) {
        //   this.selectedPrinter = this.getMstPrinters[0].printerCd;
        // }
        // del #12107 帳票印刷失敗通知が行われない limingzhe end

        // 印刷する帳票のデフォルトプリンターを選択
        const mstReport = this.mstReport.find(
          e => e.id === this.selectedReportID
        );
        if (mstReport.defaultPrinter !== "" && mstReport.defaultPrinter !== null) {
          this.selectedPrinter = mstReport.defaultPrinter;
        } else {
          // mod #12107 帳票印刷失敗通知が行われない limingzhe start
          // // 帳票未指定時のデフォルト帳票 (施設設定No117) のデフォルトプリンターを選択
          // if (this.defaultReportID !== "" && this.defaultReportID !== null && typeof this.defaultReportID !== "undefined") {
          //   const defaultReport = this.mstReport.find(
          //     e => e.id === this.defaultReportID
          //   );
          //   if (defaultReport && defaultReport.defaultPrinter !== "" && defaultReport.defaultPrinter !== null) {
          //     this.selectedPrinter = defaultReport.defaultPrinter;
          //   }
          // }
          if(this.defaultPrinter !== "" && this.defaultPrinter !== null) {
            this.selectedPrinter = this.defaultPrinter;
          }
          else {
            this.selectedPrinter = null;
          }
          // mod #12107 帳票印刷失敗通知が行われない limingzhe end
        }
      },
      closePopover() {
        this.sortPopoverBtnClick = true;
        this.popoverVisible = false;
        this.sortTemp = this.jsonCopy(this.sortTargets);
      },
      handlePostHide() {
        if (!this.sortPopoverBtnClick) {
          this.closePopover();
        }
        this.sortPopoverBtnClick = false; // フラグリセット
      },
      closePopoverPrintLable(flag) {
        if(flag == 0){
          this.onClick(this.saveLine,this.saveRow-1);
        }else{
          this.saveLine = this.colHorizontalPrintLable;
          this.saveRow = this.rowVerticalPrintLable;
        }
        this.stPos = this.getLocationReport(
          this.colHorizontalPrintLable,
          this.rowVerticalPrintLable,
          this.printDirect
        );
        this.popoverPrintLableVisible = false;
      },
      closeExportPopover() {
        this.popoverExportVisible = false;
      },
      closePrintPopover() {
        this.popoverPrintVisible = false;
      },
      sortArray(f1, f2, attr, key) {
        if (key == "desc") {
          return f2[attr].localeCompare(f1[attr]);
        }
        return f1[attr].localeCompare(f2[attr]);
      },
      jsonCopy(src) {
        return JSON.parse(JSON.stringify(src));
      },
      // 並び替えの確定ボタン押下処理
      async clickSort() {
        // データ抽出条件保存処理
        await this.saveSortList();
        this.isSortListSaveFlag = true;
        this.popoverVisible = false;
      },
      // 条件保存ボタン押下処理
      async saveSortBtnClick() {
        this.setLoadingScreenVisible(true);
        // データ抽出条件保存処理
        await this.saveSortList();
        this.setLoadingScreenVisible(false);
      },
      // データ抽出条件保存処理
      async saveSortList() {
        this.sortTargets = this.jsonCopy(this.sortTemp);
        // 並び替え情報の設定
        const sortList = this.sortTemp.map(item => ({
          key: item.key,
          sort: item.sort === "asc" ? 0 : 1
        }));
        // データ抽出条件の設定
        const dCond = this.dataCondition;
        // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
        // 0 : 透析日、 1 : 検査日、 2 : 処方日
        //const dateType = dCond.isDialysisDate === 'true' ? 0 : 1;
        var indexType = 0;
        this.dateType.forEach(type => {
          if(dCond.dateKind.toString() === type.text){
            indexType = type.value;
          }
        })
        const dateType = indexType;
        // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
        // 0: 期間指定、1: 1日指定、2: 検査日数指定
        const periodType = dCond.timeType === 'range_time' ? 0 : dCond.timeType === 'specify_date' ? 1 : 2;
        // 0: 前、1: 後
        const beforeAfter = dCond.key === 'before' ? 0 : 1;
        const dataCond = {
          dateType,
          periodType,
          rangeEndNum: dayjs(dCond.toDate).diff(dayjs(dCond.fromDate), 'days'), // 期間指定終了の日数
          beforeAfter,
          numDay: dCond.numDay,
          regOrderClass: dCond.regOrderClass,
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
          prescriptionClass: dCond.prescriptionClass,
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
          letterCategory: dCond.letterCategory,
        };
        // チェックリストの設定関数
        const getCheckedList = (item) => {
          const allChecked = item.childrens?.length > 0 && item.checkedList.length === item.childrens.length;
          // すべて選択してある場合、"all"を設定して返却
          return allChecked ? ["all"] : item.checkedList;
        };
        // 医療材料の設定
        const equipmentCheckedList = getCheckedList(this.EQUIPMENT);
        // 薬剤の設定
        const medicineCheckedList = getCheckedList(this.MEDICINE);

        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        const examSetCheckedList = getCheckedList(this.EXAMSET);
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end
        // データ抽出条件を設定
        const requestParams = {
          sortList,
          dataCond,
          equipment: {checkedList: equipmentCheckedList},
          medicine: {checkedList: medicineCheckedList},
          // add #11603 検査予定のラベル出力とフィルタ機能 高 start
          examSet: {checkedList: examSetCheckedList},
          // add #11603 検査予定のラベル出力とフィルタ機能 高 end
          inspect: this.inspectCheckBox ? 1 : 0
        };
        try {
            await ApiHelper.post("/report_menu/saveSortList", {
            facilityCd: this.facilityCd,
            reportCd: this.selectedReportID,
            sortTargets: requestParams
          });
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          //if(this.selectedReportID == "-4"){
          if(this.selectedReportID == "-5"){
            // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
            this.setSortTempDay(requestParams);
          }
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          //if(this.selectedReportID == "-5"){
          if(this.selectedReportID == "-6"){
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
            this.setSortTempReg(requestParams);
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
          if(this.selectedReportID == "-7"){
            this.setSortTempReg(requestParams);
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
        } catch (error) {
          getErrorMessage('ReportMenuListComponent.vue', 'clickSort', error);
          console.log(error);
        }
      },
      // 昇順/降順のclassを作成
      sortedClass(key) {
        return getSortedClass(key, this.currentSort);
      },
      // ソートするキーを設定する
      sortBy(key) {
        updateSort(key, this.currentSort);
      },
      // 昇順/降順のclassを作成 ※装置帳票
      sortedMClass(key) {
        return getSortedClass(key, this.currentSortM);
      },
      // ソートするキーを設定する
      sortMBy(key) {
        updateSort(key, this.currentSortM);
      },
      async getBedKur(pats) {
        try {
          if (this.dataCondition.timeType === "range_time") {
            // 期間指定
            const treatDateStart = dayjs(this.dataCondition.fromDate).format("YYYYMMDD");
            const treatDateEnd = dayjs(this.dataCondition.toDate).format("YYYYMMDD");
            const response = await ApiHelper.post("/patInfo/getBedAndPatInfoRange", {
              facilityCd: this.facilityCd,
              patIds: Object.keys(pats),
              treatDateStart: treatDateStart,
              treatDateEnd: treatDateEnd
            });
            return response.data;
          } else if (this.dataCondition.timeType === "specify_date") {
            // 1日指定
            const treatDate = dayjs(this.dataCondition.specifyDate).format("YYYYMMDD");
            const response = await ApiHelper.post("/patInfo/getBedAndPatInfoRange", {
              facilityCd: this.facilityCd,
              patIds: Object.keys(pats),
              treatDate: treatDate
            });
            return response.data;
          } else if (this.dataCondition.timeType === "inspection_date") {
            // 検査日数指定 工事中
            let fromDate = null;
            let toDate = null;
            let tmpDate1 = new Date(this.dataCondition.inspectionDate);
            let tmpDate2 = new Date(tmpDate1);
            let key = this.dataCondition.key;
            let numDay = this.dataCondition.numDay;
            if (key == "after") {
              tmpDate2.setDate(tmpDate1.getDate() + parseInt(numDay));
            } else {
              tmpDate2.setDate(tmpDate1.getDate() - parseInt(numDay));
            }
            if (tmpDate1 < tmpDate2) {
              fromDate = tmpDate1;
              toDate = tmpDate2;
            } else {
              fromDate = tmpDate2;
              toDate = tmpDate1;
            }
            const treatDateStart = dayjs(fromDate).format("YYYYMMDD");
            const treatDateEnd = dayjs(toDate).format("YYYYMMDD");
            const response = await ApiHelper.post("/patInfo/getBedAndPatInfoRange", {
              facilityCd: this.facilityCd,
              patIds: Object.keys(pats),
              treatDateStart: treatDateStart,
              treatDateEnd: treatDateEnd
            });
            return response.data;
          }
        } catch (error) {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('ReportMenuListComponent.vue', 'getBedKur', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          console.log(error);
        }
      },
      async processPatientData() {
        var pats = {};
        var patList = [];
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
        var kurl = [];
        var bed =[];
        //add 項目別(印刷情報一覧)の項目が実装されない  吉
        let searchedPatList = await this.searchedPatList;
        if (searchedPatList && searchedPatList.length === 0) {
          this.patList = patList;
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          this.kulList =kurl ;
          this.bedList = bed ;
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
          return;
        }
        for (let index = 0; index < searchedPatList.length; index++) {
          const element = JSON.parse(JSON.stringify(searchedPatList[index]));
          pats[element.pat_id] = element;
        }
        if (Object.keys(pats).length > 0) {
         let res = await this.getBedKur(pats);
            // 患者毎に、クール名、ベッド名を集計
            for (let i = 0; i < res.length; i++) {
              const ele = res[i];
              if (!("kurNames" in pats[ele.patId])) {
                pats[ele.patId]["kurNames"] = [];
                pats[ele.patId]["kurStartTimes"] = [];
              }
              pats[ele.patId]["kurNames"].push(ele.kurName);
              pats[ele.patId]["kurStartTimes"].push(ele.indKurStartTime);
              if (!("bedNames" in pats[ele.patId])) {
                pats[ele.patId]["bedNames"] = [];
                pats[ele.patId]["bedOrderIndexs"] = [];
              }
              pats[ele.patId]["bedNames"].push(ele.bedName);
              pats[ele.patId]["bedOrderIndexs"].push(ele.indBedOrderIndex);
            }

            patList = Object.keys(pats).map(key => {
              let kurs = [...new Set(pats[key].kurNames)];
              let beds = [...new Set(pats[key].bedNames)];
              //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
              if(kurs.length > 1){
                this.kulList.push("複数クール");
              }else{
                this.kulList.push(kurs[0]);
              }
              if(beds.length > 1){
                this.bedList.push(" 複数ベッド");
              }else{
                this.bedList.push(beds[0]);
              }
              //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
              return {
                bed_name: beds.length == 1 ? beds[0] : beds.length > 1 ? "複数ベッド" : "",
                bed_order_index: beds.length == 1 ? pats[key].bedOrderIndexs[0] : beds.length > 1 ? 999990 : "", // 昇順ソート順：ベッドマスタ表示順＞複数ベッド＞未登録＞空欄 となるよう999990をセット ※未登録は999999
                hosp_pat_id: pats[key].hosp_pat_id,
                kur_name: kurs.length == 1 ? kurs[0] : kurs.length > 1 ? "複数クール" : "",
                kur_start_time: kurs.length == 1 ? pats[key].kurStartTimes[0] : kurs.length > 1 ? "999990" : "", // 昇順ソート順：クールマスタ時系列順＞複数クール＞未登録＞空欄 となるよう"999990"をセット ※未登録は"999999"
                pat_first_name: pats[key].pat_first_name,
                pat_id: pats[key].pat_id,
                pat_last_name: pats[key].pat_last_name,
                //add 吉 start
                is_same:pats[key].is_same,
                //add 吉 end
                //add 入外区分が入院の場合、患者名は紫色にする  吉 start
                in_out_class:pats[key].in_out_class,
                // add 入外区分が入院の場合、患者名は紫色にする  吉 end
                // add #11880 帳票画面で患者氏名のソートが機能しないことがある 吉 start
                pat_name:pats[key].pat_last_name + " " + pats[key].pat_first_name,
                // add #11880 帳票画面で患者氏名のソートが機能しないことがある 吉 end
                pat_name_sort:pats[key].pat_name_sort, // 患者名システム共通ソート文字列
              };
            });

            this.patList = patList;
        }
      },
      // add #699,700,751 陳 start
      processMachineData() {
        var macs = {};
        var macList = [];
        if (this.searchedMacList && this.searchedMacList.length === 0) {
          this.macList = macList;
          return;
        }
        for (let index = 0; index < this.searchedMacList.length; index++) {
          const element = this.searchedMacList[index];
          macs[element.machineNo] = element;
        }
        if (Object.keys(macs).length > 0) {
          macList = Object.keys(macs).map(key => {
            return {
              bedName: macs[key].bedName,
              machineSerial: macs[key].machineSerial,
              machineName: macs[key].machineName,
              machineType: macs[key].machineType,
              machineNo: macs[key].machineNo,
              machineTypeCd: macs[key].machineTypeCd,
              model: macs[key].model,
              bedOrderIndex: macs[key].bedOrderIndex,
              machineOrderIndex: macs[key].machineOrderIndex
            };
          });
          this.macList = macList;
        }
      },
      // add #699,700,751 陳 end
      formattedDate(value) {
        if (value === null || value === "") {
          return null;
        }
        return formatDatetime(value, "YYYYMMDD");
      },
      // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
      formatYmdToJp(dateStr) {
        if (!dateStr || dateStr.length !== 8) return '';
        return `${dateStr.slice(0,4)}年${dateStr.slice(4,6)}月${dateStr.slice(6,8)}日`;
      },
      // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      showErrorMessage(msg) {
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "エラー",
          title: DIALOG_MESSAGES[12000205].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: msg
        });
      },
      // add Aspose.cells関連問題対応 鄭爽 start
      // mod #11151 帳票画面「プレビュー」のページ送りが機能しないことがある 吉 start
      //handleScroll() {
      //   //add 8507 2023-4-4 zhaoqj  ローラデータローディング start
      //   const inputData = this.processData();
      //   if (inputData) {
      //     if (inputData.reportClass !== 1) {
      //       return;
      //     }
      //   }
      //   const scrollAreaHeight = $$("#scrollArea").innerHeight();
      //   const scrollHeight = $$("#scrollArea").get(0).scrollHeight;
      //   const bottom = Math.floor(scrollHeight - scrollAreaHeight);
      //   if (this.isRedrawing !== true && this.scrollControl) {
      //     const scrollTop = Math.ceil($$("#scrollArea").scrollTop());
      //     if (bottom <= scrollTop && bottom > 0||bottom === -1) {
      //       //add 8507 2023-4-4 zhaoqj  ローラデータローディング end
      //       if(this.reportOption != 0){
      //         if(this.maxCount < this.selectedPatients.length){
      //           this.scrollControl = false;
      //           this.updateHtml();
      //           this.maxCount += 2;
      //         }
      //       }else{
      //         this.reportOption = 1;
      //         this.isRedrawing = false;
      //       }
      //     }
      //   }
      // },
      handleScroll() {
        if (!this.modalVisible) return;
        const inputData = this.processData();
        if (inputData && inputData.reportClass !== 1) return;
        const scrollArea = this.getScopedElementById("scrollArea");
        if (!scrollArea) return;
        const scrollTop = scrollArea.scrollTop;
        const scrollHeight = scrollArea.scrollHeight;
        const clientHeight = scrollArea.clientHeight;
        // スクロールバーがない → コンテンツの高さが足りない
        const noScrollbar = scrollHeight <= clientHeight;
        // 一番下までスクロール
        const isBottom = scrollTop + clientHeight >= scrollHeight - 2;
        if (this.isRedrawing || !this.scrollControl) return;
        // どちらの場合も読み込みが実行されます:
        // 1. スクロールバーなし (コンテンツが不十分であることを示します)
        // 2. 一番下までスクロールします
        if (noScrollbar || isBottom) {
          if (this.reportOption !== 0) {
            if (this.maxCount < this.selectedPatients.length) {
              this.scrollControl = false;
              this.updateHtml();
              this.maxCount += 2;
            }
          } else {
            this.reportOption = 1;
            this.isRedrawing = false;
          }
        }
      },
      // mod #11151 帳票画面「プレビュー」のページ送りが機能しないことがある 吉 end
      // add Aspose.cells関連問題対応 鄭爽 end
      postShow() {
        var modal = this.getScopedElementById("modal-content");
        // mod  デベロッパーツールに表示されたエラーをないように修正する。 吉 start
        // modal.scrollTop = 0;
        if(null != modal){
          modal.scrollTop = 0;
        }
        // mod  デベロッパーツールに表示されたエラーをないように修正する。 吉 end
      },
      async previewFile() {
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
        this.reportOption = 0;
        // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
        //add 5565 並び替えを実施してもその情報が保持されない 吉 start
        this.sortTargets = this.jsonCopy(this.sortTemp);
        //add 5565 並び替えを実施してもその情報が保持されない 吉 end
        const inputData = this.processData();
        if (inputData) {
          // 検査区分が活性状態 かつ 何も選択されていない場合は処理中断
          if (this.isRegOrderClassAlert()) {
            return;
          }
          // del #12107 帳票印刷失敗通知が行われない limingzhe start
          // // ひとまず先頭のプリンターを選択
          // if (this.getMstPrinters.length > 0) {
          //   this.selectedPrinter = this.getMstPrinters[0].printerCd;
          // }
          // del #12107 帳票印刷失敗通知が行われない limingzhe end

          // 印刷する帳票のデフォルトプリンターを選択
          const mstReport = this.mstReport.find(
            e => e.id === this.selectedReportID
          );
          if (mstReport.defaultPrinter !== "" && mstReport.defaultPrinter !== null) {
            this.selectedPrinter = mstReport.defaultPrinter;
          } else {
            // mod #12107 帳票印刷失敗通知が行われない limingzhe start
            // // 帳票未指定時のデフォルト帳票 (施設設定No117) のデフォルトプリンターを選択
            // if (this.defaultReportID !== "" && this.defaultReportID !== null && typeof this.defaultReportID !== "undefined") {
            //   const defaultReport = this.mstReport.find(
            //     e => e.id === this.defaultReportID
            //   );
            //   if (defaultReport && defaultReport.defaultPrinter !== "" && defaultReport.defaultPrinter !== null) {
            //     this.selectedPrinter = defaultReport.defaultPrinter;
            //   }
            // }
            if(this.defaultPrinter !== "" && this.defaultPrinter !== null) {
              this.selectedPrinter = this.defaultPrinter;
            }
            else {
              this.selectedPrinter = null;
            }
            // mod #12107 帳票印刷失敗通知が行われない limingzhe end
          }

          this.setLoadingScreenMessage("処理中・・・");
          this.setLoadingScreenVisible(true);
          try {
            // upd 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
            //const response = await ApiHelper.post(
            //  "/report_menu/getReportHtml",
            //  inputData
            //);
            //add 8507 2023-4-4 zhaoqj  ローラデータローディング start
            if(inputData.reportClass === 1){
              this.currentPatIds= [...inputData.patIds]
              // mod #9323 donghao start
              // inputData.patIds = this.currentPatIds.slice(0,1)
              inputData.patIds = this.currentPatIds
              // this.currentPatIds.shift()
              this.pageIndex = 1
              inputData.pageIndex = this.pageIndex
              // mod #9323 donghao end
            }

            //add IES因島）sql性能試験 後で削除 liuc start
            let currentTime = new Date();
            let timeStr = currentTime.getFullYear() +"/"+ (currentTime.getMonth()+1) +"/"+ currentTime.getDate()
              +" "+currentTime.getHours()+":"+currentTime.getMinutes()+":"+currentTime.getSeconds()
              +"."+currentTime.getMilliseconds()+" sql-test.."
            //add IES因島）sql性能試験 後で削除 liuc end
            inputData.sqlTestTimeStr = timeStr

            //add 8507 2023-4-4 zhaoqj  ローラデータローディング end
            let  response = await ApiHelper.post(
                "/report_menu/getReportHtml/" + "1/" + "1",
                inputData
              );

            // mod #11232 #10515で入れた制限の見直し 房 end
            // upd 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
            this.setLoadingScreenVisible(false);
            if (!response.data) {
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // this.showErrorMessage("該当データが存在していません。");
              this.showErrorMessage(DIALOG_MESSAGES['00200123'].message);
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              return;
            }
            // add 10546 複数集計,単集計ページ数の制限 gjn start
            if (response.data.includes("ExceedingMaxPageSetting")) {
              let mes = response.data;
              console.log(mes);
              let substringAfterComma = "";
              const commaIndex = mes.indexOf(',');
              if (commaIndex !== -1) {
                substringAfterComma = mes.substring(commaIndex + 1).trim();
              }
              this.showErrorMessage("指定の条件では帳票の最大出力ページ数を超えるため出力できません（"+ substringAfterComma +"／100 ページ）");
              return;
            }
            // add 10546 複数集計,単集計出力時にページ数の制限 gjn end
            // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
            if (response.data == "レポート無") {
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // this.showErrorMessage("帳票レイアウトが「非表示」または「削除」を指定されました。");
              this.showErrorMessage(DIALOG_MESSAGES[12000206].message);
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              return;
            }
            // add  #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王　start
            if (response.data == "テンプレートがない") {
              // テンプレートがない場合、テンプレートが見つかりません、ご確認ください。
              this.showErrorMessage("テンプレートが見つかりません、ご確認ください。");
              this.scrollControl = true;
              return;
            }
            if (response.data == "マスタに設定されていない") {
              // テンプレートがない場合、テンプレートが見つかりません、ご確認ください。
              this.showErrorMessage("マスタにテンプレートが設定されていません。");
              this.scrollControl = true;
              return;
            }
            // add #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王　end
            // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end

            this.resultPreview += response.data;
            //add  5605  李明 start
            this.resetScrollTop();
            //add  5605  李明 end
            this.modalVisible = true;
            // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
            this.isRedrawing = false;
            // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end
            return "OK";
          } catch (error) {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ReportMenuListComponent.vue', 'previewFile', "システムエラーが発生しました。");
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            this.setLoadingScreenVisible(false);
            this.showErrorMessage("システムエラーが発生しました。");
            console.log(error);
          }
        }
      },
      // add 10546 複数集計,単集計ページ数の制限 gjn start
      // Blobを文字列に変換する
      async handleBlobResponse(blob) {
        return new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () => {
            if (typeof reader.result === 'string') {
              resolve(reader.result);
            } else {
              reject(new Error('Blobデータの読み込みに失敗しました'));
            }
          };
          reader.onerror = reject;
          reader.readAsText(blob);
        });
      },
      async processResponseData(response) {
        try {
          const dataString = await this.handleBlobResponse(response.data);
          if (dataString && typeof dataString === 'string' && dataString.includes("ExceedingMaxPageSetting")) {
            let mes = dataString;
            // del #12107 帳票印刷失敗通知が行われない limingzhe start
            //console.log(mes);
            // del #12107 帳票印刷失敗通知が行われない limingzhe end
            let substringAfterComma = "";
            const commaIndex = mes.indexOf(',');
            if (commaIndex !== -1) {
              substringAfterComma = mes.substring(commaIndex + 1).trim();
            }
            this.showErrorMessage("指定の条件では帳票の最大出力ページ数を超えるため出力できません（" + substringAfterComma + "／100 ページ）");
            // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
          } else if (dataString && typeof dataString === 'string' && dataString.includes("テンプレートがない")) {
            this.showErrorMessage("テンプレートが見つかりません、ご確認ください。");
            // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
          }else {
            // del #12107 帳票印刷失敗通知が行われない limingzhe start
            //console.error('response.dataにExceedingMaxPageSettingは含まれていません');
            // del #12107 帳票印刷失敗通知が行われない limingzhe end
          }
        } catch (error) {
          // del #12107 帳票印刷失敗通知が行われない limingzhe start
          //console.error('Blobの処理中にエラーが発生しました:', error);
          // del #12107 帳票印刷失敗通知が行われない limingzhe end
        }
      },
      // add 10546 複数集計,単集計ページ数の制限 gjn end
      async downloadFile() {
        this.closeExportPopover();
        await  this.logEventFun();
        const inputData = this.processData();
        if (inputData) {
          // 検査区分が活性状態 かつ 何も選択されていない場合は処理中断
          if (this.isRegOrderClassAlert()) {
            return;
          }

          this.setLoadingScreenMessage("処理中・・・");
          this.setLoadingScreenVisible(true);
          // mod #11232 #10515で入れた制限の見直し 房 start
          let response = await axios
            .post("/ntss-admin-web/api/report_menu/getReportFile/" + this.selectedExport, inputData, {
              responseType: "blob"
            })
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('ReportMenuListComponent.vue', 'downloadFile', "システムエラーが発生しました。");
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
              console.log(error);
              this.showErrorMessage("システムエラーが発生しました。");
            })
            .finally(() => {
              this.setLoadingScreenVisible(false);
            });

          // mod #11232 #10515で入れた制限の見直し 房 end
          // add 10546 複数集計,単集計ページ数の制限 gjn start
          if (response.data.size >= 27 && response.data.type == "application/json") {
            if (response.data instanceof Blob) {
              await this.processResponseData(response);
              return;
            } else {
              console.error('response.dataはBlobオブジェクトではありません');
              return;
            }
          }
          // add 10546 複数集計,単集計出力時にページ数の制限 gjn end
          if (response.data.size == 0 || !response.data) {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // this.showErrorMessage("該当データが存在していません。");
            this.showErrorMessage(DIALOG_MESSAGES['00200123'].message);
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            return;
          }
          // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
          if (response.data.size == 15 && response.data.type == "application/json") {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // this.showErrorMessage("帳票レイアウトが「非表示」または「削除」を指定されました。");
            this.showErrorMessage(DIALOG_MESSAGES[12000206].message);
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            return;
          }
          // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end
          var blob;
          const contentDis = response.headers["content-disposition"];
          var fileName = contentDis.slice(contentDis.lastIndexOf("filename=") + 9);
          fileName = decodeURI(fileName);
          if (response.headers["content-type"] == "application/pdf") {
            blob = new Blob([response.data], { type: "application/pdf" });
          } else if (response.headers["content-type"] == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet") {
            blob = new Blob([response.data], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" });
          } else {
            blob = new Blob([response.data], { type: "application/zip" });
          }
          if (!blob) {
            return;
          }
          triggerScopedDownload({
            blob,
            filename: fileName,
            root: this.$el || null
          });
          return;
        }
      },

      async printFile() {
        this.popoverPrintVisible = false;
        const inputData = this.processData();
        if (inputData) {
          // 検査区分が活性状態 かつ 何も選択されていない場合は処理中断
          if (this.isRegOrderClassAlert()) {
            return;
          }
          const mstReport = this.mstReport.find(
            e => e.id === this.selectedReportID
          );
          inputData.printerCd = this.selectedPrinter;
          // add FNSI-印刷失敗時の通知を追加 江 start
          var reportType = this.reportClass[Number(mstReport.reportClass)];
          var reportName = mstReport.name;
          // add FNSI-印刷失敗時の通知を追加 江 end
          this.setLoadingScreenMessage("処理中・・・");
          this.setLoadingScreenVisible(true);
          // mod #11232 #10515で入れた制限の見直し 房 start
          let response = await axios
              .post("/ntss-admin-web/api/report_menu/printReport", inputData)
              .catch(error => {
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                getErrorMessage('ReportMenuListComponent.vue', 'printFile', "帳票印刷が失敗しました。");
                //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
                //console.log(error);
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
                // this.showErrorMessage("帳票印刷が失敗しました。");
                this.showErrorMessage(DIALOG_MESSAGES[12000207].message);
                // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
                // del #12107 帳票印刷失敗通知が行われない limingzhe start
                // // add FNSI-印刷失敗時の通知を追加 江 start
                // this.registration(reportType,reportName)
                //   .catch(error => {
                //     //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
                //     getErrorMessage('ReportMenuListComponent.vue', 'printFile', error);
                //     //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
                //     throw error;
                //   });
                // // add FNSI-印刷失敗時の通知を追加 江 end
                // del #12107 帳票印刷失敗通知が行われない limingzhe end
              })
              .finally(() => {
                this.setLoadingScreenVisible(false);
              });

          // mod #11232 #10515で入れた制限の見直し 房 end
          // mod #12107 帳票印刷失敗通知が行われない limingzhe start
          // // add 10546 複数集計,単集計ページ数の制限 gjn start
          // if (response.data.includes("ExceedingMaxPageSetting")) {
          //   let mes = response.data;
          //   console.log(mes);
          //   let substringAfterComma = "";
          //   const commaIndex = mes.indexOf(',');
          //   if (commaIndex !== -1) {
          //     substringAfterComma = mes.substring(commaIndex + 1).trim();
          //   }
          //   this.showErrorMessage("指定の条件では帳票の最大出力ページ数を超えるため出力できません（"+ substringAfterComma +"／100 ページ）");
          //   return;
          // }
          // // add 10546 複数集計,単集計出力時にページ数の制限 gjn end
          // if (response.data.size == 0 || !response.data) {
          //   // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          //   // this.showErrorMessage("該当データが存在していません。");
          //   this.showErrorMessage(DIALOG_MESSAGES['00200123'].message);
          //   // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          //   // add FNSI-印刷失敗時の通知を追加 江 start
          //   this.registration(reportType,reportName)
          //     .catch(error => {
          //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          //       getErrorMessage('ReportMenuListComponent.vue', 'printFile', error);
          //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          //       throw error;
          //     });
          //   // add FNSI-印刷失敗時の通知を追加 江 end
          //   return;
          // }
          // // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
          // if (response.data == "レポート無") {
          //   // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          //   // this.showErrorMessage("帳票レイアウトが「非表示」または「削除」を指定されました。");
          //   this.showErrorMessage(DIALOG_MESSAGES[12000206].message);
          //   // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          //   // add FNSI-印刷失敗時の通知を追加 江 start
          //   this.registration(reportType,reportName)
          //     .catch(error => {
          //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          //       getErrorMessage('ReportMenuListComponent.vue', 'printFile', error);
          //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          //       throw error;
          //     });
          //   // add FNSI-印刷失敗時の通知を追加 江 end
          //   return;
          // }
          // // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end
          // // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
          // if (response.data == "テンプレートがない") {
          //   // テンプレートがない場合、テンプレートが見つかりません、ご確認ください。
          //   this.showErrorMessage("テンプレートが見つかりません、ご確認ください。");
          //   this.registration(reportType,reportName)
          //     .catch(error => {
          //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          //       getErrorMessage('ReportMenuListComponent.vue', 'printFile', error);
          //       //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          //       throw error;
          //     });
          //   return;
          // }
          // // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
          if(response.data.size == 0 || !response.data){
            getErrorMessage('ReportMenuListComponent.vue', 'printFile', DIALOG_MESSAGES['00200123'].message);
            this.showErrorMessage(DIALOG_MESSAGES[12000207].message);
          }
          else if(response.data == "レポート無"
            || response.data == "テンプレートがない"
            || response.data.includes("ExceedingMaxPageSetting")){
            getErrorMessage('ReportMenuListComponent.vue', 'printFile', "帳票印刷が失敗しました。");
            this.showErrorMessage(DIALOG_MESSAGES[12000207].message);
          }
          // mod #12107 帳票印刷失敗通知が行われない limingzhe end
          if (response.status == 200) {
            return "OK";
          }
        }
      },
      async modalVisibleClose() {
        this.modalVisible = false;
        this.maxCount = 1;
        this.resultPreview = "";
      },
      // add FNSI-印刷失敗時の通知を追加 江 start
      /**
       * 通知登録実行
       */
      async registration(reportType,reportName) {
        // 通知登録APIをリクエスト
        ApiHelper.put(`/report_menu/registerNotification/${this.facilityCd}/${reportType}/${reportName}`)
          .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ReportMenuListComponent.vue', 'registration', error);
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            throw error;
          });
      },
      // add FNSI-期間指定 じょはく start
      // checkDate() {
      //   let fromDate = this.dataCondition.fromDate;
      //   let toDate = this.dataCondition.toDate;
      //   let fromDateNew;
      //   let toDateNew;
      //   if ( toDate > fromDate ) {
      //     return true;
      //   } else if ( fromDate > toDate
      //     //add ２次元帳票週間薬剤集計表対応   吉 steat
      //     && "" != fromDate && "" != toDate
      //     //add ２次元帳票週間薬剤集計表対応   吉 end
      //   ) {
      //     fromDateNew = toDate;
      //     toDateNew = fromDate;
      //     this.dataCondition.fromDate = fromDateNew;
      //     // mod  吉 start
      //     // this.dataCondition.toDate = toDateNew;
      //     this.$nextTick(() => {
      //       this.dataCondition.toDate = toDateNew;
      //     })
      //     // mod  吉 end
      //   } else {
      //     return true;
      //   }
      // },
      // add FNSI-期間指定 じょはく end
      // add FNSI-印刷失敗時の通知を追加 江 end
      processData() {
        var fromDate = null;
        var toDate = null;
        var specifyDate = null;
        var medicines = null;
        var equipments = null;
        // add #11603 検査予定のラベル出力とフィルタ機能 高 start
        var examSets = null;
        // add #11603 検査予定のラベル出力とフィルタ機能 高 end

        // mod UT帳票No.112 患者無しの場合、印刷とプレビュー不良の対応 夏 start
        //if (this.selectedReportClassID && this.selectedPatients.length > 0) {
        // mod #11293 水質検査帳票の課題対応 limingzhe start
        //if ((this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID != 7) || (this.selectedReportClassID ==7 && this.selectedMachines.length > 0)) {
        if (
          // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
          // (this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID !== 7 && !(this.selectedReportClassID === 11 && this.selectedReportTypeId === 3))
          // || (this.selectedReportClassID === 7 && this.selectedMachines.length > 0)
          // || (this.selectedReportClassID === 11 && this.selectedReportTypeId === 3 && this.selectedMachines.length > 0)
          (this.selectedPatients.length > 0 && this.selectedReportClassID && this.selectedReportClassID !== 7 && !(this.selectedReportClassID === 11 && (
            this.selectedReportTypeId === 3 || this.selectedReportTypeId === 4
            // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
            || this.selectedReportTypeId === 5
            // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
            )))
          || (this.selectedReportClassID === 11 && (
            this.selectedReportTypeId === 3 || this.selectedReportTypeId === 4
            // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
            || this.selectedReportTypeId === 5
            // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
            ) && this.selectedMachines.length > 0)
          || (this.selectedReportClassID === 7 && this.selectedMachines.length > 0)
          // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
          ) {
        // mod #11293 水質検査帳票の課題対応 limingzhe end
          // mod UT帳票No.112 患者無しの場合、印刷とプレビュー不良の対応 夏 end
          /*** データ抽出条件 ** */
          if (
            // 期間指定
            this.extractCondition[this.selectedReportClassID]["isRangeTime"] &&
            this.dataCondition.timeType == "range_time"
          ) {
            // add 5733 期間指定の昇順・降順入力対応 Gong start
            if (this.dataCondition.fromDate > this.dataCondition.toDate) {
              fromDate = this.dataCondition.toDate;
              toDate = this.dataCondition.fromDate;
            } else {
              // add 5733 期間指定の昇順・降順入力対応 Gong end
              fromDate = this.dataCondition.fromDate;
              toDate = this.dataCondition.toDate;
              // add 5733 期間指定の昇順・降順入力対応 Gong start
            }
            // add 5733 期間指定の昇順・降順入力対応 Gong end
          }

          if (
            // 検査日数指定
            this.extractCondition[this.selectedReportClassID][
              "isInspectionDate"
              ] &&
            this.dataCondition.timeType == "inspection_date"
          ) {
            if (this.dataCondition.inspectionDate) {
              var tmpDate1 = new Date(this.dataCondition.inspectionDate);
              var tmpDate2 = new Date(tmpDate1);
              var key = this.dataCondition.key;
              var numDay = this.dataCondition.numDay;
              if (key == "after") {
                tmpDate2.setDate(tmpDate1.getDate() + parseInt(numDay));
              } else {
                tmpDate2.setDate(tmpDate1.getDate() - parseInt(numDay));
              }
              if (tmpDate1 < tmpDate2) {
                fromDate = tmpDate1;
                toDate = tmpDate2;
              } else {
                fromDate = tmpDate2;
                toDate = tmpDate1;
              }
            }
          }

          if (
            // 1日指定
            this.extractCondition[this.selectedReportClassID]["isSpecifyDate"] &&
            this.dataCondition.timeType == "specify_date"
          ) {
            specifyDate = this.dataCondition.specifyDate;
          }

          if (!specifyDate && (!fromDate || !toDate)) {
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // this.showErrorMessage("治療日をご入力ください。");
            this.showErrorMessage(DIALOG_MESSAGES[12000205].message);
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            return false;
          }
          let parseIntEquipmentList = [...this.EQUIPMENT.checkedList];
          parseIntEquipmentList.forEach((item, index) => {
            parseIntEquipmentList[index] = +item;
          });
          if (this.extractCondition[this.selectedReportClassID]["isEquipment"]) {
            // 医療材料
            equipments = parseIntEquipmentList;
          }
          let parseIntMedicineList = [...this.MEDICINE.checkedList];
          parseIntMedicineList.forEach((item, index) => {
            parseIntMedicineList[index] = +item;
          });
          if (this.extractCondition[this.selectedReportClassID]["isMedicine"]) {
            // 薬剤
            medicines = parseIntMedicineList;
          }
          // add #11603 検査予定のラベル出力とフィルタ機能 高 start
          // 検査セット
          let parseIntExamSetList = [...this.EXAMSET.checkedList];
          parseIntExamSetList.forEach((item, index) => {
            parseIntExamSetList[index] = +item;
          });
          if (this.extractCondition[this.selectedReportClassID]["isExamSet"]) {
            examSets = parseIntExamSetList;
          }
          // add #11603 検査予定のラベル出力とフィルタ機能 高 end
			    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
          // 検査
          var inspections = [];
          if (this.extractCondition[this.selectedReportClassID]["isInspection"]) {
            // mod #12551 データ抽出条件「採血管」を隠す sunsy start
            // inspections.push(this.inspectCheckBox ? 1 : 0);
            inspections.push(0);//常に出さないように暫定的の対応
            // mod #12551 データ抽出条件「採血管」を隠す sunsy end
          }else{
            inspections.push(-1);
          }
			    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
          var reportName = this.mstReport.find(x => x.id == this.selectedReportID)
            .name;
          // 表示順
          var sortCond = [];
          for (let index in this.sortTargets) {
            let item = this.sortTargets[index];
            if (
              !item.key ||
              sortCond.find(e => Object.keys(e).indexOf(item.key) > -1)
            ) {
              continue;
            } else {
              sortCond.push({ [item.key]: item.sort });
            }
          }
          let parseIntPatients = [...this.selectedPatients];
          parseIntPatients.forEach((item, index) => {
            parseIntPatients[index] = +item;
          });
          /*add FNSI-改修内容装置帳票の対応 任 start*/
          const machines = [];
          this.macList.forEach(item => {
            this.selectedMachines.forEach(machine => {
              if(item.machineNo.toString() === machine){
                machines.push(item);
              }
            })
          })
          var expressCondCd=[];
          if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
            if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
              expressCondCd.push("予定");
              expressCondCd.push("実績");
            } else {
              if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
                expressCondCd.push("予定");
              } else {
                expressCondCd.push("実績");
              }
            }
          }
          /*add FNSI-改修内容装置帳票の対応 任 end*/
          //add 6502 装置帳票：定期・日常が分離されていない 吉 start
          const mstReport = this.mstReport.find(
            e => e.id === this.selectedReportID
          );
          //add 6502 装置帳票：定期・日常が分離されていない 吉 end
          // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
          let period = null;
          if(this.selectedReportClassID && this.extractCondition[this.selectedReportClassID]['isRangeTime']
            && this.dataCondition.timeType == 'range_time') {
            if(fromDate && toDate) {
              // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
              // period = this.formattedDate(fromDate) + "～" + this.formattedDate(toDate);
              period = this.formatYmdToJp(this.formattedDate(fromDate)) + "～" + this.formatYmdToJp(this.formattedDate(toDate));
              // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
            }
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            // 印刷情報の期間を指定日に設定しても、指定日に対する情報を表示させる
          } else if (this.selectedReportClassID && this.extractCondition[this.selectedReportClassID]['isSpecifyDate'] && this.dataCondition.timeType == 'specify_date') {
            period = this.formatYmdToJp(this.formattedDate(specifyDate));
          // add  #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          }
          // 医療材料分類
          let equipmentType = null;
          if(this.selectedReportClassID && this.selectedReportClassID !== 7
            && this.multiTotalID !== this.selectedReportID && this.extractCondition[this.selectedReportClassID]['isEquipment']){
            if(this.selectEquipmentAll) {
              equipmentType = "すべて";
            } else if(equipments) {
              let tempEquipmentArr = [];
              equipments.forEach(el => {
                // mod #12205 帳票画面のデータ抽出条件が分類名称の削除を考慮していない 高 start
                if (this.EQUIPMENT.childrens[this.EQUIPMENT.childrens.findIndex(obj => obj.id == el)] !== undefined) {
                  tempEquipmentArr.push(this.EQUIPMENT.childrens[this.EQUIPMENT.childrens.findIndex(obj => obj.id == el)].text);
                }
                // tempEquipmentArr.push(this.EQUIPMENT.childrens[this.EQUIPMENT.childrens.findIndex(obj => obj.id == el)].text);
                // mod #12205 帳票画面のデータ抽出条件が分類名称の削除を考慮していない 高 end
              });
              equipmentType = tempEquipmentArr.join("・");
            }
          }
          // 薬剤分類
          let medicineType = null;
          if(this.selectedReportClassID && this.selectedReportClassID !== 7
            && this.multiTotalID !== this.selectedReportID && this.extractCondition[this.selectedReportClassID]['isMedicine']) {
            if(this.selectMedicineAll) {
              medicineType = "すべて";
            } else if(medicines) {
              let tempMedicineArr = [];
              medicines.forEach(el => {
                // mod #12205 帳票画面のデータ抽出条件が分類名称の削除を考慮していない 高 start
                if (this.MEDICINE.childrens[this.MEDICINE.childrens.findIndex(obj => obj.id == el)] !== undefined) {
                  tempMedicineArr.push(this.MEDICINE.childrens[this.MEDICINE.childrens.findIndex(obj => obj.id == el)].text);
                }
                // tempMedicineArr.push(this.MEDICINE.childrens[this.MEDICINE.childrens.findIndex(obj => obj.id == el)].text);
                // mod #12205 帳票画面のデータ抽出条件が分類名称の削除を考慮していない 高 end
              });
              medicineType = tempMedicineArr.join("・");
            }
          }

          // add #11603 検査予定のラベル出力とフィルタ機能 高 start
          // 検査セット
          let examSetType = null;
          if(this.selectedReportClassID && this.selectedReportClassID !== 7
            && this.multiTotalID !== this.selectedReportID && this.extractCondition[this.selectedReportClassID]['isExamSet']) {
            if(this.selectExamSetAll) {
              examSetType = "すべて";
            } else if(examSets) {
              let tempExamSetArr = [];
              examSets.forEach(el => {
                // mod #12205 帳票画面のデータ抽出条件が分類名称の削除を考慮していない 高 start
                if (this.EXAMSET.childrens[this.EXAMSET.childrens.findIndex(obj => obj.id == el)] !== undefined) {
                  tempExamSetArr.push(this.EXAMSET.childrens[this.EXAMSET.childrens.findIndex(obj => obj.id == el)].text);
                }
                // tempExamSetArr.push(this.EXAMSET.childrens[this.EXAMSET.childrens.findIndex(obj => obj.id == el)].text);
                // mod #12205 帳票画面のデータ抽出条件が分類名称の削除を考慮していない 高 end
              });
              examSetType = tempExamSetArr.join("・");
            }
          }
          // add #11603 検査予定のラベル出力とフィルタ機能 高 end
          // 検査分類
          let inspectionType = null;
          // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
          // if(this.dataCondition.isDialysisDate =='false') {
          //   if (this.selectCheckAll) {
          //     inspectionType = "すべて";
          //   } else if (this.CHECKLIST.checkedList) {
          //     let tempCheckArr = [];
          //     this.CHECKLIST.checkedList.forEach(el => {
          //       tempCheckArr.push(this.CHECKLIST.childrens[this.CHECKLIST.childrens.findIndex(obj => obj.id == el)].text);
          //     });
          //     inspectionType = tempCheckArr.join("・");
          //   }
          if(this.selectedReportClassID && this.selectedReportClassID !== 7
            && this.multiTotalID !== this.selectedReportID && this.extractCondition[this.selectedReportClassID]['isInspection']) {
            inspectionType = this.inspectCheckBox ? "すべて" : "";
            // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
          }
          let inspectionKbn = null;
          if(this.isRegOrderClassActive) {
            if(this.dataCondition.regOrderClass) {
              if(this.dataCondition.regOrderClass.length == 3) {
                inspectionKbn = "すべて";
              } else {
                let inspectionKbnArr = [];
                this.dataCondition.regOrderClass.forEach(el => {
                  inspectionKbnArr.push(el == '0' ? 'その他' : (el == '1' ? '透析前' : '透析後'))
                })
                inspectionKbn = inspectionKbnArr.join("・");
              }
            }
          }
          let inspectionDate = null;
          let inspectionDirection = null;
          let inspectionDays = null;
          if(this.dataCondition.timeType == "inspection_date") {
            inspectionDate = this.dataCondition.inspectionDate;
            inspectionDirection = this.dataCondition.key == 'before' ? "前" : "後";
            inspectionDays = this.dataCondition.numDay;
          }
          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
          let prescriptionKbn = null;
          if (this.isChkViewPreActive && this.dataCondition.prescriptionClass) {
            if (this.dataCondition.prescriptionClass.length === 2) {
              prescriptionKbn = 'すべて';
            } else {
              prescriptionKbn = this.dataCondition.prescriptionClass
                .map(el => el === '1' ? '院外' : '院内')
                .join('・');
            }
          }

          let introductionKbn = null;
          if (this.isChkViewLetterActive && this.dataCondition.letterCategory) {
            if (this.dataCondition.letterCategory.length === 2) {
              introductionKbn = 'すべて';
            } else {
              introductionKbn = this.dataCondition.letterCategory
                .map(el => el === '0' ? '転出' : '転入')
                .join('・');
            }
          }

          const typeMap = [
            { value: equipmentType, label: '医療材料' },
            { value: medicineType, label: '薬剤' },
            { value: examSetType, label: '検査セット' },
            { value: inspectionType, label: '採血管' }
          ]

          const kind = typeMap
            .filter(item => item.value != null && item.value != "")
            .map(item => item.label)
            .join('・') || null

          // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
          let patGroups = null;
          if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
            patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
          } else {
            patGroups = "すべて";
          }
          // ソート情報
          let sortColumn1 = null;
          let sortOrder1 = null;
          let sortColumn2 = null;
          let sortOrder2 = null;
          let sortColumn3 = null;
          let sortOrder3 = null;
          if(this.sortTemp) {
            this.sortTemp.forEach((el, index) => {
              if(index == 0) {
                sortColumn1 = el.key;
                sortOrder1 = el.sort;
              } else if (index == 1) {
                sortColumn2 = el.key;
                sortOrder2 = el.sort;
              } else {
                sortColumn3 = el.key;
                sortOrder3 = el.sort;
              }
            })
          }
          let kurNames = null;
          if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
            kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
          } else {
            kurNames = "すべて";
          }
          if(!(this.dataCondition.timeType == "specify_date")) {
            specifyDate = null;
          }
          if(!toDate && fromDate) {
            toDate = fromDate
          }
          // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
          let ret = {
            fromDate: this.formattedDate(fromDate),
            toDate: this.formattedDate(toDate),
            specifyDate: this.formattedDate(specifyDate),
            medicineCdList: medicines,
            equipmentCdList: equipments,
            patIds: parseIntPatients,
            reportCd: this.selectedReportID,
            reportName: reportName,
            facilityCd: this.facilityCd,
            // ラベルの並び替え処理にて、sortConditionが逆順に設定されているのが前提となっています。
            // 下記の"sortCond.reverse()"は変更しないでください。
            // 他の帳票の並び替え処理を実装する際にも、ラベルの並び替え処理と合わせるため、
            // sortConditionが逆順に設定されていることを基準としてください。
            sortCondition: sortCond.reverse(),
            reportClass: this.selectedReportClassID,
            stPos: this.stPos,
            /*add FNSI-改修内容装置帳票の対応 任 start*/
            machines: machines,
            /*add FNSI-改修内容装置帳票の対応 任 end*/
            // 選択日付が治療日か否か ※紹介日、すべての場合、帳票生成処理は治療日指定と同じルートを通す
            isDialysisDate: this.rootDialysisDate,
            // add #11226 患者情報系historyの取得条件見直し② limingzhe start
            dateKind: this.rootDialysisDate === "true" ? "dialysis_date" : this.dataCondition.dateKind,
            // add #11226 患者情報系historyの取得条件見直し② limingzhe end
            // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            dateKindPrint: this.dataCondition.dateKind,
            kind: kind,
            // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
            //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
            freeWord:this.getStorSimlpSearchQurey.freeWord,
            treatDate:this.getStorSimlpSearchQurey.treatDate,
            // mod #11009 カテゴリ「印刷情報」の優先対応 高 start
            // kurCdList:this.getStorSimlpSearchQurey.selectedKurName,
            kurCdList:this.getStorSimlpSearchQurey.selectKurNameNewReport,
            // mod #11009 カテゴリ「印刷情報」の優先対応 高 end
            bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
            expressCondCd:expressCondCd,
            //add 6502 装置帳票：定期・日常が分離されていない 吉 start
            reportType:mstReport.reportType,
            // add #9323 donghao start
            pageIndex:1,
            // add #9323 donghao end
            //add 6502 装置帳票：定期・日常が分離されていない 吉 end
            // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
            // add 11010 スケジュール表出力時の処理が不足している 吉 start
            kurList:this.getStorSimlpSearchQurey.kurList,
            // mod #11426 【たくしん会】患者検索でベッドグループ絞り込みしていると帳票画面でシステムエラー　V1.0B 高　start
            // bedCdList:this.getStorSimlpSearchQurey.bedCdList,
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            bedCdList:Array.isArray(this.getStorSimlpSearchQurey.bedCdList) ?
            //   this.getStorSimlpSearchQurey.bedCdList : this.getStorSimlpSearchQurey.bedCdList.replace("[","").replace("]","").split(","),
              this.getStorSimlpSearchQurey.bedCdList :
              this.getStorSimlpSearchQurey.bedCdList != undefined ?
              this.getStorSimlpSearchQurey.bedCdList.replace("[","").replace("]","").split(",") : [],
            // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
            // mod #11426 【たくしん会】患者検索でベッドグループ絞り込みしていると帳票画面でシステムエラー　V1.0B 高　end
            // add 11010 スケジュール表出力時の処理が不足している 吉 end
            // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
            inspectionCdList: inspections,
            // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
            // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
            period: period,
            equipmentType: equipmentType,
            medicineType: medicineType,
            inspectionType: inspectionType,
            inspectionDate: inspectionDate,
            inspectionDirection: inspectionDirection,
            inspectionDays: inspectionDays,
            inspectionKbn: inspectionKbn,
            // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
            prescriptionKbn: prescriptionKbn,
            introductionKbn: introductionKbn,
            // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
            patGroups: patGroups,
            sortColumn1: sortColumn1,
            sortColumn2: sortColumn2,
            sortColumn3: sortColumn3,
            sortOrder1: sortOrder1,
            sortOrder2: sortOrder2,
            sortOrder3: sortOrder3,
            kurNames: kurNames,
            // add #11603 検査予定のラベル出力とフィルタ機能 高 start
            examSetType:examSetType,
            examSetCdList: examSets,
            // add #11603 検査予定のラベル出力とフィルタ機能 高 end
            // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
          };

          // 検査区分がdisabledでない場合はフィールドに追加
          if (this.isRegOrderClassActive) {
            ret.regOrderClassList = this.dataCondition.regOrderClass;
          }

          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
          if (this.isChkViewPreActive) {
            ret.prescriptionClassList = this.dataCondition.prescriptionClass;
          }
          // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end

          return ret;
        }
        return null;
      },
      //add この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
      initializeSelectAllMachinesList(){
        let selected = [];
        if (this.searchedMacList && this.searchedMacList.length > 0) {
          this.searchedMacList.forEach(pat => {
            selected.push(pat.machineNo.toString());
          });
        }
        this.selectedMachines = selected;
      },
      //add この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
      // add #699,700,751 陳 start
      setSelectedMachinesList() {
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
        // let selected = [];
        // if (this.searchedMacList && this.searchedMacList.length > 0) {
        //   this.searchedMacList.forEach(pat => {
        //     selected.push(pat.machineNo.toString());
        //   });
        // }
        // this.selectedMachines = selected;
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
        // mod #11293 水質検査帳票の課題対応 limingzhe start
        //let param = {paramSelected: this.selectedMachines, paramReportClassID: this.selectedReportClassID};
        let param = {paramSelected: this.selectedMachines, paramReportClassID: this.selectedReportClassID, selectedReportTypeId:this.selectedReportTypeId};
        // mod #11293 水質検査帳票の課題対応 limingzhe end
        EventBus.$emit("selectedMachines", param);
      },
      // add #699,700,751 陳 end
      //add この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
      initializeSelectAll(){
        let selected = [];
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //if(null == this.selectedReportID  || this.selectedReportID != -3 || this.selectedReportID != -2)
        if(null == this.selectedReportID  || this.selectedReportID != -3 || this.selectedReportID != -4)
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        {
          if (this.searchedPatList && this.searchedPatList.length > 0) {
            this.searchedPatList.forEach(pat => {
              pat.flag=1;
              selected.push(pat.pat_id.toString());
            });
          }
        }else{
          if (null != this.realyDate && this.realyDate.length > 0) {
            selected=this.realyDate;
          }
        }
        // チェックボックスの選択状態を復元
        this.restoreSelectedPatients(selected);
        let param = {paramSelected: this.selectedPatients, paramReportClassID: this.selectedReportClassID};
        EventBus.$emit("selectedPatients", param);
      },
      //add この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
      setSelectedPatientsList() {
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 start
        // let selected = [];
        // if (this.searchedPatList && this.searchedPatList.length > 0) {
        //   this.searchedPatList.forEach(pat => {
        //     selected.push(pat.pat_id.toString());
        //   });
        // }
        // this.selectedPatients = selected;
        //del この操作を行った際に、②の患者選択が破棄され、全患者選択状態となる 吉 end
        // add FNSI-改修内容 画面ボタンの位置調整 穆 start
        let param = {paramSelected: this.selectedPatients, paramReportClassID: this.selectedReportClassID};
        EventBus.$emit("selectedPatients", param);
        // add FNSI-改修内容 画面ボタンの位置調整 穆 end
      },
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 start
      async updateHtml() {
        this.reportOption = 1;
        // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
        this.setLoadingScreenMessage("処理中・・・");
        this.setLoadingScreenVisible(true);
        // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
        const inputData = this.processData();
        let pageCount = 2;
        if (inputData) {
          // del #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
          // this.setLoadingScreenMessage("処理中・・・");
          // this.setLoadingScreenVisible(true);
          // del #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
          //add 8507 2023-4-4 zhaoqj  ローラデータローディング start
          if(inputData.reportClass === 1){
            // mod #9323 donghao start
            // inputData.patIds = this.currentPatIds.slice(0,pageCount)
            inputData.patIds = this.currentPatIds
            // this.currentPatIds.splice(0,pageCount)
            this.currentPatIds
            // mod #9323 donghao end
          }
          // add #9323 donghao start
          this.pageIndex++;
          inputData.pageIndex = this.pageIndex;
          // add #9323 donghao end
          //add 8507 2023-4-4 zhaoqj  ローラデータローディング end
          try {
            // mod #11232 #10515で入れた制限の見直し 房 start
            let response = {};
            let tempPageCount = 1 + (this.pageIndex - 1) * 2;
            if(tempPageCount > inputData.patIds.length) {
              tempPageCount = inputData.patIds.length;
            }
            response = await ApiHelper.post(
              "/report_menu/getReportHtml/" + "0/" + pageCount,
              inputData
            );

            // mod #11232 #10515で入れた制限の見直し 房 end
            this.setLoadingScreenVisible(false);
            if (!response.data) {
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // this.showErrorMessage("該当データが存在していません。");
              this.showErrorMessage(DIALOG_MESSAGES['00200123'].message);
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
              this.scrollControl = true;
              // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
              return;
            }
            // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 start
            if (response.data == "レポート無") {
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // this.showErrorMessage("帳票レイアウトが「非表示」または「削除」を指定されました。");
              this.showErrorMessage(DIALOG_MESSAGES[12000206].message);
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
              this.scrollControl = true;
              // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
              return;
            }
            if (response.data == "データ無") {
              // del 外部結合テストNo.2 最後の場合、メッセージがいらないです。 夏 start
              //this.$ons.notification.alert({
              //  title: "データ無",
              //  message: "データが最後尾に達しました。"
              //});
              // del 外部結合テストNo.2 最後の場合、メッセージがいらないです。 夏 end
              this.isRedrawing =true;
              this.modalVisible = true;
              // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
              this.scrollControl = true;
              // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
              return;
            }
            // add 2020-09-17 FNSI-不良修正 レイアウトデザイナーで削除後エラー処理追加 夏 end

            this.resultPreview += response.data;
            this.modalVisible = true;
            this.isRedrawing = false;
            // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
            this.scrollControl = true;
            // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
            return "OK";
          } catch (error) {
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
            getErrorMessage('ReportMenuListComponent.vue', 'registration', "システムエラーが発生しました。");
            //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            this.setLoadingScreenVisible(false);
            this.showErrorMessage("システムエラーが発生しました。");
            console.log(error);
            // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン start
            this.scrollControl = true;
            // add #6962 「並び替えボタンが機能しない」について、再対応 鄧シン end
          }
        }
      },
      // add 2020-09-30 FNSI-改修 複数データ対象の帳票の場合の切替 夏 end

      //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
      // setSelectedPatient(patId) {
      setSelectedPatient(patId,kul,bed) {
        //mod 項目別(印刷情報一覧)の項目が実装されない  吉 end
        const selectedIndex = this.selectedPatients.indexOf(patId.toString());
        if (selectedIndex >= 0) {
          this.selectedPatients.splice(selectedIndex, 1);
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          this.kulList.splice(selectedIndex, 1);
          this.bedList.splice(selectedIndex, 1);
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
        } else {
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          if(null != kul){
            this.kulList.push(kul.toString());
          }
          if(null != bed){
            this.bedList.push(bed.toString());
          }
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
          this.selectedPatients.push(patId.toString());
        }
      },
      // add #699,700,751 陳 start
      setSelectedMachine(machineId) {
        const selectedIndex = this.selectedMachines.indexOf(machineId.toString());
        if (selectedIndex >= 0) {
          this.selectedMachines.splice(selectedIndex, 1);
        } else {
          this.selectedMachines.push(machineId.toString());
        }
      },
      // add #699,700,751 陳 end
      /*add FNSI-改修内容日付のチェックの追加対応。 吉 start*/
      showMsg(flag){
        if(flag == "0"){
          this.showErrorFromDate = this.dataCondition.fromDate ? this.getScopedElementsByClassName("fromDate")[0].validationMessage !== "" : false;
        }
        if(flag == "1"){
          this.showErrorToDate = this.dataCondition.toDate ? this.getScopedElementsByClassName("toDate")[0].validationMessage !== "" : false;
        }
        if(flag == "2"){
          this.showErrorSpecifyDate = this.dataCondition.specifyDate ? this.getScopedElementsByClassName("specifyDate")[0].validationMessage !== "" : false;
        }
        if(flag == "3"){
          this.showErrorInspectionDate = this.dataCondition.inspectionDate ? this.getScopedElementsByClassName("inspectionDate")[0].validationMessage !== "" : false;
        }
        /*this.checkDate();*/
      },
      /*add FNSI-改修内容パンくずリスト対応 任 start*/
      async refresh(){
        if (this.selfScreenName !== this.$route.name) {
          return;
        }
        this.setLoadingScreenVisible(true);
        const mstReport = await ApiHelper.get("/report/getMstReportByFacilityCd/" + this.facilityCd);
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // let items3 = [];
        // items3.push({
        //   id: "-3",
        //   reportClass: 1,
        //   name: "治療経過表",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // items3.push({
        //   id: "-2",
        //   reportClass: 1,
        //   name: "治療経過表（手書き）",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // items3.push({
        //   id: "-4",
        //   reportClass: 7,
        //   name: "日常点検記録簿",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // items3.push({
        //   id: "-5",
        //   reportClass: 7,
        //   name: "定期点検（記録簿・交換部品記録簿）",
        //   reportType: 0,
        //   defaultPrinter: "",
        //   extractionCondition: "",
        //   additionalInfo: ""
        // });
        // for (const item3 of mstReport.data) {
        //   if (item3.reportClass !== 7) {
        //     if (!(item3.reportClass == 1 && item3.reportName.substr(0, 2) !== "＊＊")) {
        //       // 治療経過表 ( reportClass = 1 ) は、名称の先頭に「＊＊」がついているもののみ表示する
        //       items3.push({
        //         id: item3.reportCd,
        //         reportClass: item3.reportClass,
        //         name: item3.reportName,
        //         reportType: item3.reportType,
        //         defaultPrinter: item3.defaultPrinter,
        //         extractionCondition: item3.extractionCondition,
        //         additionalInfo: item3.additionalInfo
        //       });
        //     }
        //   } else {
        //     // 装置帳票 ( reportClass = 7 ) の場合、名称の先頭に「＊＊」ついている、又は reportType = 1 (マルチ)のもののみ表示する
        //     if (item3.reportName.substr(0, 2) == "＊＊" || item3.reportType !== 0) {
        //       items3.push({
        //         id: item3.reportCd,
        //         reportClass: item3.reportClass,
        //         name: item3.reportName,
        //         reportType: item3.reportType,
        //         defaultPrinter: item3.defaultPrinter,
        //         extractionCondition: item3.extractionCondition,
        //         additionalInfo: item3.additionalInfo
        //       });
        //     }
        //   }
        // }
        // this.mstReport = items3;
        this.mstReport = this.getMstReportInfo(mstReport);
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        this.setLoadingScreenVisible(false);
      },
      /*add FNSI-改修内容パンくずリスト対応 任 end*/
      /*add FNSI-改修内容日付のチェックの追加対応。 吉 end*/
      // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      getMstReportInfo(mstReport){
        let items3 = [];
        if(mstReport != null && mstReport.data != null){
          for (const item3 of mstReport.data) {
            items3.push({
              id: item3.reportCd,
              reportClass: item3.reportClass,
              name: item3.reportName,
              reportType: item3.reportType,
              defaultPrinter: item3.defaultPrinter,
              extractionCondition: item3.extractionCondition,
              additionalInfo: item3.additionalInfo
            });
          }
        }
        return items3;
      },
      // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      /*add 検索条件ログ対応 吉 start*/
      async logEventFun(){
        var conditionMessage = '';
        if(null != this.reportTypeID && "" != this.reportTypeID){
          conditionMessage += this.reportClass[Number(this.reportTypeID)] + '、';
        }else{
          conditionMessage +="帳票種別:全て"+ '、';
        }
        // del 8486 CSSの修正により、ファイル保存問題が発生  吉 start
        // var elements =  this.getScopedElementsByClassName("condition")[2];
        // var parOne=elements.children[0];
        // if(null != parOne){
        //   // 基準日の設定
        //   if (parOne.children[1].children[1].children[0].children[0].checked) {
        //     conditionMessage += parOne.children[1].children[1].children[0].children[1].innerText + '、';
        //   } else {
        //     conditionMessage += parOne.children[1].children[1].children[1].children[1].innerText + '、';
        //   }
        //   if(parOne.children[2].children[0].checked){
        //     conditionMessage += parOne.children[2].children[1].innerText + '、';
        //     if(null != parOne.children[2].children[2].children[0].children[0].value && ""!= parOne.children[2].children[2].children[0].children[0].value){
        //       conditionMessage += parOne.children[2].children[2].children[0].children[0].value+ '、';
        //     }
        //     if(null != parOne.children[2].children[2].children[2].children[0].value && ""!= parOne.children[2].children[2].children[2].children[0].value){
        //       conditionMessage += parOne.children[2].children[2].children[2].children[0].value+ '、';
        //     }
        //   }else if(parOne.children[3].children[0].checked){
        //     conditionMessage += parOne.children[3].children[1].innerText + '、';
        //     if(null != parOne.children[3].children[2].children[0].value && ""!= parOne.children[3].children[2].children[0].value){
        //       conditionMessage += parOne.children[3].children[2].children[0].value+ '、';
        //     }
        //   }else{
        //     conditionMessage += parOne.children[4].children[1].innerText + '、';
        //     if(null != parOne.children[4].children[2].children[0].children[0].value && ""!= parOne.children[4].children[2].children[0].children[0].value){
        //       conditionMessage += parOne.children[4].children[2].children[0].children[0].value+ '、';
        //     }
        //     if(parOne.children[4].children[2].children[2].children[0].children[0].children[0].selected){
        //       conditionMessage += parOne.children[4].children[2].children[2].children[0].children[0].children[0].innerHTML+ '、';
        //     }else{
        //       conditionMessage += parOne.children[4].children[2].children[2].children[0].children[0].children[1].innerHTML+ '、';
        //     }
        //     if(null != parOne.children[4].children[2].children[2].children[1].value && ""!= parOne.children[4].children[2].children[2].children[1].value){
        //       conditionMessage += parOne.children[4].children[2].children[2].children[1].value+ '、';
        //     }
        //   }
        //   if(parOne.children[5].children[1].children[0].checked){
        //     conditionMessage +=parOne.children[5].children[1].innerText+ '、';
        //   }
        //   if(parOne.children[5].children[2].children[0].checked){
        //     conditionMessage +=parOne.children[5].children[2].innerText+ '、';
        //   }
        //   if(parOne.children[5].children[3].children[0].checked){
        //     conditionMessage +=parOne.children[5].children[3].innerText+ '、';
        //   }
        // }
        // var parTwo=elements.children[2].children[0];
        // if(null != parTwo){
        //   if(parTwo.children[0].children[0].checked){
        //     conditionMessage +=parTwo.children[0].children[1].innerText+ '、';
        //     var str = parTwo.children[1].innerText;
        //     str=str.replace(/[\r\n]/g, "、");
        //     conditionMessage += str;
        //   }else{
        //     for(var i=0;i<13;i++){
        //       if(parTwo.children[1].children[i].children[0].checked){
        //         conditionMessage +=parTwo.children[1].children[i].children[1].innerText+ '、';
        //       }
        //     }
        //   }
        // }
        // var parThree=elements.children[4].children[0];
        // if(null != parThree){
        //   if(parThree.children[0].children[0].checked){
        //     conditionMessage +=parThree.children[0].children[1].innerText+ '、';
        //     var strT = parThree.children[1].innerText;
        //     strT=strT.replace(/[\r\n]/g, "、");
        //     conditionMessage += strT;
        //   }else{
        //     for(var k=0;k<10;k++){
        //       if(parThree.children[1].children[k].children[0].checked){
        //         conditionMessage +=parThree.children[1].children[k].children[1].innerText+ '、';
        //       }
        //     }
        //   }
        // }
        // del 8486 CSSの修正により、ファイル保存問題が発生  吉 end
        // add 8486 CSSの修正により、ファイル保存問題が発生  吉 start
        // 基準日の設定
        if (this.getScopedElementById("dialysis_date").checked) {
          conditionMessage += this.getScopedElementById("dialysis_date_id").textContent + '、';
        // add #11226 患者情報系historyの取得条件見直し② limingzhe start
        } else if (this.getScopedElementById("issue_date").checked)  {
          conditionMessage += this.getScopedElementById("issue_date_id").textContent + '、';
        // add #11226 患者情報系historyの取得条件見直し② limingzhe end
        } else if (this.getScopedElementById("letter_issue_date").checked)  {
          conditionMessage += this.getScopedElementById("letter_issue_date_id").textContent + '、';
        } else if (this.getScopedElementById("all_date").checked)  {
          conditionMessage += this.getScopedElementById("all_date_id").textContent + '、';
        } else {
          conditionMessage += this.getScopedElementById("exam_date_id").textContent + '、';
        }
        // 期間指定
        if (this.getScopedElementById("range_time").checked) {
          conditionMessage += this.getScopedElementById("range_time_id").textContent + '、';
          conditionMessage += this.dataCondition.fromDate + '、';
          conditionMessage += this.dataCondition.toDate + '、';
        } else if(this.getScopedElementById("specify_date").checked){
          conditionMessage += this.getScopedElementById("specify_date_id").textContent + '、';
          conditionMessage += this.dataCondition.specifyDate + '、';
        }else{
          conditionMessage += this.getScopedElementById("inspection_date_id").textContent + '、';
          conditionMessage += this.dataCondition.inspectionDate + " " + this.dataCondition.key + " "+ this.dataCondition.numDay + '、';
        }
        // 検査区分
        if(this.getScopedElementById("before_dialysis").checked){
          conditionMessage += this.getScopedElementById("before_dialysis_id").textContent + '、';
        }
        if(this.getScopedElementById("after_dialysis").checked){
          conditionMessage += this.getScopedElementById("after_dialysis_id").textContent + '、';
        }
        if(this.getScopedElementById("other").checked){
          conditionMessage += this.getScopedElementById("other_id").textContent + '、';
        }
        // 処方区分
        if(this.getScopedElementById("viewPreOut").checked){
          conditionMessage += this.getScopedElementById("viewPreOut_id").textContent + '、';
        }
        if(this.getScopedElementById("viewPreIn").checked){
          conditionMessage += this.getScopedElementById("viewPreIn_id").textContent + '、';
        }
        // 紹介区分
        if(this.getScopedElementById("viewMovingOut").checked){
          conditionMessage += this.getScopedElementById("viewMovingOut_id").textContent + '、';
        }
        if(this.getScopedElementById("viewMovingIn").checked){
          conditionMessage += this.getScopedElementById("viewMovingIn_id").textContent + '、';
        }
        // 医療材料
        if(this.selectEquipmentAll){
          conditionMessage += this.getScopedElementById("equipment_all_id").textContent + '、';
        }
        if(this.EQUIPMENT.checkedList){
          for(var i=0;i<this.EQUIPMENT.checkedList.length;i++){
            var id = "equiment"+this.EQUIPMENT.checkedList[i];
            conditionMessage += this.getScopedElementById(id).textContent + '、';
          }
        }
        // 薬剤
        if(this.selectMedicineAll){
          conditionMessage += this.getScopedElementById("medicine_all_id").textContent + '、';
        }
        if(this.MEDICINE.checkedList){
          for (let i = 0; i < this.MEDICINE.checkedList.length; i++) {
            const id = "medicine" + this.MEDICINE.checkedList[i];
            conditionMessage += this.getScopedElementById(id).textContent + '、';
          }
        }
        // 検査
        // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
        // if(this.selectCheckAll){
        //   conditionMessage += this.getScopedElementById("check_all_id").textContent + '、';
        // }
        // if(this.CHECKLIST.checkedList){
        //   for(var i=0;i<this.CHECKLIST.checkedList.length;i++){
        //     var id = "checkList"+this.CHECKLIST.checkedList[i];
        //     conditionMessage += this.getScopedElementById(id).textContent + '、';
        //   }
        // }
        if(this.inspectCheckBox){
          conditionMessage += this.getScopedElementById("check_all_id").textContent + '、';
        }
        // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
        // add 8486 CSSの修正により、ファイル保存問題が発生  吉 end
        if (conditionMessage != '') {
          if (conditionMessage.charAt(conditionMessage.length - 1) === "、") {
            conditionMessage = conditionMessage.substr(0,conditionMessage.length-1);
          }

          var msg = "帳票のファイル保存が[" + conditionMessage + "]で検索しました。";
          let paramObj = {'message': msg, 'functionName': '帳票'};
          ApiHelper.put("/logs/event/conditionlog", paramObj)
            .catch(error => {
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
              getErrorMessage('ReportMenuListComponent.vue', 'logEventFun', error);
              //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
            });
        }
        await ApiHelper.post(
          "/report_menu/setLogEven",{
            payload: msg
          }
        ).catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add start
          getErrorMessage('ReportMenuListComponent.vue', 'logEventFun', error);
          //FNSI-修正 VUEのエラー場合のログ対応 呉暁鵬 add end
          this.isSearching = false;
        });
      },
      //add  精算時間は治療日と同期している  吉 start
      syntime(){
        if(null != this.getStorSimlpSearchQurey){
          var date = this.getStorSimlpSearchQurey.treatDate;
          if(null != date && "" != date){
            // 期間指定終了の日数取得
            const num = this.dataCondition.rangeEndNum ? Number(this.dataCondition.rangeEndNum) : 0;
            this.dataCondition.fromDate=date;
            this.dataCondition.toDate=dayjs(date).add(num, 'days').format("YYYY-MM-DD");
            this.dataCondition.specifyDate=date;
            this.dataCondition.inspectionDate=date;
          } else {
            // 現在設定されている期間指定の日数を取得
            const oldNum = dayjs(this.dataCondition.toDate).diff(dayjs(this.dataCondition.fromDate), 'days');
            // 期間指定終了の日数が設定されており、現在の期間指定終了の日数と異なる場合
            if (this.dataCondition.rangeEndNum !== undefined && this.dataCondition.rangeEndNum !== oldNum) {
              // 最新の日数と差分がある場合、最新の日数から算出する
              this.dataCondition.toDate=dayjs(this.dataCondition.fromDate).add(this.dataCondition.rangeEndNum, 'days').format("YYYY-MM-DD");
            }
          }
        }
      },
      //add  5605  李明 start
      resetScrollTop(){
        this.$nextTick(()=>{
          this.getScopedElementById("scrollArea").scrollTop = 0
        })
      },
      //add  5605  李明 end
    }
  };
</script>

<style lang="scss" scoped>
//add  5605  李明 start
// mod 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 start
// .custom-modal {
.custom-modal-specialized {
  // mod 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 end
  z-index:9998 !important;
}
//add  5605  李明 end
  div[id^="report-menu"] {
    color: var(--ntss-base-color);
    input,
    select {
      font-size: inherit;
    }
  }

  /** popover */
  .p-container {
    padding: 10px;
  }
  .p-title {
    margin-bottom: 10px;
  }
  .p-button {
    padding: 20px 0 0px 0;
    text-align: right;
  }
  .p-cancel {
    background-color: lightgrey;
    margin-left: 10px;
  }
  .input-large {
    height: 30px;
  }
  /* filter component */
  .filter {
    flex: 0 0 25%;
    min-width: 225px;
  }
  .actions {
    margin-bottom: 0.2em;
    .filter-input-area {
      width: 100%;
      color: var(--ntss-base-color);
      background-color: var(--ntss-base-background-color);
    }
  }
  table.filter-list-table-header {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    th {
      border-right: 1px solid var(--ntss-list-border-color);;
      font-weight: normal;
      text-align: left;
      //del 帳票種別、帳票名にマウスカーソルを合わせると、カーソルのデザインが変わる 4186  吉 start
      /*cursor: pointer;*/
      //del 帳票種別、帳票名にマウスカーソルを合わせると、カーソルのデザインが変わる 4186  吉 end
      color: var(--ntss-header-color);
      background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%) !important;
      background-color: var(--ntss-list-header-background-color);
    }
    tr:not(:last-child) {
      height: 30px;
    }
    td {
      border-right: 1px solid var(--ntss-list-border-color);
      padding: 3px;
    }
  }
  table.filter-list-table-body {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    tr {
      background-color: var(--ntss-list-item-background-color);
    }
    tr:nth-child(2n) {
      background-color: var(--ntss-list-content-2nd-background-color);
    }
    tr:hover {
      background-color: var(--master-maintenance-kgrid-item-hover-background-color);
    }
    tr:not(:last-child) {
      height: 30px;
    }
    td {
      padding: 3px;
      border-bottom: 1px solid var(--ntss-list-border-color);
    }
    td:not(:first-child) {
      border-left: 1px solid var(--ntss-list-border-color);
    }
  }
  .tr-highlight {
    background-color: var(--treatment-record-complaint-selected-background-color) !important;
    color: #ffffff;
  }
  /* patient list component */
  .patient-list {
    margin: 0 10px;
    min-width: 480px;
  }
  .pat-container {
    height: calc(100% - 3em);
    border: 1px solid var(--ntss-list-border-color);
  }
  table.patient-table-header {
    width: 100%;
    table-layout: fixed;
    thead {
      color: var(--ntss-header-color);
      background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
      background-color: var(--ntss-list-header-background-color);
    }
    th{
      border: solid var(--ntss-list-border-color);
      border-width: 0 1px 0 0;
      background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%) !important;
      background-color: var(--ntss-list-header-background-color);
      font-weight: normal;
    }
    th:not(:first-child) {
      text-align: left;
    }
  }
  table.patient-table-body {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    // border: 1px solid var(--ntss-list-border-color);
    tr:not(:last-child) {
      height: 30px;
    }
    td {
      border-bottom: 1px solid var(--ntss-list-border-color);
    }
    tr {
      background-color: var(--ntss-list-item-background-color);
    }
    tr:nth-child(2n) {
      background-color: var(--ntss-list-content-2nd-background-color);
    }
    tr:hover {
      background-color: var(--master-maintenance-kgrid-item-hover-background-color);
    }
    td:not(:first-child) {
      border-left: 1px solid var(--ntss-list-border-color);
    }
  }
  .text-center {
    text-align: center;
  }
  /* scroll table */
  .table-header-wrap {
    overflow-y: scroll;
    background: var(--ntss-list-header-background-color);
    background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
    border-bottom: 1px solid var(--ntss-list-border-color);
  }
  .table-body {
    height: calc(100% - (2em + 3px));
    overflow-y: scroll;
  }
  /*add 5352 登録帳票多数でもスクロールされない 吉 start*/
  .table-body-reprot {
    height: calc(100% - 3em);
    border: 1px solid var(--ntss-list-border-color);
  }
  /*add 5352 登録帳票多数でもスクロールされない 吉 end*/
  /* condition list */
  .filter-list-header-wrap{
    overflow-y: scroll;
    background: var(--ntss-list-header-background-color);
    background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
    border-bottom: 1px solid var(--ntss-list-border-color);
  }

  /* PCのときだけスクロールバーの背景を透明化 */
  @media (hover: hover) and (pointer: fine) {
    .table-header-wrap::-webkit-scrollbar,
    .filter-list-header-wrap::-webkit-scrollbar {
      background: transparent;
    }
  }
  .wrapper-data-condition {
    height: calc(100% - 3em);
    overflow-y: auto;
  }
  .condition {
    flex: 0 0 25%;
    min-width: 245px;
    container-type: inline-size; /* min-widthに達したかを子要素(.col-header)が判定するために必要 */
    fieldset {
      border: 1px solid #b5b5b5;
      border-radius: 8px;
    }
    fieldset legend {
      font-size: inherit;
      color: var(--ntss-base-color);
    }
    .disabled {
      pointer-events: none;
      opacity: 0.6;

    }
    .active {
      opacity: 1;
      pointer-events: all;
    }
  }
  // del FNSI-改修内容5274bug修正 関 start
  // .condition-list label,
  // .condition label {
  //   white-space: nowrap;
  // }
  // del FNSI-改修内容5274bug修正 関 end
  .l-margin {
    margin-left: 10px;
    input {
      margin-left: 0;
    }
  }
  .box-inline {
    display: inline;
    margin-right: 1em;
  }
  .b-margin {
    margin-bottom: 8px;
  }
  .btn-group {
    margin-left: 30px;
    .button {
      margin: 5px 0 0 5px;
      cursor: pointer;
    }
  }
  .btn-width-fix {
    width: 9em !important;
  }
  .condition-list {
    width: 40%;
    display: inline-table;
    margin-right: 0.5em;
    margin-bottom: 2px;
    margin-top: 2px;
  }
  /** modalPreview */
  /*スマホサイズのプレビュー画面  5965  ji  satrt*/
  .modal-preview {
    max-width: 90%;
    height: 90%;
    margin: auto;
    background-color: #fafafa;
    color: #050505;
    padding: 10px;
    overflow: auto;
    display: grid;
    // del 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 start
    /*grid-template-columns: repeat(1, 1fr);*/
    /*grid-auto-rows: calc(100% - 2em) 2em;*/
    // del 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 end
  }
  .modal-content {
    overflow: auto;
    height: 100%;
  }
  @media only screen and (max-width: 735px) {
    .modal-preview {
      width: 350px !important;
      display: block;
      // add 5625 プレビュー画面が縦に2重スクロールになっている。 吉 start
      height: 90vh !important;
      overflow: hidden !important;
      // add 5625 プレビュー画面が縦に2重スクロールになっている。 吉 end
    }
    .modal-content {
      height: calc(100% - 2em);
    }
  }
  /*スマホサイズのプレビュー画面  5965  ji  end*/
  .btn-custom {
    font-size: 1.5em !important;
    cursor: pointer;
  }

  .report-type-div {
    width: 100%;
  }
  .report-type-div label {
    line-height: 22px;
    margin: 0 10px 0 5px;
  }
  .report-type-btn .p-cancel{
    margin: 0 10px 0 0;
  }
  .print-lable {
    border: 1px solid #b5b5b5;
    width: 3.7em;
    height: 1.5em;
    margin-right: 1px;
  }
  .btn-selected {
    background-color: rgb(29, 158, 218);
  }
  .head-table {
    display: flex;
    align-items: center;
    flex-wrap: wrap;
    transform: scale(0.8);
    transform-origin: 0;
  }
  .head-table > * {
    padding: 5px;
  }
  .on-select-input {
    width: 3em;
  }
  .th-titla {
    font-weight: inherit;
    padding-bottom: 3px;
  }
  .th-titla-body {
    font-weight: inherit;
    padding-right: 5px;
  }

  /* add FNSI-改修内容 帳票画面で画面印刷を行うとレイアウトが崩れるの対応 xie start */
  @media print {
    .condition-list {
      white-space:nowrap;
      overflow: hidden !important;
      /*word-break: break-all !important;*/
      /*text-overflow: ellipsis !important;*/
    }
  }
  /* add FNSI-改修内容 帳票画面で画面印刷を行うとレイアウトが崩れるの対応 xie end */
  /* add 5935 スマホサイズで並び替えの表示が切れる場合がある 王永吉 start */
  @media screen and (max-width: 600px){
    ons-radio.radio-button {
      margin-right: 0px !important;
      vertical-align: middle;
      line-height: 0;
    }
  }
  /* add 5935 スマホサイズで並び替えの表示が切れる場合がある 王永吉 end */

  .printer-selection {
    width: 280px;
    margin-left: 10px;
    margin-top: 10px;
  }
  .printer-selection-preview {
    width: 280px;
    margin-left: 10px;
    margin-right: 10px;
    // add 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 start
    font-size: 1.5em;
    // add 9968 asposeを最新バージョンにしたところ表示フォントが変わってしまった　吉 end
  }
  .button-area {
    margin: 10px;
    height: auto;
  }
  .registration-btn-area {
    background: none;
    margin-right: initial;
  }
  .checkbox {
    vertical-align: baseline;
    margin-right: 3px;
  }
  .condition-cart{
    border: solid 1px rgb(138, 138, 138);
    margin-bottom: 0.5em;
  }
  .wrapper-cod-save {
    height: 2.2em;
    display: flex;
    align-items: flex-end;
    flex-flow: wrap;
  }
  .cod-save-btn {
    margin-bottom: 0.2em;
    height: 2em;
    width: auto;
    margin-left: auto;
  }
  .color-header {
    white-space: nowrap;
    display: flex;
    gap: clamp(0px, calc(100cqi - 245px), calc(1em - 6px));
  }
  .clickable-header-label {
    height: 100%;
    width: 100%;
    align-content: center;
    padding: 0 4px;
    white-space: nowrap;
    overflow: hidden;
  }
  .th-td-body {
    width: 22px;
    padding: 0.2px;
  }
</style>
<!--mod 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end-->
