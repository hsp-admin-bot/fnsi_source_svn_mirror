#apt install -y openssh-server
cd /home/ntss

npm install -g --unsafe-perm node-red@4.1.10 node-red-admin@4.1.6

NODE_RED_GLOBAL_DIR="$(npm root -g)/node-red"
NODE_RED_NODES_DIR="${NODE_RED_GLOBAL_DIR}/node_modules/@node-red/nodes"
NODE_RED_ADMIN_GLOBAL_DIR="$(npm root -g)/node-red-admin"

# BlackDuck #12919: @node-red/nodes 4.1.10 pins form-data 4.0.4.
# Keep the global Node-RED install, then update only the bundled form-data.
if [ -d "${NODE_RED_NODES_DIR}" ]; then
  npm pkg set dependencies.form-data=4.0.6 --prefix "${NODE_RED_NODES_DIR}"
  npm install --prefix "${NODE_RED_GLOBAL_DIR}" --unsafe-perm --ignore-scripts --no-save --package-lock=false form-data@4.0.6
else
  echo "Node-RED nodes directory not found: ${NODE_RED_NODES_DIR}" >&2
  exit 1
fi

# node-red-admin 4.1.6 uses axios 1.16.0, which may keep form-data 4.0.5
# in existing global installations. Update the global node-red-admin copy too.
if [ -d "${NODE_RED_ADMIN_GLOBAL_DIR}" ]; then
  npm install --prefix "${NODE_RED_ADMIN_GLOBAL_DIR}" --unsafe-perm --ignore-scripts --no-save --package-lock=false form-data@4.0.6
else
  echo "Node-RED admin directory not found: ${NODE_RED_ADMIN_GLOBAL_DIR}" >&2
  exit 1
fi
