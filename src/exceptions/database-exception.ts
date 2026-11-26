import { AppException } from "./app-exception";

// 503 — the database could not be reached or the query failed unexpectedly
export class DatabaseException extends AppException {
  constructor(message = "The service is temporarily unavailable. Please try again in a few minutes.") {
    super(503, "DATABASE_ERROR", message);
  }
}
