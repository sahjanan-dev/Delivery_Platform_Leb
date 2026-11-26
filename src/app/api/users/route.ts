// Next.js needs this file to create the URL /api/users.
// The real code is in src/routes/user-route.ts
import { UserRoute } from "@/routes/user-route";

export const GET = UserRoute.list;
export const POST = UserRoute.create;
