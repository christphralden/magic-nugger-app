import type { AppUser } from "@magic-nugger-app/shared";

declare global {
  namespace Express {
    interface User extends AppUser {}
  }
}
