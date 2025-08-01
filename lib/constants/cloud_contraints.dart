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
const totalCompletedWorkoutsFieldName = 'total_completed_workouts';
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

const userAchievementsTableName = 'Achievements';
const squadAchievementsTableName = 'ServerAchievements';
const squadIdFieldName = 'squad_id';
const readByFieldName = 'read_by';
const messageFieldName = 'achievement';
const userIdFieldName = 'user_id';
//^ The Achievement Constraints

const workoutTableName = 'WorkoutPlans';
const planFieldName = 'plan';
//^ The Workout Constraints

const completedWorkoutName = "CompletedWorkouts";
const workoutIdFieldName = 'workout_id';
//^ The Completed Workout Constraints

const prDateFieldName = 'pr_date';
const prTargetWeightFieldName = 'target_weight';
const prActualWeightFieldName = 'actual_weight';
const prTableName = 'PrDates';

const rowName = 'name';
const timeCreatedFieldName = 'created_at';
const idFieldName = 'id';
const ownerUserFieldName = 'owner_id';
const exerciseNameFieldName = 'exercise';
//^ The Shared Constraints
