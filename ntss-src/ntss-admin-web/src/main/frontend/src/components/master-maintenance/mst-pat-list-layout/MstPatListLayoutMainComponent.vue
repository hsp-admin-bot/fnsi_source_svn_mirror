<!-- マルチ患者レイアウトマスタ詳細 -->

<template>
  <div class="main-area" >
    <!-- レイアウト名設定 -->
    <v-ons-row class="other-area">
      <v-ons-col class="word-border" :style="cateStyle">
        レイアウト名
      </v-ons-col>
      <v-ons-col class="input-length">
        <v-ons-input
          :value="editRecord.name"
          class="input-area"
          @change="changeButton"
          @blur="setLayoutName($event.target.value)"
        />
      </v-ons-col>
    </v-ons-row>

    <!-- テンプレートコンボボックス -->
    <v-ons-row class="other-area">
      <v-ons-col class="word-border" :style="cateStyle">
        テンプレート
      </v-ons-col>
      <v-ons-col>
        <v-ons-select v-model="selectedTemplate" @change="changeButton" style="width: 99.5%">
          <option
            v-for="(t, index) in templateList"
            :key="index"
            :value="t.template_cd"
          >{{ t.template_name }}</option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>

    <!-- 職種設定(ここで設定した職種に該当するログイン者がレイアウトを選択可能となる) -->
    <v-ons-row class="occupation">
      <v-ons-col class="word-border" :style="cateStyle">
        <v-ons-checkbox
          @change="changeButton"
          v-model="isOccupationsCheck"
          @input="checkAllOccupations()"
        />
        職種
      </v-ons-col>
      <v-ons-col class="occupation-branch">
        <v-ons-col
          v-for="(occupation, index) in occupationList"
          :key="index"
          class="word-border"
        >
          <!-- 職種選択用のチェックボックス -->
          <v-ons-checkbox v-model="occupation.useable" @change="changeButton"/>
          <!-- 職種名 -->
          {{ occupation.dispName }}
        </v-ons-col>
      </v-ons-col>
    </v-ons-row>

    <!-- フィルターエリア -->
    <v-ons-row  class="other-area record-search-wrapper" :style="getTheme ? 'background-color:#050505' : 'background-color:#fafafa'">
      <v-ons-col class="word-border" :style="cateStyle">
        フィルタ（項目名）
      </v-ons-col>
      <v-ons-col class="filter-area">
        <v-ons-input
          v-model="searchText"
          class="input-area input-search"
        />
        <v-ons-button
          class="common-style-ok-button btn-search btn3-normal"
          @click="onFilterItems()"
        >検索</v-ons-button>
      </v-ons-col>
    </v-ons-row>

    <!-- 表示項目ヘッダー -->
    <!-- mod redmine 5472【データリストレイアウトマスタ】小窓時の表示不正 宋qy start -->
    <v-ons-row id="header"  class="other-area record-list-wrapper">
    <!-- mod redmine 5472【データリストレイアウトマスタ】小窓時の表示不正 宋qy end -->
      <v-ons-col class="color-header" :style="cateStyle">
        カテゴリ名
      </v-ons-col>
      <v-ons-col class="color-header">
        項目名
      </v-ons-col>
    </v-ons-row>

    <!-- SQLから項目リストの表示 -->
    <dynamic-template
      v-if="selectedTemplate !== PAT_INFO_TEMPLATE_CD && selectedTemplate !== 0"
      ref="child"
      :template-cd="selectedTemplate"
      :cate-style="cateStyle"
      :drag-options="dragOptions"
    />

    <!-- 表示項目設定 -->
    <div class="disp-item-area" v-if="selectedTemplate === PAT_INFO_TEMPLATE_CD">
      <draggable
        v-model="displayItemList"
        :options="{
          ...dragOptions, // ドラッグ方法設定
          handle: '.category-handle' // 結びつけた要素クリック時にdragする
        }"
        @change="changeButton"
        @start="startDragging"
        @end="finishDragging"
      >
        <v-ons-row
          v-for="(column, index) in displayItemList"
          :key="index"
          :class="{ 'layout-category-dragging': isDraggingCategory }"
        >
          <!-- カテゴリ名 -->
          <v-ons-col
            id="category"
            class="word-border"
            valign="top"
            width="40%"
          >
            <!-- カテゴリ名のチェックボックス -->
            <label>
              <v-ons-checkbox
                @change="changeButton"
                v-model="column.isDisp"
                @input="checkAllItem(column)"
              />
              <!-- カテゴリ名 -->
              {{ column.title }}
            </label>
            <!-- ドラッグ用アイコン -->
            <v-ons-icon icon="fa-bars" class="category-handle" />
          </v-ons-col>

          <!-- 項目名 -->
          <v-ons-col>
            <draggable
              v-model="column.categoryItem"
              @change="changeButton"
              :options="{
                ...dragOptions,
                handle: '.column-handle'
              }"
            >
              <template v-for="(item, index2) in column.categoryItem">
                <v-ons-row
                  v-if="item.key !== 'inspection_date_time'"
                  :key="index2"
                  class="word-border"
                  :class="{ 'layout-column-dragging': isDraggingCategory }"
                >
                  <v-ons-col v-if="item.key !== 'inspection_date_time'">
                    <!-- アイコンを右寄せにするため、colで囲う -->
                    <!-- チェックボックス -->
                    <label>
                      <v-ons-checkbox v-model="item.isDisp" @change="changeButton"/>
                      <!-- 項目名 -->
                      {{ item.title }}
                    </label>
                    <!-- ドラッグ用アイコン -->
                    <v-ons-icon icon="fa-bars" class="column-handle" />
                  </v-ons-col>
                </v-ons-row>
              </template>
            </draggable>
          </v-ons-col>
          <!-- 項目名ここまで -->
        </v-ons-row>
      </draggable>
    </div>
    <!-- 表示項目設定ここまで -->

    <message-dialog
      :visible.sync="dailyRegular"
      :message-cd="12000064"
      type="1"
    />
    <message-dialog
      :visible.sync="dailyRegularDefault"
      :message-cd="12000065"
      type="1"
    />
    <message-dialog
      :visible.sync="columnsIndicateItems"
      :message-cd="12000066"
      type="1"
    />

  </div>
