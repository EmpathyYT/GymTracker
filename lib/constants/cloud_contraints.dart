const nameFieldName = 'user_name';
const bioFieldName = 'biography';
const sensitiveInformationDocumentName = 'sensitive_info';
const levelFieldName = 'level';
const friendsFieldName = 'friends';
const squadFieldName = 'squads';
const premiumSquadLimit = 15;
const standardSquadLimit = 7;
const squadLimitFieldName = 'squad_limit_num';
//^ The User Constraints


const pendingFRQFieldName = 'pending_friend_requests';
const pendingSquadReqFieldName = 'pending_squad_requests';
const requestsDocumentName = 'pending_requests';
const sendingUserFieldName = 'sending_user_id';
const recipientFieldName = 'recipient_user_id';
const isAccepted = "is_accepted";
//^ The F/SRQ Constraints


const notificationCollectionName = 'notifications';
const fromUserIdFieldName = 'from_user_id';
const toUserIdFieldName = 'to_user_id';
const titleFieldName = 'title';
const bodyFieldName = 'message';
const timestampFieldName = 'timestamp';
const readFieldName = 'read';
//^ The Notification Constraints


const usersInvitedFieldName = 'users_invited';
const ownerUserFieldId = 'owner_user_id';
const squadNameFieldName = 'squad_name';
const membersFieldName = 'members';
const squadDescriptionFieldName = 'squad_description';
//^ The Squad Constraints


const timeCreatedFieldName = 'time_created';
//^ The Shared Constraints