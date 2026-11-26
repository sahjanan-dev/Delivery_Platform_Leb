import { z } from "zod";
import type { Prisma } from "@/app/generated/prisma/client";

// Query string: ?limit=20&offset=0
export const paginationSchema = z.object({
  limit: z.coerce.number().int().min(1).max(100).default(20),
  offset: z.coerce.number().int().min(0).default(0),
});

export type Pagination = z.infer<typeof paginationSchema>;

export type Paginated<T> = {
  data: T[];
  pagination: { limit: number; offset: number; total: number };
};

// Decimal columns: accept 12.5 or "12.50"
export const decimalSchema = z.union([z.number(), z.string().regex(/^-?\d+(\.\d+)?$/, "Must be a decimal number")]);

// BigInt columns: accept 123 or "123" (JSON has no bigint)
export const bigintSchema = z
  .union([z.number().int(), z.string().regex(/^-?\d+$/, "Must be an integer")])
  .transform((v) => BigInt(v));

// Json columns: any JSON value except null
export const jsonSchema = z.custom<Prisma.InputJsonValue>((v) => v !== undefined && v !== null, "Must be JSON");

// PATCH bodies must change at least one field
export const notEmpty = (data: object) => Object.keys(data).length > 0;
export const notEmptyMessage = { message: "Nothing to update" };
