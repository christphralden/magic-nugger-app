export const LEADERBOARD_PAGINATION_LIMIT = 3;
export const ADMIN_PAGINATION_LIMIT = 10;
export const PATH_TO_UNITY = "/Calculon/Build";

export const UNITY_SUBSCRIBED_EVENT = {
  INIT: "Init",
  LEVEL: "Level",
  ANSWER: "Answer",
  FINISHED: "Finished",
  REACT_MESSAGE: "ReactMessage",
};

export const UNITY_GAME_OBJECT = "ReactUnityCommunication";

export const UNITY_SEND_METHOD = {
  GIVE_INITIAL_DATA: "GiveInitialdata",
  FINALIZED: "Finalized",
};
export const DISABLED_CANVAS_EVENTS: (keyof GlobalEventHandlersEventMap)[] = [
  "dragstart",
  "scroll",
];
