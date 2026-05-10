import { toast } from "sonner";
import { Alert } from "@/components/ui/alert";

export const toastError = (message: string) => {
  toast.custom(() => <Alert variant="error" title={message} />);
};

export const toastSuccess = (message: string) => {
  toast.custom(() => <Alert variant="success" title={message} />);
};

export const toastInfo = (message: string) => {
  toast.custom(() => <Alert variant="info" title={message} />);
};
