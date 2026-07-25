/**
 * Generic error sanitizer for Admin panel.
 * Transforms technical or database tracebacks into clean, user-friendly messages.
 */
export function getGenericErrorMessage(error: any, fallbackMessage = "An unexpected error occurred. Please try again."): string {
  if (!error) return fallbackMessage;

  // Log detailed error to developer console for debugging
  console.error("[Admin API Error]:", error);

  const rawMessage = typeof error === "string" ? error : error.message || error.details || error.hint || "";
  const code = error.code || "";

  // Foreign key constraint violation (e.g., trying to delete a category or brand used by products)
  if (code === "23503" || rawMessage.includes("foreign key constraint") || rawMessage.includes("violates foreign key")) {
    return "Cannot delete or modify this record because it is referenced by existing items (e.g. products, orders, or specs).";
  }

  // Unique constraint violation (e.g., duplicate slug or email)
  if (code === "23505" || rawMessage.includes("duplicate key") || rawMessage.includes("already exists")) {
    return "A record with this unique identifier (or name) already exists in the system.";
  }

  // Permission / Row Level Security error
  if (code === "42501" || rawMessage.includes("permission denied") || rawMessage.includes("row-level security")) {
    return "You do not have administrator permissions to perform this operation.";
  }

  // Network or offline error
  if (rawMessage.includes("Failed to fetch") || rawMessage.includes("NetworkError")) {
    return "Network connection issue. Please check your internet connection and retry.";
  }

  // If the error message is already user-friendly short text, return it
  if (rawMessage && rawMessage.length < 100 && !rawMessage.includes("PGRST") && !rawMessage.includes("Postgrest")) {
    return rawMessage;
  }

  return fallbackMessage;
}
