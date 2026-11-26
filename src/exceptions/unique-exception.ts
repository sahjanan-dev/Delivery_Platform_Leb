import { AppException } from "./app-exception";

// 409 — a unique constraint failed (e.g. email is not unique)
export class UniqueException extends AppException {
  constructor(message = "Unique constraint failed") {
    super(409, "UNIQUE_CONSTRAINT", message);
  }
}
