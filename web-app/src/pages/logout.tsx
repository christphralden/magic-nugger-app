import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { useDispatch } from "@/store/hooks";
import { handleLogout } from "@/feature/auth/actions/auth.actions";

export function LogoutPage() {
  const dispatch = useDispatch();
  const navigate = useNavigate();

  useEffect(() => {
    dispatch(handleLogout()).then(() => navigate("/", { replace: true }));
  }, [dispatch, navigate]);

  return null;
}
