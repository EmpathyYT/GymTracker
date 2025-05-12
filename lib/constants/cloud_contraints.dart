const userTableName = 'Users';
const nameFieldName = 'user_name';
const authIdFieldName = 'auth_id';
const bioFieldName = 'biography';
const levelFieldName = 'level';
const friendsFieldName = 'friends';
const squadFieldName = 'servers';
const premiumSquadLimit = 15;
const standardSquadLimit = 7;
const squadLimitFieldName = 'squad_limit';
const genderFieldName = "gender";
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
const membersFieldName = 'members';
const squadDescriptionFieldName = 'description';
//^ The Squad Constraints


const achievementsTableName = 'Achievements';
const messageFieldName = 'achievement';
const userIdFieldName = 'user_id';
const achievementSquadsFieldName = 'squads';
//^ The Achievement Constraints

const workoutTableName = 'WorkoutPlans';
const planFieldName = 'plan';
//^ The Workout Constraints


const rowName = 'name';
const timeCreatedFieldName = 'created_at';
const idFieldName = 'id';
const ownerUserFieldName = 'owner_id';
//^ The Shared Constraints

