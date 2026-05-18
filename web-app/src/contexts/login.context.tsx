import { createContext, useContext, useState, type ReactNode, type BaseSyntheticEvent } from "react";
import { useNavigate } from "react-router-dom";
import { useForm, type UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";
import { RequestLoginSchema } from "@magic-nugger-app/shared";
import { useDispatch, useSelector } from "@/store/hooks";
import { selectAuthStatus } from "@/feature/auth/state/auth.slice";
import { handleLogin } from "@/feature/auth/actions/auth.actions";
import { loginPlayer } from "@/feature/auth/state/auth.thunk";
import { toastError } from "@/lib/toast";

const loginFormSchema = RequestLoginSchema.extend({
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
  password: z.string().min(1, "Password is required"),
});

type LoginFormValues = z.infer<typeof loginFormSchema>;

interface LoginContextValue {
  form: UseFormReturn<LoginFormValues>;
  showPassword: boolean;
  rememberMe: boolean;
  loading: boolean;
  handleSubmit: (e?: BaseSyntheticEvent) => Promise<void>;
  handleTogglePassword: () => void;
  handleToggleRememberMe: () => void;
  handleNavigateRegister: () => void;
  handleForgotPassword: () => void;
}

const LoginContext = createContext<LoginContextValue | null>(null);

export function useLoginContext() {
  const ctx = useContext(LoginContext);
  if (!ctx)
    throw new Error("useLoginContext must be used within LoginProvider");
  return ctx;
}

export function LoginProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const status = useSelector(selectAuthStatus);
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginFormSchema),
    defaultValues: { email: "", password: "" },
  });

  const handleSubmit = form.handleSubmit(async (values) => {
    const result = await dispatch(handleLogin(values));
    if (!result) return;
    if (loginPlayer.fulfilled.match(result)) {
      navigate("/home");
    } else {
      toastError((result.payload as string) ?? "Invalid credentials");
    }
  });

  const handleTogglePassword = () => setShowPassword((s) => !s);
  const handleToggleRememberMe = () => setRememberMe((r) => !r);
  const handleNavigateRegister = () => navigate("/register");
  const handleForgotPassword = () => {};

  return (
    <LoginContext.Provider
      value={{
        form,
        showPassword,
        rememberMe,
        loading: status === "loading",
        handleSubmit,
        handleTogglePassword,
        handleToggleRememberMe,
        handleNavigateRegister,
        handleForgotPassword,
      }}
    >
      {children}
    </LoginContext.Provider>
  );
}
