<template>
  <div class="lcd-area">
    <div class="lcd-content">
      <!-- メニュー欄 -->
      <div class="menuGroup">
        <div class="buttonGroup frameGroup" data-toggle="buttons">
          <div style="display: flex;">
            <div class="menuButtonGroup">
              <input type="radio" name="radio2" id="radio-1" v-on:click="menuOnClick(1)" checked />
              <label for="radio-1" class="menu-button">メニュー１</label>
              <input
                v-on:change="inputMenuCheck(1)"
                type="text"
                name="input"
                class="menu-text"
                maxlength="6"
                id="input1"
                v-model="editModel.menuList.menuname1"
              />
            </div>
            <div class="menuButtonGroup">
              <input type="radio" name="radio2" id="radio-2" v-on:click="menuOnClick(2)" />
              <label for="radio-2" class="menu-button">メニュー２</label>
              <input
                v-on:change="inputMenuCheck(2)"
                type="text"
                name="input"
                maxlength="6"
                class="menu-text"
                id="input2"
                v-model="editModel.menuList.menuname2"
              />
            </div>
          </div>
          <div style="display: flex;">
            <div class="menuButtonGroup">
              <input type="radio" name="radio2" id="radio-3" v-on:click="menuOnClick(3)" />
              <label for="radio-3" class="menu-button">検査１</label>
              <input
                v-on:change="inputMenuCheck(3)"
                type="text"
                name="input"
                maxlength="6"
                class="menu-text"
                id="input3"
                v-model="editModel.menuList.menuname3"
              />
            </div>
            <div class="menuButtonGroup">
              <input type="radio" name="radio2" id="radio-4" v-on:click="menuOnClick(4)" />
              <label for="radio-4" class="menu-button">検査２</label>
              <input
                v-on:change="inputMenuCheck(4)"
                type="text"
                name="input"
                maxlength="6"
                class="menu-text"
                id="input4"
                v-model="editModel.menuList.menuname4"
              />
            </div>
          </div>
        </div>
      </div>
      <!-- 区切り線 -->
      <div class="kugiri">
        <label for="menuname" id="menutitlename" v-bind="editModel.menuList.menutitlename"></label>
      </div>
      <!-- 設定欄 -->
      <div class="frameGroup">
        <div class="setting-area">
          <v-ons-select
            v-on:change="selectOnChange(1)"
            name="example"
            class="lcd-select-box"
            input-id="cmb1"
            v-model="editModel.menuList.comboidx1"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(1)"
            type="text"
            name="input1"
            class="edit-text"
            maxlength="12"
            id="settingtext1"
            v-model="editModel.menuList.combotxt1"
          />
          <v-ons-select
            v-on:change="selectOnChange(2)"
            name="example"
            class="lcd-select-box"
            input-id="cmb2"
            v-model="editModel.menuList.comboidx2"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(2)"
            type="text"
            name="input2"
            class="edit-text"
            maxlength="12"
            id="settingtext2"
            v-model="editModel.menuList.combotxt2"
          />
          <v-ons-select
            v-on:change="selectOnChange(3)"
            name="example"
            class="lcd-select-box"
            input-id="cmb3"
            v-model="editModel.menuList.comboidx3"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(3)"
            type="text"
            name="input3"
            maxlength="12"
            class="edit-text"
            id="settingtext3"
            v-model="editModel.menuList.combotxt3"
          />
          <v-ons-select
            v-on:change="selectOnChange(4)"
            name="example"
            class="lcd-select-box"
            input-id="cmb4"
            v-model="editModel.menuList.comboidx4"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(4)"
            type="text"
            maxlength="12"
            name="input4"
            class="edit-text"
            id="settingtext4"
            v-model="editModel.menuList.combotxt4"
          />
        </div>
        <div class="setting-area">
          <v-ons-select
            v-on:change="selectOnChange(5)"
            name="example"
            class="lcd-select-box"
            input-id="cmb5"
            v-model="editModel.menuList.comboidx5"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(5)"
            type="text"
            maxlength="12"
            name="input5"
            class="edit-text"
            id="settingtext5"
            v-model="editModel.menuList.combotxt5"
          />
          <v-ons-select
            v-on:change="selectOnChange(6)"
            name="example"
            class="lcd-select-box"
            input-id="cmb6"
            v-model="editModel.menuList.comboidx6"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(6)"
            type="text"
            name="input6"
            maxlength="12"
            class="edit-text"
            id="settingtext6"
            v-model="editModel.menuList.combotxt6"
          />
          <v-ons-select
            v-on:change="selectOnChange(7)"
            name="example"
            class="lcd-select-box"
            input-id="cmb7"
            v-model="editModel.menuList.comboidx7"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(7)"
            type="text"
            maxlength="12"
            name="input7"
            class="edit-text"
            id="settingtext7"
            v-model="editModel.menuList.combotxt7"
          />
          <v-ons-select
            v-on:change="selectOnChange(8)"
            name="example"
            class="lcd-select-box"
            input-id="cmb8"
            v-model="editModel.menuList.comboidx8"
          >
            <option v-for="lst in editModel.cmbList" :key="lst.no" :value="lst.no">{{ lst.name }}</option>
          </v-ons-select>
          <input
            v-on:change="saveMenuName(8)"
            type="text"
            maxlength="12"
            name="input8"
            class="edit-text"
            id="settingtext8"
            v-model="editModel.menuList.combotxt8"
          />
        </div>
      </div>
    </div>
    <div class="btn-area">
      <div
        class="movePage"
        style="display: table-cell; background:none; border-spacing: 2px 2px; width: 100%; padding-left: 1rem;"
      >
        <div style="display: table-cell;">
          <button class="button btn3-normal" @click="onDefault">規定値</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
