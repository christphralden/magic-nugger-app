import {
  useDispatch as useReduxDispatch,
  useSelector as useReduxSelector,
} from "react-redux";
import type { RootState, AppDispatch } from "./index";

export const useDispatch = () => useReduxDispatch<AppDispatch>();
export const useSelector = useReduxSelector.withTypes<RootState>();
