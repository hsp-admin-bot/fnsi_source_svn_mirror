<template>
  <div class="content-container" :style="containerStyles" @click="onClick">
    <div class="content-box" :style="widthStyles">
      <div class="header" ref="header">
        <div>
          <slot name="header-content" />
        </div>
        <div class="bread-crumbs">
          <slot name="bread-crumbs-content" />
        </div>
      </div>
      <div class="main main-font" :style="heightStyles">
        <slot name="main-content" ref="mainComponent" />
      </div>
    </div>
    <router-view />
  </div>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import LayoutMixin from "@/views/LayoutMixin";
export default {
  mixins: [LayoutMixin],
  data() {
    return {
      contentBoxWidth: 0,
    };
  },
  computed: {
    ...mapGetters("window-size", {
      splittedWidth: "getSplittedWidth",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", {
      isSplitFrame: "getSplitFrame",
    }),
    ...mapGetters("pat-info-sharing", ["getIsSearching"]),
    containerStyles() {
      const isSmallScreen = this.windowWidth < 800;
      return {
        justifyContent: isSmallScreen ? "flex-end" : "flex-start",
      };
    },
    widthStyles() {
      if (this.getIsSearching) {
        return {
          "--width": "100%",
          width: "100%",
          transform: "none",
        };
      }
      return { "--width": `${this.splittedWidth - 1}px` };
    },
  },
  watch: {
    splittedWidth() {
      const objList = document.getElementsByClassName("content-box");
      if (!objList.length) return;
      const el = objList[objList.length - 1];
      el.classList.add("fade-slide");
      requestAnimationFrame(() => {
        if (this.splittedWidth < this.contentBoxWidth) {
          el.style.transform =
            "translate3d(calc(" +
            this.contentBoxWidth +
            "px - var(--width)), 0px, 0px)";
        } else {
          el.style.transform = "";
        }
        setTimeout(() => {
          el.classList.remove("fade-slide");
        }, 200);
      });
    },
    isSplitFrame() {
      if (!this.isSplitFrame) {
        this.resetSplittableFrames();
      }
    },
  },
  methods: {
    ...mapActions("window-size", [
      "setSplittableFrames",
      "resetSplittableFrames",
    ]),
    onClick() {
      EventBus.$emit("closeUserMenu");
      EventBus.$emit("closeFooterList");
    },
  },
  mounted() {
    this.contentBoxWidth = Number(
      window
        .getComputedStyle(document.querySelector(".content-box"))
        .minWidth.replace("px", "")
    );
    EventBus.$on("forceCloseDetail", () => {
      this.resetSplittableFrames();
    });
  },
  beforeUnmount() {
    EventBus.$off("forceCloseDetail");
  },
};
</script>

<style scoped>
.content-container {
  display: flex;
  margin: 0;
  padding: 0;
  flex-direction: row;
  flex-wrap: nowrap;
  justify-content: flex-start;
}
@media (max-width: 800px) {
  .content-container {
    justify-content: flex-end;
  }
}
.content-box {
  --width: 200px;
  width: var(--width);
  min-width: 200px;
  height: inherit;
  position: relative;

  flex-shrink: 0;
  transition: transform 0.28s cubic-bezier(0.4, 0, 0.2, 1), opacity 0.2s ease,
    width 0.1s ease-out;
}
.fade-slide {
  opacity: 0.65;
}
</style>
