// コンポーネント間イベント送信用のインスタンス定義
class SimpleEventBus {
  constructor() {
    this.events = new Map();
  }

  $on(eventName, handler) {
    if (!eventName || typeof handler !== "function") {
      return this;
    }
    const handlers = this.events.get(eventName) || new Set();
    handlers.add(handler);
    this.events.set(eventName, handlers);
    return this;
  }

  $off(eventName, handler) {
    if (!eventName) {
      this.events.clear();
      return this;
    }

    if (!handler) {
      this.events.delete(eventName);
      return this;
    }

    const handlers = this.events.get(eventName);
    if (!handlers) {
      return this;
    }

    handlers.delete(handler);
    if (handlers.size === 0) {
      this.events.delete(eventName);
    }
    return this;
  }

  $once(eventName, handler) {
    if (!eventName || typeof handler !== "function") {
      return this;
    }
    const wrapped = (...args) => {
      this.$off(eventName, wrapped);
      handler(...args);
    };
    return this.$on(eventName, wrapped);
  }

  $emit(eventName, ...args) {
    const handlers = this.events.get(eventName);
    if (!handlers) {
      return this;
    }
    [...handlers].forEach((handler) => {
      handler(...args);
    });
    return this;
  }

  async $emitAsync(eventName, ...args) {
    const handlers = this.events.get(eventName);
    if (!handlers) {
      return [];
    }

    return Promise.all([...handlers].map((handler) => handler(...args)));
  }
}

export const EventBus = new SimpleEventBus();
export default EventBus;
