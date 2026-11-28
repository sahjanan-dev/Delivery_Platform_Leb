import { AccountService } from "@/services/account-service";
import { handleError, json } from "@/exceptions/handle-error";

// All HTTP handlers for accounts live here.
// Next.js finds them through the small files in src/app/api/accounts/ that re-export them.

type params = { params: Promise<{ id: string }> };

export class AccountRoute {
  // GET /api/accounts?limit=20&offset=0
  static async list(req: Request): Promise<Response> {
    try {
      const query = Object.fromEntries(new URL(req.url).searchParams);
      return json(await AccountService.list(query));
    } catch (err) {
      return handleError(err);
    }
  }

  // POST /api/accounts
  static async create(req: Request): Promise<Response> {
    try {
      return json(await AccountService.createAccount(await req.json()), 201);
    } catch (err) {
      return handleError(err);
    }
  }

  // GET /api/accounts/:id
  static async getById(_req: Request, { params }: params): Promise<Response> {
    try {
      return json(await AccountService.getById(await params));
    } catch (err) {
      return handleError(err);
    }
  }

  // PATCH /api/accounts/:id
  static async update(req: Request, { params }: params): Promise<Response> {
    try {
      return json(await AccountService.update(await params, await req.json()));
    } catch (err) {
      return handleError(err);
    }
  }

  // DELETE /api/accounts/:id (204 = deleted, no body)
  static async delete(_req: Request, { params }: params): Promise<Response> {
    try {
      await AccountService.delete(await params);
      return new Response(null, { status: 204 });
    } catch (err) {
      return handleError(err);
    }
  }
}
