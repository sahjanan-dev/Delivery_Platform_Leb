// Next.js needs this file to create the URL /api/accounts/:id
// The real code is in src/routes/account-route.ts
import { AccountRoute } from "@/routes/account-route";

export const GET = AccountRoute.getById;
export const PATCH = AccountRoute.update;
export const DELETE = AccountRoute.delete;
