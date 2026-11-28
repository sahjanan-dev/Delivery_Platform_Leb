import { randomBytes, randomUUID, scrypt as scryptCallback } from "node:crypto";
import { promisify } from "node:util";
import { AccountRepository } from "@/repository/account-repository";
import { NotFoundException } from "@/exceptions/not-found-exception";
import { UniqueException } from "@/exceptions/unique-exception";
import { paginationSchema, type Paginated } from "@/types/common";
import { accountIdSchema, createAccountSchema, updateAccountSchema, type SafeAccount } from "@/types/account-types";

const scrypt = promisify(scryptCallback) as (password: string, salt: string, keylen: number) => Promise<Buffer>;

// Never store the plain password: store "salt:hash" (scrypt, 64-byte key).
async function hashPassword(password: string): Promise<string> {
  const salt = randomBytes(16).toString("hex");
  const hash = await scrypt(password.normalize("NFKC"), salt, 64);
  return `${salt}:${hash.toString("hex")}`;
}

// Every method takes raw input (unknown) and validates it with Zod .parse().
// A ZodError becomes a 400 in handleError().
export class AccountService {
  // GET /api/accounts?limit=20&offset=0
  static async list(query: unknown): Promise<Paginated<SafeAccount>> {
    const { limit, offset } = paginationSchema.parse(query);
    const [data, total] = await Promise.all([AccountRepository.findMany(limit, offset), AccountRepository.count()]);
    return { data, pagination: { limit, offset, total } };
  }

  // GET /api/accounts/:id
  static async getById(params: unknown): Promise<SafeAccount> {
    const { id } = accountIdSchema.parse(params);
    const account = await AccountRepository.findById(id);
    if (!account) throw new NotFoundException(`No account found with the id "${id}". Please check the id and try again.`);
    return account;
  }

  // POST /api/accounts
  static async createAccount(body: unknown): Promise<SafeAccount> {
    const { password, ...input } = createAccountSchema.parse(body);

    // One account per provider for each user (e.g. only one email + password login)
    const alreadyExists = await AccountRepository.existsByUserAndProvider(input.userId, input.providerId);
    if (alreadyExists) {
      throw new UniqueException(
        `This user already has a "${input.providerId}" account. Update that account instead of creating a new one.`,
      );
    }

    return AccountRepository.createAccount({
      id: randomUUID(),
      ...input,
      password: password ? await hashPassword(password) : null,
    });
  }

  // PATCH /api/accounts/:id
  static async update(params: unknown, body: unknown): Promise<SafeAccount> {
    const { id } = accountIdSchema.parse(params);
    const { password, ...input } = updateAccountSchema.parse(body);

    return AccountRepository.update(id, {
      ...input,
      ...(password ? { password: await hashPassword(password) } : {}),
    });
  }

  // DELETE /api/accounts/:id
  // Hard delete: the user stays, only this login method is removed.
  static async delete(params: unknown): Promise<void> {
    const { id } = accountIdSchema.parse(params);
    await AccountRepository.delete(id);
  }
}

