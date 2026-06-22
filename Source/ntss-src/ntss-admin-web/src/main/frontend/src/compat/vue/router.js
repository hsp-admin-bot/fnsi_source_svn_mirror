import {
  createRouter as createVueRouter
} from "vue-router";
import { hoistTreatmentRecordRouteGuards } from "@/compat/vue/route-guards.js";

export * from "vue-router";

const LEGACY_ROUTE_CONTEXT_PARAM_KEYS = ["footer", "function_cd"];
const legacyRouteParamStore = new Map();
const legacyNavigationState = {
  tail: Promise.resolve()
};

function normalizeLegacyChildRouteRecord(route, isChildRoute = false) {
  if (!route || typeof route !== "object") {
    return route;
  }

  const normalizedRoute = { ...route };
  const hasLegacyRootChild = Array.isArray(route.children) && route.children.some((childRoute) => {
    return childRoute?.path === "/";
  });
  if (
    hasLegacyRootChild &&
    typeof normalizedRoute.path === "string" &&
    normalizedRoute.path !== "/" &&
    !normalizedRoute.path.endsWith("/")
  ) {
    normalizedRoute.path = `${normalizedRoute.path}/`;
  }

  // Vue2/Vue Router 3 の既存定義では、親ルート配下の path: "/" を親の index 画面として扱っている。
  // Vue Router 4 では "/" がルート直下の絶対パスになるため、互換層で親配下の index path に戻す。
  if (isChildRoute && normalizedRoute.path === "/") {
    normalizedRoute.path = "";
  }

  if (Array.isArray(route.children)) {
    normalizedRoute.children = route.children.map((childRoute) => {
      return normalizeLegacyChildRouteRecord(childRoute, true);
    });
  }

  return normalizedRoute;
}

function normalizeLegacyRouterOptions(options) {
  if (!options || !Array.isArray(options.routes)) {
    return options;
  }

  return {
    ...options,
    routes: options.routes.map((route) => normalizeLegacyChildRouteRecord(route, false))
  };
}

function hasOwn(target, key) {
  return Object.prototype.hasOwnProperty.call(target || {}, key);
}

function getDeclaredParamKeys(router, routeName) {
  if (!router || !routeName || typeof router.getRoutes !== "function") {
    return new Set();
  }
  const routeRecord = router.getRoutes().find((route) => route.name === routeName);
  const paramKeys = new Set();
  String(routeRecord?.path || "").replace(/:([A-Za-z0-9_]+)/g, (_match, key) => {
    paramKeys.add(key);
    return _match;
  });
  return paramKeys;
}

function normalizeRouteParamValue(value) {
  if (Array.isArray(value)) {
    return value.map((entry) => String(entry)).join(",");
  }
  return String(value ?? "");
}

function buildLegacyRouteParamKey(routeName, params) {
  const normalizedParams = Object.keys(params || {})
    .sort()
    .map((key) => `${key}:${normalizeRouteParamValue(params[key])}`)
    .join("|");
  return `${String(routeName || "")}|${normalizedParams}`;
}

function rememberLegacyRouteParams(routeName, params, legacyParams) {
  if (!routeName || !legacyParams || Object.keys(legacyParams).length === 0) {
    return;
  }
  legacyRouteParamStore.set(buildLegacyRouteParamKey(routeName, params), legacyParams);
}

function forgetLegacyRouteParams(routeName, params) {
  if (!routeName) {
    return;
  }
  legacyRouteParamStore.delete(buildLegacyRouteParamKey(routeName, params || {}));
}

function findRememberedLegacyRouteParams(route) {
  return legacyRouteParamStore.get(buildLegacyRouteParamKey(route?.name, route?.params || {})) || null;
}

export function normalizeLegacyNamedRouteLocation(location, router = null) {
  if (!location || typeof location === "string" || Array.isArray(location)) {
    return location;
  }
  // Vue2 では name 指定 + params で path 未定義キーも運搬できていたが、Vue Router 4 では破棄される。
  // path に宣言されていない params は Vue2 と同じく URL へ出さずに保持し、遷移後に $route.params へ復元する。
  if (!location.name || !location.params || typeof location.params !== "object") {
    return location;
  }

  const declaredParamKeys = getDeclaredParamKeys(router, location.name);
  const nextParams = { ...location.params };
  const nextQuery = { ...(location.query || {}) };
  const rememberedParams = {};
  let changed = false;

  Object.keys(nextParams).forEach((key) => {
    const isDeclaredPathParam = declaredParamKeys.has(key);
    if (isDeclaredPathParam) {
      return;
    }
    rememberedParams[key] = nextParams[key];
    delete nextParams[key];
    changed = true;
  });

  if (!changed) {
    forgetLegacyRouteParams(location.name, nextParams);
    return location;
  }

  rememberLegacyRouteParams(location.name, nextParams, rememberedParams);

  return {
    ...location,
    params: nextParams,
    query: nextQuery
  };
}

