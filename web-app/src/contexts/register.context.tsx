import {
  createContext,
  useContext,
  useState,
  type ReactNode,
  type FormEvent,
  type BaseSyntheticEvent,
} from "react";
import { useNavigate } from "react-router-dom";
import { useForm, type UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { type AvatarId } from "@/constants/avatars";
import { RequestCreatePlayerSchema } from "@magic-nugger-app/shared";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectAuthStatus } from "@/feature/auth/state/auth.slice";
import { handleRegister } from "@/feature/auth/actions/auth.actions";
import { registerPlayer } from "@/feature/auth/state/auth.thunk";
import { toastError } from "@/lib/toast";

const registerFormSchema = RequestCreatePlayerSchema.extend({
  username: z
    .string()
    .min(1, "Hero name is required")
    .min(3, "Must be at least 3 characters")
    .max(32, "Name is too long"),
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
  password: z
    .string()
    .min(1, "Password is required")
    .min(6, "Must be at least 6 characters")
    .max(128, "Password is too long"),
  age: z
    .string()
    .min(1, "Age is required")
    .regex(/^\d+$/, "Age must be a number")
    .refine((v) => Number(v) >= 1, "Invalid age"),
  grade: z.string().min(1, "Grade is required"),
  display_name: z.string().max(64).optional(),
});

type RegisterFormValues = z.infer<typeof registerFormSchema>;
type RegisterStep = 1 | 2;

interface RegisterContextValue {
  form: UseFormReturn<RegisterFormValues>;
  step: RegisterStep;
  selectedAvatar: AvatarId;
  showPassword: boolean;
  loading: boolean;
  handleInfoNext: (e?: BaseSyntheticEvent) => Promise<void>;
  handleAvatarSubmit: (e: FormEvent<HTMLFormElement>) => void;
  handleSelectAvatar: (id: AvatarId) => void;
  handleBack: () => void;
  handleTogglePassword: () => void;
  handleNavigateLogin: () => void;
}

const RegisterContext = createContext<RegisterContextValue | null>(null);

export function useRegisterContext() {
  const ctx = useContext(RegisterContext);
  if (!ctx)
    throw new Error("useRegisterContext must be used within RegisterProvider");
  return ctx;
}

export function RegisterProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const status = useSelector(selectAuthStatus);
  const [step, setStep] = useState<RegisterStep>(1);
  const [selectedAvatar, setSelectedAvatar] = useState<AvatarId>("fox");
  const [showPassword, setShowPassword] = useState(false);

  const form = useForm<RegisterFormValues>({
    resolver: zodResolver(registerFormSchema),
    defaultValues: {
      username: "",
      email: "",
      password: "",
      age: "",
      grade: "3",
    },
  });

  const handleInfoNext = form.handleSubmit((_values) => {
    setStep(2);
  });

  const handleAvatarSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    const values = form.getValues();
    const result = await dispatch(
      handleRegister({
        username: values.username,
        email: values.email,
        password: values.password,
        display_name: values.display_name,
        age: parseInt(values.age, 10),
        grade: parseInt(values.grade, 10),
      }),
    );
    if (!result) return;
    if (registerPlayer.fulfilled.match(result)) {
      navigate("/home");
    } else {
      toastError((result.payload as string) ?? "Registration failed");
      setStep(1);
    }
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
        loading: status === "loading",
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