// ストアについて
// testStateストアの実体は/stores/modules/test-store.jsである。
// この名前と実体ファイルの関連付けは/stores.store.jsに定義されている。

export default {
  name: "MstComsvSetting",
  data() {
    return {
      selectMenuNo: "1",
      inputModel: {
        comsvCd: "",
        facilityCd: "",
        deviceEdgeNo: "",
        lcdMenu: ""
      },
      editModel: {
        // 検査２設定値
        menuList: {
          menutitlename: "",
          menuname1: "ﾒﾆｭｰ",
          menuname2: "ﾒﾆｭｰ２",
          menuname3: "ーーー",
          menuname4: "Check",
          comboidx1: 1,
          combotxt1: "",
          comboidx2: 2,
          combotxt2: "",
          comboidx3: 3,
          combotxt3: "",
          comboidx4: 4,
          combotxt4: "",
          comboidx5: 5,
          combotxt5: "",
          comboidx6: 6,
          combotxt6: "",
          comboidx7: 7,
          combotxt7: "",
          comboidx8: 8,
          combotxt8: ""
        },
        initMenuList:{},
        // コンボボックス
        cmbList: [
          { no: 0, name: "" },
          { no: 1, name: "愁訴処置" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // { no: 2, name: "穿刺／返血" },
          { no: 2, name: "穿刺/返血" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          { no: 3, name: "酸素吸入" },
          { no: 4, name: "検査結果" },
          // #11148 2024.11.08 add 仮想端末タブの候補不足 TDC高村 start
          { no: 5, name: "血圧・脈拍" },
          // #11148 2024.11.08 add 仮想端末タブの候補不足 TDC高村 end
          { no: 6, name: "ログ" },
          { no: 7, name: "終了予定" },
          { no: 8, name: "体重ﾄﾚﾝﾄﾞ" },
          { no: 9, name: "投与薬剤" },
          { no: 10, name: "抗凝固剤" },
          { no: 12, name: "禁忌" },
          { no: 13, name: "メモ" },
          { no: 14, name: "ｸﾞﾗﾌ1-1" },
          { no: 15, name: "ｸﾞﾗﾌ1-2" },
          { no: 16, name: "ｸﾞﾗﾌ1-3" },
          { no: 17, name: "ｸﾞﾗﾌ1-4" },
          { no: 18, name: "ｸﾞﾗﾌ1-5" },
          { no: 19, name: "ﾚｰﾀﾞｰﾁｬｰﾄ" },
          { no: 20, name: "ｸﾞﾗﾌ2-1" },
          { no: 21, name: "ｸﾞﾗﾌ2-2" },
          { no: 22, name: "ｸﾞﾗﾌ2-3" },
          { no: 23, name: "ｸﾞﾗﾌ2-4" },
          { no: 24, name: "ｸﾞﾗﾌ2-5" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // { no: 25, name: "指示／特記" },
          { no: 25, name: "指示/特記" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          { no: 26, name: "CTRﾄﾚﾝﾄﾞ" },
          { no: 27, name: "透析日報" },
          { no: 28, name: "ﾁｪｯｸﾘｽﾄ-1" },
          { no: 29, name: "ﾁｪｯｸﾘｽﾄ-2" },
          { no: 30, name: "ﾁｪｯｸﾘｽﾄ-3" },
          { no: 31, name: "ﾁｪｯｸﾘｽﾄ-4" },
          { no: 32, name: "ﾁｪｯｸﾘｽﾄ-5" },
          { no: 33, name: "ﾁｪｯｸﾘｽﾄ-6" },
          { no: 34, name: "ﾁｪｯｸﾘｽﾄ-7" },
          { no: 35, name: "ﾁｪｯｸﾘｽﾄ-8" }
        ],
        defaultList: [
          { menuno: 1, settingno: 1, listidx: 1, name: "愁訴処置" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // { menuno: 1, settingno: 2, listidx: 2, name: "穿刺／返血" },
          { menuno: 1, settingno: 2, listidx: 2, name: "穿刺/返血" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          { menuno: 1, settingno: 3, listidx: 3, name: "酸素吸入" },
          { menuno: 1, settingno: 4, listidx: 4, name: "検査結果" },
          { menuno: 1, settingno: 5, listidx: 6, name: "ログ" },
          { menuno: 1, settingno: 6, listidx: 7, name: "終了予定" },
          { menuno: 1, settingno: 7, listidx: 8, name: "体重ﾄﾚﾝﾄﾞ" },
          { menuno: 1, settingno: 8, listidx: 9, name: "投与薬剤" },

          { menuno: 2, settingno: 1, listidx: 10, name: "抗凝固剤" },
          { menuno: 2, settingno: 2, listidx: 12, name: "禁忌" },
          { menuno: 2, settingno: 3, listidx: 13, name: "メモ" },
          { menuno: 2, settingno: 4, listidx: 14, name: "ｸﾞﾗﾌ1-1" },
          { menuno: 2, settingno: 5, listidx: 15, name: "ｸﾞﾗﾌ1-2" },
          { menuno: 2, settingno: 6, listidx: 16, name: "ｸﾞﾗﾌ1-3" },
          { menuno: 2, settingno: 7, listidx: 17, name: "ｸﾞﾗﾌ1-4" },
          { menuno: 2, settingno: 8, listidx: 18, name: "ｸﾞﾗﾌ1-5" },

          { menuno: 3, settingno: 1, listidx: 19, name: "ﾚｰﾀﾞｰﾁｬｰﾄ" },
          { menuno: 3, settingno: 2, listidx: 20, name: "ｸﾞﾗﾌ2-1" },
          { menuno: 3, settingno: 3, listidx: 21, name: "ｸﾞﾗﾌ2-2" },
          { menuno: 3, settingno: 4, listidx: 22, name: "ｸﾞﾗﾌ2-3" },
          { menuno: 3, settingno: 5, listidx: 23, name: "ｸﾞﾗﾌ2-4" },
          { menuno: 3, settingno: 6, listidx: 24, name: "ｸﾞﾗﾌ2-5" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 start
          // { menuno: 3, settingno: 7, listidx: 25, name: "指示／特記" },
          { menuno: 3, settingno: 7, listidx: 25, name: "指示/特記" },
          // #12297 2026.02.03 mod 仮想端末に表示される英数字が全角半角不統一 TDC高村 end
          { menuno: 3, settingno: 8, listidx: 26, name: "CTRﾄﾚﾝﾄﾞ" },

          { menuno: 4, settingno: 1, listidx: 27, name: "透析日報" },
          { menuno: 4, settingno: 2, listidx: 28, name: "ﾁｪｯｸﾘｽﾄ-1" },
          { menuno: 4, settingno: 3, listidx: 29, name: "ﾁｪｯｸﾘｽﾄ-2" },
          { menuno: 4, settingno: 4, listidx: 30, name: "ﾁｪｯｸﾘｽﾄ-3" },
          { menuno: 4, settingno: 5, listidx: 31, name: "ﾁｪｯｸﾘｽﾄ-4" },
          { menuno: 4, settingno: 6, listidx: 32, name: "ﾁｪｯｸﾘｽﾄ-5" },
          { menuno: 4, settingno: 7, listidx: 33, name: "ﾁｪｯｸﾘｽﾄ-6" },
          { menuno: 4, settingno: 8, listidx: 34, name: "ﾁｪｯｸﾘｽﾄ-7" }
        ],
        defaultList2: [],
        defaultMenuName1: "ﾒﾆｭｰ１",
        defaultMenuName2: "ﾒﾆｭｰ２",
        defaultMenuName3: "ーーー",
        defaultMenuName4: "Check",

        menuName1: "ﾒﾆｭｰ１", // メニュー名１保存用
        menuName2: "ﾒﾆｭｰ２", // メニュー名２保存用
        menuName3: "ーーー", // メニュー名３保存用
        menuName4: "Check", // メニュー名４保存用
        textLengh: 0, // 桁数保存用
        selectChangeCmbIdx: 0, // 変更したコンボのインデックス
        selectmenuidx: 0
      }
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterName: "getMasterName",
      schema: "getSchema",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      getFacilitySwitch: "getFacilitySwitch",
    }),
    ...mapGetters("mst-checklist", [
      "getChecklistSetting",
    ])
  },
  methods: {
    ...mapActions("master-maintenance", ["setEditRecord"]),
    ...mapActions("mst-checklist", [
        "fetchMstEquipClassList",
        "fetchCheckSettingList",
    ]),

    getValueByField(field) {
      return this.editRecord[field];
    },

    getSchemaByField(field) {
      return this.schema.model.fields[field];
    },

    updateEditRecord(key, value) {
      this.editRecord[key] = value;
      this.setEditRecord(this.editRecord);
    },
    // 初期設定
    onDefault() {
      this.editModel.defaultList = this.editModel.defaultList2.slice();
      this.editModel.menuName1 = this.editModel.defaultMenuName1;
      this.editModel.menuName2 = this.editModel.defaultMenuName2;
      this.editModel.menuName3 = this.editModel.defaultMenuName3;
      this.editModel.menuName4 = this.editModel.defaultMenuName4;
      this.menuClick(this.editModel.selectmenuidx);
      this.setJsonLcdMenu();
    },
    // メニュー名の入力桁数チェック
    inputMenuCheck(idx) {
      this.inputMenuCheck1(idx);
      this.setJsonLcdMenu();
    },
    // メニュー項目名の入力桁数チェック
    inputMenuNameCheck(idx) {
      this.inputMenuNameCheck1(idx);
    },
    // コンボボックスのチェンジ
    selectOnChange(idx) {
      this.selectChange(idx);
      this.getComboName(idx);
      this.saveMenuName(idx);
    },
    // メニュー項目名の保存
    saveMenuName(idx) {
      this.inputMenuNameCheck1(idx);
      this.inputMenuNameSave(idx);
    },
    // メニューボタンのクリック
    menuOnClick(idx) {
      this.menuClick(idx);
    },
    //メニューの展開処理
    deployLcdMenu(lcdMenu) {
      const idx = this.editModel.selectmenuidx;
      if (lcdMenu) {
        this.editModel.defaultList = [];
        let contact = JSON.parse(lcdMenu);
        this.editModel.menuName1 = contact.menu1_title;
        this.editModel.menuName2 = contact.menu2_title;
        this.editModel.menuName3 = contact.menu3_title;
        this.editModel.menuName4 = contact.menu4_title;
        if (idx == 0 || idx == 1) {
          for (let i = 0; i < 8; i++) {
            this.editModel.defaultList.push({
              menuno: 1,
              settingno: contact.menu1_item[i].no,
              listidx: contact.menu1_item[i].code,
              name: contact.menu1_item[i].name
            });
          }
        }
        if (idx == 0 || idx == 2) {
          for (let i = 0; i < 8; i++) {
            this.editModel.defaultList.push({
              menuno: 2,
              settingno: contact.menu2_item[i].no,
              listidx: contact.menu2_item[i].code,
              name: contact.menu2_item[i].name
            });
          }
        }
        if (idx == 0 || idx == 3) {
          for (let i = 0; i < 8; i++) {
            this.editModel.defaultList.push({
              menuno: 3,
              settingno: contact.menu3_item[i].no,
              listidx: contact.menu3_item[i].code,
              name: contact.menu3_item[i].name
            });
          }
        }
        if (idx == 0 || idx == 4) {
          for (let i = 0; i < 8; i++) {
            this.editModel.defaultList.push({
              menuno: 4,
              settingno: contact.menu4_item[i].no,
              listidx: contact.menu4_item[i].code,
              name: contact.menu4_item[i].name
            });
          }
        }
      }
    },
    // メニュー項目名を保存
    inputMenuNameSave(idx) {
      let pushMenuno = "";
      let pushNo = 0;
      let pushCode = 0;
      let pushName = "";
      let menuidx = this.editModel.selectmenuidx;

      let cmdNo = [];
      cmdNo.push(this.editModel.menuList.comboidx1);
      cmdNo.push(this.editModel.menuList.comboidx2);
      cmdNo.push(this.editModel.menuList.comboidx3);
      cmdNo.push(this.editModel.menuList.comboidx4);
      cmdNo.push(this.editModel.menuList.comboidx5);
      cmdNo.push(this.editModel.menuList.comboidx6);
      cmdNo.push(this.editModel.menuList.comboidx7);
      cmdNo.push(this.editModel.menuList.comboidx8);

      let settingText = [];
      settingText.push(this.editModel.menuList.combotxt1);
      settingText.push(this.editModel.menuList.combotxt2);
      settingText.push(this.editModel.menuList.combotxt3);
      settingText.push(this.editModel.menuList.combotxt4);
      settingText.push(this.editModel.menuList.combotxt5);
      settingText.push(this.editModel.menuList.combotxt6);
      settingText.push(this.editModel.menuList.combotxt7);
      settingText.push(this.editModel.menuList.combotxt8);

      pushMenuno = menuidx;
      pushNo = idx;
      pushCode = Number(cmdNo[idx - 1]);
      pushName = settingText[idx - 1];
      const pushData = {
        menuno: pushMenuno,
        settingno: pushNo,
        listidx: pushCode,
        name: pushName
      };
      this.saveMenuName1(pushData);
      this.setJsonLcdMenu();
    },

    saveMenuName1(payload) {
      this.editModel.defaultList.forEach((list, idx) => {
        if (list.menuno == payload.menuno) {
          if (list.settingno == payload.settingno) {
            this.editModel.defaultList.splice(idx, 1, payload);
            return;
          }
        }
      });
    },

    // コンボボックスの選択
    selectChange(idx) {
      this.editModel.selectChangeCmbIdx = idx;
    },
    // コンボボックスから名称を取得
    getComboName(idx) {
      const objData = {
        idx,
        name
      };
      var cmdidx = 0;
      if (this.editModel.selectChangeCmbIdx == 1) {
        cmdidx = this.editModel.menuList.comboidx1;
      }
      if (this.editModel.selectChangeCmbIdx == 2) {
        cmdidx = this.editModel.menuList.comboidx2;
      }
      if (this.editModel.selectChangeCmbIdx == 3) {
        cmdidx = this.editModel.menuList.comboidx3;
      }
      if (this.editModel.selectChangeCmbIdx == 4) {
        cmdidx = this.editModel.menuList.comboidx4;
      }
      if (this.editModel.selectChangeCmbIdx == 5) {
        cmdidx = this.editModel.menuList.comboidx5;
      }
      if (this.editModel.selectChangeCmbIdx == 6) {
        cmdidx = this.editModel.menuList.comboidx6;
      }
      if (this.editModel.selectChangeCmbIdx == 7) {
        cmdidx = this.editModel.menuList.comboidx7;
      }
      if (this.editModel.selectChangeCmbIdx == 8) {
        cmdidx = this.editModel.menuList.comboidx8;
      }
      this.editModel.cmbList.forEach(function(value) {
        if (value.no == cmdidx) {
          objData.idx = value.no;
          objData.name = value.name;
          return;
        }
      });
    },
    // メニューボタンクリック時の表示処理
    menuClick(idx) {
      this.editModel.selectmenuidx = idx;
      // メニュー項目名を表示
      this.editModel.menuList.menuname1 = this.editModel.menuName1;
      this.editModel.menuList.menuname2 = this.editModel.menuName2;
      this.editModel.menuList.menuname3 = this.editModel.menuName3;
      this.editModel.menuList.menuname4 = this.editModel.menuName4;
      this.editModel.defaultList.forEach(lst => {
        if (lst.menuno == idx) {
          if (lst.settingno == 1) {
            this.editModel.menuList.comboidx1 = lst.listidx;
            this.editModel.menuList.combotxt1 = lst.name;
          }
          if (lst.settingno == 2) {
            this.editModel.menuList.comboidx2 = lst.listidx;
            this.editModel.menuList.combotxt2 = lst.name;
          }
          if (lst.settingno == 3) {
            this.editModel.menuList.comboidx3 = lst.listidx;
            this.editModel.menuList.combotxt3 = lst.name;
          }
          if (lst.settingno == 4) {
            this.editModel.menuList.comboidx4 = lst.listidx;
            this.editModel.menuList.combotxt4 = lst.name;
          }
          if (lst.settingno == 5) {
            this.editModel.menuList.comboidx5 = lst.listidx;
            this.editModel.menuList.combotxt5 = lst.name;
          }
          if (lst.settingno == 6) {
            this.editModel.menuList.comboidx6 = lst.listidx;
            this.editModel.menuList.combotxt6 = lst.name;
          }
          if (lst.settingno == 7) {
            this.editModel.menuList.comboidx7 = lst.listidx;
            this.editModel.menuList.combotxt7 = lst.name;
          }
          if (lst.settingno == 8) {
            this.editModel.menuList.comboidx8 = lst.listidx;
            this.editModel.menuList.combotxt8 = lst.name;
          }
        }
      });
    },
    //
    inputMenuCheck1(idx) {
      if (idx == 1) {
        let strText = this.editModel.menuList.menuname1;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 6) {
          alert("メニュー文字列が6文字を超えています");
        }
      }
      if (idx == 2) {
        let strText = this.editModel.menuList.menuname2;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 6) {
          alert("メニュー文字列が6文字を超えています");
        }
      }
      if (idx == 3) {
        let strText = this.editModel.menuList.menuname3;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 6) {
          alert("メニュー文字列が6文字を超えています");
        }
      }
      if (idx == 4) {
        let strText = this.editModel.menuList.menuname4;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 6) {
          alert("メニュー文字列が6文字を超えています");
        }
      }
      // メニュー名を保存 いらない気が･･･
      this.editModel.menuName1 = this.editModel.menuList.menuname1;
      this.editModel.menuName2 = this.editModel.menuList.menuname2;
      this.editModel.menuName3 = this.editModel.menuList.menuname3;
      this.editModel.menuName4 = this.editModel.menuList.menuname4;
    },
    inputMenuNameCheck1(idx) {
      if (idx == 1) {
        let strText = this.editModel.menuList.combotxt1;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 2) {
        let strText = this.editModel.menuList.combotxt2;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 3) {
        let strText = this.editModel.menuList.combotxt3;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 4) {
        let strText = this.editModel.menuList.combotxt4;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 5) {
        let strText = this.editModel.menuList.combotxt5;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 6) {
        let strText = this.editModel.menuList.combotxt6;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 7) {
        let strText = this.editModel.menuList.combotxt7;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
      if (idx == 8) {
        let strText = this.editModel.menuList.combotxt8;
        this.getStringLength(strText);
        if (this.editModel.textLengh > 12) {
          alert("メニュー項目文字列が12文字を超えています");
        }
      }
    },
    //
    getStringLength(str) {
      var result = 0;
      for (var i = 0; i < str.length; i++) {
        // var chr = str.charCodeAt(i);
        // if (
        //   (chr >= 0x00 && chr < 0x81) ||
        //   chr === 0xf8f0 ||
        //   (chr >= 0xff61 && chr < 0xffa0) ||
        //   (chr >= 0xf8f1 && chr < 0xf8f4)
        // ) {
          //半角文字の場合は1を加算
          result += 1;
        // } else {
        //   //それ以外の文字の場合は2を加算
        //   result += 2;
        // }
      }
      this.editModel.textLengh = result;
    },
    //
    setJsonLcdMenu() {
      let jsondata = "";
      let jsonitem1 = [];
      let jsonitem2 = [];
      let jsonitem3 = [];
      let jsonitem4 = [];
      this.editModel.defaultList.forEach(list => {
        if (list.menuno == "1") {
          let jsonwrk = {
            no: list.settingno,
            code: list.listidx,
            name: list.name
          };
          jsonitem1.push(jsonwrk);
        }
        if (list.menuno == "2") {
          let jsonwrk = {
            no: list.settingno,
            code: list.listidx,
            name: list.name
          };
          jsonitem2.push(jsonwrk);
        }
        if (list.menuno == "3") {
          let jsonwrk = {
            no: list.settingno,
            code: list.listidx,
            name: list.name
          };
          jsonitem3.push(jsonwrk);
        }
        if (list.menuno == "4") {
          let jsonwrk = {
            no: list.settingno,
            code: list.listidx,
            name: list.name
          };
          jsonitem4.push(jsonwrk);
        }
      });
      jsondata = {
        menu1_item: jsonitem1,
        menu2_item: jsonitem2,
        menu3_item: jsonitem3,
        menu4_item: jsonitem4,
        menu1_title: this.editModel.menuName1,
        menu2_title: this.editModel.menuName2,
        menu3_title: this.editModel.menuName3,
        menu4_title: this.editModel.menuName4
      };
      this.updateEditRecord("lcdMenu", JSON.stringify(jsondata));
    },
    // cmbListの作成処理
    async setCmbListName() {
      await this.fetchMstEquipClassList(this.getFacilitySwitch);
      await this.fetchCheckSettingList(this.getFacilitySwitch);

      let c = 0;
      // チェックリストの取得ができていた場合
      if (this.getChecklistSetting != undefined) {
        // cmbListの末尾にある要素の名前をセット
        // #11148 2024.11.08 mod 仮想端末タブの候補不足 TDC高村 start
        //for (let i = 26; i < this.editModel.cmbList.length; i += 1) {
        for (let i = 27; i < this.editModel.cmbList.length; i += 1) {
        // #11148 2024.11.08 mod 仮想端末タブの候補不足 TDC高村 end
          const nm = this.getChecklistSetting[c].list_name;
          // 名前が設定されている場合
          if (nm != "") {
            this.editModel.cmbList[i].name = nm;

          // 名前がない場合は初期値ヘリセット
          } else {
            this.editModel.cmbList[i].name = `ﾁｪｯｸﾘｽﾄ-${c + 1}`;
          }
          c += 1;
        }
      }
      return;
    },
    // mountedから呼び出される処理
    async mountedProc() {
      await this.setCmbListName();
      // 描画系の処理がすべて完了した後に実行される処理
      this.editModel.defaultList2 = this.editModel.defaultList.slice();
      for (const num in this.columnDefinition) {
        if (this.columnDefinition[num].field === "comsvCd") {
          this.inputModel.comsvCd = this.getValueByField(
            this.columnDefinition[num].field
          );
        }
        if (this.columnDefinition[num].field === "facilityCd") {
          this.inputModel.facilityCd = this.getValueByField(
            this.columnDefinition[num].field
          );
        }
        if (this.columnDefinition[num].field === "deviceEdgeNo") {
          this.inputModel.deviceEdgeNo = this.getValueByField(
            this.columnDefinition[num].field
          );
        }
        if (this.columnDefinition[num].field === "lcdMenu") {
          this.inputModel.lcdMenu = this.getValueByField(
            this.columnDefinition[num].field
          );
          //JSONの分解処理を行う
          this.deployLcdMenu(this.inputModel.lcdMenu);
          this.setJsonLcdMenu();
          this.menuClick(1);
        }
      }
      this.initMenuList = JSON.parse(JSON.stringify(this.editModel.menuList));
    },
  },
  mounted() {
    this.mountedProc();
  },
};
</script>
<style scoped>
table {
  margin: 0 auto;
  /*  font-size: 16px; */
}

/*メニューグループ*/
.menuGroup {
  margin: 10px auto;
}

/*メニューボタン*/
.buttonGroup input[type="radio"] {
  display: none;
}
.buttonGroup label {
  display: block;
  font-size: 1em;
  margin: 5px 10px;
  background-color: #999999;
  float: left;
  text-align: center;
}

/*メニューボタン：クリックしたとき色変える*/
.buttonGroup input[type="radio"]:checked + label {
  background-color: #cfcfcf;
}

.frameGroup {
  display: flex;
  flex-wrap: wrap;
  justify-content: center;
}

.menuButtonGroup {
  display: flex;
  flex-direction: column;
  align-items: center;
}

.menu-button {
  width: 123px;
  box-sizing: border-box;
}
.menu-text {
  width: 123px;
  box-sizing: border-box;
}

/* 区切り線*/
.kugiri {
  height: 10px;
  border-top: solid 1px;
  margin-bottom: 10px;
}
/* 設定欄*/
.setting-area {
  display: flex;
  flex-direction: column;
  margin-left: 15px;
}

/* コンボボックス*/
.lcd-select-box {
  font-size: 1em;
  width: 150px;
  margin-bottom: 10px;
}

/* テキストボックス*/
.edit-text {
  font-size: 1em;
  width: 310px;
  margin-bottom: 10px;
}

.btn-area {
  left: 8px;
  bottom: 1px;
  background-color: var(--ntss-base-background-color);
}
.button {
  font-size: 1em;
  line-height: 25px;
}

/*メイン領域*/
.lcd-content {
  overflow-y: auto;
  height: 100%;
}
.lcd-area {
  display: flex;
  flex-direction: column;
  height: 100%;
}
</style>
