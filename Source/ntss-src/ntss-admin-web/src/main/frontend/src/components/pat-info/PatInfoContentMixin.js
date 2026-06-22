import { publicAssetPath } from "@/compat/assets/public-path";
import { getScopedElementById, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
/**
 * @description 患者情報・新規患者登録画面のカード一覧用のMixin
 * @summary
 *   ■機能
 * 　　・患者情報・新規患者登録画面のカード一覧のメニューバーの開閉
 */
// 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
export default {
  data() {
    return {
      imgUrl: "",
      direction: null,
      // 患者情報・新規患者登録毎の患者情報カード一覧のスクロール位置
      cardListScrollPos: 0,
      isMenuBarShowing: true,
      // 患者情報カード一覧メニューバーが閉じているかどうか
      menuBarClosing: false,
      // 患者情報カード一覧のスクロール位置を調整する
      cardListScrollPosAdjusting: false,
    };
  },
  created() {
    this.direction = "left";
    this.cardListScrollPos = this.getCardListScrollPos(this.cardListName);
  },
  beforeUnmount() {
    this.updateCardListScrollPos();
  },
  watch: {
    getTheme(val) {
      if (val === 0) {
        if (this.direction === "left") {
          this.imgUrl = publicAssetPath("img/pat-info/left_w.png");
        } else if (this.direction === "right") {
          this.imgUrl = publicAssetPath("img/pat-info/right_w.png");
        }
      } else if (val === 1) {
        if (this.direction === "left") {
          this.imgUrl = publicAssetPath("img/pat-info/left_b.png");
        } else if (this.direction === "right") {
          this.imgUrl = publicAssetPath("img/pat-info/right_b.png");
        }
      }
    },
    // 患者情報カード一覧メニューバー開閉ボタンのアイコン設定
    direction(val) {
      if (val === "left") {
        if (this.getTheme === 0) {
          this.imgUrl = publicAssetPath("img/pat-info/left_w.png");
        } else if (this.getTheme === 1) {
          this.imgUrl = publicAssetPath("img/pat-info/left_b.png");
        }
      } else if (val === "right") {
        if (this.getTheme === 0) {
          this.imgUrl = publicAssetPath("img/pat-info/right_w.png");
        } else if (this.getTheme === 1) {
          this.imgUrl = publicAssetPath("img/pat-info/right_b.png");
        }
      }
    },
    // 患者情報・新規患者登録毎のメニューバーが閉じている
    menuBarClosing(val) {
      if (val) {
        this.closeMenuBar();
        this.menuBarClosing = false;
      }
    },
    // 患者情報カード一覧のスクロール位置を調整する
    cardListScrollPosAdjusting(val) {
      if (val) {
        const el = this.$refs.cardListDiv;
        if (el) {
          el.scrollTop = this.cardListScrollPos;
        }
        this.cardListScrollPosAdjusting = false;
      }
    }
  },
  methods: {
    getPatInfoLayoutRoot() {
      return typeof this.getNtssLayoutRootElement === "function"
        ? this.getNtssLayoutRootElement()
        : (this.$el || null);
    },
    getPatInfoElementById(id) {
      return getScopedElementById(id, this.getPatInfoLayoutRoot());
    },
    getPatInfoFirstByClassName(className) {
      return getScopedElementsByClassName(className, this.getPatInfoLayoutRoot())[0]
        || null;
    },
    // 患者情報カード一覧メニューバーの開閉
    menuDisplay() {
      const elMenuBar = this.getPatInfoElementById("menu-bar-id");
      if (!elMenuBar) {
        return;
      }
      if (elMenuBar.classList.contains("block")) {
        this.closeMenuBar();
        this.isMenuBarShowing = false;
      } else {
        this.openMenuBar();
        this.isMenuBarShowing = true;
      }
    },
    // 患者情報カード一覧メニューバーを開く
    openMenuBar() {
      this.direction = "left";
      this.setMenuBtnMarginLeft("-13px");
      this.setMenuBarClass("block");
      this.setMenuBarLeft();
    },
    // 患者情報カード一覧メニューバーを閉じる
    closeMenuBar() {
      this.direction = "right";
      this.setMenuBtnMarginLeft("-143px");
      this.setMenuBarClass("none");
      this.setMenuBarLeft();
    },
    // 患者情報カード一覧メニューバー開閉ボタンのcss設定
    setMenuBtnMarginLeft(marginLeft) {
      if (this.$refs.menuBtn) {
        this.$refs.menuBtn.style.marginLeft = marginLeft;
      }
    },
    /**
     * 患者情報カード一覧メニューバーのcss設定
     * @param {String} attrName 
     */
    setMenuBarClass(attrName) {
      const elMenuBar = this.getPatInfoElementById("menu-bar-id");
      if (elMenuBar) {
        elMenuBar.setAttribute("class", `menu-bar-contents button-size ${attrName}`);
      }
    },
    // 患者情報カード一覧メニューバーのcss設定
    setMenuBarLeft() {
      const elMenuBarOuter = this.getPatInfoFirstByClassName("menu-bar");
      if (!elMenuBarOuter) {
        return;
      }
      if (!elMenuBarOuter.style.cssText) {
        elMenuBarOuter.style.left = "143px";
      } else {
        const menuBarOuterLeft = elMenuBarOuter.style.getPropertyValue("left");
        const left = Number(menuBarOuterLeft.replaceAll("px", ""));
        if (left >= 295 && left <= 305) {
          elMenuBarOuter.style.left = "443px";
        }
      }
    },
    // 患者情報カード一覧のスクロール・イベントハンドラー
    scrollHandler() {
      // 患者情報カード一覧のスクロール位置の更新
      const el = this.$refs.cardListDiv;
      this.cardListScrollPos = el ? el.scrollTop : 0;
    },
    // 患者情報カード一覧の表示完了通知・イベントハンドラー
    cardListMountedHandler() {
      // 患者情報・新規患者登録毎のメニューバーが閉じている
      if (!this.isMenuBarShowing) {
        // メニューバーを閉じる際にスクロール位置が変化するので先にメニューバーを閉じるための watch を更新する
        this.menuBarClosing = true;
      }
      // 患者情報カード一覧のスクロール位置を復元する
      this.cardListScrollPos = this.getCardListScrollPos(this.cardListName);
      // 患者情報カード一覧の Dom の height を設定する
      this.calculateContentHeight();
      // Dom の height が更新されるのを待ち合わせる
      setTimeout(() => {
        // スクロール位置を復元するための watch を更新する
        this.cardListScrollPosAdjusting = true;
      }, 200);
    },
    // 患者情報カード一覧のリフレッシュ・イベントハンドラー
    cardListRefreshHandler() {
      this.updateCardListScrollPos();
    },
    // 患者情報カード一覧のスクロール位置をストアに設定する
    updateCardListScrollPos() {
      this.setCardListScrollPos({
        cardListName: this.cardListName,
        scrollPos: this.cardListScrollPos,
      });
    },
  },
};
// 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