</template>

<script>
import _ from "underscore";
import { EventBus } from "@/eventBus.js";
import { mstPatListLayoutDefine } from "@/constants/mstPatListLayoutDefine";
import { mapGetters, mapActions } from "vuex";
import vuedraggable from "vuedraggable";
import { getMstJob } from "@/functions/mst/MstGetters"
import { deepCopy } from "@/functions/common/CommonFunctions";
import DynamicTemplateMasterComponent from "@/components/master-maintenance/mst-pat-list-layout/DynamicTemplateMasterComponent";
import {
  DATE_TEMPLATE_CD,
  MONTH_TEMPLATE_CD,
  TREATMENT_PLAN_TREATMENT_RECORD,
  PAT_INFO_TEMPLATE_CD,
  PAT_INFO_TWO_TEMPLATE_CD,
  VITAL_MONITORS_COMPLAINTS_CD,
  INSPECTION_RADIATION,
  DEVICE_SET,
  COLLECTIVE_DAILY_REGULAR,
  EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY,
  EQUIPMENT_INFORMATION_SELF_DIAGNOSIS,
  EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR
} from "@/constants/dataListConstant";
import {
  COOPERATION
} from "@/constants/cooperationDefine";
import {ApiHelper} from "@/apis/AxiosHelper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

