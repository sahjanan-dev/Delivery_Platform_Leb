import { AppException } from "./app-exception";

// 404 — the record does not exist
export class NotFoundException extends AppException {
  constructor(message = "Not found") {
    super(404, "NOT_FOUND", message);
  }
}
