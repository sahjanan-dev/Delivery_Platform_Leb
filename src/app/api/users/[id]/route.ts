// Next.js needs this file to create the URL /api/users/:id
// The real code is in src/routes/user-route.ts
import { UserRoute } from "@/routes/user-route";

export const GET = UserRoute.getById;
export const PATCH = UserRoute.update;
export const DELETE = UserRoute.delete;
