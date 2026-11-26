import { z } from "zod";
import { Role } from "@/app/generated/prisma/enums";
import { notEmpty, notEmptyMessage } from "@/types/common";

// ---------- Schemas (validate with .parse) ----------

export const createUserSchema = z.object({
  name: z.string().trim().min(2).max(100),
  email: z.email().toLowerCase(),
  role: z.enum(Role),
});

export const updateUserSchema = z
  .object({
    name: z.string().trim().min(2).max(100),
    email: z.email().toLowerCase(),
    role: z.enum(Role),
    banned: z.boolean(),
    banReason: z.string().trim().max(255).nullable(),
  })
  .partial()
  .refine(notEmpty, notEmptyMessage);

// Route params: /api/users/:id
export const userIdSchema = z.object({
  id: z.string().min(1),
});

// ---------- Types ----------

export type CreateUserInput = z.infer<typeof createUserSchema>;
export type UpdateUserInput = z.infer<typeof updateUserSchema>;
export type UserId = z.infer<typeof userIdSchema>;

// What the API returns for a user (never Account/password data)
export type SafeUser = {
  id: string;
  name: string;
  email: string;
  role: Role;
  emailVerified: boolean;
  image: string | null;
  banned: boolean | null;
  banReason: string | null;
  createdAt: Date;
  updatedAt: Date;
};
