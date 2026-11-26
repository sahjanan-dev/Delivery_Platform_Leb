import { Prisma } from "@/app/generated/prisma/client";

// Prisma error codes we react to:
//   P2002 = unique constraint failed (e.g. email already used)
//   P2025 = record to update/delete was not found
export function isPrismaError(err: unknown, code: "P2002" | "P2025"): boolean {
  return err instanceof Prisma.PrismaClientKnownRequestError && err.code === code;
}

// True when the database server cannot be reached (stopped, wrong URL, network down)
export function isDatabaseDown(err: unknown): boolean {
  if (err instanceof Prisma.PrismaClientInitializationError) return true;
  const code = (err as { code?: unknown })?.code;
  return code === "ECONNREFUSED" || code === "ETIMEDOUT" || code === "P1001";
}
