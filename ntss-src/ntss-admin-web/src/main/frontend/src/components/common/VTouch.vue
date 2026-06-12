<template>
  <component
    :is="tag"
    ref="root"
    v-bind="$attrs"
    @pointerdown="handleTouchStart"
    @pointermove="handleTouchMove"
    @pointerup="handleTouchEnd"
    @pointercancel="handleTouchEnd"
    @click="handleClick"
  >
    <slot />
  </component>
</template>

<script>
function getEventPoint(event) {
  const source = event?.changedTouches?.[0] || event?.touches?.[0] || event;
  if (!source) {
    return null;
  }
  return {
    x: Number(source.clientX || 0),
    y: Number(source.clientY || 0),
    time: Date.now()
  };
}

function normalizeDirection(direction) {
  if (!direction) {
    return "both";
  }
  return direction;
}

export default {
  name: "VTouch",
  inheritAttrs: false,
  props: {
    tag: {
      type: String,
      default: "div"
    },
    disabled: {
      type: Boolean,
      default: false
    },
    swipeOptions: {
      type: Object,
      default: () => ({})
    }
  },
  emits: ["tap", "swipeleft", "swiperight", "swipeup", "swipedown"],
  data() {
    return {
      touchStartPoint: null,
      touchCurrentPoint: null,
      activePointerId: null,
      lastTouchEndTime: 0
    };
  },
  computed: {
    swipeThreshold() {
      const threshold = Number(this.swipeOptions?.threshold);
      return Number.isFinite(threshold) && threshold > 0 ? threshold : 50;
    },
    tapTolerance() {
      const tolerance = Number(this.swipeOptions?.tapTolerance);
      return Number.isFinite(tolerance) && tolerance >= 0 ? tolerance : 10;
    },
    swipeDirection() {
      return normalizeDirection(this.swipeOptions?.direction);
    }
  },
  methods: {
    emitWhenEnabled(name, event) {
      if (this.disabled) {
        return;
      }
      this.$emit(name, event);
    },
    isDirectionAllowed(name) {
      const direction = this.swipeDirection;
      if (direction === "both") {
        return true;
      }
      if (direction === "horizontal") {
        return name === "swipeleft" || name === "swiperight";
      }
      if (direction === "vertical") {
        return name === "swipeup" || name === "swipedown";
      }
      return name === `swipe${direction}`;
    },
    handleClick(event) {
      if (this.lastTouchEndTime && Date.now() - this.lastTouchEndTime < 350) {
        return;
      }
      this.emitWhenEnabled("tap", event);
    },
    capturePointer(event) {
      const root = this.$refs.root;
      if (!root?.setPointerCapture || event.pointerId == null) {
        return;
      }
      try {
        root.setPointerCapture(event.pointerId);
        this.activePointerId = event.pointerId;
      } catch {
        // ignore capture failures on unsupported targets
      }
    },
    releasePointer(event) {
      const root = this.$refs.root;
      const pointerId = event?.pointerId ?? this.activePointerId;
      if (!root?.releasePointerCapture || pointerId == null) {
        this.activePointerId = null;
        return;
      }
      try {
        root.releasePointerCapture(pointerId);
      } catch {
        // ignore release failures when capture was not established
      }
      this.activePointerId = null;
    },
    handleTouchStart(event) {
      const point = getEventPoint(event);
      this.touchStartPoint = point;
      this.touchCurrentPoint = point;
    },
    handleTouchMove(event) {
      if (
        this.activePointerId != null &&
        event.pointerId != null &&
        event.pointerId !== this.activePointerId
      ) {
        return;
      }
      const point = getEventPoint(event);
      if (point) {
        this.touchCurrentPoint = point;
      }
      const start = this.touchStartPoint;
      if (!start || !point || this.activePointerId != null) {
        return;
      }
      const dx = Math.abs(point.x - start.x);
      const dy = Math.abs(point.y - start.y);
      if (dx > this.tapTolerance || dy > this.tapTolerance) {
        this.capturePointer(event);
      }
    },
    handleTouchEnd(event) {
      const start = this.touchStartPoint;
      const end = getEventPoint(event) || this.touchCurrentPoint;
      this.releasePointer(event);
      this.touchStartPoint = null;
      this.touchCurrentPoint = null;
      this.lastTouchEndTime = Date.now();
      if (!start || !end) {
        return;
      }

      const dx = end.x - start.x;
      const dy = end.y - start.y;
      const absX = Math.abs(dx);
      const absY = Math.abs(dy);
      const threshold = this.swipeThreshold;
      let swipeName = "";

      if (absX >= threshold && absX >= absY) {
        swipeName = dx < 0 ? "swipeleft" : "swiperight";
      } else if (absY >= threshold && absY > absX) {
        swipeName = dy < 0 ? "swipeup" : "swipedown";
      }

      if (swipeName && this.isDirectionAllowed(swipeName)) {
        this.emitWhenEnabled(swipeName, event);
        return;
      }

      if (absX <= this.tapTolerance && absY <= this.tapTolerance) {
        this.emitWhenEnabled("tap", event);
      }
    }
  }
};
</script>
