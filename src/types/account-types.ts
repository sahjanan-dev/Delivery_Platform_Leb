import { z } from "zod";
import { notEmpty, notEmptyMessage } from "@/types/common";

// An Account is how a User logs in:
//   providerId "credential" -> email + password (password is required)
//   providerId "google", "github", ... -> OAuth login (tokens instead of a password)
// One User can have several Accounts (e.g. password + Google).

// ---------- Reusable field rules ----------

// Plain password sent by the client. The service hashes it before saving; the hash is never returned.
const passwordSchema = z
  .string()
  .min(8, "Password must be at least 8 characters")
  .max(128, "Password must be at most 128 characters");

const tokenSchema = z.string().trim().min(1);

// ---------- Schemas (validate with .parse) ----------

export const createAccountSchema = z
  .object({
    userId: z.string().trim().min(1, "userId is required"),
    providerId: z.string().trim().toLowerCase().min(1, "providerId is required"),
    accountId: z.string().trim().min(1, "accountId is required"),
    password: passwordSchema.optional(),
    accessToken: tokenSchema.nullish(),
    refreshToken: tokenSchema.nullish(),
    idToken: tokenSchema.nullish(),
    accessTokenExpiresAt: z.coerce.date().nullish(),
    refreshTokenExpiresAt: z.coerce.date().nullish(),
    scope: z.string().trim().max(500).nullish(),
  })
  .refine((data) => data.providerId !== "credential" || data.password, {
    message: "Password is required for a credential (email + password) account",
    path: ["password"],
  });

// userId, providerId and accountId never change; only the login data can be updated.
export const updateAccountSchema = z
  .object({
    password: passwordSchema,
    accessToken: tokenSchema.nullable(),
    refreshToken: tokenSchema.nullable(),
    idToken: tokenSchema.nullable(),
    accessTokenExpiresAt: z.coerce.date().nullable(),
    refreshTokenExpiresAt: z.coerce.date().nullable(),
    scope: z.string().trim().max(500).nullable(),
  })
  .partial()
  .refine(notEmpty, notEmptyMessage);

// Route params: /api/accounts/:id
export const accountIdSchema = z.object({
  id: z.string().min(1),
});

// ---------- Types ----------

export type CreateAccountInput = z.infer<typeof createAccountSchema>;
export type UpdateAccountInput = z.infer<typeof updateAccountSchema>;
export type AccountId = z.infer<typeof accountIdSchema>;

// What the API returns for an account: never the password or the tokens
export type SafeAccount = {
  id: string;
  userId: string;
  providerId: string;
  accountId: string;
  scope: string | null;
  accessTokenExpiresAt: Date | null;
  refreshTokenExpiresAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
};
