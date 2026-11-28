// Next.js needs this file to create the URL /api/accounts.
// The real code is in src/routes/account-route.ts
import { AccountRoute } from "@/routes/account-route";

export const GET = AccountRoute.list;
export const POST = AccountRoute.create;