export function hydrateLegacyRouteParams(route) {
  if (!route || typeof route !== "object") {
    return route;
  }

  const params = route.params || {};
  const query = route.query || {};
  const rememberedParams = findRememberedLegacyRouteParams(route);
  const legacyKeys = Array.from(new Set([
    ...LEGACY_ROUTE_CONTEXT_PARAM_KEYS
  ]));
  let changed = false;

  legacyKeys.forEach((key) => {
    if (hasOwn(params, key) || !hasOwn(query, key)) {
      return;
    }
    try {
      params[key] = query[key];
      changed = true;
    } catch (_error) {
      // route.params が read-only の場合は補完できないため、そのまま返却する。
    }
  });

  Object.keys(rememberedParams || {}).forEach((key) => {
    if (hasOwn(params, key)) {
      return;
    }
    try {
      params[key] = rememberedParams[key];
      changed = true;
    } catch (_error) {
      // route.params が read-only の場合は補完できないため、そのまま返却する。
    }
  });

  if (changed && route.params !== params) {
    try {
      route.params = params;
    } catch (_error) {
      // Vue Router の route が read-only の場合でも、既存 params object への補完で互換性を維持する。
    }
  }

  return route;
}


function buildResolvedRouteKey(router, location) {
  try {
    const resolved = router?.resolve?.(location);
    if (!resolved) {
      return null;
    }
    return `${String(resolved.name || "")}|${resolved.fullPath || resolved.path || ""}`;
  } catch (_error) {
    return null;
  }
}

function buildCurrentRouteKey(router) {
  const route = router?.currentRoute?.value || router?.currentRoute;
  if (!route) {
    return null;
  }
  return `${String(route.name || "")}|${route.fullPath || route.path || ""}`;
}

function createLegacyPendingRoute(router, location) {
  try {
    const resolved = router?.resolve?.(location);
    return hydrateLegacyRouteParams({
      ...(resolved || {}),
      params: { ...(resolved?.params || {}) },
      query: { ...(resolved?.query || {}) },
      meta: { ...(resolved?.meta || {}) }
    });
  } catch (_error) {
    return null;
  }
}

function installLegacyRouterHistory(router) {
  if (!router || router.history) {
    return;
  }
  const legacyHistory = {
    pending: null
  };
  Object.defineProperty(router, "history", {
    configurable: true,
    enumerable: false,
    value: legacyHistory
  });
}

function createLegacyNavigation(router, navigate, navigationState = legacyNavigationState) {
  let pendingRouteKey = null;
  let pendingPromise = null;

  function runLegacyNavigate(normalizedLocation, routeKey, pendingRoute) {
    const currentRouteKey = buildCurrentRouteKey(router);
    if (routeKey && currentRouteKey === routeKey) {
      return Promise.resolve(router.currentRoute?.value || router.currentRoute);
    }

    if (router.history) {
      router.history.pending = pendingRoute;
    }

    return navigate(normalizedLocation)
      .catch((err) => err)
      .finally(() => {
        if (pendingRouteKey === routeKey) {
          pendingRouteKey = null;
          pendingPromise = null;
          if (router.history && router.history.pending === pendingRoute) {
            router.history.pending = null;
          }
        }
      });
  }

  return function legacyNavigate(location) {
    const normalizedLocation = normalizeLegacyNamedRouteLocation(location, router);
    const routeKey = buildResolvedRouteKey(router, normalizedLocation);

    if (routeKey && pendingPromise && pendingRouteKey === routeKey) {
      return pendingPromise;
    }

    const currentRouteKey = buildCurrentRouteKey(router);
    if (routeKey && currentRouteKey === routeKey) {
      return Promise.resolve(router.currentRoute?.value || router.currentRoute);
    }

    const pendingRoute = createLegacyPendingRoute(router, normalizedLocation);
    const run = () => runLegacyNavigate(normalizedLocation, routeKey, pendingRoute);
    const promise = navigationState.tail.then(run, run);
    navigationState.tail = promise.then(() => undefined, () => undefined);

    pendingRouteKey = routeKey;
    pendingPromise = promise;

    return promise;
  };
}

export function createRouter(options) {
  const normalizedOptions = normalizeLegacyRouterOptions(options);
  hoistTreatmentRecordRouteGuards(normalizedOptions?.routes);
  const router = createVueRouter(normalizedOptions);
  installLegacyRouterHistory(router);
  const navigationState = { tail: Promise.resolve() };
  const originalPush = router.push.bind(router);
  router.push = createLegacyNavigation(router, originalPush, navigationState);

  const originalReplace = router.replace.bind(router);
  router.replace = createLegacyNavigation(router, originalReplace, navigationState);

  return router;
}
