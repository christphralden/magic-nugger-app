import { createContext, useContext, useState, type ReactNode } from "react";
import { useNavigate } from "react-router-dom";
import { useForm, type UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { z } from "zod";

const loginSchema = z.object({
  username: z.string().min(1, "Username is required"),
  password: z.string().min(1, "Password is required"),
});

type LoginFormValues = z.infer<typeof loginSchema>;

const LOADING_DURATION_MS = 2200;

interface LoginContextValue {
  form: UseFormReturn<LoginFormValues>;
  showPassword: boolean;
  rememberMe: boolean;
  loading: boolean;
  handleSubmit: (values: LoginFormValues) => void;
  handleTogglePassword: () => void;
  handleToggleRememberMe: () => void;
  handleNavigateRegister: () => void;
  handleForgotPassword: () => void;
}

const LoginContext = createContext<LoginContextValue | null>(null);

export function useLoginContext() {
  const ctx = useContext(LoginContext);
  if (!ctx) throw new Error("useLoginContext must be used within LoginProvider");
  return ctx;
}

export function LoginProvider({ children }: { children: ReactNode }) {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [loading, setLoading] = useState(false);

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { username: "", password: "" },
  });

  const handleSubmit = (_values: LoginFormValues) => {
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      navigate("/levels");
    }, LOADING_DURATION_MS);
  };

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
        loading,
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
