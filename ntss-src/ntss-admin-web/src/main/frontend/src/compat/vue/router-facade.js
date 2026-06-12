import { hydrateLegacyRouteParams } from "@/compat/vue/router";

let routerInstance = null;

export function setRouterInstance(router) {
  routerInstance = router;
}

export function getRouterInstance() {
  return routerInstance;
}

export function getCurrentRoute(router = routerInstance) {
  const currentRoute = router?.currentRoute;
  const route = currentRoute?.value || currentRoute || {};
  return hydrateLegacyRouteParams(route);
}

export function getCurrentRouteName(router = routerInstance) {
  return getCurrentRoute(router)?.name;
}

export function getCurrentRoutePath(router = routerInstance) {
  return getCurrentRoute(router)?.path;
}

export function getCurrentRouteFullPath(router = routerInstance) {
  return getCurrentRoute(router)?.fullPath || getCurrentRoute(router)?.path;
}

export function pushRoute(location) {
  return routerInstance?.push(location);
}

export function replaceRoute(location) {
  return routerInstance?.replace(location);
}

export { routerInstance as router };

export default {
  get router() {
    return routerInstance;
  },
  setRouterInstance,
  getRouterInstance,
  getCurrentRoute,
  getCurrentRouteName,
  getCurrentRoutePath,
  getCurrentRouteFullPath,
  pushRoute,
  replaceRoute
};
