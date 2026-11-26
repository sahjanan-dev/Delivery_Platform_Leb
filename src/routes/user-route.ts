import { UserService } from "@/services/user-service";
import { handleError, json } from "@/exceptions/handle-error";

// All HTTP handlers for users live here.
// Next.js finds them through the small files in src/app/api/users/ that re-export them.

type Ctx = { params: Promise<{ id: string }> };

export class UserRoute {
  // GET /api/users?limit=20&offset=0
  static async list(req: Request): Promise<Response> {
    try {
      const query = Object.fromEntries(new URL(req.url).searchParams);
      return json(await UserService.list(query));
    } catch (err) {
      return handleError(err);
    }
  }

  // POST /api/users
  static async create(req: Request): Promise<Response> {
    try {
      return json(await UserService.createUser(await req.json()), 201);
    } catch (err) {
      return handleError(err);
    }
  }

  // GET /api/users/:id
  static async getById(_req: Request, { params }: Ctx): Promise<Response> {
    try {
      return json(await UserService.getById(await params));
    } catch (err) {
      return handleError(err);
    }
  }

  // PATCH /api/users/:id
  static async update(req: Request, { params }: Ctx): Promise<Response> {
    try {
      return json(await UserService.update(await params, await req.json()));
    } catch (err) {
      return handleError(err);
    }
  }

  // DELETE /api/users/:id (soft delete)
  static async delete(_req: Request, { params }: Ctx): Promise<Response> {
    try {
      return json(await UserService.delete(await params));
    } catch (err) {
      return handleError(err);
    }
  }
}
