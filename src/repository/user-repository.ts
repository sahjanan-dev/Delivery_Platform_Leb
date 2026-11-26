import { prisma } from "@/lib/prisma";
import type { Prisma } from "@/app/generated/prisma/client";
import { DatabaseException } from "@/exceptions/database-exception";
import { NotFoundException } from "@/exceptions/not-found-exception";
import { isDatabaseDown, isPrismaError } from "@/exceptions/prisma-exception";
import { UniqueException } from "@/exceptions/unique-exception";
import type { CreateUserInput, SafeUser, UpdateUserInput } from "@/types/user-types";

// Fields returned for a user (never Account/password data)
const safeUserSelect = {
  id: true,
  name: true,
  email: true,
  role: true,
  emailVerified: true,
  image: true,
  banned: true,
  banReason: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.UserSelect;

// Errors that can happen in any query: database down, or something unexpected.
function databaseError(err: unknown, action: string): DatabaseException {
  console.error(`[UserRepository] ${action} failed:`, err); // full details stay in the server log
  if (isDatabaseDown(err)) {
    return new DatabaseException("We can't reach the database right now. Please try again in a few minutes.");
  }
  return new DatabaseException(`Something went wrong while trying to ${action}. Please try again.`);
}

export class UserRepository {
  // One page of users, newest first.
  // GET /api/users?limit=20&offset=40 -> SELECT ... ORDER BY created_at DESC LIMIT 20 OFFSET 40
  static async findMany(limit: number, offset: number): Promise<SafeUser[]> {
    try {
      return await prisma.user.findMany({
        select: safeUserSelect, // only safe columns, never password data
        orderBy: { createdAt: "desc" }, // fixed order so pages never overlap or skip rows
        take: limit, // page size (LIMIT)
        skip: offset, // rows to skip before this page (OFFSET)
      });
    } catch (err) {
      throw databaseError(err, "load the list of users");
    }
  }

  static async count(): Promise<number> {
    try {
      return await prisma.user.count();
    } catch (err) {
      throw databaseError(err, "count the users");
    }
  }

  static async findById(id: string): Promise<SafeUser | null> {
    try {
      return await prisma.user.findUnique({ where: { id }, select: safeUserSelect });
    } catch (err) {
      throw databaseError(err, "load this user");
    }
  }

  static async createUser(data: CreateUserInput & { id: string }): Promise<SafeUser> {
    try {
      return await prisma.user.create({ data, select: safeUserSelect });
    } catch (err) {
      if (isPrismaError(err, "P2002")) {
        throw new UniqueException(
          `A user with the email "${data.email}" already exists. Please use a different email address.`,
        );
      }
      throw databaseError(err, "create the user");
    }
  }

  static async update(id: string, data: UpdateUserInput): Promise<SafeUser> {
    try {
      return await prisma.user.update({
        where: { id },
        data: { ...data, updatedAt: new Date() },
        select: safeUserSelect,
      });
    } catch (err) {
      if (isPrismaError(err, "P2025")) {
        throw new NotFoundException(`No user found with the id "${id}". It may have been deleted.`);
      }
      if (isPrismaError(err, "P2002")) {
        throw new UniqueException(
          `The email "${data.email}" is already used by another user. Please choose a different email address.`,
        );
      }
      throw databaseError(err, "update the user");
    }
  }
}
