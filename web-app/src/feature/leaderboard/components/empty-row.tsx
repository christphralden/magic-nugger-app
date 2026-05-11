import { TableRow, TableCell } from "@/components/ui/table";
import { Typography } from "@/components/ui/typography";

interface EmptyRowProps {
  colSpan: number;
  message: string;
}

export function EmptyRow({ colSpan, message }: EmptyRowProps) {
  return (
    <TableRow>
      <TableCell colSpan={colSpan} className="py-12 text-center">
        <Typography variant="body" className="text-placeholder">
          {message}
        </Typography>
      </TableCell>
    </TableRow>
  );
}
