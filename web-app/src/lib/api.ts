/// <reference types="vite/client" />

export const WEB_SERVER_URL =
  import.meta.env.VITE_WEB_SERVER_URL ?? "http://localhost:3000";
export const API_VERSION_BASE = import.meta.env.VITE_API_URL ?? "api/v1";
