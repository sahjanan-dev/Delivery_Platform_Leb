// Base class for every error the API throws on purpose.
// handleError() turns it into { error: { code, message } } with the right HTTP status.
export class AppException extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = new.target.name;
  }
}
