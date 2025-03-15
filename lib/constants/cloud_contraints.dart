const userTableName = 'Users';
const nameFieldName = 'user_name';
const authIdFieldName = 'auth_id';
const bioFieldName = 'biography';
const levelFieldName = 'level';
const friendsFieldName = 'friends';
const squadFieldName = 'squads';
const premiumSquadLimit = 15;
const standardSquadLimit = 7;
const squadLimitFieldName = 'squad_limit';
//^ The User Constraints


const pendingFriendRequestsTableName = 'FriendRequests';
const pendingServerRequestsTableName = 'ServerRequests';
const sendingUserFieldName = 'from_user';
const recipientFieldName = 'to_user';
const acceptedFieldName = "accepted";
const readFieldName = 'read';
const serverIdFieldName = 'server_id';
//^ The F/SRQ Constraints



const squadTableName = 'Servers';
const ownerUserFieldId = 'owner_id';
const squadNameFieldName = 'name';
const membersFieldName = 'members';
const squadDescriptionFieldName = 'description';
//^ The Squad Constraints


const timeCreatedFieldName = 'created_at';
const idFieldName = 'id';
//^ The Shared Constraints
