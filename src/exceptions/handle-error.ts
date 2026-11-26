import { ZodError } from "zod";
import { AppException } from "./app-exception";

// Response.json() cannot serialize BigInt, so BigInt columns are sent as strings.
export function json(data: unknown, status = 200): Response {
  const body = JSON.stringify(data, (_key, value) => (typeof value === "bigint" ? value.toString() : value));
  return new Response(body, { status, headers: { "Content-Type": "application/json" } });
}

// One shared error -> response mapper: { error: { code, message } }
export function handleError(err: unknown): Response {
  if (err instanceof AppException) {
    return json({ error: { code: err.code, message: err.message } }, err.status);
  }

  if (err instanceof ZodError) {
    const details = err.issues.map((i) => ({ path: i.path.join("."), message: i.message }));
    return json({ error: { code: "VALIDATION", message: "Invalid input", details } }, 400);
  }

  if (err instanceof SyntaxError) {
    return json({ error: { code: "BAD_JSON", message: "Body must be valid JSON" } }, 400);
  }

  console.error(err);
  return json({ error: { code: "INTERNAL", message: "Something went wrong" } }, 500);
}
