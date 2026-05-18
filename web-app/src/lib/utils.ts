import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function nameInitials(name: string): string {
  return name
    .split(" ", 2)
    .map((v) => v.at(0)?.toUpperCase())
    .join("");
}
