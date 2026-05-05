import type { Player } from "@magic-nugger-app/shared";

export type PlayerDbRecord = Player & {
  password_hash: string | null;
};
