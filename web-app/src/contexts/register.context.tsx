import {
  createContext,
  useContext,
  useState,
  type ReactNode,
  type FormEvent,
} from "react";
import { useNavigate } from "react-router-dom";
import { useForm, type UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { type AvatarId } from "@/constants/avatars";

const registerSchema = z.object({
  name: z.string().min(1, "Name is required"),
  age: z.string().regex(/^\d+$/, "Age must be a number"),
  grade: z.string().min(1, "Grade is required"),
  parentEmail: z.string().email("Enter a valid email"),
  password: z.string().min(6, "Password must be at least 6 characters"),
});

type RegisterFormValues = z.infer<typeof registerSchema>;
type RegisterStep = 1 | 2;

const LOADING_DURATION_MS = 2400;

interface RegisterContextValue {
  form: UseFormReturn<RegisterFormValues>;
  step: RegisterStep;
  selectedAvatar: AvatarId;
  showPassword: boolean;
  loading: boolean;
  handleInfoNext: (values: RegisterFormValues) => void;
  handleAvatarSubmit: (e: FormEvent<HTMLFormElement>) => void;
  handleSelectAvatar: (id: AvatarId) => void;
  handleBack: () => void;
  handleTogglePassword: () => void;
  handleNavigateLogin: () => void;
}

const RegisterContext = createContext<RegisterContextValue | null>(null);

export function useRegisterContext() {
  const ctx = useContext(RegisterContext);
  if (!ctx) throw new Error("useRegisterContext must be used within RegisterProvider");
  return ctx;
}

export function RegisterProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const [step, setStep] = useState<RegisterStep>(1);
  const [selectedAvatar, setSelectedAvatar] = useState<AvatarId>("fox");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);

  const form = useForm<RegisterFormValues>({
    resolver: zodResolver(registerSchema),
    defaultValues: { name: "", age: "", grade: "3rd grade", parentEmail: "", password: "" },
  });

  const handleInfoNext = (_values: RegisterFormValues) => {
    setStep(2);
  };

  const handleAvatarSubmit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      navigate("/levels");
    }, LOADING_DURATION_MS);
  };

  const handleSelectAvatar = (id: AvatarId) => setSelectedAvatar(id);
  const handleBack = () => setStep(1);
  const handleTogglePassword = () => setShowPassword((s) => !s);
  const handleNavigateLogin = () => navigate("/login");

  return (
    <RegisterContext.Provider
      value={{
        form,
        step,
        selectedAvatar,
        showPassword,
        loading,
        handleInfoNext,
        handleAvatarSubmit,
        handleSelectAvatar,
        handleBack,
        handleTogglePassword,
        handleNavigateLogin,
      }}
    >
      {children}
    </RegisterContext.Provider>
  );
}