export default {
  components: {
    draggable: vuedraggable,
    "dynamic-template": DynamicTemplateMasterComponent,
    "message-dialog": messageDialog
  },

  data() {
    return {
      //マルチ患者一覧の設定項目
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      // displayItemList: {},
      displayItemList: [],
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
      //職種一覧
      occupationList: [],

      // ドラック時の詳細設定
      dragOptions: {
        animation: 250, //drag時の速度
        forceFallback: true, //trueにすると、draggable用のDnDが作動するようになる
        dragClass: "drag", //ドラッグ時のクラス名
        ghostClass: "ghost" //ドロップ時のクラス名
      },
      //カテゴリをドラッグしているかのフラグ
      isDraggingCategory: false,

      //表示設定画面のカテゴリ横幅
      dispWidth: 0,
      //表示設定画面のヘッダー横幅
      headWidth: 0,
      // テンプレートリスト
      templateList: [
        {
          template_cd: PAT_INFO_TEMPLATE_CD,
          // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 start
          // template_name: '患者情報2'
          template_name: '患者情報1'
          // mod FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 陳 end
        },
        {
          template_cd: PAT_INFO_TWO_TEMPLATE_CD,
          template_name: '患者情報2'
        },
        {
          template_cd: DEVICE_SET,
          template_name: '装置設定'
        },
        {
          template_cd: TREATMENT_PLAN_TREATMENT_RECORD,
          template_name: '治療予定・治療記録'
        },
        {
          template_cd: VITAL_MONITORS_COMPLAINTS_CD,
          template_name: 'バイタル・モニタ・愁訴処置'
        },
        {
          template_cd: INSPECTION_RADIATION,
          template_name: '検査結果'
        },
        {
          template_cd: DATE_TEMPLATE_CD,
          // mod redmine 5175 データリストレイアウトマスタ詳細＞テンプレート選択の選択肢の表示不正(カッコの全角、半角が混在している) 宋 start
          template_name: '集計（日別）'
          // mod redmine 5175 データリストレイアウトマスタ詳細＞テンプレート選択の選択肢の表示不正(カッコの全角、半角が混在している) 宋 end
        },
        {
          template_cd: MONTH_TEMPLATE_CD,
          // mod redmine 5175 データリストレイアウトマスタ詳細＞テンプレート選択の選択肢の表示不正(カッコの全角、半角が混在している) 宋 start
          template_name: '集計（月別）'
          // mod redmine 5175 データリストレイアウトマスタ詳細＞テンプレート選択の選択肢の表示不正(カッコの全角、半角が混在している) 宋 end
        },
        {
          template_cd: EQUIPMENT_INFORMATION_SELF_DIAGNOSIS,
          template_name: '装置情報（自己診断）'
        },
        {
          template_cd: EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR,
          template_name: '装置情報（日常点検・定期点検）'
        },
        {
          template_cd: COLLECTIVE_DAILY_REGULAR,
          template_name: '集計（日常点検・定期点検）'
        },
        {
          template_cd: EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY,
          template_name: '装置情報（水質検査）'
        },
      ],
      selectedTemplate: 0,
      // フィルタ（項目名）検索
      searchText: "",
      originalList: [],
      // 集計(日別)
      DATE_TEMPLATE_CD: DATE_TEMPLATE_CD,
      // 集計(月別)
      MONTH_TEMPLATE_CD: MONTH_TEMPLATE_CD,
      // 治療予定・治療記録
      TREATMENT_PLAN_TREATMENT_RECORD: TREATMENT_PLAN_TREATMENT_RECORD,
      // 患者情報1のコード
      PAT_INFO_TEMPLATE_CD: PAT_INFO_TEMPLATE_CD,
      // 患者情報2のコード
      PAT_INFO_TWO_TEMPLATE_CD: PAT_INFO_TWO_TEMPLATE_CD,
      // バイタル・モニタ・愁訴処置のコード
      VITAL_MONITORS_COMPLAINTS_CD: VITAL_MONITORS_COMPLAINTS_CD,
      // 検査結果
      INSPECTION_RADIATION: INSPECTION_RADIATION,
      // 装置設定
      DEVICE_SET: DEVICE_SET,
      // 集計（日常点検・定期点検）
      COLLECTIVE_DAILY_REGULAR: COLLECTIVE_DAILY_REGULAR,
      // 装置情報（水質検査）
      EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY: EQUIPMENT_INFORMATION_WATER_QUALITY_SURVEY,
      // 装置情報（自己診断）
      EQUIPMENT_INFORMATION_SELF_DIAGNOSIS: EQUIPMENT_INFORMATION_SELF_DIAGNOSIS,
      // 装置情報（日常点検・定期点検）
      EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR: EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR,
      // 治療予定・治療記録 連携コード
      cooperation:COOPERATION,
      dailyRegular: false,
      dailyRegularDefault: false,
      columnsIndicateItems: false,
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      initOccupationList: [],
      initDisplayItemList: [],
      initEditRecord: {},
      initDisplayItemFlag: true,
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      isOccupationsCheck: false,
    };
  },

  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("master-maintenance", { editRecord: "getEditRecord" }),
    ...mapGetters("window-size", {windowHeight: "getWindowHeight",}),
    ...mapGetters("account-edit", {getStateUserAccountInfo: "getStateUserAccountInfo",getFontSize :"getFontSize", getTheme: "getTheme"}),
    ...mapGetters("pat-list-layout", ["getOriginalList"]),

    //各項目のヘッダーのwidthを、表示項目設定のカテゴリの幅に合わせる
    cateStyle() {
      //指定するwidthの%を計算(カテゴリの幅/カテゴリと項目の幅)
      // mod redmine 5472【データリストレイアウトマスタ】小窓時の表示不正 宋qy start
      let width = (this.dispWidth / this.headWidth) * 100;
      if (isNaN(width)) {
        width = 40;
      }
      // mod redmine 5472【データリストレイアウトマスタ】小窓時の表示不正 宋qy end
      //widthを設定
      return `flex: 0 0 ${width}%; max-width: ${width}%;`;
    }
  },

  watch: {
    windowHeight() {
      this.adaptiveHeight();
    },
    getFontSize()  {
      this.adaptiveHeight();
    },
    /**
     * @description マルチ患者一覧の設定項目チェックボックス監視処理
     */
    displayItemList: {
      handler(categories) {
        // カテゴリ名・項目名のチェックボックスを対応させる
        this.connectingItemDisp();
        // ストアにチェックを入れた項目を格納
        this.setDispItemInfo(categories);
      },
      deep: true
    },

    /**
     * @description 職種一覧のチェックボックス監視処理
     */
    occupationList: {
      handler(occupationArray) {
        // 職種・項目のチェックボックスを対応させる
        this.connectingOccupationDisp();
        // ストアにチェックを入れた職種を格納
        this.setOccupations(occupationArray);
      },
      deep: true
    },

    /**
     * @description 選択したテンプレート処理
     */
    selectedTemplate: {
      handler(id) {
        this.searchText = "";
        this.setTemplateId(id);
      },
      deep: true
    },
    //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
    editRecord: {
      handler() {
        this.changeButton();
      },
      deep: true
    }
    //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
  },

   async created() {
     this.setLoadingScreenVisible(true);

    // add マスタ一覧 施設切替を可能とする 王 start
    // let userFacilityCd = this.getStateUserAccountInfo.facilityCd;
    let userFacilityCd = this.getFacilitySwitch;
    // add マスタ一覧 施設切替を可能とする 王 end
    const mstJob = await getMstJob(userFacilityCd);
    if (mstJob) {
      this.occupationList = mstJob.map(occupation => {
        return {
          keyName: occupation.jobCd,
          dispName: occupation.jobName,
          useable: false
        }
      });
      // 先頭に「未登録」を追加
      this.occupationList.unshift({
        keyName: -1,
        dispName: '未登録',
        useable: false
      });
    }
    /**
     * @description 設定している職種にチェックを入れる処理
     */
    //設定された職種のキー名一覧を取得
    const useableUsers = this.editRecord.occupations;

    //設定されている職種があれば、チェックを入れる
    if (useableUsers) {
      //設定されている職種一覧を配列に変換
      const userArray = JSON.parse(useableUsers);

      //設定されている職種分、判定処理
      for (const key of userArray) {
        //職種一覧のそれぞれの項目にチェック入れるか確認
        this.occupationList.forEach(occupation => {
          //key名が同じか判定
          if (occupation.keyName === key) {
            //チェックを入れる
            occupation.useable = true;
          }
        });
      }
    }
    if (this.editRecord.templateCd === 0 || !this.editRecord.templateCd) {
      // デフォルトテンプレート格納
      this.selectedTemplate = PAT_INFO_TEMPLATE_CD;
      this.setTemplateId(this.selectedTemplate);
    } else {
      this.selectedTemplate = this.editRecord.templateCd;
    }

    /**
     * @description マルチ患者一覧の設定項目に表示フラグを付与し、表示設定された項目はストアに格納された順番で画面に表示
     */
    /*新規登録か否か確認*/
    if (!this.editRecord.dispItemInfo || this.editRecord.dispItemInfo.length === 0) {
      //全ての項目のチェックを外す
      this.removeCheck();
      //職種を全件チェック
      this.occupationsChecked();
    } else {
      //ストアに格納してある、表示項目リストを取得(各カテゴリと表示する項目のみ格納されている)
      const dispCategoryList = JSON.parse(this.editRecord.dispItemInfo);
      /*ストアの表示項目リストが存在しているか判定*/
      if (dispCategoryList.length === 0) {
        //全ての項目のチェックを外す
        this.removeCheck();
      } else {
        //表示設定されたカテゴリオブジェクト一覧
        const checkedItemList = [];
        //表示設定されたカテゴリオブジェクト一覧
        const sortCheckedItemList = [];
        //表示設定されていないカテゴリオブジェクト一覧
        const uncheckedItemList = [];

        /*マルチ患者一覧の設定項目を全てを展開(チェック有無を判定する)*/
        for (const multiPatDefine of mstPatListLayoutDefine) {
          // カテゴリのkey名を取得
          const multiComponent = multiPatDefine.key;
          // 表示設定されている項目か否かの判別フラグ
          let dispCategoryFlag = false;

          /*カテゴリ毎に表示フラグを付与するか確認*/
          for (const dispCategory of dispCategoryList) {
            //カテゴリkey名を取得
            const dispCategoryKey = dispCategory.category;
            //表示設定された項目のkey名一覧を取得
            const dispColumnList = dispCategory.items;

            /*表示設定されている項目があるカテゴリの場合*/
            if (multiComponent === dispCategoryKey) {
              //表示設定された項目一覧
              const checkedColumnList = [];
              //表示設定された項目の順序を整えたリスト
              const sortCheckedColumnList = [];
              //表示設定されていない項目一覧
              const uncheckedColumnList = [];

              /*チェック有無を入れる*/
              multiPatDefine.categoryItem.forEach(item => {
                //項目key名
                const keyName = item.key;

                //項目key名が表示設定されているか否かを判定
                const dispFlag = dispColumnList.some(
                  dispKey => keyName === dispKey
                );
                // チェック有無を入れる
                item.isDisp = dispFlag;

                /*チェック有無によって異なるリストに格納*/
                if (dispFlag) {
                  checkedColumnList.push(item);
                } else {
                  uncheckedColumnList.push(item);
                }
              });

              /*表示設定された項目一覧を、ストアに格納された項目の順番に合わせる*/
              dispColumnList.forEach(dispColumn => {
                for (let i = 0; i < checkedColumnList.length; i++) {
                  //表示設定された項目のkey名を取得
                  const checkedColumn = checkedColumnList[i];

                  //項目key名が同じ場合
                  if (dispColumn === checkedColumn.key)
                    //ストアに格納された順にリストに格納
                    sortCheckedColumnList.push(checkedColumn);
                }
              });

              /*チェック有無を入れた配列を合体して保持*/
              multiPatDefine.categoryItem = sortCheckedColumnList.concat(
                uncheckedColumnList
              );
              /*表示設定された項目カテゴリ一覧に格納*/
              checkedItemList.push(multiPatDefine);

              /*判定フラグを変更*/
              dispCategoryFlag = true;
            }
          }
          /*表示設定されている項目がないカテゴリの場合*/
          if (!dispCategoryFlag) {
            //表示設定されてないカテゴリの全ての項目のチェックボックスを外す
            multiPatDefine.categoryItem = multiPatDefine.categoryItem.map(
              item => {
                return { ...item, isDisp: false };
              }
            );
            //表示設定されていない項目カテゴリ一覧に格納
            uncheckedItemList.push(multiPatDefine);
          }
        }

        /*表示設定されたカテゴリ一覧を、ストアに格納されたカテゴリの順番に合わせる*/
        dispCategoryList.forEach(dispCategory => {
          for (let i = 0; i < checkedItemList.length; i++) {
            //表示設定された項目のkey名を取得
            const checkedCategory = checkedItemList[i];

            //項目key名が同じ場合
            if (dispCategory.category === checkedCategory.key)
              //ストアに格納された順にリストに格納
              sortCheckedItemList.push(checkedCategory);
          }
        });
        /*2つのリストを合わせて、チェック有無判定を終えたリストを取得*/
        this.displayItemList = sortCheckedItemList.concat(uncheckedItemList);
        this.originalList = deepCopy(this.displayItemList);
      }
    }

    /**
     * @description 画面サイズで各項目の横幅を変えるようイベントを設定
     */
    window.addEventListener("resize", this.resizeWidth);

    let mstMainteLayoutData;
    let mstMainteLayoutGroupData;
    await ApiHelper.get(
       `/master_maintenance/${'mst_mainte_layout'}/data/${this.getFacilitySwitch}`
     ).then(response => {
       mstMainteLayoutData = response.data.localDataSource.data
     });

     await ApiHelper.get(
       `/master_maintenance/${'mst_mainte_layout_group'}/data/${this.getFacilitySwitch}`
     ).then(response => {
       mstMainteLayoutGroupData = response.data.localDataSource.data
     });
     //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
     await this.setInitData()
     //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
     mstMainteLayoutData = mstMainteLayoutData.filter(data => data.layoutClass === "1")

     if (mstMainteLayoutData.length === 0 && mstMainteLayoutGroupData.length === 0) {
       this.templateList = this.templateList.filter(data => data.template_cd !== 12)
     }
  },
  destroyed() {
    //イベントリスナーを手放してメモリを開放
    this.setPrevEditRecord([]);
    this.setOriginalList([]);
    window.removeEventListener("resize", this.resizeWidth);
  },

  mounted() {
    //画面生成が完了後、各項目の横幅を設定
    this.resizeWidth();

    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
      this.setLoadingScreenVisible(false);
    }, 200);
  },

  updated() {
    this.$nextTick(() => {
      this.adaptiveHeight();
    });
  },

  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("pat-list-layout", ["setPrevEditRecord", "setOriginalList"]),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    /**
     * @description ドラッグを始めた際と終えた際の処理
     */
    startDragging() {
      //項目を非表示にする
      this.isDraggingCategory = true;
    },
    finishDragging() {
      //項目を表示する
      this.isDraggingCategory = false;
    },

    /**
     * @description 表示項目の全てのチェックを外す処理
     */
    removeCheck() {
      //マルチ患者一覧の設定項目を定義ファイルから取得(全ての項目を取得)
      this.displayItemList = mstPatListLayoutDefine;

      //すべての項目のチェックボックスを外す
      this.displayItemList.forEach(category => {
        category.categoryItem = category.categoryItem.map(item => {
          return { ...item, isDisp: false };
        });
      });

      this.originalList = deepCopy(this.displayItemList);
    },

    /**
     * @description 職種を全選択する処理
     */
    occupationsChecked() {
      //職種毎のチェックボックスをON
      this.occupationList.forEach(item => {
        item.useable = true;
      });
    },

    /**
     * @description レイアウト名変更の処理
     * @param 変更後のレイアウト名
     */
    setLayoutName(value) {
      //変更後のレイアウト名をストアに格納
      const layoutName = value;
      this.setEditRecord({ ...this.editRecord, name: layoutName });
      // データリストレイアウトマスタ：缺少レイアウト名长度check 林峻峰 start
      if (value.length > 50) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200101'].title,
          message: messageFormat(DIALOG_MESSAGES['00200101'].message)
        });
        EventBus.$emit("mstHolidayRegistered", true);
        return;
      }
      // データリストレイアウトマスタ：缺少レイアウト名长度check 林峻峰 end
    },

    /**
     * @description 職種選択時の処理
     * @param 選択された職種
     */
    setOccupations(occupationArray) {
      //ストアに格納するデータリスト
      const saveInfo = [];

      //チェックした職種のkey名を取得する処理
      occupationArray.forEach(occupation => {
        // チェックを入れたか判定
        if (occupation.useable) {
          //職種のキー名を取得
          const checkedItemArray = occupation.keyName;

          //チェックした職種のkey名をリストに格納
          saveInfo.push(checkedItemArray);
        }
      });

      //保存するデータをJson形式に変換し、ストアに格納
      const saveInfoJson = JSON.stringify(saveInfo);

      this.setEditRecord({ ...this.editRecord, occupations: saveInfoJson });
    },

    /**
     * @description カテゴリと項目のチェックボックスを関連させる処理
     *  カテゴリの表示が1つもない場合、それが属するカテゴリを非表示に切り替える
     */
    connectingItemDisp() {
      this.displayItemList.forEach(category => {
        //項目が1つでも選択されているかの判定フラグ
        let categoryCheck = false;

        category.categoryItem.forEach(item => {
          //項目のチェックボックス
          const itemCheck = item.isDisp;
          //項目が1つでもチェックされていれば、カテゴリにチェックを付ける
          categoryCheck = itemCheck ? itemCheck : categoryCheck;
        });
        // カテゴリのチェック有無を保持
        category.isDisp = categoryCheck;
      });
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      if(this.initDisplayItemFlag){
        this.initDisplayItemList = JSON.parse(JSON.stringify(this.displayItemList));
        this.initDisplayItemFlag = false;
      }
      //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
    },

    /**
     * @description 職種と項目のチェックボックスを関連させる処理
     */
    connectingOccupationDisp() {
      // 職種が一つでも選択されている場合は職種全件チェックボックスをON / それ以外の場合はOFF 
      this.isOccupationsCheck = false;
      this.occupationList.forEach(item => {
        if(item.useable) {
          this.isOccupationsCheck = true;
        }
      });
    },

    /**
     * @description チェックを入れた項目をストアに格納する処理
     * @param マルチ患者一覧の設定項目
     */
    setDispItemInfo(categories) {
      //ストアに格納するデータリスト
      const saveInfo = [];

      //各カテゴリのkey名とチェックした項目のkey名を取得する処理
      this.displayItemList.forEach(column => {
        //カテゴリkey名を取得
        const categoryKey = column.key;

        // チェックを入れた項目を抽出
        const checkedItem = column.categoryItem.filter(
          item => item.isDisp === true
        );

        this.mappingCheckedItems(categoryKey, checkedItem);

        //チェックを入れた項目が存在する場合はリストに格納
        if (checkedItem.length > 0) {
          //抽出した項目のkey名を取得しリストに追加
          const checkedItemArray = checkedItem.map(item => {
            return item.key;
          });

          //保存するデータを作成し、リストに格納
          const dispInfo = {
            category: categoryKey,
            items: checkedItemArray
          };
          saveInfo.push(dispInfo);
        }
      });

      //保存するデータをJson形式に変換し、ストアに格納
      const saveInfoJson = JSON.stringify(saveInfo);
      if (this.selectedTemplate === PAT_INFO_TEMPLATE_CD) {
        this.setEditRecord({ ...this.editRecord, dispItemInfo: saveInfoJson });
      }
    },

    /**
     * @description カテゴリのチェックボックスを押した際の処理
     *  カテゴリに属する項目のチェックボックスにtrue/falseを入れる
     * @param チェックしたカテゴリ
     */
    checkAllItem(column) {
      //チェックボックスをクリックする前の状態を取得
      const categoryDisp = column.isDisp;

      //チェックを入れたなら、属する項目全てにチェックを入れる。外したなら全て外す
      column.categoryItem.forEach(item => {
        item.isDisp = !categoryDisp;
      });
    },

    /**
     * @description 職種のチェックボックスを押した際の処理
     *  職種に属する項目のチェックボックスにtrue/falseを入れる
     */
    checkAllOccupations() {
      //チェックボックスをクリックする前の状態を取得
      const check = this.isOccupationsCheck;

      //チェックを入れたなら、属する項目全てにチェックを入れる。外したなら全て外す
      this.occupationList.forEach(item => {
        item.useable = !check;
      });
    },

    resizeWidth() {
      if (this.selectedTemplate !== PAT_INFO_TEMPLATE_CD) return;
      //表示項目設定画面のカテゴリの幅を取得
      const category = document
        .getElementById("category")
        .getBoundingClientRect();
      this.dispWidth = category.width;

      //表示項目設定画面のカテゴリ+項目の幅を取得
      const header = document.getElementById("header").getBoundingClientRect();
      this.headWidth = header.width;
    },

    setTemplateId(id) {
      if (id !== 0) {
        this.setEditRecord({ ...this.editRecord, templateCd: id });
      }
    },

    onFilterItems() {
      const text = this.searchText.toLowerCase();
      if (this.selectedTemplate !== PAT_INFO_TEMPLATE_CD) {
        EventBus.$emit("filterItems", text);
        return;
      }

      let copyList = deepCopy(this.originalList);

      if (!text) {
        this.displayItemList = deepCopy(copyList);
        return;
      }
      copyList.forEach(category => {
        category.categoryItem = category.categoryItem.filter(item =>
          item.title.toLowerCase().includes(text)
        );
      });
      copyList = copyList.filter(category => {
        return category.title.toLowerCase().includes(text) || category.categoryItem.length > 0;
      });
      this.displayItemList = deepCopy(copyList);
    },

    mappingCheckedItems(key, checkedItems) {
      if (checkedItems.length === 0) return;

      const oriCategoryIndex = this.originalList.findIndex(oriCategory => oriCategory.key === key);

      if (oriCategoryIndex === -1) return;

      checkedItems.forEach(checkItem => {
        const oriItemIndex = this.originalList[oriCategoryIndex].categoryItem.findIndex(oriItem => oriItem.key === checkItem.key);
        if (oriItemIndex >=0) {
          this.originalList[oriCategoryIndex].isDisp = true;
          this.originalList[oriCategoryIndex].categoryItem[oriItemIndex] = checkItem;
        }
      })
    },
    /**
     * 入力データの検証チェック
     */
    validateOnRegistration(){
      // データリストレイアウトマスタ：缺少レイアウト名长度check 林峻峰 start
      if (this.editRecord.name.length > 50) {
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES['00200101'].title,
          message: messageFormat(DIALOG_MESSAGES['00200101'].message)
        });
        return;
      }
      // データリストレイアウトマスタ：缺少レイアウト名长度check 林峻峰 end
      if (this.editRecord.templateCd === EQUIPMENT_INFORMATION_INSPECTION_DAILY_REGULAR) {
        let saveInfo = JSON.parse(this.editRecord.dispItemInfo);

        // 日常点検出力対象
        let inspectionItem = 0;
        // 定期点検出力対象
        let inspectionType = 0;
        // 点検種別（定期点検専用）
        let inspectionOnly = 0;
        // 列表示項目
        let columnsIndicate = 0;

        for (let i = 0; i < saveInfo.length; i++) {
          if (saveInfo[i].data_list_detail_cd === 1390) {
            inspectionItem++;
          }
          if (saveInfo[i].data_list_detail_cd === 1391) {
            inspectionType++;
          }
          if (saveInfo[i].data_list_detail_cd === 1393 || saveInfo[i].data_list_detail_cd === 1394) {
            inspectionOnly++;
          }
          if (saveInfo[i].data_list_detail_cd === 1397 || saveInfo[i].data_list_detail_cd === 1396 || saveInfo[i].data_list_detail_cd === 1395) {
            columnsIndicate++;
          }

        }

        if ((inspectionItem + inspectionType) === 0) {
          this.dailyRegular = true;
          return false;
        }

        if (inspectionType > 0 && inspectionOnly === 0) {
          this.dailyRegularDefault = true;
          return false;
        }

        if (columnsIndicate === 0) {
          this.columnsIndicateItems = true;
          return false;
        }

      }

      // add チェックするときに応答が遅いことを対応 劉 start
      if (this.editRecord.templateCd !== PAT_INFO_TEMPLATE_CD){
        this.$refs.child.setStoreValue();
      }
      // add チェックするときに応答が遅いことを対応 劉 end
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        this.setDispItemInfo(this.originalList);
        if (this.selectedTemplate !== PAT_INFO_TEMPLATE_CD) {
          this.setDispItemInfoForDynamicTemplate(this.getOriginalList);
        }
        return true;
      }

      let message = "";
      if (!validationResult.isSelectedOccupation) {
        // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "職種を選んでください。";
        message = messageFormat(DIALOG_MESSAGES['00200091'].message);
        // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      } else if (!validationResult.isSelectedDisplayItem) {
        // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "項目を選んでください。";
        message = messageFormat(DIALOG_MESSAGES['00200059'].message);
        // add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }

      this.$ons.notification.alert({
        title: DIALOG_MESSAGES['00200091'].title,
        message: message
      });

      return false;
    },

    validateData() {
      const isSelectedOccupation = this.occupationList.some(occupation => occupation.useable);
      let isSelectedDisplayItem = this.originalList.some(category => category.categoryItem.some(item => item.isDisp));
      if (this.editRecord.templateCd !== PAT_INFO_TEMPLATE_CD) {
        if (this.getOriginalList.length === 0) {
          isSelectedDisplayItem = false;
        } else {
          isSelectedDisplayItem = this.getOriginalList.some(category => category.categoryItem.some(item => item.isChecked));
        }
      }

      return {
        isSelectedOccupation,
        isSelectedDisplayItem
      }
    },

    setDispItemInfoForDynamicTemplate(categories) {
      let listDataListItem = [];
      const saveInfo = [];
      categories.forEach(column => {
        listDataListItem.push(column.categoryItem);
      });
      listDataListItem = _.flatten(listDataListItem);

      // 全てのチェックした項目をフィルタする。
      const listDataListItemChecked = listDataListItem.filter(l => l.isChecked);

      const listDataListDetailCd = [];
      if (listDataListItemChecked.length > 0) {
        listDataListItemChecked.forEach(item => {
          const dataListDetailCd = item.dataListDetailCd;
          if (listDataListDetailCd.includes(dataListDetailCd)) {
            return;
          }
          listDataListDetailCd.push(dataListDetailCd);
          // 指定されたデータリスト詳細コードに該当する項目をフィルタする。
          const listItems = listDataListItemChecked.filter(
            i => i.dataListDetailCd === dataListDetailCd
          );
          if (!listItems || listItems.length === 0) {
            return;
          }
          let items = [];
          listItems.forEach(itemDetail => {
            // mod redmine バイタル・モニタ項目追加マスタ改修成name 宋qy start
            // mod #10077 by zhangruixue 2024-01-03 --start
            // if (itemDetail.dataListDetailCd == "1095" || itemDetail.dataListDetailCd == "1097") {
            //   items.push(itemDetail.name);
            // } else {
            //   items.push(itemDetail.id);
            // }
            if (itemDetail.dataListDetailCd == "1095" || itemDetail.dataListDetailCd == "1097") {
              items.push(10000 + itemDetail.id + "");
            } else {
              items.push(itemDetail.id);
            }
            // mod #10077 by zhangruixue 2024-01-03 --start
            // mod redmine バイタル・モニタ項目追加マスタ改修成name 宋qy end
          });
          items = Array.from(new Set(items));
          const dispInfo = {
            items,
            data_list_detail_cd: dataListDetailCd
          };
          saveInfo.push(dispInfo);
        });
      }
      //#5905項目連携取消----------------------注釈が落ちる   ljg
      // for (const addition of this.cooperation) {
      //   let index = saveInfo.findIndex(e => e.data_list_detail_cd == addition.detail_cd)
      //   if (index++ !== -1) {
      //     for (let i = 1; i <= addition.cooperation_num; i++) {
      //       saveInfo.splice(index++,
      //         0,
      //         {
      //           "items": [0],
      //           "data_list_detail_cd": (addition.detail_cd * 10) + i
      //         })
      //     }
      //   }
      // }
      const saveInfoJson = JSON.stringify(saveInfo);
      this.setEditRecord({ ...this.editRecord, dispItemInfo: saveInfoJson });
    },

    adaptiveHeight(){
      // let mainArea = document.getElementsByClassName("main-area")[0].clientHeight
      // let otherArea1 = document.getElement1!sByClassName("other-area")[0].clientHeight
      // let otherArea2 = document.getElementsByClassName("other-area")[1].clientHeight
      // let otherArea3 = document.getElementsByClassName("other-area")[2].clientHeight
      // let otherArea4 = document.getElementsByClassName("other-area")[3].clientHeight
      // let occupation = document.getElementsByClassName("occupation")[0].clientHeight
      // let dispItemArea = document.getElementsByClassName("disp-item-area")
      // dispItemArea[0].style.height = (mainArea -  occupation - otherArea1 - otherArea2 - otherArea3 - otherArea4) + 'px'
    },
    changeButton() {
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
      if ((this.initOccupationList.length > 0 && this.initDisplayItemList.length > 0 && Object.keys(this.initEditRecord).length > 0) &&
          (JSON.stringify(this.occupationList).replace(/\s/g, '') !== JSON.stringify(this.initOccupationList).replace(/\s/g, '')
          || JSON.stringify(this.displayItemList).replace(/\s/g, '') !== JSON.stringify(this.initDisplayItemList).replace(/\s/g, '')
          || JSON.stringify(this.editRecord).replace(/\s/g, '') !== JSON.stringify(this.initEditRecord).replace(/\s/g, ''))) {
        EventBus.$emit("mstHolidayRegistered", false);
      } else {
        EventBus.$emit("mstHolidayRegistered", true);
      }
      //mod #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
    },
    //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
    setInitData(){
      this.initOccupationList = JSON.parse(JSON.stringify(this.occupationList));
      this.initDisplayItemList = JSON.parse(JSON.stringify(this.displayItemList));
      this.initEditRecord = JSON.parse(JSON.stringify(this.editRecord));
    }
    //add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
  },
};
</script>
<style scoped>
.main-area {
  box-sizing: border-box;
  overflow-y: auto;
}

