import { prisma } from "@/lib/prisma";
import type { Prisma } from "@/app/generated/prisma/client";
import { DatabaseException } from "@/exceptions/database-exception";
import { NotFoundException } from "@/exceptions/not-found-exception";
import { isDatabaseDown, isPrismaError } from "@/exceptions/prisma-exception";
import type { SafeAccount } from "@/types/account-types";

// Fields returned for an account: never the password or the tokens
const safeAccountSelect = {
  id: true,
  userId: true,
  providerId: true,
  accountId: true,
  scope: true,
  accessTokenExpiresAt: true,
  refreshTokenExpiresAt: true,
  createdAt: true,
  updatedAt: true,
} satisfies Prisma.AccountSelect;

// What the service sends to the database (password already hashed)
export type AccountCreateData = {
  id: string;
  userId: string;
  providerId: string;
  accountId: string;
  password?: string | null;
  accessToken?: string | null;
  refreshToken?: string | null;
  idToken?: string | null;
  accessTokenExpiresAt?: Date | null;
  refreshTokenExpiresAt?: Date | null;
  scope?: string | null;
};

// userId, providerId and accountId never change
export type AccountUpdateData = Partial<Omit<AccountCreateData, "id" | "userId" | "providerId" | "accountId">>;

// Errors that can happen in any query: database down, or something unexpected.
function databaseError(err: unknown, action: string): DatabaseException {
  console.error(`[AccountRepository] ${action} failed:`, err); // full details stay in the server log
  if (isDatabaseDown(err)) {
    return new DatabaseException("We can't reach the database right now. Please try again in a few minutes.");
  }
  return new DatabaseException(`Something went wrong while trying to ${action}. Please try again.`);
}

export class AccountRepository {
  // One page of accounts, newest first.
  // GET /api/accounts?limit=20&offset=40 -> SELECT ... ORDER BY created_at DESC LIMIT 20 OFFSET 40
  static async findMany(limit: number, offset: number): Promise<SafeAccount[]> {
    try {
      return await prisma.account.findMany({
        select: safeAccountSelect, // never password or tokens
        orderBy: [{ createdAt: "desc" }, { id: "desc" }], // fixed order so pages never overlap or skip rows
        take: limit, // page size (LIMIT)
        skip: offset, // rows to skip before this page (OFFSET)
      });
    } catch (err) {
      throw databaseError(err, "load the list of accounts");
    }
  }

  static async count(): Promise<number> {
    try {
      return await prisma.account.count();
    } catch (err) {
      throw databaseError(err, "count the accounts");
    }
  }

  static async findById(id: string): Promise<SafeAccount | null> {
    try {
      return await prisma.account.findUnique({ where: { id }, select: safeAccountSelect });
    } catch (err) {
      throw databaseError(err, "load this account");
    }
  }

  // true if this user already has an account with this provider (e.g. a "credential" account)
  static async existsByUserAndProvider(userId: string, providerId: string): Promise<boolean> {
    try {
      const count = await prisma.account.count({ where: { userId, providerId } });
      return count > 0;
    } catch (err) {
      throw databaseError(err, "check the user's accounts");
    }
  }

  static async createAccount(data: AccountCreateData): Promise<SafeAccount> {
    try {
      return await prisma.account.create({ data, select: safeAccountSelect });
    } catch (err) {
      if (isPrismaError(err, "P2003")) {
        throw new NotFoundException(`No user found with the id "${data.userId}". Create the user first.`);
      }
      throw databaseError(err, "create the account");
    }
  }

  static async update(id: string, data: AccountUpdateData): Promise<SafeAccount> {
    try {
      return await prisma.account.update({
        where: { id },
        data: { ...data, updatedAt: new Date() },
        select: safeAccountSelect,
      });
    } catch (err) {
      if (isPrismaError(err, "P2025")) {
        throw new NotFoundException(`No account found with the id "${id}". It may have been deleted.`);
      }
      throw databaseError(err, "update the account");
    }
  }

  static async delete(id: string): Promise<void> {
    try {
      await prisma.account.delete({ where: { id } });//if it's work it's done
    } catch (err) {//if it fails go into catch
      if (isPrismaError(err, "P2025")) {// P2025 (not found),throw a NotFoundException,
        throw new NotFoundException(`No account found with the id "${id}". It may have already been deleted.`);
      }// otherwise throw databaseerror
      throw databaseError(err, "delete the account");
    }
  }
}
