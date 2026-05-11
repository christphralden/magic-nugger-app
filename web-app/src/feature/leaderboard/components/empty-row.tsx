import { Typography } from "@/components/ui/typography";

interface EmptyRowProps {
  colSpan: number;
  message: string;
}

export function EmptyRow({ colSpan, message }: EmptyRowProps) {
  return (
    <tr>
      <td colSpan={colSpan} className="px-6 py-12 text-center">
        <Typography variant="body" className="text-placeholder">
          {message}
        </Typography>
      </td>
    </tr>
  );
}
