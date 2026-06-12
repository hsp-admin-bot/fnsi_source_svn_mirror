const targetDbName = process.env.MONGO_DB_NAME || "ntss";
const appUser = process.env.MONGO_APP_USER || "nkk";
const appPassword = process.env.MONGO_APP_PASSWORD || "nkk";
const recreateDb = ["1", "true", "yes", "on"].includes(
  String(process.env.MONGO_RECREATE_DB || "false").toLowerCase()
);

const targetDb = db.getSiblingDB(targetDbName);

print(`[init][mongo] prepare db=${targetDbName} user=${appUser} recreateDb=${recreateDb}`);

if (recreateDb) {
  print(`[init][mongo] drop database ${targetDbName}`);
  printjson(targetDb.dropDatabase());
}

const existingUser = targetDb.getUser(appUser);
if (existingUser) {
  print(`[init][mongo] drop existing user ${appUser}`);
  printjson(targetDb.dropUser(appUser));
}

print(`[init][mongo] create user ${appUser}`);
printjson(targetDb.createUser({
  user: appUser,
  pwd: appPassword,
  roles: [
    { role: "readWrite", db: targetDbName },
    { role: "dbAdmin", db: targetDbName }
  ]
}));

print(`[init][mongo] user list for ${targetDbName}`);
printjson(targetDb.getUsers());
