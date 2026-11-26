import { randomUUID } from "node:crypto";
import { UserRepository } from "@/repository/user-repository";
import { NotFoundException } from "@/exceptions/not-found-exception";
import { paginationSchema, type Paginated } from "@/types/common";
import { createUserSchema, updateUserSchema, userIdSchema, type SafeUser } from "@/types/user-types";

// Every method takes raw input (unknown) and validates it with Zod .parse().
// A ZodError becomes a 400 in handleError().
export class UserService {
  // GET /api/users?limit=20&offset=0
  static async list(query: unknown): Promise<Paginated<SafeUser>> {
    const { limit, offset } = paginationSchema.parse(query);
    const [data, total] = await Promise.all([UserRepository.findMany(limit, offset), UserRepository.count()]);
    return { data, pagination: { limit, offset, total } };
  }

  // GET /api/users/:id
  static async getById(params: unknown): Promise<SafeUser> {
    const { id } = userIdSchema.parse(params);
    const user = await UserRepository.findById(id);
    if (!user) throw new NotFoundException(`No user found with the id "${id}". Please check the id and try again.`);
    return user;
  }

  // POST /api/users
  static async createUser(body: unknown): Promise<SafeUser> {
    const input = createUserSchema.parse(body);
    return UserRepository.createUser({ id: randomUUID(), ...input });
  }

  // PATCH /api/users/:id
  static async update(params: unknown, body: unknown): Promise<SafeUser> {
    const { id } = userIdSchema.parse(params);
    const input = updateUserSchema.parse(body);
    return UserRepository.update(id, input);
  }

  // DELETE /api/users/:id
  // Soft delete: orders and events reference users, so we ban instead of removing the row.
  static async delete(params: unknown): Promise<SafeUser> {
    const { id } = userIdSchema.parse(params);
    return UserRepository.update(id, { banned: true });
  }
}