.left-area {
  flex: 0 0 40%;
  max-width: 40%;
}

.input-area {
  padding: 2px 0;
  width: 99.5%;
}
.record-search-wrapper {
  position: sticky;
  top: -0.4em;
  z-index: 1;
}

.record-list-wrapper {
  position: sticky;
  --top: 1.9em;
  top: var(--top);
  z-index: 1;
}
.word-border {
  border: 1px solid #d3d3d3;
  padding: 2px;
}

/* ドロップしている要素 */
.ghost {
  opacity: 0.5;
}
/* ドラッグしている要素*/
.drag {
  display: none;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
.category-handle,
.column-handle {
  cursor: move;
  float: right;
}

.disp-item-area {
  display: block;
  overflow-y: hidden;
}

/* カテゴリをドラック時、カテゴリの欄を小さくする*/
.layout-category-dragging {
  height: 30px;
}

/* カテゴリをドラック時、項目を見えなくする*/
.layout-column-dragging {
  display: none;
}

ons-row {
  height: auto;
}

.input-search {
  width: 85%;
}
.filter-area {
  display: flex;
  align-items: center;
}
.btn-search {
  min-width: 50px;
  margin-left: auto;
  width: 14%;
  background-image: linear-gradient(#B1CBD8 0%,#3D82A5 50%,#3D82A5 50%,#377B9E 100%);
}

</style>
