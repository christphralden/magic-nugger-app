import passport from "passport";
import { Strategy as LocalStrategy } from "passport-local";
import { Strategy as GoogleStrategy } from "passport-google-oauth20";
import bcrypt from "bcrypt";
import type { PlayerDbRecord } from "@/types/player.types.js";
import { AppUser } from "@magic-nugger-app/shared";
import { getDb } from "@/db/transaction-context";

function userSelect(): string {
  return `
    SELECT
      p.id, p.username, p.display_name, p.email, p.avatar_url, p.role_id,
      r.name as role_name,
      ARRAY(
        SELECT perm.name
        FROM role_permissions rp2
        JOIN permissions perm ON perm.id = rp2.permission_id
        WHERE rp2.role_id = r.id
      ) as role_permissions,
      p.current_elo,
      p.total_questions_answered, p.total_correct, p.total_incorrect, p.longest_streak,
      p.age, p.grade, p.guardian_email
    FROM players p
    JOIN roles r ON r.id = p.role_id
  `;
}

passport.serializeUser((user: Express.User, done) => {
  done(null, (user as AppUser).id);
});

passport.deserializeUser(async (id: string, done) => {
  try {
    const { rows } = await getDb().query<AppUser>(
      `${userSelect()} WHERE p.id = $1`,
      [id],
    );
    done(null, rows[0] ?? null);
  } catch (err) {
    done(err, null);
  }
});

passport.use(
  new LocalStrategy(
    { usernameField: "email" },
    async (email, password, done) => {
      try {
        const { rows: hashRows } = await getDb().query<
          Pick<PlayerDbRecord, "password_hash">
        >(`SELECT password_hash FROM players WHERE email = $1`, [email]);
        const hash = hashRows[0]?.password_hash;
        if (!hash) return done(null, false);

        const valid = await bcrypt.compare(password, hash);
        if (!valid) return done(null, false);

        const { rows } = await getDb().query<AppUser>(
          `${userSelect()} WHERE p.email = $1`,
          [email],
        );
        return done(null, rows[0] ?? false);
      } catch (err) {
        return done(err);
      }
    },
  ),
);

if (
  process.env.GOOGLE_CLIENT_ID &&
  process.env.GOOGLE_CLIENT_SECRET &&
  process.env.GOOGLE_CALLBACK_URL
) {
  passport.use(
    new GoogleStrategy(
      {
        clientID: process.env.GOOGLE_CLIENT_ID,
        clientSecret: process.env.GOOGLE_CLIENT_SECRET,
        callbackURL: process.env.GOOGLE_CALLBACK_URL,
      },
      async (_accessToken, _refreshToken, profile, done) => {
        try {
          const { rows } = await getDb().query<AppUser>(
            `${userSelect()} WHERE p.oauth_provider = $1 AND p.oauth_id = $2`,
            ["google", profile.id],
          );

          if (rows[0]) return done(null, rows[0]);

          const email = profile.emails?.[0]?.value;
          if (!email) return done(null, false, { message: "no_email" });
          if (!profile.emails?.[0]?.verified) {
            return done(null, false, { message: "email_not_verified" });
          }

          const { rows: existingRows } = await getDb().query<{ id: string }>(
            `SELECT id FROM players WHERE email = $1`,
            [email],
          );
          const existing = existingRows[0];

          if (existing) {
            await getDb().query(
              `UPDATE players SET oauth_provider = $1, oauth_id = $2 WHERE id = $3`,
              ["google", profile.id, existing.id],
            );
          } else {
            const username = (profile.displayName ?? email.split("@")[0])
              .replace(/\s+/g, "_")
              .slice(0, 24);
            const { rows: usernameConflict } = await getDb().query<{
              id: string;
            }>(`SELECT id FROM players WHERE username = $1`, [username]);
            const uniqueUsername = usernameConflict[0]
              ? `${username}_${profile.id.slice(-8)}`.slice(0, 32)
              : username;

            await getDb().query(
              `INSERT INTO players (username, email, display_name, avatar_url, oauth_provider, oauth_id)
               VALUES ($1, $2, $3, $4, $5, $6)`,
              [
                uniqueUsername,
                email,
                profile.displayName ?? null,
                profile.photos?.[0]?.value ?? null,
                "google",
                profile.id,
              ],
            );
          }

          const { rows: result } = await getDb().query<AppUser>(
            `${userSelect()} WHERE p.email = $1`,
            [email],
          );

          return done(null, result[0]);
        } catch (err) {
          return done(err);
        }
      },
    ),
  );
}

export { passport };
